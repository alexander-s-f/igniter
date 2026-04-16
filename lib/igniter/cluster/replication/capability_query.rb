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
        attr_reader :name, :all_of, :any_of, :none_of, :tags, :metadata

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

        def initialize(name: nil, all_of: [], any_of: [], none_of: [], tags: [], metadata: {})
          @name     = name&.to_sym
          @all_of   = Array(all_of).map(&:to_sym).uniq.sort.freeze
          @any_of   = Array(any_of).map(&:to_sym).uniq.sort.freeze
          @none_of  = Array(none_of).map(&:to_sym).uniq.sort.freeze
          @tags     = Array(tags).map(&:to_sym).uniq.sort.freeze
          @metadata = Hash(metadata).transform_keys(&:to_sym).freeze
          freeze
        end

        def matches_profile?(profile)
          return false unless profile

          all_match = @all_of.all? { |capability| profile.capability?(capability) }
          any_match = @any_of.empty? || @any_of.any? { |capability| profile.capability?(capability) }
          none_match = @none_of.none? { |capability| profile.capability?(capability) }
          tags_match = @tags.all? { |tag| profile.tag?(tag) }

          all_match && any_match && none_match && tags_match
        end

        def label
          return @name.to_s if @name

          fragments = []
          fragments << "all(#{@all_of.join(",")})" unless @all_of.empty?
          fragments << "any(#{@any_of.join(",")})" unless @any_of.empty?
          fragments << "none(#{@none_of.join(",")})" unless @none_of.empty?
          fragments << "tags(#{@tags.join(",")})" unless @tags.empty?
          fragments.join(" ")
        end

        def compact_signature
          all_of = @all_of.join("+")
          all_of = "any:#{@any_of.join(",")}" if all_of.empty? && @any_of.any?
          tags = @tags.empty? ? nil : "@#{@tags.join("+")}"
          [all_of, tags].compact.join
        end

        def to_h
          {
            name: @name,
            all_of: @all_of,
            any_of: @any_of,
            none_of: @none_of,
            tags: @tags,
            metadata: @metadata
          }
        end
      end
    end
  end
end
