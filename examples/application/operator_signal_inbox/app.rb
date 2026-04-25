# frozen_string_literal: true

require "uri"

require "igniter/application"

require_relative "services/signal_inbox"
require_relative "web/signal_inbox"

module OperatorSignalInbox
  APP_ROOT = File.expand_path(__dir__)

  def self.feedback_path(params)
    "/?#{URI.encode_www_form(params)}"
  end

  def self.events_read_model(snapshot)
    recent = snapshot.recent_events.map do |event|
      signal_id = event.fetch(:signal_id) || "-"
      "#{event.fetch(:kind)}:#{signal_id}:#{event.fetch(:status)}"
    end
    "open=#{snapshot.open_count} critical=#{snapshot.critical_count} actions=#{snapshot.action_count} recent=#{recent.join("|")}"
  end

  def self.build
    Igniter::Application.rack_app(:operator_signal_inbox, root: APP_ROOT, env: :test) do
      service(:signal_inbox) { Services::SignalInbox.new }

      mount_web(
        :signal_inbox,
        Web.signal_inbox_mount,
        at: "/",
        capabilities: %i[screen command],
        metadata: { poc: true }
      )

      get "/events" do
        text OperatorSignalInbox.events_read_model(service(:signal_inbox).snapshot(recent_limit: 7))
      end

      post "/signals/acknowledge" do |params|
        result = service(:signal_inbox).acknowledge(params.fetch("id", ""))
        if result.success?
          redirect OperatorSignalInbox.feedback_path(notice: result.feedback_code, signal: result.signal_id)
        else
          redirect OperatorSignalInbox.feedback_path(error: result.feedback_code, signal: result.signal_id)
        end
      end

      post "/signals/escalate" do |params|
        result = service(:signal_inbox).escalate(params.fetch("id", ""), note: params.fetch("note", ""))
        if result.success?
          redirect OperatorSignalInbox.feedback_path(notice: result.feedback_code, signal: result.signal_id)
        else
          redirect OperatorSignalInbox.feedback_path(error: result.feedback_code, signal: result.signal_id)
        end
      end
    end
  end
end
