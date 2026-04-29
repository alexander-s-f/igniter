# frozen_string_literal: true

require "date"

module Companion
  module Services
    class CompanionState
      Reminder = Struct.new(:id, :title, :due, :status, keyword_init: true)
      Tracker = Struct.new(:id, :name, :template, :unit, keyword_init: true)
      TrackerSnapshot = Struct.new(:id, :name, :template, :unit, :log_entries, keyword_init: true) do
        def to_h
          super.merge(entries: log_entries)
        end
      end
      TrackerLog = Struct.new(:tracker_id, :date, :value, keyword_init: true)
      DailyFocus = Struct.new(:date, :title, keyword_init: true)
      Countdown = Struct.new(:id, :title, :target_date, keyword_init: true)
      CountdownSnapshot = Struct.new(:id, :title, :target_date, :days_remaining, keyword_init: true)
      Article = Struct.new(:id, :title, :body, :created_at, :status, keyword_init: true)
      Comment = Struct.new(:index, :article_id, :body, :created_at, keyword_init: true)
      WizardTypeSpec = Struct.new(:id, :contract, :spec, keyword_init: true)
      WizardTypeSpecChange = Struct.new(:index, :spec_id, :contract, :change_kind, :spec, :created_at, keyword_init: true)
      MaterializerAttempt = Struct.new(
        :index, :kind, :status, :approval_request, :blocked_capabilities,
        :blocked_step_count, :executed, :review_only,
        keyword_init: true
      )
      Action = Struct.new(:index, :kind, :subject_id, :status, keyword_init: true)

      attr_accessor :live_summary
      attr_reader :reminders, :trackers, :tracker_logs, :daily_focuses, :countdowns, :articles,
                  :comments, :wizard_type_specs, :wizard_type_spec_changes, :materializer_attempts,
                  :actions, :next_action_index, :next_comment_index,
                  :next_wizard_type_spec_change_index, :next_materializer_attempt_index

      def self.seeded
        new.tap(&:seed)
      end

      def self.from_h(state)
        new.tap { |record| record.restore(state) }
      end

      def self.article_comment_type_spec
        {
          schema_version: 1,
          id: "article-comment",
          name: :Article,
          capability: :articles,
          kind: :record,
          storage: { shape: :store, key: :id, adapter: :sqlite },
          persist: { key: :id, adapter: :sqlite },
          fields: [
            { name: :id, type: :string, required: true },
            { name: :title, type: :string, required: true },
            { name: :body, type: :string },
            { name: :created_at, type: :datetime },
            { name: :status, type: :enum, values: %i[draft published archived], default: :draft }
          ],
          indexes: [
            { name: :status, fields: [:status] }
          ],
          scopes: [
            { name: :drafts, where: { status: :draft } },
            { name: :published, where: { status: :published } }
          ],
          commands: [
            { name: :publish, operation: :record_update, changes: { status: :published } }
          ],
          histories: [
            {
              name: :Comment,
              capability: :comments,
              storage: { shape: :history, key: :index, adapter: :sqlite },
              history: { key: :index, adapter: :sqlite },
              fields: [
                { name: :index, type: :integer },
                { name: :article_id, type: :string },
                { name: :body, type: :string },
                { name: :created_at, type: :datetime }
              ],
              relation: {
                name: :comments_by_article,
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
            }
          ],
          metadata: { source: :static_sync, materialized: true }
        }
      end

      def initialize
        @actions = []
        @next_action_index = 0
        @reminders = []
        @trackers = []
        @tracker_logs = []
        @daily_focuses = []
        @countdowns = []
        @articles = []
        @comments = []
        @wizard_type_specs = []
        @wizard_type_spec_changes = []
        @materializer_attempts = []
        @live_summary = nil
        @next_comment_index = 0
        @next_wizard_type_spec_change_index = 0
        @next_materializer_attempt_index = 0
      end

      def seed
        reminders << Reminder.new(id: "morning-water", title: "Drink water after wake-up", due: "morning", status: :open)
        reminders << Reminder.new(id: "evening-review", title: "Review the day", due: "evening", status: :open)
        trackers << Tracker.new(id: "sleep", name: "Sleep", template: :sleep, unit: "hours")
        trackers << Tracker.new(id: "training", name: "Training", template: :workout, unit: "minutes")
        countdowns << Countdown.new(id: "new-year", title: "New Year", target_date: "#{Date.today.year + 1}-01-01")
        articles << Article.new(
          id: "welcome-note",
          title: "Welcome note",
          body: "Static contract proof for wizard-shaped durable types.",
          created_at: Date.today.iso8601,
          status: :draft
        )
        append_comment_event(article_id: "welcome-note", body: "First comment from static materialization.", created_at: Date.today.iso8601)
        wizard_type_specs << WizardTypeSpec.new(
          id: "article-comment",
          contract: "Article",
          spec: self.class.article_comment_type_spec
        )
        append_wizard_type_spec_change(
          spec_id: "article-comment",
          contract: "Article",
          change_kind: :seeded_static_sync,
          spec: self.class.article_comment_type_spec,
          created_at: Date.today.iso8601
        )
        record_action(kind: :companion_seeded, subject_id: :companion, status: :ready)
      end

      def restore(state)
        @reminders = Array(state.fetch(:reminders)).map do |entry|
          payload = symbolize(entry)
          Reminder.new(
            id: payload.fetch(:id),
            title: payload.fetch(:title),
            due: payload.fetch(:due),
            status: payload.fetch(:status).to_sym
          )
        end
        nested_logs = []
        @trackers = Array(state.fetch(:trackers)).map do |entry|
          payload = symbolize(entry)
          nested_logs.concat(
            Array(payload.fetch(:entries, [])).map do |tracker_entry|
              symbolize(tracker_entry).merge(tracker_id: payload.fetch(:id))
            end
          )
          Tracker.new(
            id: payload.fetch(:id),
            name: payload.fetch(:name),
            template: payload.fetch(:template).to_sym,
            unit: payload.fetch(:unit)
          )
        end
        @tracker_logs = Array(state.fetch(:tracker_logs, nested_logs)).map do |entry|
          payload = symbolize(entry)
          TrackerLog.new(
            tracker_id: payload.fetch(:tracker_id),
            date: payload.fetch(:date),
            value: payload.fetch(:value)
          )
        end
        @daily_focuses = Array(state.fetch(:daily_focuses, legacy_daily_focus(state))).map do |entry|
          payload = symbolize(entry)
          DailyFocus.new(
            date: payload.fetch(:date),
            title: payload.fetch(:title)
          )
        end
        @countdowns = Array(state.fetch(:countdowns)).map do |entry|
          Countdown.new(**symbolize(entry))
        end
        @articles = Array(state.fetch(:articles, [])).map do |entry|
          payload = symbolize(entry)
          Article.new(
            id: payload.fetch(:id),
            title: payload.fetch(:title),
            body: payload.fetch(:body),
            created_at: payload.fetch(:created_at),
            status: payload.fetch(:status).to_sym
          )
        end
        @comments = Array(state.fetch(:comments, [])).map do |entry|
          payload = symbolize(entry)
          Comment.new(
            index: payload.fetch(:index),
            article_id: payload.fetch(:article_id),
            body: payload.fetch(:body),
            created_at: payload.fetch(:created_at)
          )
        end
        @wizard_type_specs = Array(state.fetch(:wizard_type_specs, [])).map do |entry|
          payload = symbolize(entry)
          WizardTypeSpec.new(
            id: payload.fetch(:id),
            contract: payload.fetch(:contract),
            spec: payload.fetch(:spec)
          )
        end
        @wizard_type_spec_changes = Array(state.fetch(:wizard_type_spec_changes, [])).map do |entry|
          payload = symbolize(entry)
          WizardTypeSpecChange.new(
            index: payload.fetch(:index),
            spec_id: payload.fetch(:spec_id),
            contract: payload.fetch(:contract),
            change_kind: payload.fetch(:change_kind).to_sym,
            spec: payload.fetch(:spec),
            created_at: payload.fetch(:created_at)
          )
        end
        @materializer_attempts = Array(state.fetch(:materializer_attempts, [])).map do |entry|
          payload = symbolize(entry)
          MaterializerAttempt.new(
            index: payload.fetch(:index),
            kind: payload.fetch(:kind).to_sym,
            status: payload.fetch(:status).to_sym,
            approval_request: payload.fetch(:approval_request),
            blocked_capabilities: payload.fetch(:blocked_capabilities),
            blocked_step_count: payload.fetch(:blocked_step_count),
            executed: payload.fetch(:executed),
            review_only: payload.fetch(:review_only)
          )
        end
        @actions = Array(state.fetch(:actions)).map do |entry|
          payload = symbolize(entry)
          Action.new(
            index: payload.fetch(:index),
            kind: payload.fetch(:kind).to_sym,
            subject_id: payload.fetch(:subject_id),
            status: payload.fetch(:status).to_sym
          )
        end
        @live_summary = state[:live_summary]
        @next_action_index = state.fetch(:next_action_index, actions.map(&:index).max.to_i + 1)
        @next_comment_index = state.fetch(:next_comment_index, comments.map(&:index).max.to_i + 1)
        @next_wizard_type_spec_change_index = state.fetch(
          :next_wizard_type_spec_change_index,
          wizard_type_spec_changes.map(&:index).max.to_i + 1
        )
        @next_materializer_attempt_index = state.fetch(
          :next_materializer_attempt_index,
          materializer_attempts.map(&:index).max.to_i + 1
        )
        ensure_default_wizard_type_specs
      end

      def to_h
        {
          reminders: reminders.map(&:to_h),
          trackers: trackers.map(&:to_h),
          tracker_logs: tracker_logs.map(&:to_h),
          daily_focuses: daily_focuses.map(&:to_h),
          countdowns: countdowns.map(&:to_h),
          articles: articles.map(&:to_h),
          comments: comments.map(&:to_h),
          wizard_type_specs: wizard_type_specs.map(&:to_h),
          wizard_type_spec_changes: wizard_type_spec_changes.map(&:to_h),
          materializer_attempts: materializer_attempts.map(&:to_h),
          actions: actions.map(&:to_h),
          daily_focus_title: daily_focus_title,
          live_summary: live_summary,
          next_action_index: next_action_index,
          next_comment_index: next_comment_index,
          next_wizard_type_spec_change_index: next_wizard_type_spec_change_index,
          next_materializer_attempt_index: next_materializer_attempt_index
        }
      end

      def base_payload(live_ready:, tracker_read_model:, open_reminders:, next_reminder_title:)
        {
          open_reminders: open_reminders,
          tracker_logs_today: tracker_read_model.fetch(:logs_today),
          next_reminder_title: next_reminder_title,
          daily_focus_title: daily_focus_title,
          sleep_hours_today: tracker_read_model.fetch(:sleep_hours_today),
          training_minutes_today: tracker_read_model.fetch(:training_minutes_today),
          live_ready: live_ready
        }
      end

      def daily_focus_title(date = Date.today.iso8601)
        daily_focuses.find { |entry| entry.date == date.to_s }&.title
      end

      def tracker_log_entries
        tracker_logs.map(&:to_h)
      end

      def append_tracker_log(event)
        return nil unless trackers.any? { |tracker| tracker.id == event.fetch(:tracker_id).to_s }

        TrackerLog.new(
          tracker_id: event.fetch(:tracker_id).to_s,
          date: event.fetch(:date),
          value: event.fetch(:value)
        ).tap { |entry| tracker_logs << entry }
      end

      def record_action(kind:, subject_id:, status:)
        append_action_event(index: next_action_index, kind: kind, subject_id: subject_id, status: status)
      end

      def action_entries
        actions.map(&:to_h)
      end

      def comment_entries
        comments.map(&:to_h)
      end

      def append_comment_event(event)
        comment = Comment.new(
          index: event.fetch(:index, next_comment_index),
          article_id: event.fetch(:article_id),
          body: event.fetch(:body),
          created_at: event.fetch(:created_at)
        )
        comments << comment
        @next_comment_index = [next_comment_index, comment.index + 1].max
        comment.to_h
      end

      def wizard_type_spec_change_entries
        wizard_type_spec_changes.map(&:to_h)
      end

      def append_wizard_type_spec_change(event)
        change = WizardTypeSpecChange.new(
          index: event.fetch(:index, next_wizard_type_spec_change_index),
          spec_id: event.fetch(:spec_id),
          contract: event.fetch(:contract),
          change_kind: event.fetch(:change_kind).to_sym,
          spec: event.fetch(:spec),
          created_at: event.fetch(:created_at)
        )
        wizard_type_spec_changes << change
        @next_wizard_type_spec_change_index = [next_wizard_type_spec_change_index, change.index + 1].max
        change.to_h
      end

      def materializer_attempt_entries
        materializer_attempts.map(&:to_h)
      end

      def append_materializer_attempt(event)
        attempt = MaterializerAttempt.new(
          index: event.fetch(:index, nil) || next_materializer_attempt_index,
          kind: event.fetch(:kind).to_sym,
          status: event.fetch(:status).to_sym,
          approval_request: event.fetch(:approval_request),
          blocked_capabilities: event.fetch(:blocked_capabilities),
          blocked_step_count: event.fetch(:blocked_step_count),
          executed: event.fetch(:executed),
          review_only: event.fetch(:review_only)
        )
        materializer_attempts << attempt
        @next_materializer_attempt_index = [next_materializer_attempt_index, attempt.index + 1].max
        attempt.to_h
      end

      def append_action_event(event)
        action = Action.new(
          index: event.fetch(:index),
          kind: event.fetch(:kind).to_sym,
          subject_id: event.fetch(:subject_id),
          status: event.fetch(:status).to_sym
        )
        actions << action
        @next_action_index = [next_action_index, action.index + 1].max
        action.to_h
      end

      def next_id_for(title, collection)
        base = title.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-|-+\z/, "")
        base = "item" if base.empty?
        candidate = base
        suffix = 2
        while collection.any? { |entry| entry.id == candidate }
          candidate = "#{base}-#{suffix}"
          suffix += 1
        end
        candidate
      end

      private

      def ensure_default_wizard_type_specs
        existing = wizard_type_specs.find { |entry| entry.id == "article-comment" }
        canonical = self.class.article_comment_type_spec

        if existing
          existing.spec = canonical unless existing.spec.fetch(:schema_version, nil)
        else
          existing = WizardTypeSpec.new(
            id: "article-comment",
            contract: "Article",
            spec: canonical
          )
          wizard_type_specs << existing
        end

        canonical_change_exists = wizard_type_spec_changes.any? do |entry|
          entry.spec_id == "article-comment" && entry.spec.fetch(:schema_version, nil) == 1
        end
        return if canonical_change_exists

        append_wizard_type_spec_change(
          spec_id: "article-comment",
          contract: "Article",
          change_kind: :backfilled_static_sync,
          spec: existing.spec,
          created_at: Date.today.iso8601
        )
      end

      def legacy_daily_focus(state)
        title = state[:daily_focus_title]
        title.to_s.empty? ? [] : [{ date: Date.today.iso8601, title: title }]
      end

      def symbolize(value)
        value.transform_keys(&:to_sym)
      end
    end
  end
end
