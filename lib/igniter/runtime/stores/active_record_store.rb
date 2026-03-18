# frozen_string_literal: true

require "json"

module Igniter
  module Runtime
    module Stores
      class ActiveRecordStore
        def initialize(record_class:, execution_id_column: :execution_id, snapshot_column: :snapshot_json)
          @record_class = record_class
          @execution_id_column = execution_id_column.to_sym
          @snapshot_column = snapshot_column.to_sym
        end

        def save(snapshot)
          execution_id = snapshot[:execution_id] || snapshot["execution_id"]
          record = @record_class.find_or_initialize_by(@execution_id_column => execution_id)
          record.public_send(:"#{@snapshot_column}=", JSON.generate(snapshot))
          record.save!
          execution_id
        end

        def fetch(execution_id)
          record = @record_class.find_by(@execution_id_column => execution_id)
          raise Igniter::ResolutionError, "No execution snapshot found for '#{execution_id}'" unless record

          JSON.parse(record.public_send(@snapshot_column))
        end

        def delete(execution_id)
          record = @record_class.find_by(@execution_id_column => execution_id)
          record&.destroy!
        end

        def exist?(execution_id)
          !!@record_class.find_by(@execution_id_column => execution_id)
        end
      end
    end
  end
end
