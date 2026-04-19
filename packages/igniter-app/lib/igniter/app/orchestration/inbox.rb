# frozen_string_literal: true

require "securerandom"
require "time"

module Igniter
  class App
    module Orchestration
      class Inbox
        RESOLVED_STATUSES = %i[resolved dismissed].freeze

        def initialize(clock: -> { Time.now.utc.iso8601 })
          @clock = clock
          @items = []
        end

        def open(action, source:, graph: nil, execution_id: nil, session: nil)
          existing = find_active(action[:id])
          return existing if existing

          item = {
            item_id: SecureRandom.uuid,
            id: action[:id],
            action: action[:action],
            policy: action[:policy],
            node: action[:node],
            interaction: action[:interaction],
            reason: action[:reason],
            guidance: action[:guidance],
            attention_required: action[:attention_required],
            resumable: action[:resumable],
            lane: action[:lane],
            routing: action[:routing],
            source: source.to_sym,
            graph: graph,
            execution_id: execution_id,
            assignee: action.dig(:routing, :assignee),
            queue: action.dig(:routing, :queue),
            channel: action.dig(:routing, :channel),
            handoff_count: 0,
            handoff_history: [].freeze,
            status: :open,
            created_at: @clock.call
          }.merge(session_item_attributes(session)).compact.freeze

          @items << item
          item
        end

        def find(id)
          @items.reverse_each.find { |item| item[:id] == id.to_s }
        end

        def find_active(id)
          @items.reverse_each.find { |item| item[:id] == id.to_s && !RESOLVED_STATUSES.include?(item[:status]) }
        end

        def acknowledge(id, note: nil)
          transition(id, to: :acknowledged, timestamp_key: :acknowledged_at, note: note)
        end

        def handoff(id, assignee: nil, queue: nil, channel: nil, note: nil)
          current = find(id)
          return nil unless current

          validate_handoff_target!(assignee: assignee, queue: queue, channel: channel, id: id)

          timestamp = @clock.call
          handoff_entry = {
            at: timestamp,
            assignee: assignee,
            queue: queue,
            channel: channel
          }
          handoff_entry[:note] = note unless note.nil? || note.to_s.empty?

          updated = current.merge(
            status: :acknowledged,
            acknowledged_at: current[:acknowledged_at] || timestamp,
            handed_off_at: timestamp,
            assignee: assignee || current[:assignee],
            queue: queue || current[:queue],
            channel: channel || current[:channel],
            handoff_count: current.fetch(:handoff_count, 0) + 1,
            handoff_history: (Array(current[:handoff_history]) + [handoff_entry.freeze]).freeze
          )
          updated[:note] = note unless note.nil? || note.to_s.empty?
          updated = updated.freeze

          index = @items.index(current)
          @items[index] = updated
          updated
        end

        def resolve(id, note: nil, metadata: {})
          transition(id, to: :resolved, timestamp_key: :resolved_at, note: note, metadata: metadata)
        end

        def dismiss(id, note: nil)
          transition(id, to: :dismissed, timestamp_key: :dismissed_at, note: note)
        end

        def items(status: nil)
          selected = status ? @items.select { |item| item[:status] == status.to_sym } : @items
          selected.map(&:dup)
        end

        def query
          InboxQuery.new(items)
        end

        def clear!
          @items.clear
          self
        end

        def snapshot(limit: 20)
          selected = limit ? @items.last(limit) : @items

          {
            total: @items.size,
            open: @items.count { |item| item[:status] == :open },
            acknowledged: @items.count { |item| item[:status] == :acknowledged },
            resolved: @items.count { |item| item[:status] == :resolved },
            dismissed: @items.count { |item| item[:status] == :dismissed },
            actionable: @items.count { |item| !RESOLVED_STATUSES.include?(item[:status]) },
            by_status: @items.each_with_object(Hash.new(0)) { |item, memo| memo[item[:status]] += 1 },
            by_action: @items.each_with_object(Hash.new(0)) { |item, memo| memo[item[:action]] += 1 },
            by_policy: @items.each_with_object(Hash.new(0)) do |item, memo|
              memo[item.dig(:policy, :name)] += 1 if item[:policy]
            end,
            by_lane: @items.each_with_object(Hash.new(0)) do |item, memo|
              memo[item.dig(:lane, :name)] += 1 if item[:lane]
            end,
            by_assignee: @items.each_with_object(Hash.new(0)) do |item, memo|
              memo[item[:assignee]] += 1 if item[:assignee]
            end,
            by_queue: @items.each_with_object(Hash.new(0)) do |item, memo|
              memo[item[:queue]] += 1 if item[:queue]
            end,
            by_channel: @items.each_with_object(Hash.new(0)) do |item, memo|
              memo[item[:channel]] += 1 if item[:channel]
            end,
            latest_action: @items.last&.dig(:action),
            latest_node: @items.last&.dig(:node),
            latest_policy: @items.last&.dig(:policy, :name),
            latest_lane: @items.last&.dig(:lane, :name),
            latest_assignee: @items.last&.dig(:assignee),
            latest_queue: @items.last&.dig(:queue),
            latest_channel: @items.last&.dig(:channel),
            latest_status: @items.last&.dig(:status),
            items: selected.map(&:dup)
          }
        end

        private

        def transition(id, to:, timestamp_key:, note:, metadata: {})
          current = find(id)
          return nil unless current

          updated = current.merge(
            status: to,
            timestamp_key => @clock.call
          )
          updated[:note] = note unless note.nil? || note.to_s.empty?
          metadata.each do |key, value|
            updated[key] = value unless value.nil?
          end
          updated = updated.freeze

          index = @items.index(current)
          @items[index] = updated
          updated
        end

        def session_item_attributes(session)
          return {} unless session

          {
            token: session.token,
            reply_mode: session.reply_mode,
            waiting_on: session.waiting_on,
            source_node: session.source_node,
            phase: session.phase,
            turn: session.turn,
            graph: session.graph,
            execution_id: session.execution_id
          }
        end

        def validate_handoff_target!(assignee:, queue:, channel:, id:)
          return if assignee || queue || channel

          raise ArgumentError, "orchestration item #{id.inspect} handoff requires assignee:, queue:, or channel:"
        end
      end
    end
  end
end
