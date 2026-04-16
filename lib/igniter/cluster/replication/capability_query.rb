# frozen_string_literal: true

require "set"

module Igniter
  module Cluster
    module Replication
      # Declarative matcher over the capability space of a node profile.
      #
      # This is the capability-first replacement for role labels. A query can be
      # used as a slice through the mesh capability cube: "all of these
      # capabilities", "at least one of these", "none of these", and "with these
      # tags".
      class CapabilityQuery
        attr_reader :name, :all_of, :any_of, :none_of, :tags, :metadata, :order_by, :policy, :decision

        OPERATOR_KEYS = %i[eq min max in includes contains present].freeze
        DECISION_MODES = %i[auto_only approval_ok deny_risky].freeze

        def self.normalize(query)
          case query
          when self
            query
          when Array
            new(all_of: query)
          when Hash
            new(**query)
          when Symbol, String
            new(name: query, all_of: [query])
          else
            raise ArgumentError, "Unsupported capability query: #{query.inspect}"
          end
        end

        def initialize(name: nil, all_of: [], any_of: [], none_of: [], tags: [], metadata: {}, order_by: [], policy: {}, decision: {})
          @name     = name&.to_sym
          @all_of   = Array(all_of).map(&:to_sym).uniq.sort.freeze
          @any_of   = Array(any_of).map(&:to_sym).uniq.sort.freeze
          @none_of  = Array(none_of).map(&:to_sym).uniq.sort.freeze
          @tags     = Array(tags).map(&:to_sym).uniq.sort.freeze
          @metadata = normalize_metadata(metadata).freeze
          @order_by = normalize_order_by(order_by).freeze
          @policy   = normalize_policy(policy).freeze
          @decision = normalize_decision(decision).freeze
          freeze
        end

        def matches_profile?(profile)
          return false unless profile

          all_match = @all_of.all? { |capability| profile.capability?(capability) }
          any_match = @any_of.empty? || @any_of.any? { |capability| profile.capability?(capability) }
          none_match = @none_of.none? { |capability| profile.capability?(capability) }
          tags_match = @tags.all? { |tag| profile.tag?(tag) }
          metadata_match = metadata_matches?(profile)
          policy_match = policy_matches?(profile)
          decision_match = decision_matches?(profile)

          all_match && any_match && none_match && tags_match && metadata_match && policy_match && decision_match
        end

        def label
          return @name.to_s if @name

          fragments = []
          fragments << "all(#{@all_of.join(",")})" unless @all_of.empty?
          fragments << "any(#{@any_of.join(",")})" unless @any_of.empty?
          fragments << "none(#{@none_of.join(",")})" unless @none_of.empty?
          fragments << "tags(#{@tags.join(",")})" unless @tags.empty?
          fragments << "metadata(#{@metadata.keys.join(",")})" unless @metadata.empty?
          fragments << "policy(#{@policy.keys.join(",")})" unless @policy.empty?
          fragments << "decision(#{@decision[:mode]})" unless @decision.empty?
          fragments << "order(#{@order_by.map { |clause| "#{clause[:metadata].join(".")}:#{clause[:direction]}" }.join(",")})" unless @order_by.empty?
          fragments.join(" ")
        end

        def compact_signature
          all_of = @all_of.join("+")
          all_of = "any:#{@any_of.join(",")}" if all_of.empty? && @any_of.any?
          tags = @tags.empty? ? nil : "@#{@tags.join("+")}"
          ordering = @order_by.empty? ? nil : "~#{@order_by.map { |clause| "#{clause[:metadata].join(".")}:#{clause[:direction]}" }.join(",")}"
          [all_of, tags, ordering].compact.join
        end

        def to_h
          {
            name: @name,
            all_of: @all_of,
            any_of: @any_of,
            none_of: @none_of,
            tags: @tags,
            metadata: @metadata,
            order_by: @order_by,
            policy: @policy,
            decision: @decision
          }
        end

        def ordered?
          !@order_by.empty?
        end

        def decisioned?
          !@decision.empty?
        end

        def compare_profiles(left, right)
          decision_comparison = compare_decision_outcomes(left, right)
          return decision_comparison unless decision_comparison.zero?

          @order_by.each do |clause|
            comparison = compare_values(
              metadata_value(left, clause[:metadata]),
              metadata_value(right, clause[:metadata]),
              direction: clause[:direction],
              nulls: clause[:nulls]
            )
            return comparison unless comparison.zero?
          end

          0
        end

        def ranking_fingerprint(profile)
          fingerprint = @order_by.map { |clause| metadata_value(profile, clause[:metadata]) }
          return fingerprint unless decisioned?

          [decision_priority(profile)] + fingerprint
        end

        private

        def normalize_metadata(value)
          case value
          when Hash
            value.each_with_object({}) do |(key, nested), memo|
              memo[key.to_sym] = normalize_metadata(nested)
            end
          when Array
            value.map { |item| normalize_metadata(item) }
          else
            value
          end
        end

        def normalize_order_by(order_by)
          Array(order_by).map do |clause|
            normalize_order_clause(clause)
          end
        end

        def normalize_policy(policy)
          normalize_policy_value(policy)
        end

        def normalize_decision(decision)
          case decision
          when nil
            {}
          when Symbol, String
            { mode: normalize_decision_mode(decision) }
          when Hash
            normalized = normalize_policy_value(decision)
            return {} if normalized.empty?

            if normalized.key?(:mode)
              normalized[:mode] = normalize_decision_mode(normalized[:mode])
            else
              normalized[:mode] = :auto_only
            end
            normalized[:actions] = Array(normalized[:actions]).map(&:to_sym).uniq.freeze if normalized.key?(:actions)
            normalized[:risky] = Array(normalized[:risky]).map(&:to_sym).uniq.freeze if normalized.key?(:risky)
            normalized
          else
            raise ArgumentError, "Unsupported decision query: #{decision.inspect}"
          end
        end

        def normalize_decision_mode(mode)
          mode = mode.to_sym
          raise ArgumentError, "Unsupported decision mode: #{mode.inspect}" unless DECISION_MODES.include?(mode)

          mode
        end

        def normalize_policy_value(value)
          case value
          when Hash
            value.each_with_object({}) do |(key, nested), memo|
              memo[key.to_sym] = normalize_policy_value(nested)
            end
          when Array
            value.map { |item| normalize_policy_value(item) }
          when Symbol, String
            value.to_sym
          else
            value
          end
        end

        def normalize_order_clause(clause)
          clause = normalize_metadata(clause)
          raise ArgumentError, "Unsupported order clause: #{clause.inspect}" unless clause.is_a?(Hash)

          {
            metadata: normalize_metadata_path(clause.fetch(:metadata)),
            direction: normalize_direction(clause.fetch(:direction, :asc)),
            nulls: normalize_nulls(clause.fetch(:nulls, :last))
          }.freeze
        end

        def normalize_metadata_path(path)
          case path
          when Array
            path.map(&:to_sym).freeze
          when Symbol, String
            path.to_s.split(".").map(&:to_sym).freeze
          else
            raise ArgumentError, "Unsupported metadata path: #{path.inspect}"
          end
        end

        def normalize_direction(direction)
          direction = direction.to_sym
          raise ArgumentError, "Unsupported order direction: #{direction.inspect}" unless %i[asc desc].include?(direction)

          direction
        end

        def normalize_nulls(nulls)
          nulls = nulls.to_sym
          raise ArgumentError, "Unsupported null ordering: #{nulls.inspect}" unless %i[first last].include?(nulls)

          nulls
        end

        def metadata_matches?(profile)
          return true if @metadata.empty?
          return false unless profile.respond_to?(:metadata)

          matches_metadata_subset?(@metadata, normalize_metadata(profile.metadata || {}))
        end

        def policy_matches?(profile)
          return true if @policy.empty?
          return false unless profile.respond_to?(:metadata)

          effective = effective_policy_sets(profile)
          @policy.all? do |key, expected|
            policy_requirement_matches?(key, expected, effective)
          end
        end

        def decision_matches?(profile)
          return true if @decision.empty?

          outcome = decision_outcome(profile)
          case @decision.fetch(:mode, :auto_only)
          when :auto_only
            outcome == :automatic
          when :approval_ok
            %i[automatic approval_required].include?(outcome)
          when :deny_risky
            outcome == :automatic && risky_guard_satisfied?(profile)
          else
            false
          end
        end

        def metadata_value(profile, path)
          metadata = normalize_metadata(profile&.metadata || {})
          path.reduce(metadata) do |memo, key|
            break nil unless memo.is_a?(Hash)

            memo[key]
          end
        end

        def matches_metadata_subset?(expected, actual)
          expected.all? do |key, requirement|
            actual_value = actual[key]
            matches_metadata_requirement?(requirement, actual_value)
          end
        end

        def effective_policy_sets(profile)
          raw_policy = normalize_policy_value(profile.metadata.fetch(:policy, {}))
          allows = policy_set(raw_policy[:allows])
          denies = policy_set(raw_policy[:denies])
          requires_approval = policy_set(raw_policy[:requires_approval])

          {
            allows: allows,
            denies: denies,
            requires_approval: requires_approval,
            permits: allows - denies - requires_approval,
            approvable: requires_approval - denies,
            forbidden: denies
          }
        end

        def decision_outcome(profile)
          return :automatic if @decision.empty?

          actions = decision_actions
          return :automatic if actions.empty?

          effective = effective_policy_sets(profile)
          return :automatic if actions.subset?(effective[:permits])
          return :approval_required if actions.subset?(effective[:permits] + effective[:approvable])

          :rejected
        end

        def decision_priority(profile)
          return 0 if @decision.empty?

          case decision_outcome(profile)
          when :automatic
            0
          when :approval_required
            1
          else
            2
          end
        end

        def compare_decision_outcomes(left, right)
          return 0 unless decisioned?

          decision_priority(left) <=> decision_priority(right)
        end

        def policy_set(value)
          Array(value).map(&:to_sym).uniq.to_set
        end

        def policy_requirement_matches?(key, expected, effective)
          values = policy_set(expected)

          case key
          when :allows, :denies, :requires_approval, :permits, :approvable, :forbidden
            values.subset?(effective.fetch(key))
          else
            false
          end
        end

        def decision_actions
          policy_set(@decision[:actions])
        end

        def risky_guard_satisfied?(profile)
          risky = policy_set(@decision[:risky])
          return true if risky.empty?

          effective_policy_sets(profile).fetch(:forbidden).superset?(risky)
        end

        def matches_metadata_requirement?(requirement, actual_value)
          case requirement
          when Hash
            if operator_hash?(requirement)
              matches_operator_requirement?(requirement, actual_value)
            else
              actual_value.is_a?(Hash) && matches_metadata_subset?(requirement, actual_value)
            end
          when Array
            actual_value == requirement
          else
            actual_value == requirement
          end
        end

        def operator_hash?(requirement)
          !(requirement.keys & OPERATOR_KEYS).empty?
        end

        def matches_operator_requirement?(requirement, actual_value)
          return false if requirement[:present] && actual_value.nil?
          return false if requirement.key?(:eq) && actual_value != requirement[:eq]
          return false if requirement.key?(:min) && (actual_value.nil? || actual_value < requirement[:min])
          return false if requirement.key?(:max) && (actual_value.nil? || actual_value > requirement[:max])
          return false if requirement.key?(:in) && !Array(requirement[:in]).include?(actual_value)

          if requirement.key?(:includes)
            expected_values = Array(requirement[:includes])
            return false unless actual_value.respond_to?(:include?)
            return false unless expected_values.all? { |value| actual_value.include?(value) }
          end

          if requirement.key?(:contains)
            return false unless actual_value.is_a?(Hash)
            return false unless matches_metadata_subset?(normalize_metadata(requirement[:contains]), actual_value)
          end

          true
        end

        def compare_values(left, right, direction:, nulls:)
          return 0 if left == right
          return null_comparison(left, right, nulls) if left.nil? || right.nil?

          comparison = if left.is_a?(Numeric) && right.is_a?(Numeric)
                         left <=> right
                       else
                         left.to_s <=> right.to_s
                       end

          direction == :desc ? -comparison : comparison
        end

        def null_comparison(left, right, nulls)
          return 0 if left.nil? && right.nil?

          if left.nil?
            nulls == :first ? -1 : 1
          else
            nulls == :first ? 1 : -1
          end
        end
      end
    end
  end
end
