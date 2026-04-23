# frozen_string_literal: true

module Igniter
  module Dataflow
    # Immutable record of what changed in an incremental collection resolve.
    #
    # @attr added     [Array<Object>] keys of items added since the last resolve
    # @attr removed   [Array<Object>] keys of items removed since the last resolve
    # @attr changed   [Array<Object>] keys of items whose content changed
    # @attr unchanged [Array<Object>] keys of items that were identical to the last resolve
    Diff = Struct.new(:added, :removed, :changed, :unchanged, keyword_init: true) do
      # Returns true if any items were added, removed, or changed.
      def any_changes?
        added.any? || removed.any? || changed.any?
      end

      # Returns the total number of items that needed processing (added + changed).
      def processed_count
        added.size + changed.size
      end

      # Returns a compact human-readable summary.
      def explain # rubocop:disable Metrics/AbcSize
        parts = []
        parts << "added(#{added.size}): #{added.inspect}" unless added.empty?
        parts << "removed(#{removed.size}): #{removed.inspect}" unless removed.empty?
        parts << "changed(#{changed.size}): #{changed.inspect}" unless changed.empty?
        parts << "unchanged(#{unchanged.size})" unless unchanged.empty?
        parts.empty? ? "(no changes)" : parts.join(", ")
      end

      def to_h
        { added: added, removed: removed, changed: changed, unchanged: unchanged }
      end
    end
  end
end
