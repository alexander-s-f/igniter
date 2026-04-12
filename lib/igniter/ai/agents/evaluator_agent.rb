# frozen_string_literal: true

module Igniter
  module AI
    module Agents
    # Tracks performance metrics for named subjects (agents, services,
    # contracts), computes weighted aggregate scores, and compares subjects
    # against each other or against stored baselines.
    #
    # Scoring:
    # * Metrics are grouped by name; the last 20 readings are averaged.
    # * Per-subject or global weights scale each metric's contribution.
    # * When a baseline is set the score is normalised to 0–100 relative to it;
    #   without a baseline the raw weighted average is returned.
    # * Grades: A ≥ 90, B ≥ 75, C ≥ 60, D otherwise.
    #
    # @example Track two services and compare
    #   ref = EvaluatorAgent.start
    #   ref.send(:record_metric, subject: :api, name: :throughput, value: 850)
    #   ref.send(:record_metric, subject: :api, name: :error_rate,  value: 2.1)
    #   ref.send(:set_baseline,  subject: :api, baseline: 800)
    #   ref.send(:evaluate,      subject: :api)
    #   ev = ref.call(:evaluations, subject: :api).last
    #   puts ev.grade   # => "A"
      class EvaluatorAgent < Igniter::Agent
      MetricRecord = Struct.new(:name, :value, :recorded_at, keyword_init: true)
      Evaluation   = Struct.new(:subject, :score, :grade, :metrics,
                                :recorded_at, keyword_init: true)
      Comparison   = Struct.new(:subject_a, :subject_b, :winner, :delta,
                                keyword_init: true)

      GRADES = [
        [90.0, "A"],
        [75.0, "B"],
        [60.0, "C"],
        [  0.0, "D"]
      ].freeze

      # subjects: Hash<String, { metrics: Array<MetricRecord>, baseline: Float?, weights: Hash }>
      initial_state \
        subjects:    {},
        evaluations: [],
        weights:     {}

      # Record a metric reading for a subject.
      #
      # Payload keys:
      #   subject [String, Symbol]  — subject identifier
      #   name    [String, Symbol]  — metric name
      #   value   [Numeric]         — metric value
      on :record_metric do |state:, payload:|
        subject = payload.fetch(:subject).to_s
        metric  = MetricRecord.new(
          name:        payload.fetch(:name).to_s,
          value:       payload.fetch(:value).to_f,
          recorded_at: Time.now
        )
        entry   = state[:subjects].fetch(subject, { metrics: [], baseline: nil, weights: {} })
        updated = entry.merge(metrics: (entry[:metrics] + [metric]).last(200))
        state.merge(subjects: state[:subjects].merge(subject => updated))
      end

      # Set the reference baseline value for a subject.
      # Scores will be expressed as a percentage of this baseline.
      #
      # Payload keys:
      #   subject  [String, Symbol]
      #   baseline [Numeric]
      on :set_baseline do |state:, payload:|
        subject  = payload.fetch(:subject).to_s
        baseline = payload.fetch(:baseline).to_f
        entry    = state[:subjects].fetch(subject, { metrics: [], baseline: nil, weights: {} })
        updated  = entry.merge(baseline: baseline)
        state.merge(subjects: state[:subjects].merge(subject => updated))
      end

      # Set per-metric weights for a subject.
      #
      # Payload keys:
      #   subject [String, Symbol]
      #   weights [Hash<String, Numeric>]  — metric name → weight
      on :set_weights do |state:, payload:|
        subject = payload.fetch(:subject).to_s
        weights = payload.fetch(:weights).transform_keys(&:to_s)
        entry   = state[:subjects].fetch(subject, { metrics: [], baseline: nil, weights: {} })
        updated = entry.merge(weights: weights)
        state.merge(subjects: state[:subjects].merge(subject => updated))
      end

      # Compute and store an Evaluation for a subject.
      #
      # Payload keys:
      #   subject [String, Symbol]
      on :evaluate do |state:, payload:|
        agent    = new
        ev       = agent.send(:compute_evaluation, payload.fetch(:subject).to_s, state)
        next state unless ev

        state.merge(evaluations: state[:evaluations] + [ev])
      end

      # Sync query — compare the most recent evaluations of two subjects.
      #
      # Payload keys:
      #   a [String, Symbol]  — first subject
      #   b [String, Symbol]  — second subject
      #
      # @return [Comparison, nil]
      on :compare do |state:, payload:|
        a = state[:evaluations].select { |e| e.subject == payload.fetch(:a).to_s }.last
        b = state[:evaluations].select { |e| e.subject == payload.fetch(:b).to_s }.last
        next nil unless a && b

        delta  = (a.score - b.score).round(4)
        winner = if delta > 0 then a.subject
                 elsif delta < 0 then b.subject
                 else :tie
                 end
        Comparison.new(subject_a: a.subject, subject_b: b.subject,
                       winner: winner, delta: delta.abs)
      end

      # Sync query — all evaluations, optionally filtered by subject.
      #
      # Payload keys:
      #   subject [String, Symbol, nil]
      #
      # @return [Array<Evaluation>]
      on :evaluations do |state:, payload:|
        filter = payload&.fetch(:subject, nil)
        evs    = state[:evaluations]
        evs    = evs.select { |e| e.subject == filter.to_s } if filter
        evs.dup
      end

      # Sync query — list registered subject names.
      #
      # @return [Array<String>]
      on :subjects do |state:, **|
        state[:subjects].keys
      end

      # Set global default weights (applied when a subject has no per-metric weight).
      #
      # Payload keys:
      #   weights [Hash<String, Numeric>]
      on :configure do |state:, payload:|
        state.merge(payload.slice(:weights).compact)
      end

      # Clear all subjects and evaluations.
      on :reset do |state:, **|
        state.merge(subjects: {}, evaluations: [])
      end

      private

      def compute_evaluation(name, state)
        data = state[:subjects][name]
        return nil unless data && data[:metrics].any?

        weights  = state[:weights].merge(data[:weights] || {})
        metrics  = data[:metrics]
        baseline = data[:baseline]

        grouped = metrics.group_by(&:name)
        score_parts = grouped.map do |mname, records|
          avg    = records.last(20).sum(&:value) / [records.last(20).size, 1].max
          weight = (weights[mname] || 1.0).to_f
          [avg * weight, weight]
        end

        total_weight = [score_parts.sum { |_, w| w }, 0.001].max
        raw          = score_parts.sum { |v, _| v } / total_weight

        score = if baseline && baseline > 0
          [(raw / baseline * 100).round(4), 100.0].min
        else
          raw.round(4)
        end

        grade = GRADES.find { |threshold, _| score.to_f >= threshold }&.last || "D"

        Evaluation.new(
          subject:     name,
          score:       score,
          grade:       grade,
          metrics:     grouped.keys,
          recorded_at: Time.now
        )
      end
      end
    end
  end
end
