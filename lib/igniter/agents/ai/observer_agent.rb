# frozen_string_literal: true

module Igniter
  module Agents
    # Passive-watching agent that records observations from other agents or
    # systems, applies user-defined anomaly-detection rules, and surfaces
    # detected anomalies for inspection or alerting.
    #
    # Design:
    # * Observations are appended via +:observe+.
    # * Anomaly rules are callables +:matcher+ stored with a +:name+.
    # * Call +:check+ to scan new (unscanned) observations against all rules.
    #   The agent tracks a cursor so rules are never applied twice to the same
    #   observation, preventing duplicates.
    #
    # @example Detect error spikes
    #   ref = ObserverAgent.start
    #   ref.send(:watch, subject: :payments)
    #   ref.send(:add_rule,
    #     name:    :consecutive_errors,
    #     matcher: ->(obs) { obs.event == :error })
    #   ref.send(:observe, subject: :payments, event: :error)
    #   ref.send(:check)
    #   ref.call(:anomalies)   # => [Anomaly(...)]
    class ObserverAgent < Igniter::Agent
      # A single recorded event.
      Observation = Struct.new(:subject, :event, :data, :observed_at, keyword_init: true)

      # A detected rule violation.
      Anomaly = Struct.new(:subject, :rule, :observation, :detected_at, keyword_init: true)

      # A detection rule.
      Rule = Struct.new(:name, :matcher, keyword_init: true)

      # Sync-query summary.
      Summary = Struct.new(:subjects, :observations, :anomalies, :rules, keyword_init: true)

      initial_state \
        subjects:         [],
        observations:     [],
        anomalies:        [],
        rules:            [],
        checked_until:    0,
        max_observations: 500

      # Register a subject to watch.
      #
      # Payload keys:
      #   subject [Symbol, String]
      on :watch do |state:, payload:|
        subject = payload.fetch(:subject).to_sym
        next state if state[:subjects].include?(subject)

        state.merge(subjects: state[:subjects] + [subject])
      end

      # Stop watching a subject.
      #
      # Payload keys:
      #   subject [Symbol, String]
      on :unwatch do |state:, payload:|
        subject = payload.fetch(:subject).to_sym
        state.merge(subjects: state[:subjects] - [subject])
      end

      # Record an observation event.
      #
      # Payload keys:
      #   subject [Symbol, String]  — source of the event
      #   event   [Symbol, String]  — event type
      #   data    [Hash]            — optional extra data
      on :observe do |state:, payload:|
        obs = Observation.new(
          subject:     payload.fetch(:subject),
          event:       payload.fetch(:event),
          data:        payload.fetch(:data, {}),
          observed_at: Time.now
        )
        kept = (state[:observations] + [obs]).last(state[:max_observations])
        state.merge(observations: kept)
      end

      # Add (or replace) an anomaly-detection rule.
      #
      # Payload keys:
      #   name    [Symbol, String]  — unique rule identifier
      #   matcher [#call]           — callable(Observation) → truthy when anomaly
      on :add_rule do |state:, payload:|
        rule  = Rule.new(name: payload.fetch(:name).to_sym, matcher: payload.fetch(:matcher))
        rules = state[:rules].reject { |r| r.name == rule.name } + [rule]
        state.merge(rules: rules)
      end

      # Remove a rule by name.
      #
      # Payload keys:
      #   name [Symbol, String]
      on :remove_rule do |state:, payload:|
        name = payload.fetch(:name).to_sym
        state.merge(rules: state[:rules].reject { |r| r.name == name })
      end

      # Scan observations added since the last check against all rules.
      # Uses a cursor to guarantee each observation is checked at most once.
      #
      # Payload keys:
      #   window [Integer, nil]  — max recent observations to scan (default: all new)
      on :check do |state:, payload:|
        cursor  = state[:checked_until]
        new_obs = state[:observations].drop(cursor)
        new_obs = new_obs.last(payload[:window]) if payload&.fetch(:window, nil)

        detected = new_obs.flat_map do |obs|
          state[:rules].filter_map do |rule|
            next unless rule.matcher.call(obs)

            Anomaly.new(
              subject:     obs.subject,
              rule:        rule.name,
              observation: obs,
              detected_at: Time.now
            )
          end
        end

        state.merge(
          anomalies:     state[:anomalies] + detected,
          checked_until: state[:observations].size
        )
      end

      # Sync query — return observations, optionally filtered by subject.
      #
      # Payload keys:
      #   subject [Symbol, String, nil]
      #
      # @return [Array<Observation>]
      on :observations do |state:, payload:|
        filter = payload&.fetch(:subject, nil)
        obs    = state[:observations]
        obs    = obs.select { |o| o.subject.to_s == filter.to_s } if filter
        obs.dup
      end

      # Sync query — return anomalies, optionally filtered by subject.
      #
      # Payload keys:
      #   subject [Symbol, String, nil]
      #
      # @return [Array<Anomaly>]
      on :anomalies do |state:, payload:|
        filter = payload&.fetch(:subject, nil)
        anoms  = state[:anomalies]
        anoms  = anoms.select { |a| a.subject.to_s == filter.to_s } if filter
        anoms.dup
      end

      # Sync query — aggregate counts.
      #
      # @return [Summary]
      on :summary do |state:, **|
        Summary.new(
          subjects:     state[:subjects].size,
          observations: state[:observations].size,
          anomalies:    state[:anomalies].size,
          rules:        state[:rules].size
        )
      end

      # Clear detected anomalies (observations and rules are preserved).
      on :clear_anomalies do |state:, **|
        state.merge(anomalies: [], checked_until: 0)
      end

      # Update configuration.
      #
      # Payload keys:
      #   max_observations [Integer]
      on :configure do |state:, payload:|
        state.merge(payload.slice(:max_observations).compact)
      end
    end
  end
end
