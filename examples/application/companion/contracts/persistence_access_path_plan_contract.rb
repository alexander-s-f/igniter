# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :PersistenceAccessPathPlanContract,
              outputs: %i[schema_version descriptor status path_count records histories relations projections summary] do
      input :manifest
      input :storage_plan
      input :relation_type_plan

      compute :schema_version do
        1
      end

      compute :descriptor do
        {
          schema_version: 1,
          kind: :persistence_access_path_plan,
          report_only: true,
          gates_runtime: false,
          grants_capabilities: false,
          store_read_node_allowed: false,
          runtime_planner_allowed: false,
          cache_execution_allowed: false,
          source: {
            storage: :persistence_storage_plan_sketch,
            relation_types: :persistence_relation_type_plan
          },
          preserves: {
            persist: :store_t,
            history: :history_t,
            relation: :relation_t
          }
        }
      end

      compute :records, depends_on: %i[manifest storage_plan] do |manifest:, storage_plan:|
        manifest.fetch(:records).to_h do |name, _entry|
          consumers = Companion::Contracts.access_path_consumers(name, manifest)
          [name, Companion::Contracts.record_access_path_report(name, storage_plan.fetch(:records).fetch(name), consumers)]
        end
      end

      compute :histories, depends_on: %i[manifest storage_plan] do |manifest:, storage_plan:|
        manifest.fetch(:histories).to_h do |name, _entry|
          consumers = Companion::Contracts.access_path_consumers(name, manifest)
          [name, Companion::Contracts.history_access_path_report(name, storage_plan.fetch(:histories).fetch(name), consumers)]
        end
      end

      compute :relations, depends_on: [:relation_type_plan] do |relation_type_plan:|
        relation_type_plan.fetch(:relations).to_h do |name, relation|
          [name, Companion::Contracts.relation_access_path_report(name, relation)]
        end
      end

      compute :projections, depends_on: [:manifest] do |manifest:|
        manifest.fetch(:projections).to_h do |name, projection|
          [name, Companion::Contracts.projection_access_path_consumer_report(name, projection)]
        end
      end

      compute :path_count, depends_on: %i[records histories relations] do |records:, histories:, relations:|
        records.values.sum { |report| report.fetch(:paths).length } +
          histories.values.sum { |report| report.fetch(:paths).length } +
          relations.values.sum { |report| report.fetch(:paths).length }
      end

      compute :status do
        :sketched
      end

      compute :summary, depends_on: %i[status path_count records histories relations projections descriptor] do |status:, path_count:, records:, histories:, relations:, projections:, descriptor:|
        {
          status: status,
          path_count: path_count,
          record_target_count: records.length,
          history_target_count: histories.length,
          relation_target_count: relations.length,
          projection_consumer_count: projections.length,
          store_read_node_allowed: descriptor.fetch(:store_read_node_allowed),
          runtime_planner_allowed: descriptor.fetch(:runtime_planner_allowed),
          cache_execution_allowed: descriptor.fetch(:cache_execution_allowed)
        }
      end

      output :schema_version
      output :descriptor
      output :status
      output :path_count
      output :records
      output :histories
      output :relations
      output :projections
      output :summary
    end

    def self.record_access_path_report(name, storage, consumers)
      paths = [
        access_path(
          name: :all,
          source_api: :all,
          target: name,
          target_shape: :store,
          lookup_kind: :scan,
          key_binding: nil,
          filter_source: nil,
          implemented: true,
          consumer_hints: consumers
        ),
        access_path(
          name: :find,
          source_api: :find,
          target: name,
          target_shape: :store,
          lookup_kind: :key,
          key_binding: { field: storage.fetch(:primary_key_candidate), source: :argument },
          filter_source: nil,
          implemented: true,
          consumer_hints: consumers
        )
      ]
      paths.concat(storage.fetch(:scopes).map { |scope| scope_access_path(name, scope, consumers) })
      paths.concat(storage.fetch(:indexes).map { |index| index_access_path(name, index, consumers) })
      {
        capability: name,
        target_shape: :store,
        lowering: :store_t,
        storage_name_candidate: storage.fetch(:storage_name_candidate),
        paths: paths
      }
    end

    def self.history_access_path_report(name, storage, consumers)
      paths = [
        access_path(
          name: :all,
          source_api: :all,
          target: name,
          target_shape: :history,
          lookup_kind: :scan,
          key_binding: nil,
          filter_source: nil,
          implemented: true,
          consumer_hints: consumers
        ),
        access_path(
          name: :partition,
          source_api: :where,
          target: name,
          target_shape: :history,
          lookup_kind: :partition,
          key_binding: { field: storage.fetch(:partition_key_candidate), source: :criteria },
          filter_source: { source: :criteria_argument },
          implemented: true,
          consumer_hints: consumers
        ),
        access_path(
          name: :where,
          source_api: :where,
          target: name,
          target_shape: :history,
          lookup_kind: :filter,
          key_binding: nil,
          filter_source: { source: :criteria_argument },
          implemented: true,
          consumer_hints: consumers
        ),
        access_path(
          name: :count,
          source_api: :count,
          target: name,
          target_shape: :history,
          lookup_kind: :aggregate_count,
          key_binding: nil,
          filter_source: { source: :criteria_argument },
          implemented: true,
          consumer_hints: consumers
        )
      ]
      {
        capability: name,
        target_shape: :history,
        lowering: :history_t,
        storage_name_candidate: storage.fetch(:storage_name_candidate),
        append_only: storage.fetch(:append_only),
        paths: paths
      }
    end

    def self.scope_access_path(target, scope, consumers)
      access_path(
        name: :"scope_#{scope.fetch(:name)}",
        source_api: :scope,
        target: target,
        target_shape: :store,
        lookup_kind: :scope,
        key_binding: nil,
        filter_source: { source: :scope_descriptor, scope: scope.fetch(:name), where: scope.fetch(:where) },
        implemented: true,
        consumer_hints: consumers
      )
    end

    def self.index_access_path(target, index, consumers)
      access_path(
        name: :"index_#{index.fetch(:name)}",
        source_api: :future_index_lookup,
        target: target,
        target_shape: :store,
        lookup_kind: :index,
        key_binding: { fields: index.fetch(:fields), source: :index_descriptor },
        filter_source: { source: :index_descriptor, index: index.fetch(:name), unique: index.fetch(:unique) },
        implemented: false,
        consumer_hints: consumers
      )
    end

    def self.relation_access_path_report(name, relation)
      join = relation.fetch(:joins).first
      {
        relation: name,
        target_shape: :relation,
        lowering: :relation_t,
        paths: [
          access_path(
            name: :join,
            source_api: :relation_join,
            target: name,
            target_shape: :relation,
            lookup_kind: :join,
            key_binding: {
              from_field: join.fetch(:from_field),
              to_field: join.fetch(:to_field),
              compatibility: join.fetch(:compatibility)
            },
            filter_source: { source: :relation_descriptor, enforcement: relation.fetch(:enforcement) },
            implemented: false,
            consumer_hints: [relation.fetch(:name)]
          )
        ]
      }
    end

    def self.projection_access_path_consumer_report(name, projection)
      {
        projection: name,
        reads: projection.fetch(:reads, []),
        relations: projection.fetch(:relations, []),
        consumer_hint: :projection_read_model,
        reactive_consumer_hint: true
      }
    end

    def self.access_path_consumers(capability, manifest)
      manifest.fetch(:projections, {}).filter_map do |name, projection|
        name if Array(projection.fetch(:reads, [])).include?(capability)
      end
    end

    def self.access_path(name:, source_api:, target:, target_shape:, lookup_kind:, key_binding:, filter_source:, implemented:, consumer_hints:)
      {
        name: name,
        kind: :store_read_descriptor,
        source_api: source_api,
        target: target,
        target_shape: target_shape,
        lookup_kind: lookup_kind,
        key_binding: key_binding,
        filter_source: filter_source,
        mutates: false,
        boundary: :app,
        implemented: implemented,
        cache_hint: :coalesce_per_execution,
        reactive_consumer_hint: consumer_hints.any?,
        consumer_hints: consumer_hints
      }
    end
  end
end
