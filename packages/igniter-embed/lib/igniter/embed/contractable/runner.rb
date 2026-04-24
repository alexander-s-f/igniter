# frozen_string_literal: true

module Igniter
  module Embed
    module Contractable
      class Runner
        OutputsLike = Struct.new(:payload, keyword_init: true) do
          def to_h
            payload
          end
        end
        ExecutionLike = Struct.new(:outputs, keyword_init: true)

        attr_reader :config

        def initialize(config:)
          @config = config
          @config.validate!
        end

        def call(*args, **kwargs)
          primary_result = invoke(config.primary_callable, args, kwargs)
          started_at = config.now
          sampled = config.sampled?

          if sampled
            work = -> { observe(started_at: started_at, primary_result: primary_result, args: args, kwargs: kwargs, sampled: true) }
            if config.async
              config.async_adapter.enqueue(name: config.name, inputs: redacted_inputs(args, kwargs), metadata: metadata_payload, &work)
            else
              work.call
            end
          else
            record_observation(sampled_observation(started_at: started_at, primary_result: primary_result, args: args, kwargs: kwargs))
          end

          primary_result
        end

        private

        def observe(started_at:, primary_result:, args:, kwargs:, sampled:)
          primary = normalize_side(config.primary_normalizer, primary_result)
          candidate = candidate_payload(args, kwargs)
          report = build_report(primary: primary, candidate: candidate, args: args, kwargs: kwargs)
          acceptance = if candidate
                         Acceptance.evaluate(
                           policy: config.acceptance_policy,
                           report: report,
                           candidate: candidate,
                           options: config.acceptance_options
                         )
                       end

          record_observation(
            observation(
              started_at: started_at,
              finished_at: config.now,
              args: args,
              kwargs: kwargs,
              sampled: sampled,
              primary: primary,
              candidate: candidate,
              report: report,
              acceptance: acceptance
            )
          )
        end

        def sampled_observation(started_at:, primary_result:, args:, kwargs:)
          primary = normalize_side(config.primary_normalizer, primary_result)
          observation(
            started_at: started_at,
            finished_at: config.now,
            args: args,
            kwargs: kwargs,
            sampled: false,
            primary: primary,
            candidate: nil,
            report: nil,
            acceptance: nil
          )
        end

        def candidate_payload(args, kwargs)
          return nil if config.observed_service?

          candidate_result = invoke(config.candidate_callable, args, kwargs)
          normalize_side(config.candidate_normalizer, candidate_result)
        rescue StandardError => e
          {
            status: :error,
            outputs: {},
            metadata: {},
            error: serialize_error(e)
          }
        end

        def normalize_side(normalizer, value)
          normalized = normalizer.call(value)
          {
            status: normalized.fetch(:status, :ok).to_sym,
            outputs: normalize_hash(normalized.fetch(:outputs)),
            metadata: normalize_hash(normalized.fetch(:metadata, {})),
            error: normalized[:error]
          }
        rescue StandardError => e
          {
            status: :error,
            outputs: {},
            metadata: {},
            error: serialize_error(e)
          }
        end

        def build_report(primary:, candidate:, args:, kwargs:)
          return nil unless candidate

          Igniter::Extensions::Contracts::DifferentialPack.compare(
            inputs: redacted_inputs(args, kwargs),
            primary_result: execution_like(primary.fetch(:outputs)),
            candidate_result: execution_like(candidate.fetch(:outputs)),
            primary_name: "#{config.name}:primary",
            candidate_name: "#{config.name}:candidate"
          )
        end

        def observation(started_at:, finished_at:, args:, kwargs:, sampled:, primary:, candidate:, report:, acceptance:)
          {
            name: config.name,
            role: config.role,
            stage: config.stage,
            mode: candidate ? :shadow : :observe,
            async: config.async,
            sampled: sampled,
            started_at: serialize_time(started_at),
            finished_at: serialize_time(finished_at),
            duration_ms: duration_ms(started_at, finished_at),
            inputs: redacted_inputs(args, kwargs),
            primary: primary,
            candidate: candidate,
            report: report_payload(report),
            match: report&.match?,
            accepted: acceptance&.fetch(:accepted),
            acceptance: acceptance,
            error: candidate&.fetch(:error),
            store_error: nil,
            metadata: metadata_payload
          }
        end

        def record_observation(observation)
          if config.store_adapter
            begin
              config.store_adapter.record(observation)
            rescue StandardError => e
              observation[:store_error] = serialize_error(e)
            end
          end
          config.observation_callback&.call(observation)
          observation
        end

        def invoke(callable, args, kwargs)
          callable.call(*args, **kwargs)
        end

        def execution_like(outputs)
          ExecutionLike.new(outputs: OutputsLike.new(payload: outputs))
        end

        def report_payload(report)
          return nil unless report

          {
            match: report.match?,
            summary: report.summary,
            details: report.to_h
          }
        end

        def redacted_inputs(args, kwargs)
          normalize_hash(config.normalize_inputs(args, kwargs))
        end

        def metadata_payload
          normalize_hash(config.metadata_payload)
        end

        def normalize_hash(value)
          value.to_h.transform_keys(&:to_sym)
        end

        def serialize_error(error)
          {
            type: error.class.name,
            message: error.message,
            details: error.respond_to?(:to_h) ? error.to_h : {}
          }
        end

        def serialize_time(value)
          value.respond_to?(:iso8601) ? value.iso8601 : value.to_s
        end

        def duration_ms(started_at, finished_at)
          return nil unless started_at.respond_to?(:to_f) && finished_at.respond_to?(:to_f)

          ((finished_at.to_f - started_at.to_f) * 1000).round(3)
        end
      end
    end
  end
end
