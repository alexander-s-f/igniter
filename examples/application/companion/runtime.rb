# frozen_string_literal: true

require "fileutils"
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
      config = Companion.default_configuration(store_path: db_path)
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
      log_status, log_headers = post(app, "/trackers/sleep/log", value: "7.5")
      logged_status = get_status(app, log_headers.fetch("location"))
      complete_status, complete_headers = post(app, "/reminders/morning-water/complete")
      completed_status = get_status(app, complete_headers.fetch("location"))

      events_status, _events_headers, events_body = app.call(rack_env("GET", "/events"))
      setup_status, _setup_headers, setup_body = app.call(rack_env("GET", "/setup"))
      html_status, _html_headers, html_body = app.call(rack_env("GET", "/"))
      final = store.snapshot
      persisted = Companion.build(config: config).service(:companion).snapshot
      html = html_body.join
      events = events_body.join
      setup = setup_body.join

      out.puts "companion_poc_live_ready=#{initial.live_ready}"
      out.puts "companion_poc_open_reminders=#{final.open_reminders}"
      out.puts "companion_poc_tracker_logs=#{final.tracker_logs_today}"
      out.puts "companion_poc_countdowns=#{final.countdown_count}"
      out.puts "companion_poc_store_backend=#{config.store_backend}"
      out.puts "companion_poc_store_file=#{File.exist?(db_path)}"
      out.puts "companion_poc_sqlite_persisted=#{persisted.tracker_logs_today == final.tracker_logs_today}"
      out.puts "companion_poc_summary=#{final.daily_summary.fetch(:summary).include?("tracker logs")}"
      out.puts "companion_poc_create_status=#{create_status}"
      out.puts "companion_poc_created_status=#{created_status}"
      out.puts "companion_poc_log_status=#{log_status}"
      out.puts "companion_poc_logged_status=#{logged_status}"
      out.puts "companion_poc_complete_status=#{complete_status}"
      out.puts "companion_poc_completed_status=#{completed_status}"
      out.puts "companion_poc_events_status=#{events_status}"
      out.puts "companion_poc_setup_status=#{setup_status}"
      out.puts "companion_poc_html_status=#{html_status}"
      out.puts "companion_poc_setup_redacted=#{setup.include?("openai_api_key") && !setup.include?("sk-")}"
      out.puts "companion_poc_web_surface=#{html.include?('data-ig-poc-surface="companion_dashboard"')}"
      out.puts "companion_poc_capsules=#{%w[reminders trackers countdowns daily-summary].all? { |name| html.include?("data-capsule=\"#{name}\"") }}"
      out.puts "companion_poc_events_parity=#{events.include?("tracker_logs=#{final.tracker_logs_today}")}"
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
