# frozen_string_literal: true

require_relative "companion_state"
require_relative "contract_history"
require_relative "contract_record_set"

module Companion
  module Services
    class CompanionPersistence
      RECORD_BINDINGS = {
        reminders: {
          contract_class: Contracts::Reminder,
          collection: :reminders,
          record_class: CompanionState::Reminder
        },
        trackers: {
          contract_class: Contracts::Tracker,
          collection: :trackers,
          record_class: CompanionState::Tracker
        },
        daily_focuses: {
          contract_class: Contracts::DailyFocus,
          collection: :daily_focuses,
          record_class: CompanionState::DailyFocus
        },
        countdowns: {
          contract_class: Contracts::Countdown,
          collection: :countdowns,
          record_class: CompanionState::Countdown
        },
        articles: {
          contract_class: Contracts::Article,
          collection: :articles,
          record_class: CompanionState::Article
        },
        wizard_type_specs: {
          contract_class: Contracts::WizardTypeSpec,
          collection: :wizard_type_specs,
          record_class: CompanionState::WizardTypeSpec
        }
      }.freeze

      HISTORY_BINDINGS = {
        tracker_logs: {
          contract_class: Contracts::TrackerLog,
          entries: :tracker_log_entries,
          append: :append_tracker_log
        },
        actions: {
          contract_class: Contracts::CompanionAction,
          entries: :action_entries,
          append: :append_action_event
        },
        comments: {
          contract_class: Contracts::Comment,
          entries: :comment_entries,
          append: :append_comment_event
        },
        wizard_type_spec_changes: {
          contract_class: Contracts::WizardTypeSpecChange,
          entries: :wizard_type_spec_change_entries,
          append: :append_wizard_type_spec_change
        },
        materializer_attempts: {
          contract_class: Contracts::MaterializerAttempt,
          entries: :materializer_attempt_entries,
          append: :append_materializer_attempt
        }
      }.freeze

      PROJECTION_BINDINGS = {
        tracker_read_model: Contracts::TrackerReadModelContract,
        countdown_read_model: Contracts::CountdownReadModelContract,
        activity_feed: Contracts::ActivityFeedContract,
        materializer_audit_trail: Contracts::MaterializerAuditTrailContract
      }.freeze

      PROJECTION_INPUT_BINDINGS = {
        tracker_read_model: {
          reads: %i[trackers tracker_logs],
          relations: %i[tracker_logs_by_tracker]
        },
        countdown_read_model: {
          reads: %i[countdowns],
          relations: []
        },
        activity_feed: {
          reads: %i[actions],
          relations: []
        },
        materializer_audit_trail: {
          reads: %i[materializer_attempts],
          relations: []
        }
      }.freeze

      COMMAND_BINDINGS = {
        reminder_commands: {
          contract_class: Contracts::ReminderContract,
          commands: %i[create complete],
          operations: %i[record_append record_update none]
        },
        countdown_commands: {
          contract_class: Contracts::CountdownContract,
          commands: %i[create],
          operations: %i[record_append none]
        },
        tracker_log_commands: {
          contract_class: Contracts::TrackerLogContract,
          commands: %i[append],
          operations: %i[history_append none]
        },
        materializer_attempt_commands: {
          contract_class: Contracts::MaterializerAttemptContract,
          commands: %i[record_blocked],
          operations: %i[history_append none]
        }
      }.freeze

      RELATION_BINDINGS = {
        tracker_logs_by_tracker: {
          kind: :event_owner,
          from: :trackers,
          to: :tracker_logs,
          join: { id: :tracker_id },
          cardinality: :one_to_many,
          integrity: :validate_on_append,
          consistency: :local,
          projection: :tracker_read_model,
          enforced: false
        },
        comments_by_article: {
          kind: :event_owner,
          from: :articles,
          to: :comments,
          join: { id: :article_id },
          cardinality: :one_to_many,
          integrity: :validate_on_append,
          consistency: :local,
          projection: nil,
          enforced: false
        }
      }.freeze

      def initialize(state:)
        @state = state
      end

      def capability_names
        capability_manifest.keys
      end

      def capability_manifest
        record_manifest
          .merge(history_manifest)
          .merge(projection_manifest)
      end

      def validation_errors
        record_validation_errors + history_validation_errors + projection_validation_errors + relation_validation_errors
      end

      def valid?
        validation_errors.empty?
      end

      def relation_warnings
        RELATION_BINDINGS.to_h do |name, relation|
          [name, relation_health_warnings(relation)]
        end
      end

      def relation_health
        Contracts::PersistenceRelationHealthContract.evaluate(
          relation_manifest: relation_manifest,
          relation_warnings: relation_warnings
        )
      end

      def materialization_plan
        Contracts::DurableTypeMaterializationContract.evaluate(type_spec: article_comment_type_spec)
      end

      def materialization_parity
        Contracts::StaticMaterializationParityContract.evaluate(
          materialization_plan: materialization_plan,
          manifest_snapshot: manifest_snapshot
        )
      end

      def wizard_type_spec_export
        Contracts::WizardTypeSpecExportContract.evaluate(
          specs: wizard_type_specs.all.map(&:to_h),
          spec_history: wizard_type_spec_changes.all
        )
      end

      def wizard_type_spec_migration_plan
        Contracts::WizardTypeSpecMigrationPlanContract.evaluate(
          spec_history: wizard_type_spec_changes.all
        )
      end

      def infrastructure_loop_health
        Contracts::InfrastructureLoopHealthContract.evaluate(
          readiness: readiness,
          manifest_summary: manifest_snapshot.fetch(:summary),
          materialization_plan: materialization_plan,
          materialization_parity: materialization_parity,
          migration_plan: wizard_type_spec_migration_plan
        )
      end

      def materializer_gate(approved: false)
        Contracts::MaterializerGateContract.evaluate(
          infrastructure_loop_health: infrastructure_loop_health,
          materialization_plan: materialization_plan,
          approved: approved
        )
      end

      def materializer_preflight
        Contracts::MaterializerPreflightContract.evaluate(
          infrastructure_loop_health: infrastructure_loop_health,
          materialization_parity: materialization_parity,
          migration_plan: wizard_type_spec_migration_plan,
          materializer_gate: materializer_gate
        )
      end

      def materializer_runbook
        Contracts::MaterializerRunbookContract.evaluate(
          materializer_preflight: materializer_preflight
        )
      end

      def materializer_receipt
        Contracts::MaterializerReceiptContract.evaluate(
          materializer_runbook: materializer_runbook
        )
      end

      def materializer_attempt_command
        Contracts::MaterializerAttemptContract.evaluate(
          receipt: materializer_receipt
        )
      end

      def materializer_audit_trail
        Contracts::MaterializerAuditTrailContract.evaluate(
          attempts: materializer_attempts.all
        )
      end

      def materializer_supervision
        Contracts::MaterializerSupervisionContract.evaluate(
          materializer_gate: materializer_gate,
          materializer_preflight: materializer_preflight,
          materializer_runbook: materializer_runbook,
          materializer_receipt: materializer_receipt,
          materializer_attempt_command: materializer_attempt_command,
          materializer_audit_trail: materializer_audit_trail
        )
      end

      def materializer_approval_policy(approved_by: nil, approved_capabilities: [])
        Contracts::MaterializerApprovalPolicyContract.evaluate(
          approval_request: materializer_gate.fetch(:approval_request),
          approved_by: approved_by,
          approved_capabilities: approved_capabilities
        )
      end

      def readiness
        Contracts::PersistenceReadinessContract.evaluate(
          capability_manifest: capability_manifest,
          relation_manifest: relation_manifest,
          relation_health: relation_health,
          validation_errors: validation_errors
        )
      end

      def manifest_snapshot
        Contracts::PersistenceManifestContract.evaluate(
          capability_manifest: capability_manifest,
          operation_manifest: operation_manifest
        )
      end

      def reminders
        record(:reminders)
      end

      def trackers
        record(:trackers)
      end

      def daily_focuses
        record(:daily_focuses)
      end

      def daily_focus_title_for(date)
        daily_focuses.find(date)&.title
      end

      def countdowns
        record(:countdowns)
      end

      def articles
        record(:articles)
      end

      def wizard_type_specs
        record(:wizard_type_specs)
      end

      def tracker_logs
        history(:tracker_logs)
      end

      def comments
        history(:comments)
      end

      def wizard_type_spec_changes
        history(:wizard_type_spec_changes)
      end

      def materializer_attempts
        history(:materializer_attempts)
      end

      def actions
        history(:actions)
      end

      def tracker_read_model_for(date)
        Contracts::TrackerReadModelContract.evaluate(
          trackers: trackers.all,
          tracker_logs: tracker_logs.all,
          date: date
        )
      end

      def countdown_read_model_for(date)
        Contracts::CountdownReadModelContract.evaluate(
          countdowns: countdowns.all,
          date: date
        )
      end

      def activity_feed_for(recent_limit)
        Contracts::ActivityFeedContract.evaluate(
          actions: actions.all,
          recent_limit: recent_limit
        )
      end

      private

      attr_reader :state

      def record(name)
        binding = RECORD_BINDINGS.fetch(name)
        ContractRecordSet.new(
          contract_class: binding.fetch(:contract_class),
          collection: state.public_send(binding.fetch(:collection)),
          record_class: binding.fetch(:record_class)
        )
      end

      def history(name)
        binding = HISTORY_BINDINGS.fetch(name)
        ContractHistory.new(
          contract_class: binding.fetch(:contract_class),
          entries: method(binding.fetch(:entries)),
          append: method(binding.fetch(:append))
        )
      end

      def record_manifest
        RECORD_BINDINGS.keys.to_h do |name|
          [name, { kind: :record, contract: RECORD_BINDINGS.fetch(name).fetch(:contract_class) }]
        end
      end

      def history_manifest
        HISTORY_BINDINGS.keys.to_h do |name|
          [name, { kind: :history, contract: HISTORY_BINDINGS.fetch(name).fetch(:contract_class) }]
        end
      end

      def projection_manifest
        PROJECTION_BINDINGS.keys.to_h do |name|
          [name, { kind: :projection, contract: PROJECTION_BINDINGS.fetch(name) }.merge(PROJECTION_INPUT_BINDINGS.fetch(name))]
        end
      end

      def operation_manifest
        {
          records: record_operation_manifest,
          histories: history_operation_manifest,
          projections: projection_operation_manifest,
          commands: command_operation_manifest,
          relations: relation_manifest
        }
      end

      def record_operation_manifest
        RECORD_BINDINGS.keys.to_h do |name|
          api = record(name).api_manifest
          [name, api.merge(kind: :record)]
        end
      end

      def history_operation_manifest
        HISTORY_BINDINGS.keys.to_h do |name|
          api = history(name).api_manifest
          [name, api.merge(kind: :history)]
        end
      end

      def projection_operation_manifest
        PROJECTION_BINDINGS.keys.to_h do |name|
          [name, { kind: :projection, contract: PROJECTION_BINDINGS.fetch(name) }.merge(PROJECTION_INPUT_BINDINGS.fetch(name))]
        end
      end

      def command_operation_manifest
        COMMAND_BINDINGS.transform_values do |binding|
          {
            kind: :command,
            contract: binding.fetch(:contract_class),
            commands: binding.fetch(:commands),
            operations: binding.fetch(:operations)
          }
        end
      end

      def relation_manifest
        RELATION_BINDINGS
      end

      def record_validation_errors
        RECORD_BINDINGS.flat_map do |name, binding|
          manifest = binding.fetch(:contract_class).persistence_manifest
          fields = manifest.fetch(:fields).map { |field| field.fetch(:name).to_sym }
          members = binding.fetch(:record_class).members.map(&:to_sym)
          errors = []
          errors << "#{name}: missing persist declaration" unless manifest.fetch(:persist)
          missing_fields = fields - members
          errors << "#{name}: record class missing fields #{missing_fields.join(",")}" unless missing_fields.empty?
          invalid_indexes = manifest.fetch(:indexes, []).map { |index| index.fetch(:name).to_sym } - fields
          errors << "#{name}: indexes reference missing fields #{invalid_indexes.join(",")}" unless invalid_indexes.empty?
          errors.concat(command_metadata_errors(name, manifest.fetch(:commands, []), fields))
          errors
        end
      end

      def command_metadata_errors(name, commands, fields)
        commands.flat_map do |command|
          attributes = command.fetch(:attributes)
          operation = attributes.fetch(:operation, nil)&.to_sym
          changes = attributes.fetch(:changes, {})
          errors = []
          errors << "#{name}: command #{command.fetch(:name)} has unsupported operation #{operation.inspect}" unless %i[record_append record_update none].include?(operation)
          missing_changes = changes.keys.map(&:to_sym) - fields
          errors << "#{name}: command #{command.fetch(:name)} changes missing fields #{missing_changes.join(",")}" unless missing_changes.empty?
          errors
        end
      end

      def history_validation_errors
        HISTORY_BINDINGS.flat_map do |name, binding|
          manifest = binding.fetch(:contract_class).persistence_manifest
          errors = []
          errors << "#{name}: missing history declaration" unless manifest.fetch(:history)
          errors << "#{name}: missing entries binding" unless respond_to?(binding.fetch(:entries), true)
          errors << "#{name}: missing append binding" unless respond_to?(binding.fetch(:append), true)
          errors
        end
      end

      def projection_validation_errors
        PROJECTION_BINDINGS.flat_map do |name, contract_class|
          contract_class.compile
          projection_input_errors(name)
        rescue StandardError => e
          ["#{name}: projection contract failed to compile #{e.class}"]
        end
      end

      def projection_input_errors(name)
        binding = PROJECTION_INPUT_BINDINGS.fetch(name)
        reads = binding.fetch(:reads)
        relations = binding.fetch(:relations)
        errors = []
        missing_reads = reads - capability_manifest.keys
        errors << "#{name}: projection reads missing capabilities #{missing_reads.join(",")}" unless missing_reads.empty?
        missing_relations = relations - relation_manifest.keys
        errors << "#{name}: projection uses missing relations #{missing_relations.join(",")}" unless missing_relations.empty?
        mismatched_relations = relations.reject { |relation| relation_manifest.fetch(relation).fetch(:projection) == name }
        errors << "#{name}: projection relation mismatch #{mismatched_relations.join(",")}" unless mismatched_relations.empty?
        errors
      end

      def relation_validation_errors
        RELATION_BINDINGS.flat_map do |name, relation|
          errors = []
          from = relation.fetch(:from)
          to = relation.fetch(:to)
          join = relation.fetch(:join)
          projection = relation.fetch(:projection, nil)

          errors << "#{name}: from capability missing #{from}" unless capability_manifest.key?(from)
          errors << "#{name}: to capability missing #{to}" unless capability_manifest.key?(to)
          errors.concat(relation_kind_errors(name, relation)) if capability_manifest.key?(from) && capability_manifest.key?(to)
          errors.concat(relation_join_errors(name, from, to, join)) if capability_manifest.key?(from) && capability_manifest.key?(to)
          errors << "#{name}: projection missing #{projection}" if projection && !PROJECTION_BINDINGS.key?(projection)
          errors << "#{name}: enforcement must remain false" if relation.fetch(:enforced)
          errors
        end
      end

      def relation_kind_errors(name, relation)
        from_kind = capability_manifest.fetch(relation.fetch(:from)).fetch(:kind)
        to_kind = capability_manifest.fetch(relation.fetch(:to)).fetch(:kind)
        return [] unless relation.fetch(:kind) == :event_owner

        errors = []
        errors << "#{name}: event_owner from must be record" unless from_kind == :record
        errors << "#{name}: event_owner to must be history" unless to_kind == :history
        errors
      end

      def relation_join_errors(name, from, to, join)
        from_fields = capability_fields(from)
        to_fields = capability_fields(to)
        missing_from = join.keys.map(&:to_sym) - from_fields
        missing_to = join.values.map(&:to_sym) - to_fields
        errors = []
        errors << "#{name}: join source fields missing #{missing_from.join(",")}" unless missing_from.empty?
        errors << "#{name}: join target fields missing #{missing_to.join(",")}" unless missing_to.empty?
        errors
      end

      def capability_fields(name)
        binding = RECORD_BINDINGS[name] || HISTORY_BINDINGS[name]
        binding.fetch(:contract_class).persistence_manifest.fetch(:fields).map { |field| field.fetch(:name).to_sym }
      end

      def relation_health_warnings(relation)
        join = relation.fetch(:join)
        source_field, target_field = join.first
        source_values = record(relation.fetch(:from)).all.map { |entry| relation_value(entry, source_field) }.map(&:to_s)
        orphan_values = history(relation.fetch(:to))
                        .all
                        .map { |entry| relation_value(entry, target_field) }
                        .map(&:to_s)
                        .reject { |value| source_values.include?(value) }
                        .uniq
        return [] if orphan_values.empty?

        [
          {
            kind: :missing_source,
            from: relation.fetch(:from),
            to: relation.fetch(:to),
            values: orphan_values,
            message: "#{relation.fetch(:to)} references missing #{relation.fetch(:from)} #{orphan_values.join(",")}"
          }
        ]
      end

      def relation_value(entry, field)
        return entry.fetch(field.to_sym) if entry.respond_to?(:fetch)

        entry.public_send(field)
      end

      def tracker_log_entries
        state.tracker_log_entries
      end

      def append_tracker_log(event)
        state.append_tracker_log(event)
      end

      def action_entries
        state.action_entries
      end

      def append_action_event(event)
        state.append_action_event(event)
      end

      def comment_entries
        state.comment_entries
      end

      def append_comment_event(event)
        state.append_comment_event(event)
      end

      def wizard_type_spec_change_entries
        state.wizard_type_spec_change_entries
      end

      def append_wizard_type_spec_change(event)
        state.append_wizard_type_spec_change(event)
      end

      def materializer_attempt_entries
        state.materializer_attempt_entries
      end

      def append_materializer_attempt(event)
        state.append_materializer_attempt(event)
      end

      def article_comment_type_spec
        wizard_type_specs.find("article-comment")&.spec || CompanionState.article_comment_type_spec
      end
    end
  end
end
