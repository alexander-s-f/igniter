# frozen_string_literal: true

module Igniter
  module Compiler
    module Validators
      class CallableValidator
        def self.call(context)
          new(context).call
        end

        def initialize(context)
          @context = context
        end

        def call
          @context.runtime_nodes.each do |node|
            if node.kind == :compute
              validate_callable_signature!(node)
            elsif node.kind == :effect
              validate_effect_adapter!(node)
            end
          end
        end

        private

        def validate_effect_adapter!(node)
          adapter = node.adapter_class
          unless adapter.is_a?(Class) && adapter <= Igniter::Effect
            raise @context.validation_error(
              node,
              "Effect '#{node.name}' adapter must be a subclass of Igniter::Effect"
            )
          end

          validate_parameters_signature!(
            node,
            adapter.instance_method(:call).parameters,
            adapter.name || "effect"
          )
        end

        def validate_callable_signature!(node)
          callable = node.callable

          case callable
          when Proc
            validate_parameters_signature!(node, callable.parameters, "proc")
          when Class
            validate_class_callable_signature!(node, callable)
          when Symbol, String
            nil
          else
            validate_object_callable_signature!(node, callable)
          end
        end

        def validate_class_callable_signature!(node, callable)
          if callable <= Igniter::Executor
            validate_executor_inputs!(node, callable)
            validate_parameters_signature!(node, callable.instance_method(:call).parameters, callable.name || "executor")
          elsif callable.respond_to?(:call)
            validate_parameters_signature!(node, callable.method(:call).parameters, callable.name || "callable class")
          else
            raise @context.validation_error(node, "Compute '#{node.name}' class callable must respond to `.call`")
          end
        end

        def validate_object_callable_signature!(node, callable)
          unless callable.respond_to?(:call)
            raise @context.validation_error(node, "Compute '#{node.name}' callable object must respond to `call`")
          end

          validate_parameters_signature!(node, callable.method(:call).parameters, callable.class.name || "callable object")
        end

        def validate_executor_inputs!(node, executor_class)
          declared_inputs = executor_class.executor_inputs
          required_inputs = declared_inputs.select { |_name, config| config[:required] }.keys
          missing_dependencies = required_inputs - node.dependencies

          return if missing_dependencies.empty?

          raise @context.validation_error(
            node,
            "Compute '#{node.name}' executor requires undeclared dependencies: #{missing_dependencies.sort.join(', ')}"
          )
        end

        def validate_parameters_signature!(node, parameters, callable_label)
          positional_kinds = %i[req opt rest]
          positional = parameters.select { |kind, _name| positional_kinds.include?(kind) }
          unless positional.empty?
            raise @context.validation_error(
              node,
              "Compute '#{node.name}' #{callable_label} must use keyword arguments for dependencies, got positional parameters"
            )
          end

          accepts_any_keywords = parameters.any? { |kind, _name| kind == :keyrest }
          accepted_keywords = parameters.select { |kind, _name| %i[key keyreq].include?(kind) }.map(&:last)
          required_keywords = parameters.select { |kind, _name| kind == :keyreq }.map(&:last)

          missing_dependencies = required_keywords - node.dependencies
          unless missing_dependencies.empty?
            raise @context.validation_error(
              node,
              "Compute '#{node.name}' #{callable_label} requires undeclared dependencies: #{missing_dependencies.sort.join(', ')}"
            )
          end

          return if accepts_any_keywords

          unknown_dependencies = node.dependencies - accepted_keywords
          return if unknown_dependencies.empty?

          raise @context.validation_error(
            node,
            "Compute '#{node.name}' declares unsupported dependencies for its #{callable_label}: #{unknown_dependencies.sort.join(', ')}"
          )
        end
      end
    end
  end
end
