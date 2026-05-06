#!/usr/bin/env ruby
# frozen_string_literal: true

require "bigdecimal"
require "json"

module StdlibExecutionKernelStage1
  DecimalValue = Struct.new(:decimal, :scale, keyword_init: true) do
    def self.parse(value, scale:)
      new(decimal: BigDecimal(value), scale: scale)
    end

    def +(other)
      raise ArgumentError, "Decimal scale mismatch" unless scale == other.scale

      self.class.new(decimal: decimal + other.decimal, scale: scale)
    end

    def as_json
      format("%.#{scale}f", decimal)
    end
  end

  class StdlibKernel
    PRE_RESOLUTION_OPERATORS = ["stdlib.numeric.add"].freeze

    def call(operator, args)
      reject_pre_resolution_operator!(operator)

      case operator
      when "stdlib.integer.add"
        require_all!(operator, args, Integer)
        args.reduce(0, :+)
      when "stdlib.float.add"
        require_all!(operator, args, Float)
        args.reduce(0.0, :+)
      when "stdlib.decimal.add"
        require_all!(operator, args, DecimalValue)
        args.reduce { |acc, value| acc + value }
      when "fold"
        collection, initial, reducer = args
        Array(collection).reduce(initial) { |acc, item| call(reducer, [acc, item]) }
      when "map"
        collection, spec = args
        Array(collection).map { |item| call(spec.fetch("operator"), [item, spec.fetch("arg")]) }
      when "filter"
        collection, spec = args
        Array(collection).select { |item| matches_filter?(item, spec) }
      when "count"
        Array(args.fetch(0)).length
      when "or_else"
        value, fallback = args
        value.nil? ? fallback : value
      else
        raise ArgumentError, "Unknown stdlib operator: #{operator}"
      end
    end

    private

    def reject_pre_resolution_operator!(operator)
      return unless PRE_RESOLUTION_OPERATORS.include?(operator)

      raise ArgumentError, "#{operator} is pre-resolution only; runtime requires a monomorphic stdlib operator"
    end

    def require_all!(operator, args, klass)
      return if args.all? { |arg| arg.is_a?(klass) }

      raise TypeError, "#{operator} expected #{klass}"
    end

    def matches_filter?(item, spec)
      case spec.fetch("predicate")
      when "truthy"
        !!item
      when "field_equals"
        item.fetch(spec.fetch("field")) == spec.fetch("value")
      else
        raise ArgumentError, "Unknown filter predicate: #{spec.fetch("predicate")}"
      end
    end
  end

  class RuntimeMachineProbe
    def initialize(stdlib:)
      @stdlib = stdlib
    end

    def evaluate_contract(contract, inputs)
      values = {}
      contract.fetch("input_ports").each do |port|
        name = port.fetch("name")
        values[name] = inputs.fetch(name)
      end

      contract.fetch("compute_nodes").each do |node|
        values[node.fetch("name")] = eval_expr(node.fetch("expression"), values)
      end

      contract.fetch("output_ports").to_h do |port|
        name = port.fetch("name")
        [name, render_value(values.fetch(name))]
      end
    end

    private

    def eval_expr(expr, values)
      case expr.fetch("kind")
      when "apply"
        args = expr.fetch("operands").map { |operand| eval_expr(operand, values) }
        @stdlib.call(expr.fetch("operator"), args)
      when "ref"
        values.fetch(expr.fetch("name"))
      when "literal"
        expr.fetch("value")
      else
        raise ArgumentError, "Unknown expression kind: #{expr.fetch("kind")}"
      end
    end

    def render_value(value)
      value.is_a?(DecimalValue) ? value.as_json : value
    end
  end

  module Proof
    module_function

    def run
      kernel = StdlibKernel.new
      runtime = RuntimeMachineProbe.new(stdlib: kernel)
      results = {}

      results["kernel.integer_add"] = assert_equal(5, kernel.call("stdlib.integer.add", [2, 3]))
      results["kernel.float_add"] = assert_equal(4.0, kernel.call("stdlib.float.add", [1.5, 2.5]))
      results["kernel.decimal_add_exact"] = assert_equal(
        "13.00",
        kernel.call(
          "stdlib.decimal.add",
          [DecimalValue.parse("12.34", scale: 2), DecimalValue.parse("0.66", scale: 2)]
        ).as_json
      )
      results["kernel.fold"] = assert_equal(10, kernel.call("fold", [[1, 2, 3, 4], 0, "stdlib.integer.add"]))
      results["kernel.map"] = assert_equal(
        [2, 3, 4],
        kernel.call("map", [[1, 2, 3], { "operator" => "stdlib.integer.add", "arg" => 1 }])
      )
      results["kernel.filter"] = assert_equal(
        [{ "id" => "tech-1", "active" => true }],
        kernel.call(
          "filter",
          [
            [{ "id" => "tech-1", "active" => true }, { "id" => "tech-2", "active" => false }],
            { "predicate" => "field_equals", "field" => "active", "value" => true }
          ]
        )
      )
      results["kernel.count"] = assert_equal(3, kernel.call("count", [["a", "b", "c"]]))
      results["kernel.or_else_some"] = assert_equal("kept", kernel.call("or_else", ["kept", "fallback"]))
      results["kernel.or_else_none"] = assert_equal("fallback", kernel.call("or_else", [nil, "fallback"]))
      results["kernel.numeric_add_rejected"] = assert_raises(ArgumentError) do
        kernel.call("stdlib.numeric.add", [1, 2])
      end
      results["runtime.add_igapp_style_integer_add"] = assert_equal(
        { "sum" => 42 },
        runtime.evaluate_contract(add_contract("stdlib.integer.add"), { "a" => 19, "b" => 23 })
      )
      results["runtime.add_igapp_style_rejects_numeric_add"] = assert_raises(ArgumentError) do
        runtime.evaluate_contract(add_contract("stdlib.numeric.add"), { "a" => 1, "b" => 2 })
      end

      emit(results)
      results.values.all?
    end

    def add_contract(operator)
      {
        "contract_id" => "add",
        "input_ports" => [
          { "name" => "a", "type_tag" => "Integer", "lifecycle" => "local" },
          { "name" => "b", "type_tag" => "Integer", "lifecycle" => "local" }
        ],
        "compute_nodes" => [
          {
            "name" => "sum",
            "expression" => {
              "kind" => "apply",
              "operator" => operator,
              "operands" => [
                { "kind" => "ref", "name" => "a" },
                { "kind" => "ref", "name" => "b" }
              ]
            }
          }
        ],
        "output_ports" => [
          { "name" => "sum", "type_tag" => "Integer", "lifecycle" => "session" }
        ]
      }
    end

    def assert_equal(expected, actual)
      expected == actual
    end

    def assert_raises(error_class)
      yield
      false
    rescue error_class
      true
    end

    def emit(results)
      results.each do |name, ok|
        puts "#{name}: #{ok ? "ok" : "FAIL"}"
      end

      summary = {
        "proof" => "stdlib-execution-kernel-stage1-v0",
        "status" => results.values.all? ? "PASS" : "FAIL",
        "runtime_operator_boundary" => {
          "pre_resolution" => ["stdlib.numeric.add"],
          "executable" => ["stdlib.integer.add", "stdlib.float.add", "stdlib.decimal.add"]
        },
        "stage2_deferred" => ["History[T]", "stream T", "OLAPPoint[T, Dims]"]
      }

      puts JSON.pretty_generate(summary)
    end
  end
end

success = StdlibExecutionKernelStage1::Proof.run
exit(success ? 0 : 1)
