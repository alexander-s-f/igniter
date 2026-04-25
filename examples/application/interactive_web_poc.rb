#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-web/lib", __dir__))

require "stringio"
require "uri"

require "igniter/application"
require "igniter/web"

class InteractiveTaskBoard
  Task = Struct.new(:id, :title, :status, keyword_init: true)

  attr_reader :name

  def initialize
    @name = :operator_task_board
    @tasks = [
      Task.new(id: "triage-sensor", title: "Triage sensor drift", status: :open),
      Task.new(id: "ack-runbook", title: "Acknowledge runbook update", status: :open)
    ]
  end

  def tasks
    @tasks.map(&:dup)
  end

  def open_count
    @tasks.count { |task| task.status == :open }
  end

  def resolve(id)
    task = @tasks.find { |entry| entry.id == id.to_s }
    return false unless task

    task.status = :resolved
    true
  end

  def resolved?(id)
    @tasks.any? { |task| task.id == id.to_s && task.status == :resolved }
  end
end

class InteractivePocHost
  attr_reader :environment, :mount

  def initialize(environment:, mount:)
    @environment = environment
    @mount = mount.bind(environment: environment)
  end

  def call(env)
    case [env.fetch("REQUEST_METHOD", "GET"), env.fetch("PATH_INFO", "/")]
    in ["GET", "/"]
      mount.rack_app.call(env)
    in ["GET", "/events"]
      text_response("open=#{board.open_count}")
    in ["POST", "/tasks"]
      handle_task_post(env)
    else
      not_found
    end
  end

  private

  def handle_task_post(env)
    params = URI.decode_www_form(read_body(env)).to_h
    board.resolve(params.fetch("id", ""))
    [
      303,
      { "location" => "/", "content-type" => "text/plain; charset=utf-8" },
      ["See /"]
    ]
  end

  def read_body(env)
    input = env["rack.input"]
    input ? input.read.to_s : ""
  ensure
    input&.rewind
  end

  def board
    environment.service(:task_board).call
  end

  def text_response(body)
    [200, { "content-type" => "text/plain; charset=utf-8" }, [body]]
  end

  def not_found
    [404, { "content-type" => "text/plain; charset=utf-8" }, ["not found"]]
  end
end

board = InteractiveTaskBoard.new
kernel = Igniter::Application.build_kernel
kernel.manifest(:interactive_operator, root: "/tmp/igniter_interactive_operator", env: :test)
kernel.provide(:task_board, -> { board })

web = Igniter::Web.application do
  root title: "Operator task board" do
    board = assigns[:ctx].service(:task_board).call

    main class: "task-board",
         "data-ig-poc-surface": "operator_task_board",
         style: "max-width: 760px; margin: 40px auto; padding: 28px; font-family: ui-sans-serif, system-ui; background: #f8f4ea; border: 1px solid #2f2a1f; box-shadow: 10px 10px 0 #2f2a1f;" do
      header style: "display: flex; justify-content: space-between; gap: 20px; align-items: flex-start;" do
        div do
          para "Interactive Igniter POC", style: "margin: 0 0 8px; text-transform: uppercase; letter-spacing: 0.16em; font-size: 12px;"
          h1 "Operator task board", style: "margin: 0; font-size: 42px; line-height: 1;"
        end

        aside class: "open-count",
              "data-open-count": board.open_count,
              style: "min-width: 120px; padding: 14px; color: #f8f4ea; background: #2f2a1f; text-align: center;" do
          strong board.open_count.to_s, style: "display: block; font-size: 34px;"
          span "open tasks"
        end
      end

      para "This page is rendered by igniter-web, reads app-owned state through MountContext, and submits a Rack POST back to the host.",
           style: "margin: 22px 0; max-width: 620px;"

      board.tasks.each do |task|
        card_style = "margin-top: 14px; padding: 18px; background: #fffdf7; border: 1px solid #2f2a1f;"
        card_style += " opacity: 0.62;" if task.status == :resolved

        section class: "task #{task.status}", "data-task-id": task.id, style: card_style do
          h2 task.title, style: "margin: 0 0 8px;"
          para "Status: #{task.status}", style: "margin: 0 0 14px;"
          if task.status == :open
            form action: "/tasks", method: "post" do
              input type: "hidden", name: "id", value: task.id
              button "Resolve", type: "submit", style: "padding: 10px 14px; border: 1px solid #2f2a1f; background: #f2b84b; cursor: pointer;"
            end
          else
            para "Resolved", class: "resolved", style: "margin: 0; font-weight: 700;"
          end
        end
      end

      footer style: "margin-top: 22px; font-size: 13px;" do
        para "Read endpoint: GET /events -> open=#{board.open_count}", style: "margin: 0;"
      end
    end
  end
end

mount = Igniter::Web.mount(:operator_board, path: "/", application: web)
kernel.mount_web(:operator_board, mount, at: "/", capabilities: %i[screen command], metadata: { poc: true })
environment = Igniter::Application::Environment.new(profile: kernel.finalize)
app = InteractivePocHost.new(environment: environment, mount: mount)

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
  post_status, _post_headers, _post_body = app.call(rack_env("POST", "/tasks", "id=triage-sensor"))
  final_status, _final_headers, final_body = app.call(rack_env("GET", "/"))
  events_status, _events_headers, events_body = app.call(rack_env("GET", "/events"))
  initial_html = initial_body.join
  final_html = final_body.join

  puts "interactive_web_poc_initial_status=#{initial_status}"
  puts "interactive_web_poc_content_type=#{initial_headers.fetch("content-type")}"
  puts "interactive_web_poc_initial_open=#{initial_html.include?("data-open-count=\"2\"")}"
  puts "interactive_web_poc_post_status=#{post_status}"
  puts "interactive_web_poc_final_status=#{final_status}"
  puts "interactive_web_poc_final_open=#{final_html.include?("data-open-count=\"1\"")}"
  puts "interactive_web_poc_surface=#{final_html.include?("data-ig-poc-surface=\"operator_task_board\"")}"
  puts "interactive_web_poc_resolved=#{board.resolved?("triage-sensor")}"
  puts "interactive_web_poc_events_status=#{events_status}"
  puts "interactive_web_poc_events=#{events_body.join}"
  puts "interactive_web_poc_service=#{board.name}"
end
