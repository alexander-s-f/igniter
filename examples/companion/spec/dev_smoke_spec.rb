# frozen_string_literal: true

require_relative "spec_helper"
require "json"
require "net/http"
require "open3"
require "timeout"

RSpec.describe "Companion dev stack smoke" do
  ROOT = File.expand_path("..", __dir__)

  def http_get(port, path)
    Net::HTTP.start("127.0.0.1", port, read_timeout: 5) do |http|
      http.get(path)
    end
  end

  it "serves dashboard html and overview json via bin/dev" do
    base_port = 46670 + rand(200)
    main_port = base_port
    inference_port = base_port + 1
    dashboard_port = base_port + 2
    output = +""

    Open3.popen2e(
      {
        "ORCHESTRATOR_PORT" => main_port.to_s,
        "INFERENCE_PORT" => inference_port.to_s,
        "DASHBOARD_PORT" => dashboard_port.to_s
      },
      File.join(ROOT, "bin/dev"),
      chdir: ROOT
    ) do |_stdin, stdout_and_stderr, wait_thread|
      reader = Thread.new do
        stdout_and_stderr.each_line do |line|
          output << line
        end
      end

      begin
        root_response = nil
        overview_response = nil

        Timeout.timeout(15) do
          loop do
            if wait_thread.join(0)
              raise "companion dev stack exited early:\n#{output}"
            end

            begin
              root_response = http_get(dashboard_port, "/")
              overview_response = http_get(dashboard_port, "/api/overview")
              break
            rescue Errno::ECONNREFUSED, EOFError, Net::ReadTimeout
              sleep 0.1
            end
          end
        end

        expect(root_response.code).to eq("200")
        expect(root_response["Content-Type"]).to include("text/html")
        expect(root_response.body).to include("Companion Dashboard")
        expect(root_response.body).to include("@tailwindcss/browser@4")

        expect(overview_response.code).to eq("200")
        expect(overview_response["Content-Type"]).to include("application/json")

        overview = JSON.parse(overview_response.body)
        expect(overview.dig("stack", "default_app")).to eq("main")
        expect(overview.dig("counts", "view_schemas")).to eq(2)
        expect(overview.fetch("view_schemas")).to include(
          include("id" => "training-checkin"),
          include("id" => "weekly-review")
        )
      ensure
        begin
          Process.kill("INT", wait_thread.pid)
        rescue Errno::ESRCH
          nil
        end
        wait_thread.value
        reader.join
      end
    end
  end

  it "fails fast with a clear preflight error when a port is already occupied" do
    occupied_port = 46890 + rand(50)
    server = TCPServer.new("0.0.0.0", occupied_port)
    output = +""
    status = nil

    Open3.popen2e(
      {
        "ORCHESTRATOR_PORT" => (occupied_port - 2).to_s,
        "INFERENCE_PORT" => (occupied_port - 1).to_s,
        "DASHBOARD_PORT" => occupied_port.to_s
      },
      File.join(ROOT, "bin/dev"),
      chdir: ROOT
    ) do |_stdin, stdout_and_stderr, wait_thread|
      reader = Thread.new do
        stdout_and_stderr.each_line do |line|
          output << line
        end
      end

      finished = wait_thread.join(5)
      unless finished
        begin
          Process.kill("INT", wait_thread.pid)
        rescue Errno::ESRCH
          nil
        end
        raise "bin/dev did not fail fast:\n#{output}"
      end

      status = wait_thread.value
      reader.join
    end

    expect(status.success?).to be(false)
    expect(output).to include("companion/bin/dev preflight failed")
    expect(output).to include("dashboard port #{occupied_port} is already in use")
    expect(output).to include("DASHBOARD_PORT")
  ensure
    server&.close
  end
end
