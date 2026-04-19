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
            node: action[:node],
            interaction: action[:interaction],
            reason: action[:reason],
            guidance: action[:guidance],
            attention_required: action[:attention_required],
            resumable: action[:resumable],
            source: source.to_sym,
            graph: graph,
            execution_id: execution_id,
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
            latest_action: @items.last&.dig(:action),
            latest_node: @items.last&.dig(:node),
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
      end
    end
  end
end
