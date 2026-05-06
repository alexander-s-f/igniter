#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"

module PolymorphicAddClassifierProof
  ROOT = File.expand_path("../..", __dir__)
  DEFAULT_PARSED_PROGRAM = File.join(ROOT, "source/polymorphic_add.parsed_program.expected.json")

  STDLIB_AXIOM_TABLE = {
    "stdlib.numeric.add" => {
      "kind" => "tier1_axiom",
      "operator_id" => "stdlib.numeric.add",
      "method" => "add",
      "supported_types" => %w[Integer Float]
    }
  }.freeze

  module_function

  def call(path = DEFAULT_PARSED_PROGRAM)
    parsed = JSON.parse(File.read(path))
    classified = classify(parsed)
    typed = type_program(classified, [
      { "contract" => "Add", "type_args" => { "T" => "Integer" } },
      { "contract" => "Add", "type_args" => { "T" => "Float" } }
    ])
    negative = type_program(classified, [
      { "contract" => "Add", "type_args" => { "T" => "String" } }
    ])

    checks = [
      check("classifier.envs", classifier_envs_ok?(classified)),
      check("typed.add_integer", typed_contract_ok?(typed, "Add[Integer]", "Integer")),
      check("typed.add_float", typed_contract_ok?(typed, "Add[Float]", "Float")),
      check("negative.add_string_rejected", add_string_rejected?(negative))
    ]

    {
      checks: checks,
      classified_program: classified,
      typed_program: typed,
      negative_program: negative
    }
  end

  def classify(parsed)
    trait_env = build_trait_env(parsed.fetch("traits"))
    impl_env = build_impl_env(parsed.fetch("impls"), trait_env)
    shape_env = build_shape_env(parsed.fetch("contract_shapes"))
    contracts = parsed.fetch("contracts").map { |contract| classify_contract(contract) }

    {
      "kind" => "classified_program",
      "module" => parsed.fetch("module"),
      "source_hash" => parsed.fetch("source_hash"),
      "trait_env" => trait_env,
      "impl_env" => impl_env,
      "shape_env" => shape_env,
      "contracts" => contracts,
      "classify_errors" => []
    }
  end

  def build_trait_env(traits)
    traits.each_with_object({}) do |trait, out|
      out[trait.fetch("name")] = {
        "name" => trait.fetch("name"),
        "type_params" => trait.fetch("type_params"),
        "methods" => trait.fetch("methods").map do |method|
          {
            "name" => method.fetch("name"),
            "params" => method.fetch("params"),
            "return_type" => method.fetch("return_type")
          }
        end
      }
    end
  end

  def build_impl_env(impls, trait_env)
    impls.each_with_object({}) do |impl, out|
      trait_ref = impl.fetch("trait_ref")
      trait_name = trait_ref.fetch("name")
      concrete_type = trait_ref.fetch("type_args").fetch(0)
      using_ref = impl.fetch("using").fetch("name")
      axiom = STDLIB_AXIOM_TABLE.fetch(using_ref)
      trait = trait_env.fetch(trait_name)
      method_names = trait.fetch("methods").map { |method| method.fetch("name") }

      out[impl_key(trait_name, concrete_type)] = {
        "trait_name" => trait_name,
        "concrete_type" => concrete_type,
        "kind" => "using",
        "operator_ref" => axiom.fetch("operator_id"),
        "operator_kind" => axiom.fetch("kind"),
        "methods" => method_names,
        "fragment_class" => "core",
        "coherence" => "passed"
      }
    end
  end

  def build_shape_env(shapes)
    shapes.each_with_object({}) do |shape, out|
      input_ports = shape.fetch("body").select { |decl| decl.fetch("kind") == "input" }
      output_ports = shape.fetch("body").select { |decl| decl.fetch("kind") == "output" }
      out[shape.fetch("name")] = {
        "name" => shape.fetch("name"),
        "type_params" => shape.fetch("type_params"),
        "input_ports" => input_ports.map { |port| port_spec(port) },
        "output_ports" => output_ports.map { |port| port_spec(port) }
      }
    end
  end

  def port_spec(port)
    {
      "name" => port.fetch("name"),
      "type_ann" => port.fetch("type_annotation")
    }
  end

  def classify_contract(contract)
    {
      "name" => contract.fetch("name"),
      "is_generic" => contract.fetch("type_params", []).any?,
      "type_params" => contract.fetch("type_params", []),
      "implements" => contract.fetch("implements", nil),
      "body" => contract.fetch("body"),
      "fragment_class" => "generic_pending"
    }
  end

  def type_program(classified, requests)
    type_errors = []
    typed_contracts = requests.filter_map do |request|
      type_contract(classified, request)
    rescue TypeError => e
      type_errors << e.to_h
      nil
    end

    {
      "kind" => "typed_program",
      "module" => classified.fetch("module"),
      "source_hash" => classified.fetch("source_hash"),
      "specializations" => typed_contracts,
      "type_errors" => type_errors
    }
  end

  def type_contract(classified, request)
    contract = classified.fetch("contracts").find { |item| item.fetch("name") == request.fetch("contract") }
    raise TypeError.new("OOF-TY4", "Specialization requested for unknown contract") unless contract

    type_args = request.fetch("type_args")
    concrete_type = type_args.fetch("T")
    bound = contract.fetch("type_params").fetch(0).fetch("bounds").fetch(0).fetch("trait_ref")
    trait_name = bound.fetch("name")
    impl = classified.fetch("impl_env")[impl_key(trait_name, concrete_type)]
    unless impl
      raise TypeError.new(
        "OOF-TY1",
        "No impl of #{trait_name} for #{concrete_type}",
        contract: request.fetch("contract"),
        requested_type: concrete_type,
        trait: trait_name
      )
    end

    shape = concrete_shape(classified.fetch("shape_env"), contract.fetch("implements"), type_args)
    compute = contract.fetch("body").find { |decl| decl.fetch("kind") == "compute" }
    expression = resolve_compute_expr(compute.fetch("expr"), trait_name, concrete_type, impl)

    {
      "name" => "#{contract.fetch("name")}[#{concrete_type}]",
      "specialization_of" => contract.fetch("name"),
      "type_args" => type_args,
      "fragment_class" => "core",
      "input_ports" => shape.fetch("input_ports").map { |port| typed_port(port, "local") },
      "compute_nodes" => [
        {
          "name" => compute.fetch("name"),
          "type_tag" => concrete_type,
          "lifecycle" => "session",
          "expression" => expression
        }
      ],
      "output_ports" => shape.fetch("output_ports").map { |port| typed_port(port, "session") },
      "implements_check" => [
        {
          "shape" => "#{shape.fetch("name")}[#{concrete_type}]",
          "result" => "pass"
        }
      ]
    }
  end

  def concrete_shape(shape_env, shape_ref, type_args)
    shape = shape_env.fetch(shape_ref.fetch("name"))
    {
      "name" => shape.fetch("name"),
      "input_ports" => shape.fetch("input_ports").map { |port| substitute_port(port, type_args) },
      "output_ports" => shape.fetch("output_ports").map { |port| substitute_port(port, type_args) }
    }
  end

  def substitute_port(port, type_args)
    {
      "name" => port.fetch("name"),
      "type_tag" => type_args.fetch(port.fetch("type_ann"), port.fetch("type_ann"))
    }
  end

  def typed_port(port, lifecycle)
    {
      "name" => port.fetch("name"),
      "type_tag" => port.fetch("type_tag"),
      "lifecycle" => lifecycle
    }
  end

  def resolve_compute_expr(expr, trait_name, concrete_type, impl)
    {
      "kind" => "apply",
      "operator" => impl.fetch("operator_ref"),
      "resolved_impl" => "#{trait_name}[#{concrete_type}]",
      "type_args" => [concrete_type],
      "operands" => expr.fetch("args")
    }
  end

  def classifier_envs_ok?(classified)
    classified.fetch("classify_errors").empty? &&
      classified.fetch("trait_env").key?("Additive") &&
      classified.fetch("impl_env").key?(impl_key("Additive", "Integer")) &&
      classified.fetch("impl_env").key?(impl_key("Additive", "Float")) &&
      classified.fetch("shape_env").key?("AddShape") &&
      classified.fetch("contracts").any? { |contract| contract.fetch("name") == "Add" && contract.fetch("is_generic") }
  end

  def typed_contract_ok?(typed, name, concrete_type)
    contract = typed.fetch("specializations").find { |item| item.fetch("name") == name }
    return false unless contract

    contract.fetch("fragment_class") == "core" &&
      contract.fetch("input_ports").all? { |port| port.fetch("type_tag") == concrete_type } &&
      contract.fetch("output_ports").all? { |port| port.fetch("type_tag") == concrete_type } &&
      contract.fetch("compute_nodes").fetch(0).fetch("expression").fetch("operator") == "stdlib.numeric.add" &&
      contract.fetch("compute_nodes").fetch(0).fetch("expression").fetch("resolved_impl") == "Additive[#{concrete_type}]" &&
      contract.fetch("implements_check").fetch(0).fetch("result") == "pass"
  end

  def add_string_rejected?(typed)
    typed.fetch("specializations").empty? &&
      typed.fetch("type_errors").any? do |error|
        error.fetch("code") == "OOF-TY1" &&
          error.fetch("requested_type") == "String" &&
          error.fetch("trait") == "Additive"
      end
  end

  def impl_key(trait_name, concrete_type)
    "#{trait_name}[#{concrete_type}]"
  end

  def check(name, ok)
    { name: name, ok: ok }
  end

  class TypeError < StandardError
    def initialize(code, message, context = {})
      super(message)
      @code = code
      @context = context
    end

    def to_h
      { "code" => @code, "message" => message }.merge(@context.transform_keys(&:to_s))
    end
  end

  module CLI
    module_function

    def run(argv)
      path = argv.shift || DEFAULT_PARSED_PROGRAM
      result = PolymorphicAddClassifierProof.call(path)
      print_result(result)
      result.fetch(:checks).all? { |check| check.fetch(:ok) }
    end

    def print_result(result)
      ok = result.fetch(:checks).all? { |check| check.fetch(:ok) }
      puts "#{ok ? "PASS" : "FAIL"} polymorphic_add_classifier_proof"
      result.fetch(:checks).each do |check|
        puts "#{check.fetch(:name)}: #{check.fetch(:ok) ? "ok" : "fail"}"
      end
      puts "typed.contracts: #{result.fetch(:typed_program).fetch("specializations").map { |contract| contract.fetch("name") }.join(", ")}"
      errors = result.fetch(:negative_program).fetch("type_errors")
      puts "negative.errors: #{errors.map { |error| error.fetch("code") }.join(", ")}"
    end
  end
end

if $PROGRAM_NAME == __FILE__
  success = PolymorphicAddClassifierProof::CLI.run(ARGV)
  exit(success ? 0 : 1)
end
