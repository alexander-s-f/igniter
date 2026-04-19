# frozen_string_literal: true

module Igniter
  module AI
    module Agents
    # Executes a sequence of callables where each step's output becomes the
    # next step's input.
    #
    # Each step callable receives:
    #   input:   [Object]         — output from the previous step (or initial input)
    #   context: [Hash]           — shared context unchanged throughout the run
    #   results: [Array<StepResult>]  — results from all preceding steps
    #
    # On error the chain stops immediately by default. Pass +stop_on_error: false+
    # to continue with the error message as the next step's input.
    #
    # @example Summarise → translate → format
    #   ref = ChainAgent.start
    #   ref.send(:set_chain, steps: [
    #     { name: :summarise,  callable: ->(input:, **) { SummariseSkill.call(text: input) } },
    #     { name: :translate,  callable: ->(input:, **) { TranslateSkill.call(text: input) } },
    #     { name: :format,     callable: ->(input:, **) { FormatSkill.call(content: input)  } }
    #   ])
    #   ref.send(:run, input: long_article, context: { target_lang: "es" })
    #   steps = ref.call(:results)
      class ChainAgent < Igniter::Agent
      # Immutable record for one completed step.
      StepResult = Struct.new(:name, :input, :output, :status, keyword_init: true)

      initial_state chain: [], results: [], context: {}

      # Append a step to the end of the chain.
      #
      # Payload keys:
      #   name     [String, Symbol]  — step identifier
      #   callable [#call]           — receives (input:, context:, results:)
      on :add_step do |state:, payload:|
        step = { name: payload.fetch(:name).to_s, callable: payload.fetch(:callable) }
        state.merge(chain: state[:chain] + [step])
      end

      # Replace the entire chain.
      #
      # Payload keys:
      #   steps [Array<Hash>]  — each element must have :name and :callable keys
      on :set_chain do |state:, payload:|
        steps = Array(payload.fetch(:steps)).map do |s|
          { name: s.fetch(:name).to_s, callable: s.fetch(:callable) }
        end
        state.merge(chain: steps)
      end

      # Remove a step by name.
      #
      # Payload keys:
      #   name [String, Symbol]
      on :remove_step do |state:, payload:|
        name = payload.fetch(:name).to_s
        state.merge(chain: state[:chain].reject { |s| s[:name] == name })
      end

      # Execute the chain with an initial input.
      #
      # Payload keys:
      #   input         [Object]   — starting value for the first step
      #   context       [Hash]     — shared context passed to every step (default: {})
      #   stop_on_error [Boolean]  — halt on first error (default: true)
      on :run do |state:, payload:|
        agent = new
        agent.send(:run_chain, state, payload)
      end

      # Sync query — step results from the most recent run.
      #
      # @return [Array<StepResult>]
      on :results do |state:, **|
        state[:results]
      end

      # Sync query — list registered step names.
      #
      # @return [Array<String>]
      on :steps do |state:, **|
        state[:chain].map { |s| s[:name] }
      end

      # Clear results and context from the last run (chain is preserved).
      on :reset do |state:, **|
        state.merge(results: [], context: {})
      end

      private

      def run_chain(state, payload)
        input         = payload.fetch(:input)
        context       = payload.fetch(:context, state[:context])
        stop_on_error = payload.fetch(:stop_on_error, true)
        results       = []
        current       = input

        state[:chain].each do |step|
          output, status = invoke_step(step[:callable], current, context, results)

          results << StepResult.new(
            name:   step[:name],
            input:  current,
            output: output,
            status: status
          )

          break if status == :error && stop_on_error

          current = output
        end

        state.merge(results: results, context: context)
      end

      # @return [[output, status]]
      def invoke_step(callable, input, context, results)
        output = callable.call(input: input, context: context, results: results)
        [output, :ok]
      rescue StandardError => e
        [e.message, :error]
      end
      end
    end
  end
end
