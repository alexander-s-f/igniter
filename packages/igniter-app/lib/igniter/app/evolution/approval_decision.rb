# frozen_string_literal: true

require "set"

module Igniter
  class App
    module Evolution
      class ApprovalDecision
        attr_reader :mode, :approved_action_ids, :denied_action_ids, :selections, :metadata

        class << self
          def approve_all(selections: {}, metadata: {})
            new(mode: :approve_all, selections: selections, metadata: metadata)
          end

          def build(approved_action_ids: [], denied_action_ids: [], selections: {}, metadata: {})
            new(
              mode: :selective,
              approved_action_ids: approved_action_ids,
              denied_action_ids: denied_action_ids,
              selections: selections,
              metadata: metadata
            )
          end

          def normalize(value, selections: {})
            case value
            when nil
              nil
            when true
              approve_all(selections: selections)
            when false
              nil
            when self
              merged_selections = value.selections.merge(normalize_selections(selections))
              new(
                mode: value.mode,
                approved_action_ids: value.approved_action_ids.to_a,
                denied_action_ids: value.denied_action_ids.to_a,
                selections: merged_selections,
                metadata: value.metadata
              )
            when Hash
              normalized = symbolize_hash(value)
              if normalized[:approve_all]
                approve_all(
                  selections: normalize_selections(normalized[:selections]).merge(normalize_selections(selections)),
                  metadata: normalized[:metadata] || {}
                )
              else
                build(
                  approved_action_ids: normalized[:approved_action_ids] || normalized[:approved] || [],
                  denied_action_ids: normalized[:denied_action_ids] || normalized[:denied] || [],
                  selections: normalize_selections(normalized[:selections]).merge(normalize_selections(selections)),
                  metadata: normalized[:metadata] || {}
                )
              end
            else
              raise ArgumentError, "Unsupported approval decision #{value.inspect}"
            end
          end

          private

          def normalize_selections(selections)
            symbolize_hash(selections).transform_values do |value|
              Array(value).map(&:to_sym).uniq.sort.freeze
            end
          end

          def symbolize_hash(value)
            Array(value).each_with_object({}) do |(key, nested), memo|
              memo[key.to_sym] = nested
            end
          end
        end

        def initialize(mode:, approved_action_ids: [], denied_action_ids: [], selections: {}, metadata: {})
          @mode = mode.to_sym
          @approved_action_ids = Set.new(Array(approved_action_ids).map(&:to_s)).freeze
          @denied_action_ids = Set.new(Array(denied_action_ids).map(&:to_s)).freeze
          @selections = self.class.send(:normalize_selections, selections).freeze
          @metadata = self.class.send(:symbolize_hash, metadata).freeze
          freeze
        end

        def approve_action?(action_id)
          action_key = action_id.to_s
          return false if denied_action_ids.include?(action_key)
          return true if mode == :approve_all

          approved_action_ids.include?(action_key)
        end

        def deny_action?(action_id)
          denied_action_ids.include?(action_id.to_s)
        end

        def selection_for(capability)
          selections[capability.to_sym] || selections[capability.to_s.to_sym] || []
        end

        def to_h
          {
            mode: mode,
            approved_action_ids: approved_action_ids.to_a.sort,
            denied_action_ids: denied_action_ids.to_a.sort,
            selections: selections,
            metadata: metadata
          }
        end
      end
    end
  end
end
