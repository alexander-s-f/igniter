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
      relation_health_status, _relation_health_headers, relation_health_body = app.call(rack_env("GET", "/setup/relation-health"))
      relation_health_json_status, _relation_health_json_headers, relation_health_json_body = app.call(rack_env("GET", "/setup/relation-health.json"))
      materialization_status, _materialization_headers, materialization_body = app.call(rack_env("GET", "/setup/materialization-plan"))
      materialization_json_status, _materialization_json_headers, materialization_json_body = app.call(rack_env("GET", "/setup/materialization-plan.json"))
      parity_status, _parity_headers, parity_body = app.call(rack_env("GET", "/setup/materialization-parity"))
      parity_json_status, _parity_json_headers, parity_json_body = app.call(rack_env("GET", "/setup/materialization-parity.json"))
      wizard_spec_status, _wizard_spec_headers, wizard_spec_body = app.call(rack_env("GET", "/setup/wizard-type-specs"))
      wizard_spec_json_status, _wizard_spec_json_headers, wizard_spec_json_body = app.call(rack_env("GET", "/setup/wizard-type-specs.json"))
      wizard_export_status, _wizard_export_headers, wizard_export_body = app.call(rack_env("GET", "/setup/wizard-type-spec-export"))
      wizard_export_json_status, _wizard_export_json_headers, wizard_export_json_body = app.call(rack_env("GET", "/setup/wizard-type-spec-export.json"))
      wizard_migration_status, _wizard_migration_headers, wizard_migration_body = app.call(rack_env("GET", "/setup/wizard-type-spec-migration-plan"))
      wizard_migration_json_status, _wizard_migration_json_headers, wizard_migration_json_body = app.call(rack_env("GET", "/setup/wizard-type-spec-migration-plan.json"))
      loop_health_status, _loop_health_headers, loop_health_body = app.call(rack_env("GET", "/setup/infrastructure-loop-health"))
      loop_health_json_status, _loop_health_json_headers, loop_health_json_body = app.call(rack_env("GET", "/setup/infrastructure-loop-health.json"))
      materializer_gate_status, _materializer_gate_headers, materializer_gate_body = app.call(rack_env("GET", "/setup/materializer-gate"))
      materializer_gate_json_status, _materializer_gate_json_headers, materializer_gate_json_body = app.call(rack_env("GET", "/setup/materializer-gate.json"))
      materializer_preflight_status, _materializer_preflight_headers, materializer_preflight_body = app.call(rack_env("GET", "/setup/materializer-preflight"))
      materializer_preflight_json_status, _materializer_preflight_json_headers, materializer_preflight_json_body = app.call(rack_env("GET", "/setup/materializer-preflight.json"))
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
      relation_health = relation_health_body.join
      relation_health_json = relation_health_json_body.join
      materialization = materialization_body.join
      materialization_json = materialization_json_body.join
      parity = parity_body.join
      parity_json = parity_json_body.join
      wizard_specs = wizard_spec_body.join
      wizard_specs_json = wizard_spec_json_body.join
      wizard_export = wizard_export_body.join
      wizard_export_json = wizard_export_json_body.join
      wizard_migration = wizard_migration_body.join
      wizard_migration_json = wizard_migration_json_body.join
      loop_health = loop_health_body.join
      loop_health_json = loop_health_json_body.join
      materializer_gate = materializer_gate_body.join
      materializer_gate_json = materializer_gate_json_body.join
      materializer_preflight = materializer_preflight_body.join
      materializer_preflight_json = materializer_preflight_json_body.join
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
      out.puts "companion_poc_setup_relation_health_status=#{relation_health_status}"
      out.puts "companion_poc_setup_relation_health_json_status=#{relation_health_json_status}"
      out.puts "companion_poc_setup_materialization_status=#{materialization_status}"
      out.puts "companion_poc_setup_materialization_json_status=#{materialization_json_status}"
      out.puts "companion_poc_setup_materialization_parity_status=#{parity_status}"
      out.puts "companion_poc_setup_materialization_parity_json_status=#{parity_json_status}"
      out.puts "companion_poc_setup_wizard_type_specs_status=#{wizard_spec_status}"
      out.puts "companion_poc_setup_wizard_type_specs_json_status=#{wizard_spec_json_status}"
      out.puts "companion_poc_setup_wizard_type_spec_export_status=#{wizard_export_status}"
      out.puts "companion_poc_setup_wizard_type_spec_export_json_status=#{wizard_export_json_status}"
      out.puts "companion_poc_setup_wizard_type_spec_migration_status=#{wizard_migration_status}"
      out.puts "companion_poc_setup_wizard_type_spec_migration_json_status=#{wizard_migration_json_status}"
      out.puts "companion_poc_setup_infrastructure_loop_health_status=#{loop_health_status}"
      out.puts "companion_poc_setup_infrastructure_loop_health_json_status=#{loop_health_json_status}"
      out.puts "companion_poc_setup_materializer_gate_status=#{materializer_gate_status}"
      out.puts "companion_poc_setup_materializer_gate_json_status=#{materializer_gate_json_status}"
      out.puts "companion_poc_setup_materializer_preflight_status=#{materializer_preflight_status}"
      out.puts "companion_poc_setup_materializer_preflight_json_status=#{materializer_preflight_json_status}"
      out.puts "companion_poc_hub_status=#{hub_status}"
      out.puts "companion_poc_html_status=#{html_status}"
      out.puts "companion_poc_hub_install_status=#{hub_install_status}"
      out.puts "companion_poc_hub_installed_status=#{hub_installed_status}"
      out.puts "companion_poc_setup_redacted=#{setup.include?("openai_api_key") && !setup.include?("sk-")}"
      out.puts "companion_poc_setup_persistence_readiness=#{setup.include?("persistence") && setup.include?("ready")}"
      out.puts "companion_poc_setup_relation_health=#{setup.include?("relation_health") && setup.include?("clear")}"
      out.puts "companion_poc_setup_relation_health_endpoint=#{setup_relation_health_endpoint?(relation_health)}"
      out.puts "companion_poc_setup_relation_health_json_endpoint=#{setup_relation_health_json_endpoint?(relation_health_json)}"
      out.puts "companion_poc_setup_materialization_endpoint=#{setup_materialization_endpoint?(materialization)}"
      out.puts "companion_poc_setup_materialization_json_endpoint=#{setup_materialization_json_endpoint?(materialization_json)}"
      out.puts "companion_poc_setup_materialization_parity_endpoint=#{setup_materialization_parity_endpoint?(parity)}"
      out.puts "companion_poc_setup_materialization_parity_json_endpoint=#{setup_materialization_parity_json_endpoint?(parity_json)}"
      out.puts "companion_poc_setup_wizard_type_specs_endpoint=#{setup_wizard_type_specs_endpoint?(wizard_specs)}"
      out.puts "companion_poc_setup_wizard_type_specs_json_endpoint=#{setup_wizard_type_specs_json_endpoint?(wizard_specs_json)}"
      out.puts "companion_poc_setup_wizard_type_spec_export_endpoint=#{setup_wizard_type_spec_export_endpoint?(wizard_export)}"
      out.puts "companion_poc_setup_wizard_type_spec_export_json_endpoint=#{setup_wizard_type_spec_export_json_endpoint?(wizard_export_json)}"
      out.puts "companion_poc_setup_wizard_type_spec_migration_endpoint=#{setup_wizard_type_spec_migration_endpoint?(wizard_migration)}"
      out.puts "companion_poc_setup_wizard_type_spec_migration_json_endpoint=#{setup_wizard_type_spec_migration_json_endpoint?(wizard_migration_json)}"
      out.puts "companion_poc_setup_infrastructure_loop_health_endpoint=#{setup_infrastructure_loop_health_endpoint?(loop_health)}"
      out.puts "companion_poc_setup_infrastructure_loop_health_json_endpoint=#{setup_infrastructure_loop_health_json_endpoint?(loop_health_json)}"
      out.puts "companion_poc_setup_materializer_gate_endpoint=#{setup_materializer_gate_endpoint?(materializer_gate)}"
      out.puts "companion_poc_setup_materializer_gate_json_endpoint=#{setup_materializer_gate_json_endpoint?(materializer_gate_json)}"
      out.puts "companion_poc_setup_materializer_preflight_endpoint=#{setup_materializer_preflight_endpoint?(materializer_preflight)}"
      out.puts "companion_poc_setup_materializer_preflight_json_endpoint=#{setup_materializer_preflight_json_endpoint?(materializer_preflight_json)}"
      out.puts "companion_poc_web_surface=#{html.include?('data-ig-poc-surface="companion_dashboard"')}"
      out.puts "companion_poc_relation_health_dashboard=#{relation_health_dashboard?(html)}"
      out.puts "companion_poc_today_surface=#{html.include?('data-companion-today="true"') && html.include?('data-today-next-action="true"')}"
      out.puts "companion_poc_today_signal=#{daily_plan_signal? && html.include?("data-today-signal=")}"
      out.puts "companion_poc_today_quick_action=#{daily_plan_quick_action? && html.include?("data-today-quick-action=")}"
      out.puts "companion_poc_today_quick_action_command=#{daily_plan_quick_action_command? && html.include?("data-today-command=")}"
      out.puts "companion_poc_today_quick_action_route=#{today_quick_action_route? && html.include?('action="/today/quick-action"')}"
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
      out.puts "companion_poc_persistence_relation_health_contract=#{persistence_relation_health_contract?}"
      out.puts "companion_poc_relation_health_reports=#{relation_health_reports?}"
      out.puts "companion_poc_relation_health_structured_warnings=#{relation_health_structured_warnings?}"
      out.puts "companion_poc_relation_health_repair_suggestions=#{relation_health_repair_suggestions?}"
      out.puts "companion_poc_persistence_operation_model=#{persistence_operation_model?}"
      out.puts "companion_poc_persistence_manifest_contract=#{persistence_manifest_contract?}"
      out.puts "companion_poc_persistence_metadata_manifest=#{persistence_metadata_manifest?}"
      out.puts "companion_poc_user_defined_article_contract=#{user_defined_article_contract?}"
      out.puts "companion_poc_wizard_type_spec_store=#{wizard_type_spec_store?}"
      out.puts "companion_poc_wizard_type_spec_history=#{wizard_type_spec_history?}"
      out.puts "companion_poc_wizard_type_spec_export=#{wizard_type_spec_export?}"
      out.puts "companion_poc_wizard_type_spec_canonical=#{wizard_type_spec_canonical?}"
      out.puts "companion_poc_wizard_type_spec_migration_plan=#{wizard_type_spec_migration_plan?}"
      out.puts "companion_poc_infrastructure_loop_health=#{infrastructure_loop_health?}"
      out.puts "companion_poc_materializer_gate=#{materializer_gate?}"
      out.puts "companion_poc_materializer_preflight=#{materializer_preflight?}"
      out.puts "companion_poc_static_materialization_plan=#{static_materialization_plan?}"
      out.puts "companion_poc_static_materialization_parity=#{static_materialization_parity?}"
      out.puts "companion_poc_persistence_relation_manifest=#{persistence_relation_manifest?}"
      out.puts "companion_poc_projection_relation_manifest=#{projection_relation_manifest?}"
      out.puts "companion_poc_relation_health_warning=#{relation_health_warning?}"
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

    def daily_plan_signal?
      log_tracker = Contracts::DailyPlanContract.evaluate(
        daily_focus_title: nil,
        next_reminder_id: nil,
        next_reminder_title: nil,
        suggested_tracker_id: "sleep",
        body_battery: { status: "steady" },
        open_reminders: 0,
        tracker_logs_today: 0,
        urgent_countdown_id: nil,
        urgent_countdown_title: nil
      )
      close_reminder = Contracts::DailyPlanContract.evaluate(
        daily_focus_title: "Write note",
        next_reminder_id: "morning-water",
        next_reminder_title: "Drink water",
        suggested_tracker_id: "sleep",
        body_battery: { status: "charged" },
        open_reminders: 1,
        tracker_logs_today: 1,
        urgent_countdown_id: nil,
        urgent_countdown_title: nil
      )

      log_tracker.fetch(:signal) == :log_tracker &&
        log_tracker.fetch(:next_action).include?("tracker") &&
        close_reminder.fetch(:signal) == :close_reminder &&
        close_reminder.fetch(:next_action).include?("Drink water")
    end

    def daily_plan_quick_action?
      log_tracker = Contracts::DailyPlanContract.evaluate(
        daily_focus_title: nil,
        next_reminder_id: nil,
        next_reminder_title: nil,
        suggested_tracker_id: "sleep",
        body_battery: { status: "steady" },
        open_reminders: 0,
        tracker_logs_today: 0,
        urgent_countdown_id: nil,
        urgent_countdown_title: nil
      ).fetch(:quick_action)
      close_reminder = Contracts::DailyPlanContract.evaluate(
        daily_focus_title: "Write note",
        next_reminder_id: "morning-water",
        next_reminder_title: "Drink water",
        suggested_tracker_id: "sleep",
        body_battery: { status: "charged" },
        open_reminders: 1,
        tracker_logs_today: 1,
        urgent_countdown_id: nil,
        urgent_countdown_title: nil
      ).fetch(:quick_action)

      log_tracker.fetch(:kind) == :tracker_log &&
        log_tracker.fetch(:subject_id) == "sleep" &&
        close_reminder.fetch(:kind) == :complete_reminder &&
        close_reminder.fetch(:subject_id) == "morning-water"
    end

    def daily_plan_quick_action_command?
      log_tracker = Contracts::DailyPlanContract.evaluate(
        daily_focus_title: nil,
        next_reminder_id: nil,
        next_reminder_title: nil,
        suggested_tracker_id: "sleep",
        body_battery: { status: "steady" },
        open_reminders: 0,
        tracker_logs_today: 0,
        urgent_countdown_id: nil,
        urgent_countdown_title: nil
      ).fetch(:quick_action).fetch(:command)
      close_reminder = Contracts::DailyPlanContract.evaluate(
        daily_focus_title: "Write note",
        next_reminder_id: "morning-water",
        next_reminder_title: "Drink water",
        suggested_tracker_id: "sleep",
        body_battery: { status: "charged" },
        open_reminders: 1,
        tracker_logs_today: 1,
        urgent_countdown_id: nil,
        urgent_countdown_title: nil
      ).fetch(:quick_action).fetch(:command)

      log_tracker.fetch(:name) == :log_tracker &&
        log_tracker.fetch(:arguments).fetch(:id) == "sleep" &&
        log_tracker.fetch(:arguments).fetch(:value) == :input_value &&
        close_reminder.fetch(:name) == :complete_reminder &&
        close_reminder.fetch(:arguments).fetch(:id) == "morning-water"
    end

    def today_quick_action_route?
      db_path = File.join(Dir.mktmpdir("igniter-companion-today-action"), "companion.sqlite3")
      config = Companion.default_configuration(store_path: db_path)
      app = Companion.build(config: config)
      store = app.service(:companion)
      initial = store.snapshot
      initial_action = initial.daily_plan.fetch(:quick_action)
      first_status, first_headers = post(app, "/today/quick-action", value: "8")
      first_result_status = get_status(app, first_headers.fetch("location"))
      after_log = store.snapshot
      after_log_action = after_log.daily_plan.fetch(:quick_action)
      second_status, second_headers = post(app, "/today/quick-action")
      second_result_status = get_status(app, second_headers.fetch("location"))
      after_done = store.snapshot

      first_status == 303 &&
        first_result_status == 200 &&
        second_status == 303 &&
        second_result_status == 200 &&
        initial_action.fetch(:kind) == :tracker_log &&
        after_log.tracker_logs_today == initial.tracker_logs_today + 1 &&
        after_log_action.fetch(:kind) == :complete_reminder &&
        after_done.open_reminders == initial.open_reminders - 1
    end

    def persistence_registry?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      manifest = persistence.capability_manifest
      persistence.capability_names == %i[
        reminders trackers daily_focuses countdowns articles wizard_type_specs tracker_logs actions comments
        wizard_type_spec_changes tracker_read_model countdown_read_model activity_feed
      ] &&
        manifest.fetch(:reminders).fetch(:kind) == :record &&
        manifest.fetch(:countdowns).fetch(:kind) == :record &&
        manifest.fetch(:articles).fetch(:kind) == :record &&
        manifest.fetch(:wizard_type_specs).fetch(:kind) == :record &&
        manifest.fetch(:comments).fetch(:kind) == :history &&
        manifest.fetch(:wizard_type_spec_changes).fetch(:kind) == :history &&
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
        readiness.fetch(:capability_count) == 13 &&
        readiness.fetch(:record_count) == 6 &&
        readiness.fetch(:history_count) == 4 &&
        readiness.fetch(:projection_count) == 3 &&
        readiness.fetch(:relation_count) == 2 &&
        readiness.fetch(:warning_count).zero?
    end

    def persistence_relation_health_contract?
      clean = Services::CompanionPersistence.new(state: Services::CompanionState.seeded).relation_health
      warning = Contracts::PersistenceRelationHealthContract.evaluate(
        relation_manifest: { tracker_logs_by_tracker: {} },
        relation_warnings: {
          tracker_logs_by_tracker: [
            {
              kind: :missing_source,
              from: :trackers,
              to: :tracker_logs,
              values: ["ghost-tracker"],
              message: "tracker_logs references missing trackers ghost-tracker"
            }
          ]
        }
      )
      warning_entry = warning.fetch(:warnings).first

      clean.fetch(:status) == :clear &&
        clean.fetch(:warning_count).zero? &&
        clean.fetch(:repair_suggestions).empty? &&
        clean.fetch(:relation_reports).fetch(:tracker_logs_by_tracker).fetch(:status) == :clear &&
        warning.fetch(:status) == :warning &&
        warning.fetch(:warning_count) == 1 &&
        warning.fetch(:relation_reports).fetch(:tracker_logs_by_tracker).fetch(:status) == :warning &&
        warning_entry.fetch(:relation) == :tracker_logs_by_tracker &&
        warning_entry.fetch(:kind) == :missing_source &&
        warning_entry.fetch(:values) == ["ghost-tracker"] &&
        warning.fetch(:summary).include?("1 warnings")
    end

    def relation_health_reports?
      health = Services::CompanionPersistence.new(state: Services::CompanionState.seeded).relation_health
      report = health.fetch(:relation_reports).fetch(:tracker_logs_by_tracker)
      article_report = health.fetch(:relation_reports).fetch(:comments_by_article)

      report.fetch(:status) == :clear &&
        report.fetch(:warning_count).zero? &&
        report.fetch(:warnings).empty? &&
        report.fetch(:repair_suggestions).empty? &&
        article_report.fetch(:status) == :clear
    end

    def relation_health_structured_warnings?
      orphaned_state = Services::CompanionState.seeded
      orphaned_state.tracker_logs << Services::CompanionState::TrackerLog.new(
        tracker_id: "ghost-tracker",
        date: Date.today.iso8601,
        value: "7"
      )
      warning = Services::CompanionPersistence
                .new(state: orphaned_state)
                .relation_health
                .fetch(:warnings)
                .first

      warning.fetch(:relation) == :tracker_logs_by_tracker &&
        warning.fetch(:kind) == :missing_source &&
        warning.fetch(:from) == :trackers &&
        warning.fetch(:to) == :tracker_logs &&
        warning.fetch(:values) == ["ghost-tracker"] &&
        warning.fetch(:message).include?("ghost-tracker")
    end

    def relation_health_repair_suggestions?
      orphaned_state = Services::CompanionState.seeded
      orphaned_state.tracker_logs << Services::CompanionState::TrackerLog.new(
        tracker_id: "ghost-tracker",
        date: Date.today.iso8601,
        value: "7"
      )
      health = Services::CompanionPersistence.new(state: orphaned_state).relation_health
      suggestion = health.fetch(:repair_suggestions).first
      report_suggestion = health.fetch(:relation_reports)
                                .fetch(:tracker_logs_by_tracker)
                                .fetch(:repair_suggestions)
                                .first

      suggestion.fetch(:relation) == :tracker_logs_by_tracker &&
        suggestion.fetch(:kind) == :review_missing_source &&
        suggestion.fetch(:command).fetch(:name) == :review_relation_warning &&
        suggestion.fetch(:command).fetch(:arguments).fetch(:values) == ["ghost-tracker"] &&
        report_suggestion.fetch(:command).fetch(:arguments).fetch(:relation) == :tracker_logs_by_tracker
    end

    def setup_relation_health_endpoint?(relation_health)
      relation_health.include?("relation_reports") &&
        relation_health.include?("tracker_logs_by_tracker") &&
        relation_health.include?("repair_suggestions") &&
        relation_health.include?("status=>:clear")
    end

    def setup_relation_health_json_endpoint?(relation_health_json)
      payload = JSON.parse(relation_health_json)
      report = payload.fetch("relation_reports").fetch("tracker_logs_by_tracker")

      payload.fetch("status") == "clear" &&
        payload.fetch("warning_count").zero? &&
        payload.fetch("repair_suggestions").empty? &&
        report.fetch("status") == "clear" &&
        report.fetch("repair_suggestions").empty?
    end

    def setup_materialization_endpoint?(materialization)
      materialization.include?("ready_for_static_materialization") &&
        materialization.include?("comments_by_article") &&
        materialization.include?("write")
    end

    def setup_materialization_json_endpoint?(materialization_json)
      payload = JSON.parse(materialization_json)

      record = payload.fetch("record_contract")
      history = payload.fetch("history_contracts").first
      payload.fetch("status") == "ready_for_static_materialization" &&
        payload.fetch("schema_version") == 1 &&
        payload.fetch("static_required") &&
        record.fetch("storage").fetch("shape") == "store" &&
        history.fetch("storage").fetch("shape") == "history" &&
        payload.fetch("relations").key?("comments_by_article") &&
        payload.fetch("required_capabilities") == %w[write git test restart]
    end

    def setup_materialization_parity_endpoint?(parity)
      parity.include?("matched") &&
        parity.include?("comments_by_article") &&
        parity.include?("Static materialization matches")
    end

    def setup_materialization_parity_json_endpoint?(parity_json)
      payload = JSON.parse(parity_json)

      payload.fetch("schema_version") == 1 &&
        payload.fetch("status") == "matched" &&
        payload.fetch("mismatches").empty? &&
        payload.fetch("checked_capabilities").include?("comments_by_article")
    end

    def setup_wizard_type_specs_endpoint?(wizard_specs)
      wizard_specs.include?("article-comment") &&
        wizard_specs.include?("Article") &&
        wizard_specs.include?("comments_by_article")
    end

    def setup_wizard_type_specs_json_endpoint?(wizard_specs_json)
      payload = JSON.parse(wizard_specs_json)
      spec = payload.find { |entry| entry.fetch("id") == "article-comment" }.fetch("spec")

      spec.fetch("schema_version") == 1 &&
        spec.fetch("storage").fetch("shape") == "store" &&
        spec.fetch("histories").first.fetch("storage").fetch("shape") == "history" &&
        spec.fetch("name") == "Article" &&
        spec.fetch("fields").any? { |field| field.fetch("name") == "status" && field.fetch("type") == "enum" } &&
        spec.fetch("histories").first.fetch("relation").fetch("name") == "comments_by_article"
    end

    def setup_wizard_type_spec_export_endpoint?(wizard_export)
      wizard_export.include?("dev_config") &&
        wizard_export.include?("prod_config") &&
        wizard_export.include?("latest-only")
    end

    def setup_wizard_type_spec_export_json_endpoint?(wizard_export_json)
      payload = JSON.parse(wizard_export_json)

      payload.fetch("schema_versions") == [1] &&
        payload.fetch("dev_config").fetch("history").any? &&
        payload.fetch("prod_config").fetch("history").empty? &&
        payload.fetch("prod_config").fetch("compressed")
    end

    def setup_wizard_type_spec_migration_endpoint?(wizard_migration)
      wizard_migration.include?("review-only migration candidates") &&
        wizard_migration.include?("article-comment") &&
        wizard_migration.include?("status=>:stable")
    end

    def setup_wizard_type_spec_migration_json_endpoint?(wizard_migration_json)
      payload = JSON.parse(wizard_migration_json)
      report = payload.fetch("reports").find { |entry| entry.fetch("spec_id") == "article-comment" }

      payload.fetch("status") == "stable" &&
        payload.fetch("candidate_count").zero? &&
        report.fetch("status") == "stable"
    end

    def setup_infrastructure_loop_health_endpoint?(loop_health)
      loop_health.include?("self_supporting") &&
        loop_health.include?("no write capability requested")
    end

    def setup_infrastructure_loop_health_json_endpoint?(loop_health_json)
      payload = JSON.parse(loop_health_json)
      loop_state = payload.fetch("loop_state")
      signals = payload.fetch("signals")

      payload.fetch("status") == "self_supporting" &&
        signals.fetch("parity_matched") &&
        signals.fetch("migration_review_only") &&
        loop_state.fetch("write_capability_requested") == false
    end

    def setup_materializer_gate_endpoint?(materializer_gate)
      materializer_gate.include?("status=>:blocked") &&
        materializer_gate.include?("human_approval_required") &&
        materializer_gate.include?("write")
    end

    def setup_materializer_gate_json_endpoint?(materializer_gate_json)
      payload = JSON.parse(materializer_gate_json)

      payload.fetch("status") == "blocked" &&
        payload.fetch("approved_capabilities").empty? &&
        payload.fetch("blocked_capabilities") == %w[write git test restart] &&
        payload.fetch("reasons") == ["human_approval_required"] &&
        payload.fetch("approval_request").fetch("kind") == "materializer_capability_request" &&
        payload.fetch("approval_request").fetch("review_only")
    end

    def setup_materializer_preflight_endpoint?(materializer_preflight)
      materializer_preflight.include?("blocked_until_approval") &&
        materializer_preflight.include?("materializer_capability_request") &&
        materializer_preflight.include?("review-only")
    end

    def setup_materializer_preflight_json_endpoint?(materializer_preflight_json)
      payload = JSON.parse(materializer_preflight_json)
      checklist = payload.fetch("checklist")

      payload.fetch("status") == "blocked_until_approval" &&
        checklist.values.all? &&
        payload.fetch("evidence").fetch("blocked_capabilities") == %w[write git test restart] &&
        payload.fetch("evidence").fetch("reasons") == ["human_approval_required"] &&
        payload.fetch("approval_request").fetch("kind") == "materializer_capability_request" &&
        payload.fetch("approval_request").fetch("review_only")
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

      summary.fetch(:record_count) == 6 &&
        summary.fetch(:history_count) == 4 &&
        summary.fetch(:projection_count) == 3 &&
        summary.fetch(:command_count) == 3 &&
        summary.fetch(:relation_count) == 2 &&
        manifest.fetch(:records).fetch(:articles).fetch(:fields).include?(:status) &&
        manifest.fetch(:records).fetch(:wizard_type_specs).fetch(:fields).include?(:spec) &&
        manifest.fetch(:histories).fetch(:comments).fetch(:fields).include?(:article_id) &&
        manifest.fetch(:histories).fetch(:wizard_type_spec_changes).fetch(:fields).include?(:change_kind) &&
        manifest.fetch(:records).fetch(:reminders).fetch(:operations) == %i[all find save update delete clear scope command] &&
        manifest.fetch(:histories).fetch(:tracker_logs).fetch(:operations) == %i[append all where count] &&
        manifest.fetch(:projections).fetch(:tracker_read_model).fetch(:relations) == %i[tracker_logs_by_tracker] &&
        manifest.fetch(:relations).fetch(:tracker_logs_by_tracker).fetch(:join) == { id: :tracker_id } &&
        manifest.fetch(:commands).fetch(:tracker_log_commands).fetch(:operations).include?(:history_append)
    end

    def persistence_relation_manifest?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      manifest = persistence.manifest_snapshot
      relation = manifest.fetch(:relations).fetch(:tracker_logs_by_tracker)
      article_relation = manifest.fetch(:relations).fetch(:comments_by_article)

      persistence.valid? &&
        relation.fetch(:kind) == :event_owner &&
        relation.fetch(:from) == :trackers &&
        relation.fetch(:to) == :tracker_logs &&
        relation.fetch(:join) == { id: :tracker_id } &&
        relation.fetch(:cardinality) == :one_to_many &&
        relation.fetch(:projection) == :tracker_read_model &&
        relation.fetch(:enforced) == false &&
        article_relation.fetch(:from) == :articles &&
        article_relation.fetch(:to) == :comments &&
        article_relation.fetch(:join) == { id: :article_id } &&
        article_relation.fetch(:enforced) == false
    end

    def projection_relation_manifest?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      projection = persistence.manifest_snapshot.fetch(:projections).fetch(:tracker_read_model)

      persistence.valid? &&
        projection.fetch(:reads) == %i[trackers tracker_logs] &&
        projection.fetch(:relations) == %i[tracker_logs_by_tracker]
    end

    def relation_health_warning?
      clean = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      orphaned_state = Services::CompanionState.seeded
      orphaned_state.tracker_logs << Services::CompanionState::TrackerLog.new(
        tracker_id: "ghost-tracker",
        date: Date.today.iso8601,
        value: "7"
      )
      orphaned = Services::CompanionPersistence.new(state: orphaned_state)
      readiness = orphaned.readiness
      warning = readiness.fetch(:warnings).first

      clean.relation_warnings.fetch(:tracker_logs_by_tracker).empty? &&
        orphaned.relation_health.fetch(:status) == :warning &&
        orphaned.relation_health.fetch(:relation_reports).fetch(:tracker_logs_by_tracker).fetch(:warning_count) == 1 &&
        readiness.fetch(:ready) &&
        readiness.fetch(:warning_count) == 1 &&
        warning.fetch(:relation) == :tracker_logs_by_tracker &&
        warning.fetch(:kind) == :missing_source &&
        warning.fetch(:values) == ["ghost-tracker"]
    end

    def relation_health_dashboard?(html)
      html.include?('data-relation-health-status="clear"') &&
        html.include?('data-relation-warning-count="0"') &&
        html.include?("relations clear")
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

    def user_defined_article_contract?
      article_manifest = Contracts::Article.persistence_manifest
      comment_manifest = Contracts::Comment.persistence_manifest
      api = Services::ContractRecordSet.new(
        contract_class: Contracts::Article,
        collection: [],
        record_class: Services::CompanionState::Article
      ).api_manifest
      comments = Services::ContractHistory.new(
        contract_class: Contracts::Comment,
        entries: -> { [] },
        append: ->(event) { event }
      ).api_manifest
      article = Services::CompanionPersistence.new(state: Services::CompanionState.seeded).articles.find("welcome-note")

      article_manifest.fetch(:persist).fetch(:key) == :id &&
        article_manifest.fetch(:fields).any? { |field| field.fetch(:name) == :status && field.fetch(:attributes).fetch(:default) == :draft } &&
        article_manifest.fetch(:fields).any? { |field| field.fetch(:name) == :status && field.fetch(:attributes).fetch(:type) == :enum } &&
        article_manifest.fetch(:commands).any? { |command| command.fetch(:name) == :publish && command.fetch(:attributes).fetch(:changes) == { status: :published } } &&
        comment_manifest.fetch(:history).fetch(:key) == :index &&
        comment_manifest.fetch(:fields).any? { |field| field.fetch(:name) == :article_id } &&
        api.fetch(:scopes).any? { |scope| scope.fetch(:name) == :drafts } &&
        comments.fetch(:operations) == %i[append all where count] &&
        article.status == :draft
    end

    def wizard_type_spec_store?
      manifest = Contracts::WizardTypeSpec.persistence_manifest
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      record = persistence.wizard_type_specs.find("article-comment")
      api = persistence.manifest_snapshot.fetch(:records).fetch(:wizard_type_specs)

      manifest.fetch(:persist).fetch(:key) == :id &&
        manifest.fetch(:fields).any? { |field| field.fetch(:name) == :spec && field.fetch(:attributes).fetch(:type) == :json } &&
        api.fetch(:fields) == %i[id contract spec] &&
        record.contract == "Article" &&
        record.spec.fetch(:schema_version) == 1 &&
        record.spec.fetch(:id) == "article-comment" &&
        record.spec.fetch(:storage).fetch(:shape) == :store &&
        record.spec.fetch(:name) == :Article &&
        record.spec.fetch(:histories).first.fetch(:relation).fetch(:name) == :comments_by_article &&
        persistence.materialization_plan.fetch(:record_contract).fetch(:contract) == record.spec.fetch(:name)
    end

    def wizard_type_spec_history?
      manifest = Contracts::WizardTypeSpecChange.persistence_manifest
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      changes = persistence.wizard_type_spec_changes.all

      manifest.fetch(:history).fetch(:key) == :index &&
        manifest.fetch(:fields).any? { |field| field.fetch(:name) == :spec && field.fetch(:attributes).fetch(:type) == :json } &&
        changes.any? { |change| change.fetch(:spec_id) == "article-comment" && change.fetch(:change_kind) == :seeded_static_sync } &&
        changes.first.fetch(:spec).fetch(:schema_version) == 1 &&
        changes.first.fetch(:spec).fetch(:name) == :Article
    end

    def wizard_type_spec_export?
      export = Services::CompanionPersistence.new(state: Services::CompanionState.seeded).wizard_type_spec_export

      export.fetch(:schema_versions) == [1] &&
        export.fetch(:dev_config).fetch(:compressed) == false &&
        export.fetch(:dev_config).fetch(:history).any? &&
        export.fetch(:prod_config).fetch(:compressed) &&
        export.fetch(:prod_config).fetch(:history).empty? &&
        export.fetch(:prod_config).fetch(:specs).length == export.fetch(:dev_config).fetch(:specs).length
    end

    def wizard_type_spec_migration_plan?
      current = Services::CompanionPersistence.new(state: Services::CompanionState.seeded).wizard_type_spec_migration_plan
      current_spec = Services::CompanionState.article_comment_type_spec
      previous_spec = current_spec.merge(
        fields: current_spec.fetch(:fields).reject { |field| field.fetch(:name) == :body }
      )
      synthetic = Contracts::WizardTypeSpecMigrationPlanContract.evaluate(
        spec_history: [
          {
            index: 0,
            spec_id: "article-comment",
            contract: "Article",
            change_kind: :wizard_edit,
            spec: previous_spec,
            created_at: "2026-04-28"
          },
          {
            index: 1,
            spec_id: "article-comment",
            contract: "Article",
            change_kind: :wizard_edit,
            spec: current_spec,
            created_at: "2026-04-29"
          }
        ]
      )
      candidate = synthetic.fetch(:reports).first.fetch(:candidates).first

      current.fetch(:status) == :stable &&
        current.fetch(:candidate_count).zero? &&
        synthetic.fetch(:status) == :review_required &&
        candidate.fetch(:kind) == :additive &&
        candidate.fetch(:review_only) &&
        candidate.fetch(:added_fields) == [:body]
    end

    def infrastructure_loop_health?
      health = Services::CompanionPersistence.new(state: Services::CompanionState.seeded).infrastructure_loop_health

      health.fetch(:status) == :self_supporting &&
        health.fetch(:signals).values.all? &&
        health.fetch(:loop_state).fetch(:schema_version) == 1 &&
        health.fetch(:loop_state).fetch(:checked_capabilities) == %i[articles comments comments_by_article] &&
        health.fetch(:loop_state).fetch(:write_capability_requested) == false &&
        health.fetch(:summary).include?("no write capability requested")
    end

    def materializer_gate?
      persistence = Services::CompanionPersistence.new(state: Services::CompanionState.seeded)
      blocked = persistence.materializer_gate
      approved = persistence.materializer_gate(approved: true)

      blocked.fetch(:status) == :blocked &&
        blocked.fetch(:reasons) == %i[human_approval_required] &&
        blocked.fetch(:approved_capabilities).empty? &&
        blocked.fetch(:blocked_capabilities) == %i[write git test restart] &&
        blocked.fetch(:approval_request).fetch(:contract) == :Article &&
        blocked.fetch(:approval_request).fetch(:review_only) &&
        approved.fetch(:status) == :ready_to_request_capabilities &&
        approved.fetch(:approval_request).fetch(:requested_capabilities) == %i[write git test restart] &&
        approved.fetch(:approved_capabilities) == %i[write git test restart]
    end

    def materializer_preflight?
      preflight = Services::CompanionPersistence.new(state: Services::CompanionState.seeded).materializer_preflight

      preflight.fetch(:status) == :blocked_until_approval &&
        preflight.fetch(:checklist).values.all? &&
        preflight.fetch(:evidence).fetch(:blocked_capabilities) == %i[write git test restart] &&
        preflight.fetch(:evidence).fetch(:reasons) == %i[human_approval_required] &&
        preflight.fetch(:approval_request).fetch(:kind) == :materializer_capability_request &&
        preflight.fetch(:summary).include?("review-only")
    end

    def wizard_type_spec_canonical?
      spec = Services::CompanionState.article_comment_type_spec
      history = spec.fetch(:histories).first

      spec.fetch(:schema_version) == 1 &&
        spec.fetch(:kind) == :record &&
        spec.fetch(:storage) == { shape: :store, key: :id, adapter: :sqlite } &&
        spec.fetch(:persist) == { key: :id, adapter: :sqlite } &&
        history.fetch(:storage) == { shape: :history, key: :index, adapter: :sqlite } &&
        history.fetch(:history) == { key: :index, adapter: :sqlite } &&
        history.fetch(:relation).fetch(:enforced) == false
    end

    def static_materialization_plan?
      plan = Services::CompanionPersistence.new(state: Services::CompanionState.seeded).materialization_plan
      record = plan.fetch(:record_contract)
      relation = plan.fetch(:relations).fetch(:comments_by_article)

      plan.fetch(:status) == :ready_for_static_materialization &&
        plan.fetch(:schema_version) == 1 &&
        plan.fetch(:static_required) &&
        record.fetch(:contract) == :Article &&
        record.fetch(:storage).fetch(:shape) == :store &&
        record.fetch(:fields).any? { |field| field.fetch(:name) == :status && field.fetch(:default, field.dig(:attributes, :default)) == :draft } &&
        plan.fetch(:history_contracts).any? { |history| history.fetch(:contract) == :Comment && history.fetch(:storage).fetch(:shape) == :history } &&
        relation.fetch(:from) == :articles &&
        relation.fetch(:to) == :comments &&
        relation.fetch(:enforced) == false &&
        plan.fetch(:required_capabilities) == %i[write git test restart] &&
        plan.fetch(:validation_errors).empty?
    end

    def static_materialization_parity?
      parity = Services::CompanionPersistence.new(state: Services::CompanionState.seeded).materialization_parity

      parity.fetch(:status) == :matched &&
        parity.fetch(:schema_version) == 1 &&
        parity.fetch(:plan_status) == :ready_for_static_materialization &&
        parity.fetch(:static_required) &&
        parity.fetch(:checked_capabilities) == %i[articles comments comments_by_article] &&
        parity.fetch(:mismatches).empty? &&
        parity.fetch(:summary).include?("3 planned capabilities")
    end

    def setup_manifest?(manifest)
      manifest.include?("records") &&
        manifest.include?("histories") &&
        manifest.include?("projections") &&
        manifest.include?("commands") &&
        manifest.include?("relations") &&
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
