# frozen_string_literal: true

require "fileutils"
require "json"
require "stringio"
require "tmpdir"
require "uri"

require_relative "app"

module Companion
  module Runtime
    module_function

    def call(argv, env: ENV, out: $stdout)
      return server(env: env, out: out) if argv.first == "server"

      env.delete("OPENAI_API_KEY") unless env["COMPANION_LIVE"] == "1"
      db_path = File.join(Dir.tmpdir, "igniter_companion_poc_#{Process.pid}.sqlite3")
      FileUtils.rm_f(db_path)
      hub = build_local_hub_fixture
      config = Companion.default_configuration(store_path: db_path)
      config.hub(catalog_path: hub.fetch(:catalog_path), install_root: hub.fetch(:install_root))
      app = Companion.build(config: config)
      run_smoke(app, config: config, db_path: db_path, out: out)
    end

    def server(env:, out:)
      require "webrick"

      app = Companion.build(
        config: Companion.default_configuration(
          store_path: env.fetch("COMPANION_DB", File.join(Companion::APP_ROOT, "tmp", "companion.sqlite3"))
        )
      )
      server = WEBrick::HTTPServer.new(
        Port: Integer(env.fetch("PORT", "9298")),
        BindAddress: "127.0.0.1",
        AccessLog: [],
        Logger: WEBrick::Log.new(File::NULL)
      )
      server.mount_proc("/") do |request, response|
        status, headers, body = app.call(
          "REQUEST_METHOD" => request.request_method,
          "PATH_INFO" => request.path,
          "QUERY_STRING" => request.query_string.to_s,
          "rack.input" => StringIO.new(request.body.to_s)
        )
        response.status = status
        headers.each { |key, value| response[key] = value }
        response.body = body.join
      end
      trap("INT") { server.shutdown }
      out.puts "companion_poc_url=http://127.0.0.1:#{server.config[:Port]}/"
      server.start
    end

    def run_smoke(app, config:, db_path:, out:)
      store = app.service(:companion)
      initial = store.snapshot

      create_status, create_headers = post(app, "/reminders/create", title: "Stretch for five minutes")
      created_status = get_status(app, create_headers.fetch("location"))
      blank_reminder_status, blank_reminder_headers = post(app, "/reminders/create", title: " ")
      blank_reminder_result_status = get_status(app, blank_reminder_headers.fetch("location"))
      log_status, log_headers = post(app, "/trackers/sleep/log", value: "7.5")
      logged_status = get_status(app, log_headers.fetch("location"))
      blank_tracker_status, blank_tracker_headers = post(app, "/trackers/sleep/log", value: " ")
      blank_tracker_result_status = get_status(app, blank_tracker_headers.fetch("location"))
      focus_status, focus_headers = post(app, "/today/focus", title: "Draft the launch note")
      focused_status = get_status(app, focus_headers.fetch("location"))
      countdown_status, countdown_headers = post(app, "/countdowns/create", title: "Launch day", target_date: "2026-05-15")
      countdown_created_status = get_status(app, countdown_headers.fetch("location"))
      blank_countdown_status, blank_countdown_headers = post(app, "/countdowns/create", title: " ", target_date: " ")
      blank_countdown_result_status = get_status(app, blank_countdown_headers.fetch("location"))
      complete_status, complete_headers = post(app, "/reminders/morning-water/complete")
      completed_status = get_status(app, complete_headers.fetch("location"))

      events_status, _events_headers, events_body = app.call(rack_env("GET", "/events"))
      setup_status, _setup_headers, setup_body = app.call(rack_env("GET", "/setup"))
      manifest_status, _manifest_headers, manifest_body = app.call(rack_env("GET", "/setup/manifest"))
      hub_status, _hub_headers, hub_body = app.call(rack_env("GET", "/hub"))
      html_status, _html_headers, html_body = app.call(rack_env("GET", "/"))
      hub_install_status, hub_install_headers = post(app, "/hub/horoscope/install")
      hub_installed_status = get_status(app, hub_install_headers.fetch("location"))
      hub_installed_file = File.exist?(File.join(config.hub_install_root, "horoscope", "contracts", "daily_horoscope.rb"))
      _installed_html_status, _installed_html_headers, installed_html_body = app.call(rack_env("GET", "/"))
      final = store.snapshot
      persisted = Companion.build(config: config).service(:companion).snapshot
      html = html_body.join
      events = events_body.join
      setup = setup_body.join
      manifest = manifest_body.join
      hub_catalog = hub_body.join
      installed_html = installed_html_body.join

      out.puts "companion_poc_live_ready=#{initial.live_ready}"
      out.puts "companion_poc_open_reminders=#{final.open_reminders}"
      out.puts "companion_poc_tracker_logs=#{final.tracker_logs_today}"
      out.puts "companion_poc_countdowns=#{final.countdown_count}"
      out.puts "companion_poc_body_battery=#{final.body_battery.fetch(:score).positive?}"
      out.puts "companion_poc_daily_plan=#{final.daily_plan.fetch(:block_minutes).positive?}"
      out.puts "companion_poc_store_backend=#{config.store_backend}"
      out.puts "companion_poc_store_file=#{File.exist?(db_path)}"
      out.puts "companion_poc_sqlite_persisted=#{persisted.tracker_logs_today == final.tracker_logs_today}"
      out.puts "companion_poc_summary=#{final.daily_summary.fetch(:summary).include?("tracker logs")}"
      out.puts "companion_poc_create_status=#{create_status}"
      out.puts "companion_poc_created_status=#{created_status}"
      out.puts "companion_poc_blank_reminder_status=#{blank_reminder_status}"
      out.puts "companion_poc_blank_reminder_result_status=#{blank_reminder_result_status}"
      out.puts "companion_poc_log_status=#{log_status}"
      out.puts "companion_poc_logged_status=#{logged_status}"
      out.puts "companion_poc_blank_tracker_status=#{blank_tracker_status}"
      out.puts "companion_poc_blank_tracker_result_status=#{blank_tracker_result_status}"
      out.puts "companion_poc_focus_status=#{focus_status}"
      out.puts "companion_poc_focused_status=#{focused_status}"
      out.puts "companion_poc_countdown_status=#{countdown_status}"
      out.puts "companion_poc_countdown_created_status=#{countdown_created_status}"
      out.puts "companion_poc_blank_countdown_status=#{blank_countdown_status}"
      out.puts "companion_poc_blank_countdown_result_status=#{blank_countdown_result_status}"
      out.puts "companion_poc_complete_status=#{complete_status}"
      out.puts "companion_poc_completed_status=#{completed_status}"
      out.puts "companion_poc_events_status=#{events_status}"
      out.puts "companion_poc_setup_status=#{setup_status}"
      out.puts "companion_poc_setup_manifest_status=#{manifest_status}"
      out.puts "companion_poc_hub_status=#{hub_status}"
      out.puts "companion_poc_html_status=#{html_status}"
      out.puts "companion_poc_hub_install_status=#{hub_install_status}"
      out.puts "companion_poc_hub_installed_status=#{hub_installed_status}"
      out.puts "companion_poc_setup_redacted=#{setup.include?("openai_api_key") && !setup.include?("sk-")}"
      out.puts "companion_poc_setup_persistence_readiness=#{setup.include?("persistence") && setup.include?("ready")}"
      out.puts "companion_poc_web_surface=#{html.include?('data-ig-poc-surface="companion_dashboard"')}"
      out.puts "companion_poc_today_surface=#{html.include?('data-companion-today="true"') && html.include?('data-today-next-action="true"')}"
      out.puts "companion_poc_daily_focus=#{final.daily_plan.fetch(:focus_title) == "Draft the launch note"}"
      out.puts "companion_poc_daily_focus_persisted=#{persisted.daily_focus_title == final.daily_focus_title}"
      out.puts "companion_poc_daily_focus_persistence_manifest=#{daily_focus_persistence_manifest?}"
      out.puts "companion_poc_daily_focus_generated_api=#{daily_focus_generated_api?}"
      out.puts "companion_poc_daily_focus_first_class_record=#{daily_focus_first_class_record?(config)}"
      out.puts "companion_poc_countdown_persistence_manifest=#{countdown_persistence_manifest?}"
      out.puts "companion_poc_countdown_generated_api=#{countdown_generated_api?}"
      out.puts "companion_poc_countdown_contract_refusal=#{blank_countdown_headers.fetch("location").include?("blank_countdown")}"
      out.puts "companion_poc_countdown_created=#{final.countdowns.any? { |countdown| countdown.id == "launch-day" }}"
      out.puts "companion_poc_countdown_persisted=#{persisted.countdowns.any? { |countdown| countdown.id == "launch-day" }}"
      out.puts "companion_poc_countdown_projection_contract=#{countdown_projection_contract?}"
      out.puts "companion_poc_countdown_days_surface=#{html.include?("data-countdown-days=")}"
      out.puts "companion_poc_reminder_contract_refusal=#{blank_reminder_headers.fetch("location").include?("blank_reminder")}"
      out.puts "companion_poc_tracker_log_contract_refusal=#{blank_tracker_headers.fetch("location").include?("blank_tracker_value")}"
      out.puts "companion_poc_reminder_persistence_manifest=#{reminder_persistence_manifest?}"
      out.puts "companion_poc_reminder_generated_api=#{reminder_generated_api?}"
      out.puts "companion_poc_reminder_scope_api=#{reminder_scope_api?}"
      out.puts "companion_poc_reminder_command_metadata_api=#{reminder_command_metadata_api?}"
      out.puts "companion_poc_tracker_persistence_manifest=#{tracker_persistence_manifest?}"
      out.puts "companion_poc_tracker_generated_api=#{tracker_generated_api?}"
      out.puts "companion_poc_tracker_projection_composes_history=#{tracker_projection_composes_history?(final)}"
      out.puts "companion_poc_tracker_projection_contract=#{tracker_projection_contract?}"
      out.puts "companion_poc_tracker_log_history_manifest=#{tracker_log_history_manifest?}"
      out.puts "companion_poc_tracker_log_history_api=#{tracker_log_history_api?}"
      out.puts "companion_poc_tracker_log_first_class_history=#{tracker_log_first_class_history?(config)}"
      out.puts "companion_poc_action_history_manifest=#{action_history_manifest?}"
      out.puts "companion_poc_action_history_api=#{action_history_api?}"
      out.puts "companion_poc_activity_feed_contract=#{activity_feed_contract?}"
      out.puts "companion_poc_persistence_registry=#{persistence_registry?}"
      out.puts "companion_poc_persistence_registry_valid=#{persistence_registry_valid?}"
      out.puts "companion_poc_persistence_readiness_contract=#{persistence_readiness_contract?}"
      out.puts "companion_poc_persistence_operation_model=#{persistence_operation_model?}"
      out.puts "companion_poc_persistence_manifest_contract=#{persistence_manifest_contract?}"
      out.puts "companion_poc_persistence_metadata_manifest=#{persistence_metadata_manifest?}"
      out.puts "companion_poc_setup_manifest=#{setup_manifest?(manifest)}"
      out.puts "companion_poc_capsules=#{%w[reminders trackers countdowns body-battery daily-plan daily-summary].all? { |name| html.include?("data-capsule=\"#{name}\"") }}"
      out.puts "companion_poc_body_battery_surface=#{html.include?("data-body-battery-score=")}"
      out.puts "companion_poc_daily_plan_surface=#{html.include?("data-daily-plan-block=")}"
      out.puts "companion_poc_hub_surface=#{html.include?('data-capsule="hub"') && html.include?('data-action="install-hub-capsule"')}"
      out.puts "companion_poc_events_parity=#{events.include?("tracker_logs=#{final.tracker_logs_today}")}"
      out.puts "companion_poc_agent_capability=#{app.environment.agent_names.include?(:daily_companion)}"
      out.puts "companion_poc_hub_catalog=#{hub_catalog}"
      out.puts "companion_poc_hub_install=installed"
      out.puts "companion_poc_hub_receipt=#{hub_installed_file}"
      out.puts "companion_poc_hub_installed_file=#{hub_installed_file}"
      out.puts "companion_poc_hub_registry=#{app.service(:hub).installed?(:horoscope)}"
      out.puts "companion_poc_hub_history=#{app.service(:hub).registry.history(:horoscope).length}"
      out.puts "companion_poc_hub_installed_surface=#{installed_html.include?('data-hub-installed="true"')}"
    end

    def build_local_hub_fixture
      root = Dir.mktmpdir("igniter-companion-hub")
      capsule_root = File.join(root, "horoscope_source")
      bundle_path = File.join(root, "bundles", "horoscope")
      install_root = File.join(root, "installed")
      catalog_path = File.join(root, "catalog.json")

      FileUtils.mkdir_p(File.join(capsule_root, "contracts"))
      FileUtils.mkdir_p(File.join(capsule_root, "services"))
      FileUtils.mkdir_p(File.join(capsule_root, "spec"))
      File.write(File.join(capsule_root, "contracts/daily_horoscope.rb"), "# deterministic horoscope contract\n")
      File.write(File.join(capsule_root, "services/horoscope_service.rb"), "# deterministic horoscope service\n")
      File.write(File.join(capsule_root, "igniter.rb"), "# horoscope capsule config\n")

      capsule = Igniter::Application.capsule(:horoscope, root: capsule_root, env: :test) do
        layout :capsule
        groups :contracts, :services
        contract "Contracts::DailyHoroscope"
        service :horoscope_service
        export :daily_horoscope, kind: :service, target: "Services::HoroscopeService"
      end
      readiness = Igniter::Application.transfer_readiness(
        handoff_manifest: Igniter::Application.handoff_manifest(
          subject: :horoscope_bundle,
          capsules: [capsule]
        ),
        transfer_inventory: Igniter::Application.transfer_inventory(capsule)
      )
      bundle_plan = Igniter::Application.transfer_bundle_plan(transfer_readiness: readiness)
      Igniter::Application.write_transfer_bundle(bundle_plan, output: bundle_path, create_parent: true)

      File.write(
        catalog_path,
        JSON.pretty_generate(
          entries: [
            {
              name: :horoscope,
              title: "Daily Horoscope",
              version: "0.1.0",
              description: "Deterministic horoscope capsule for Companion.",
              bundle_path: File.join("bundles", "horoscope"),
              capabilities: %i[daily_horoscope]
            }
          ]
        )
      )

      {
        catalog_path: catalog_path,
        install_root: install_root
      }
    end

    def reminder_persistence_manifest?
      manifest = Contracts::Reminder.persistence_manifest
      persist = manifest.fetch(:persist)
      fields = manifest.fetch(:fields).map { |field| field.fetch(:name) }
      persist.fetch(:key) == :id &&
        persist.fetch(:adapter) == :sqlite &&
        fields == %i[id title due status]
    end

    def reminder_generated_api?
      records = Services::ContractRecordSet.new(
        contract_class: Contracts::Reminder,
        collection: [],
        record_class: Services::CompanionState::Reminder
      )
      created = records.save(id: "contract-api", title: "Generated API", due: "today")
      defaulted = created.status == :open
      records.update("contract-api", status: :done)

      records.api_manifest.fetch(:operations) == %i[all find save update delete clear scope command] &&
        defaulted &&
        records.find("contract-api").status == :done &&
        records.all.length == 1
    end

    def reminder_scope_api?
      records = Services::ContractRecordSet.new(
        contract_class: Contracts::Reminder,
        collection: [],
        record_class: Services::CompanionState::Reminder
      )
      records.save(id: "open-reminder", title: "Open", due: "today")
      records.save(id: "done-reminder", title: "Done", due: "today", status: :done)
      open = records.scope(:open)

      open.length == 1 &&
        open.first.id == "open-reminder" &&
        records.api_manifest.fetch(:scopes).any? { |scope| scope.fetch(:name) == :open }
    end

    def reminder_command_metadata_api?
      records = Services::ContractRecordSet.new(
        contract_class: Contracts::Reminder,
        collection: [],
        record_class: Services::CompanionState::Reminder
      )
      command = records.command(:complete)
      mutation = Contracts::ReminderContract.evaluate(
        operation: :complete,
        id: "morning-water",
        title: nil,
        reminders: [Services::CompanionState::Reminder.new(id: "morning-water", title: "Water", due: "morning", status: :open)]
      ).fetch(:mutation)

      command.fetch(:attributes).fetch(:operation) == :record_update &&
        command.fetch(:attributes).fetch(:changes) == { status: :done } &&
        mutation.fetch(:operation) == :record_update &&
        mutation.fetch(:target) == :reminders
    end

    def daily_focus_persistence_manifest?
      manifest = Contracts::DailyFocus.persistence_manifest
      persist = manifest.fetch(:persist)
      fields = manifest.fetch(:fields).map { |field| field.fetch(:name) }
      persist.fetch(:key) == :date &&
        persist.fetch(:adapter) == :sqlite &&
        fields == %i[date title]
    end

    def daily_focus_generated_api?
      records = Services::ContractRecordSet.new(
        contract_class: Contracts::DailyFocus,
        collection: [],
        record_class: Services::CompanionState::DailyFocus
      )
      records.save(date: "2026-04-28", title: "Focus")
      records.update("2026-04-28", title: "Updated focus")

      records.api_manifest.fetch(:operations) == %i[all find save update delete clear scope command] &&
        records.find("2026-04-28").title == "Updated focus" &&
        records.all.length == 1
    end

    def daily_focus_first_class_record?(config)
      state = config.store_adapter.load_state
      focuses = Array(state.fetch(:daily_focuses))
      focuses.length == 1 &&
        focuses.first.fetch(:date) == Date.today.iso8601 &&
        focuses.first.fetch(:title) == "Draft the launch note"
    end

    def countdown_persistence_manifest?
      manifest = Contracts::Countdown.persistence_manifest
      persist = manifest.fetch(:persist)
      fields = manifest.fetch(:fields).map { |field| field.fetch(:name) }
      persist.fetch(:key) == :id &&
        persist.fetch(:adapter) == :sqlite &&
        fields == %i[id title target_date]
    end

    def countdown_generated_api?
      records = Services::ContractRecordSet.new(
        contract_class: Contracts::Countdown,
        collection: [],
        record_class: Services::CompanionState::Countdown
      )
      records.save(id: "launch", title: "Launch", target_date: "2026-05-01")
      records.update("launch", title: "Public launch")

      records.api_manifest.fetch(:operations) == %i[all find save update delete clear scope command] &&
        records.find("launch").title == "Public launch" &&
        records.all.length == 1
    end

    def countdown_projection_contract?
      projection = Contracts::CountdownReadModelContract.evaluate(
        countdowns: [
          Services::CompanionState::Countdown.new(id: "launch", title: "Launch", target_date: "2026-05-01")
        ],
        date: "2026-04-29"
      )
      snapshot = projection.fetch(:countdown_snapshots).first

      snapshot.id == "launch" &&
        snapshot.days_remaining == 2
    end

    def tracker_persistence_manifest?
      manifest = Contracts::Tracker.persistence_manifest
      persist = manifest.fetch(:persist)
      fields = manifest.fetch(:fields).map { |field| field.fetch(:name) }
      persist.fetch(:key) == :id &&
        persist.fetch(:adapter) == :sqlite &&
        fields == %i[id name template unit]
    end

    def tracker_generated_api?
      records = Services::ContractRecordSet.new(
        contract_class: Contracts::Tracker,
        collection: [],
        record_class: Services::CompanionState::Tracker
      )
      records.save(id: "mood", name: "Mood", template: :scale, unit: "score")
      records.update("mood", unit: "points")

      records.api_manifest.fetch(:operations) == %i[all find save update delete clear scope command] &&
        records.find("mood").unit == "points" &&
        records.all.length == 1
    end

    def tracker_projection_composes_history?(snapshot)
      sleep = snapshot.trackers.find { |tracker| tracker.id == "sleep" }
      sleep&.log_entries&.length == 1 &&
        sleep.log_entries.first.fetch(:value) == "7.5"
    end

    def tracker_projection_contract?
      projection = Contracts::TrackerReadModelContract.evaluate(
        trackers: [
          Services::CompanionState::Tracker.new(id: "sleep", name: "Sleep", template: :sleep, unit: "hours"),
          Services::CompanionState::Tracker.new(id: "training", name: "Training", template: :workout, unit: "minutes")
        ],
        tracker_logs: [
          { tracker_id: "sleep", date: "2026-04-28", value: "7.5" },
          { tracker_id: "training", date: "2026-04-28", value: "20" }
        ],
        date: "2026-04-28"
      )
      sleep = projection.fetch(:tracker_snapshots).find { |tracker| tracker.id == "sleep" }

      projection.fetch(:logs_today) == 2 &&
        projection.fetch(:sleep_hours_today).between?(7.49, 7.51) &&
        projection.fetch(:training_minutes_today).between?(19.99, 20.01) &&
        sleep.log_entries.first.fetch(:value) == "7.5"
    end

    def tracker_log_history_manifest?
      manifest = Contracts::TrackerLog.persistence_manifest
      history = manifest.fetch(:history)
      fields = manifest.fetch(:fields).map { |field| field.fetch(:name) }
      history.fetch(:key) == :tracker_id &&
        history.fetch(:adapter) == :sqlite &&
        fields == %i[tracker_id date value]
    end

    def tracker_log_history_api?
      entries = []
      history = Services::ContractHistory.new(
        contract_class: Contracts::TrackerLog,
        entries: -> { entries },
        append: ->(event) { entries << event }
      )
      history.append(tracker_id: "sleep", date: "2026-04-28", value: "7.5")

      history.api_manifest.fetch(:operations) == %i[append all where count] &&
        history.count(tracker_id: "sleep") == 1 &&
        history.where(date: "2026-04-28").first.fetch(:value) == "7.5"
    end

    def tracker_log_first_class_history?(config)
      state = config.store_adapter.load_state
      logs = Array(state.fetch(:tracker_logs))
      nested_logs = Array(state.fetch(:trackers)).flat_map { |tracker| Array(tracker.fetch(:entries, [])) }
      logs.length == 1 &&
        logs.first.fetch(:tracker_id) == "sleep" &&
        nested_logs.empty?
    end

    def action_history_manifest?
      manifest = Contracts::CompanionAction.persistence_manifest
      history = manifest.fetch(:history)
      fields = manifest.fetch(:fields).map { |field| field.fetch(:name) }
      history.fetch(:key) == :index &&
        history.fetch(:adapter) == :sqlite &&
        fields == %i[index kind subject_id status]
    end

    def action_history_api?
      actions = []
      history = Services::ContractHistory.new(
        contract_class: Contracts::CompanionAction,
        entries: -> { actions },
        append: ->(event) { actions << event }
      )
      history.append(index: 0, kind: :smoke, subject_id: :companion, status: :ready)

      history.api_manifest.fetch(:operations) == %i[append all where count] &&
        history.count(status: :ready) == 1 &&
        history.where(kind: :smoke).first.fetch(:subject_id) == :companion
    end

    def activity_feed_contract?
      feed = Contracts::ActivityFeedContract.evaluate(
        actions: [
          { index: 1, kind: :second, subject_id: :companion, status: :ready },
          { index: 0, kind: :first, subject_id: :companion, status: :ready },
          { index: 2, kind: :third, subject_id: :companion, status: :ready }
        ],
        recent_limit: 2
      )

      feed.fetch(:action_count) == 3 &&
        feed.fetch(:recent_events).map { |event| event.fetch(:kind) } == %i[second third]
    end

    def persistence_registry?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      manifest = persistence.capability_manifest
      persistence.capability_names == %i[
        reminders trackers daily_focuses countdowns tracker_logs actions
        tracker_read_model countdown_read_model activity_feed
      ] &&
        manifest.fetch(:reminders).fetch(:kind) == :record &&
        manifest.fetch(:countdowns).fetch(:kind) == :record &&
        manifest.fetch(:countdown_read_model).fetch(:kind) == :projection &&
        manifest.fetch(:tracker_logs).fetch(:kind) == :history &&
        manifest.fetch(:activity_feed).fetch(:kind) == :projection
    end

    def persistence_registry_valid?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      persistence.valid? && persistence.validation_errors.empty?
    end

    def persistence_readiness_contract?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      readiness = persistence.readiness
      readiness.fetch(:ready) &&
        readiness.fetch(:status) == :ready &&
        readiness.fetch(:capability_count) == 9 &&
        readiness.fetch(:record_count) == 4 &&
        readiness.fetch(:history_count) == 2 &&
        readiness.fetch(:projection_count) == 3
    end

    def persistence_operation_model?
      reminder_create = Contracts::ReminderContract.evaluate(
        operation: :create,
        id: nil,
        title: "Operation model",
        reminders: []
      ).fetch(:mutation)
      reminder_complete = Contracts::ReminderContract.evaluate(
        operation: :complete,
        id: "morning-water",
        title: nil,
        reminders: [Services::CompanionState::Reminder.new(id: "morning-water", title: "Water", due: "morning", status: :open)]
      ).fetch(:mutation)
      tracker_log = Contracts::TrackerLogContract.evaluate(
        tracker_id: "sleep",
        value: "7",
        date: "2026-04-29",
        trackers: [Services::CompanionState::Tracker.new(id: "sleep", name: "Sleep", template: :sleep, unit: "hours")]
      ).fetch(:mutation)
      refused = Contracts::CountdownContract.evaluate(
        title: " ",
        target_date: " ",
        countdowns: []
      ).fetch(:mutation)

      reminder_create.fetch(:operation) == :record_append &&
        reminder_create.fetch(:target) == :reminders &&
        reminder_complete.fetch(:operation) == :record_update &&
        tracker_log.fetch(:operation) == :history_append &&
        tracker_log.fetch(:target) == :tracker_logs &&
        refused.fetch(:operation) == :none
    end

    def persistence_manifest_contract?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      manifest = persistence.manifest_snapshot
      summary = manifest.fetch(:summary)

      summary.fetch(:record_count) == 4 &&
        summary.fetch(:history_count) == 2 &&
        summary.fetch(:projection_count) == 3 &&
        summary.fetch(:command_count) == 3 &&
        manifest.fetch(:records).fetch(:reminders).fetch(:operations) == %i[all find save update delete clear scope command] &&
        manifest.fetch(:histories).fetch(:tracker_logs).fetch(:operations) == %i[append all where count] &&
        manifest.fetch(:commands).fetch(:tracker_log_commands).fetch(:operations).include?(:history_append)
    end

    def persistence_metadata_manifest?
      manifest = Contracts::Reminder.persistence_manifest
      api = Services::ContractRecordSet.new(
        contract_class: Contracts::Reminder,
        collection: [],
        record_class: Services::CompanionState::Reminder
      ).api_manifest
      command_mutation = Contracts::ReminderContract.evaluate(
        operation: :complete,
        id: "morning-water",
        title: nil,
        reminders: [Services::CompanionState::Reminder.new(id: "morning-water", title: "Water", due: "morning", status: :open)]
      ).fetch(:mutation)

      manifest.fetch(:indexes).any? { |index| index.fetch(:name) == :status } &&
        manifest.fetch(:scopes).any? { |scope| scope.fetch(:name) == :open && scope.fetch(:attributes).fetch(:where) == { status: :open } } &&
        manifest.fetch(:commands).any? { |command| command.fetch(:name) == :complete && command.fetch(:attributes).fetch(:operation) == :record_update } &&
        api.fetch(:indexes).any? { |index| index.fetch(:name) == :status } &&
        api.fetch(:scopes).any? { |scope| scope.fetch(:name) == :open } &&
        api.fetch(:commands).any? { |command| command.fetch(:name) == :complete } &&
        command_mutation.fetch(:operation) == :record_update
    end

    def setup_manifest?(manifest)
      manifest.include?("records") &&
        manifest.include?("histories") &&
        manifest.include?("projections") &&
        manifest.include?("commands") &&
        manifest.include?("indexes") &&
        manifest.include?("scopes") &&
        manifest.include?("record_append") &&
        manifest.include?("history_append")
    end

    def post(app, path, values = {})
      status, headers = app.call(rack_env("POST", path, form_body(values)))
      [status, headers]
    end

    def get_status(app, path)
      status, = app.call(rack_env("GET", path))
      status
    end

    def rack_env(method, path, body = "")
      path_info, query_string = path.split("?", 2)
      {
        "REQUEST_METHOD" => method,
        "PATH_INFO" => path_info,
        "QUERY_STRING" => query_string.to_s,
        "rack.input" => StringIO.new(body)
      }
    end

    def form_body(values)
      URI.encode_www_form(values)
    end
  end
end
