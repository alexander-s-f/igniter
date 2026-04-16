# frozen_string_literal: true

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
        attr_reader :name, :all_of, :any_of, :none_of, :tags, :metadata, :order_by

        OPERATOR_KEYS = %i[eq min max in includes contains present].freeze

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

        def initialize(name: nil, all_of: [], any_of: [], none_of: [], tags: [], metadata: {}, order_by: [])
          @name     = name&.to_sym
          @all_of   = Array(all_of).map(&:to_sym).uniq.sort.freeze
          @any_of   = Array(any_of).map(&:to_sym).uniq.sort.freeze
          @none_of  = Array(none_of).map(&:to_sym).uniq.sort.freeze
          @tags     = Array(tags).map(&:to_sym).uniq.sort.freeze
          @metadata = normalize_metadata(metadata).freeze
          @order_by = normalize_order_by(order_by).freeze
          freeze
        end

        def matches_profile?(profile)
          return false unless profile

          all_match = @all_of.all? { |capability| profile.capability?(capability) }
          any_match = @any_of.empty? || @any_of.any? { |capability| profile.capability?(capability) }
          none_match = @none_of.none? { |capability| profile.capability?(capability) }
          tags_match = @tags.all? { |tag| profile.tag?(tag) }
          metadata_match = metadata_matches?(profile)

          all_match && any_match && none_match && tags_match && metadata_match
        end

        def label
          return @name.to_s if @name

          fragments = []
          fragments << "all(#{@all_of.join(",")})" unless @all_of.empty?
          fragments << "any(#{@any_of.join(",")})" unless @any_of.empty?
          fragments << "none(#{@none_of.join(",")})" unless @none_of.empty?
          fragments << "tags(#{@tags.join(",")})" unless @tags.empty?
          fragments << "metadata(#{@metadata.keys.join(",")})" unless @metadata.empty?
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
            order_by: @order_by
          }
        end

        def ordered?
          !@order_by.empty?
        end

        def compare_profiles(left, right)
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
          @order_by.map { |clause| metadata_value(profile, clause[:metadata]) }
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
