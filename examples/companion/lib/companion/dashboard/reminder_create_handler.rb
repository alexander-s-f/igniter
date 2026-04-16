# frozen_string_literal: true

require "igniter/plugins/view"

module Companion
  module Dashboard
    module ReminderCreateHandler
      module_function

      def call(params:, body:, headers:, env: nil, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
        task = body.fetch("task", "").to_s.strip
        timing = body.fetch("timing", "").to_s.strip
        channel = body.fetch("channel", "").to_s.strip
        chat_id = body.fetch("chat_id", "").to_s.strip
        notifications_enabled = body["notifications_enabled"] == "1"

        return validation_error("task is required") if task.empty?
        return validation_error("timing is required") if timing.empty?

        reminder = Companion::ReminderStore.create(
          task: task,
          timing: timing,
          request: [task, timing].join(" — "),
          channel: presence(channel),
          chat_id: presence(chat_id),
          notifications_enabled: presence(channel) == "telegram" ? notifications_enabled : nil
        )

        {
          status: 303,
          body: "",
          headers: {
            "Location" => "/?created_reminder=#{reminder.fetch("id")}"
          }
        }
      end

      def validation_error(message)
        body = Igniter::Plugins::View.render do |view|
          view.doctype
          view.tag(:html, lang: "en") do |html|
            html.tag(:head) do |head|
              head.tag(:meta, charset: "utf-8")
              head.tag(:title, "Reminder Error")
            end
            html.tag(:body) do |page|
              page.tag(:main) do |main|
                main.tag(:h1, "Reminder could not be created")
                main.tag(:p, message)
                main.tag(:p) do |paragraph|
                  paragraph.tag(:a, "Back to dashboard", href: "/")
                end
              end
            end
          end
        end

        Igniter::Plugins::View::Response.html(body, status: 422)
      end

      def presence(value)
        stripped = value.to_s.strip
        stripped.empty? ? nil : stripped
      end
    end
  end
end
