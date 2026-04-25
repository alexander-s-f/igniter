#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-web/lib", __dir__))

require "stringio"

require_relative "interactive_operator/app"

app = InteractiveOperator.build

def rack_env(method, path, body = "")
  {
    "REQUEST_METHOD" => method,
    "PATH_INFO" => path,
    "rack.input" => StringIO.new(body)
  }
end

if ARGV.first == "server"
  require "webrick"

  server = WEBrick::HTTPServer.new(Port: Integer(ENV.fetch("PORT", "9292")), AccessLog: [], Logger: WEBrick::Log.new(File::NULL))
  server.mount_proc("/") do |request, response|
    status, headers, body = app.call(
      "REQUEST_METHOD" => request.request_method,
      "PATH_INFO" => request.path,
      "rack.input" => StringIO.new(request.body.to_s)
    )
    response.status = status
    headers.each { |key, value| response[key] = value }
    response.body = body.join
  end
  trap("INT") { server.shutdown }
  puts "interactive_web_poc_url=http://127.0.0.1:#{server.config[:Port]}/"
  server.start
else
  initial_status, initial_headers, initial_body = app.call(rack_env("GET", "/"))
  create_status, _create_headers, _create_body = app.call(
    rack_env("POST", "/tasks/create", "title=Review+operator+handoff")
  )
  created_status, _created_headers, created_body = app.call(rack_env("GET", "/"))
  post_status, _post_headers, _post_body = app.call(rack_env("POST", "/tasks", "id=triage-sensor"))
  final_status, _final_headers, final_body = app.call(rack_env("GET", "/"))
  events_status, _events_headers, events_body = app.call(rack_env("GET", "/events"))
  initial_html = initial_body.join
  created_html = created_body.join
  final_html = final_body.join

  puts "interactive_web_poc_initial_status=#{initial_status}"
  puts "interactive_web_poc_content_type=#{initial_headers.fetch("content-type")}"
  puts "interactive_web_poc_initial_open=#{initial_html.include?("data-open-count=\"2\"")}"
  puts "interactive_web_poc_create_status=#{create_status}"
  puts "interactive_web_poc_created_status=#{created_status}"
  puts "interactive_web_poc_created_open=#{created_html.include?("data-open-count=\"3\"")}"
  puts "interactive_web_poc_created_task=#{created_html.include?("data-task-id=\"review-operator-handoff\"")}"
  puts "interactive_web_poc_post_status=#{post_status}"
  puts "interactive_web_poc_final_status=#{final_status}"
  puts "interactive_web_poc_final_open=#{final_html.include?("data-open-count=\"2\"")}"
  puts "interactive_web_poc_surface=#{final_html.include?("data-ig-poc-surface=\"operator_task_board\"")}"
  puts "interactive_web_poc_resolved=#{app.service(:task_board).resolved?("triage-sensor")}"
  puts "interactive_web_poc_events_status=#{events_status}"
  puts "interactive_web_poc_events=#{events_body.join}"
  puts "interactive_web_poc_service=#{app.service(:task_board).name}"
end
