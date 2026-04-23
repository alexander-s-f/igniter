# frozen_string_literal: true

module Igniter
  module AI
    module Agents
    # Mission: become better.
    #
    # An evolutionary self-improvement agent that maintains a population of
    # strategies (prompt variants, parameter configs, tool selections — any
    # Hash), evaluates their fitness, selects survivors, generates mutations,
    # and tracks lineage across generations.
    #
    # The agent is intentionally domain-agnostic. Strategies are plain Hashes
    # whose semantics are defined by the caller's +fitness_fn+.
    #
    # Life-cycle of one generation:
    #   seed → evaluate_population → evolve   (or: seed → run_generation × N)
    #
    # Mutation:
    # * **Rule-based** (default) — numeric values are scaled ±20 %, booleans
    #   are flipped, arrays are sub-sampled. Strings are kept unchanged.
    # * **LLM-assisted** — delegates to any callable that accepts
    #   +strategy:+ and +generation:+ and returns a Hash.
    #
    # @example Evolve a prompt configuration
    #   fitness = ->(config) { MyEvaluator.score(config) }
    #   ref = EvolutionAgent.start(initial_state: {
    #     fitness_fn: fitness,
    #     population_size: 4
    #   })
    #   ref.send(:seed, strategies: [
    #     { temperature: 0.7, max_tokens: 512 },
    #     { temperature: 0.3, max_tokens: 256 }
    #   ])
    #   3.times { ref.send(:run_generation) }
    #   best = ref.call(:best)   # => Strategy struct
      class EvolutionAgent < Igniter::Agent
      # An individual strategy in the population.
      Strategy = Struct.new(:id, :config, :fitness, :generation,
                            :parent_ids, :mutations, keyword_init: true)

      # Summary record for one completed generation.
      GenerationReport = Struct.new(:generation, :population_size, :best_fitness,
                                    :mean_fitness, :best_id, keyword_init: true)

      initial_state \
        population:       [],
        generation:       0,
        history:          [],
        best_strategy:    nil,
        fitness_fn:       nil,
        llm:              nil,
        population_size:  6,
        mutation_rate:    0.3,
        elite_fraction:   0.5

      # Seed the population with an initial set of strategy configs.
      # Resets generation counter and history.
      #
      # Payload keys:
      #   strategies [Array<Hash>]  — initial strategy configs
      on :seed do |state:, payload:|
        pop = Array(payload.fetch(:strategies)).each_with_index.map do |cfg, i|
          Strategy.new(
            id:         "gen0_#{i}",
            config:     cfg,
            fitness:    nil,
            generation: 0,
            parent_ids: [],
            mutations:  []
          )
        end
        state.merge(population: pop, generation: 0, history: [], best_strategy: nil)
      end

      # Score every strategy in the population using the fitness function.
      # Strategies that raise are assigned fitness 0.0.
      #
      # Payload keys:
      #   fitness_fn [#call, nil]  — override the state fitness function
      on :evaluate_population do |state:, payload:|
        fitness_fn = (payload && payload[:fitness_fn]) || state[:fitness_fn]
        next state unless fitness_fn

        agent     = new
        evaluated = agent.send(:score_population, state[:population], fitness_fn)
        best      = evaluated.max_by { |s| s.fitness || -Float::INFINITY }
        state.merge(population: evaluated, best_strategy: best)
      end

      # Select elite survivors, generate children by mutation, increment generation.
      # Requires the population to be already evaluated (see +:evaluate_population+).
      on :evolve do |state:, payload:|
        agent          = new
        new_pop, report = agent.send(:run_evolution, state)
        next state unless new_pop

        best = new_pop.max_by { |s| s.fitness || -Float::INFINITY }
        state.merge(
          population:    new_pop,
          generation:    state[:generation] + 1,
          history:       state[:history] + [report],
          best_strategy: best
        )
      end

      # Convenience: evaluate the current population then evolve — one full cycle.
      #
      # Payload keys:
      #   fitness_fn [#call, nil]  — override the state fitness function
      on :run_generation do |state:, payload:|
        fitness_fn = (payload && payload[:fitness_fn]) || state[:fitness_fn]
        next state unless fitness_fn

        agent = new

        # evaluate
        evaluated_pop = agent.send(:score_population, state[:population], fitness_fn)
        with_scores   = state.merge(population: evaluated_pop)

        # evolve
        new_pop, report = agent.send(:run_evolution, with_scores)
        next with_scores unless new_pop

        best = new_pop.max_by { |s| s.fitness || -Float::INFINITY }
        with_scores.merge(
          population:    new_pop,
          generation:    state[:generation] + 1,
          history:       state[:history] + [report],
          best_strategy: best
        )
      end

      # Add a single mutated child of a given strategy to the population.
      #
      # Payload keys:
      #   id [String]  — id of the parent strategy
      on :mutate_strategy do |state:, payload:|
        parent = state[:population].find { |s| s.id == payload.fetch(:id) }
        next state unless parent

        agent = new
        child = agent.send(:mutate_one, parent, state, state[:population].size)
        state.merge(population: state[:population] + [child])
      end

      # Sync query — best evaluated strategy so far.
      #
      # @return [Strategy, nil]
      on :best do |state:, **|
        state[:best_strategy]
      end

      # Sync query — current population.
      #
      # @return [Array<Strategy>]
      on :population do |state:, **|
        state[:population].dup
      end

      # Sync query — evolution history (one GenerationReport per generation).
      #
      # @return [Array<GenerationReport>]
      on :history do |state:, **|
        state[:history].dup
      end

      # Sync query — current generation number.
      #
      # @return [Integer]
      on :generation do |state:, **|
        state[:generation]
      end

      # Update agent configuration.
      #
      # Payload keys:
      #   fitness_fn      [#call]
      #   llm             [#call]
      #   population_size [Integer]
      #   mutation_rate   [Float]   — 0.0–1.0
      #   elite_fraction  [Float]   — 0.0–1.0
      on :configure do |state:, payload:|
        state.merge(
          payload.slice(:fitness_fn, :llm, :population_size,
                        :mutation_rate, :elite_fraction).compact
        )
      end

      # Clear population and history (configuration is preserved).
      on :reset do |state:, **|
        state.merge(population: [], generation: 0, history: [], best_strategy: nil)
      end

      private

      def score_population(population, fitness_fn)
        population.map do |s|
          score = begin
            fitness_fn.call(s.config).to_f
          rescue StandardError
            0.0
          end
          Strategy.new(
            id: s.id, config: s.config, fitness: score,
            generation: s.generation, parent_ids: s.parent_ids, mutations: s.mutations
          )
        end
      end

      def run_evolution(state)
        evaluated = state[:population].reject { |s| s.fitness.nil? }
        return [nil, nil] if evaluated.empty?

        elite_count = [(evaluated.size * state[:elite_fraction]).ceil, 1].max
        elite       = evaluated.sort_by { |s| -(s.fitness || 0) }.first(elite_count)

        fitnesses = elite.map { |s| s.fitness.to_f }
        report    = GenerationReport.new(
          generation:      state[:generation],
          population_size: state[:population].size,
          best_fitness:    fitnesses.max.round(6),
          mean_fitness:    (fitnesses.sum / fitnesses.size).round(6),
          best_id:         elite.first.id
        )

        target   = [state[:population_size], elite.size].max
        children = []
        idx      = 0
        until elite.size + children.size >= target
          parent = elite[idx % elite.size]
          child  = mutate_one(parent, state, elite.size + idx)
          children << child
          idx += 1
        end

        [elite + children, report]
      end

      def mutate_one(parent, state, idx)
        next_gen = state[:generation] + 1
        config   = if state[:llm]
          mutate_with_llm(state[:llm], parent.config, next_gen)
        else
          mutate_rule_based(parent.config, state[:mutation_rate])
        end

        Strategy.new(
          id:         "gen#{next_gen}_#{idx}",
          config:     config,
          fitness:    nil,
          generation: next_gen,
          parent_ids: [parent.id],
          mutations:  detect_mutations(parent.config, config)
        )
      end

      def mutate_rule_based(config, rate)
        config.each_with_object({}) do |(k, v), acc|
          acc[k] = rand < rate ? mutate_value(v) : v
        end
      end

      def mutate_value(value)
        case value
        when Numeric           then (value * (0.8 + rand * 0.4)).round(6)
        when TrueClass, FalseClass then !value
        when Array             then value.empty? ? value : value.sample([1, rand(value.size)].max)
        else value
        end
      end

      def mutate_with_llm(llm, config, generation)
        result = llm.call(strategy: config, generation: generation)
        result.is_a?(Hash) ? result : mutate_rule_based(config, 0.3)
      rescue StandardError
        mutate_rule_based(config, 0.3)
      end

      def detect_mutations(original, mutated)
        original.keys.filter_map do |k|
          "#{k}: #{original[k].inspect} → #{mutated[k].inspect}" if original[k] != mutated[k]
        end
      end
      end
    end
  end
end
