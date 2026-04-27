#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-web/lib", __dir__))

require "stringio"
require "uri"

require_relative "companion/app"

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

if ARGV.first == "server"
  require "webrick"

  app = Companion.build
  server = WEBrick::HTTPServer.new(
    Port: Integer(ENV.fetch("PORT", "9298")),
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
  puts "companion_poc_url=http://127.0.0.1:#{server.config[:Port]}/"
  server.start
  exit
end

ENV.delete("OPENAI_API_KEY") unless ENV["COMPANION_LIVE"] == "1"

app = Companion.build
store = app.service(:companion)
initial = store.snapshot

create_status, create_headers, = app.call(
  rack_env("POST", "/reminders/create", form_body(title: "Stretch for five minutes"))
)
created_status, = app.call(rack_env("GET", create_headers.fetch("location")))

log_status, log_headers, = app.call(
  rack_env("POST", "/trackers/sleep/log", form_body(value: "7.5"))
)
logged_status, = app.call(rack_env("GET", log_headers.fetch("location")))

complete_status, complete_headers, = app.call(
  rack_env("POST", "/reminders/morning-water/complete")
)
completed_status, = app.call(rack_env("GET", complete_headers.fetch("location")))

events_status, _events_headers, events_body = app.call(rack_env("GET", "/events"))
setup_status, _setup_headers, setup_body = app.call(rack_env("GET", "/setup"))
html_status, _html_headers, html_body = app.call(rack_env("GET", "/"))
final = store.snapshot
html = html_body.join
events = events_body.join
setup = setup_body.join

puts "companion_poc_live_ready=#{initial.live_ready}"
puts "companion_poc_open_reminders=#{final.open_reminders}"
puts "companion_poc_tracker_logs=#{final.tracker_logs_today}"
puts "companion_poc_countdowns=#{final.countdown_count}"
puts "companion_poc_summary=#{final.daily_summary.fetch(:summary).include?("tracker logs")}"
puts "companion_poc_create_status=#{create_status}"
puts "companion_poc_created_status=#{created_status}"
puts "companion_poc_log_status=#{log_status}"
puts "companion_poc_logged_status=#{logged_status}"
puts "companion_poc_complete_status=#{complete_status}"
puts "companion_poc_completed_status=#{completed_status}"
puts "companion_poc_events_status=#{events_status}"
puts "companion_poc_setup_status=#{setup_status}"
puts "companion_poc_html_status=#{html_status}"
puts "companion_poc_setup_redacted=#{setup.include?("openai_api_key") && !setup.include?("sk-")}"
puts "companion_poc_web_surface=#{html.include?('data-ig-poc-surface="companion_dashboard"')}"
puts "companion_poc_capsules=#{%w[reminders trackers countdowns daily-summary].all? { |name| html.include?("data-capsule=\"#{name}\"") }}"
puts "companion_poc_events_parity=#{events.include?("tracker_logs=#{final.tracker_logs_today}")}"
