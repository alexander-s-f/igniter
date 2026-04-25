# frozen_string_literal: true

require "uri"

require "igniter/web"

module InteractiveOperator
  module Web
    STYLES = {
      shell: "max-width: 760px; margin: 40px auto; padding: 28px; font-family: ui-sans-serif, system-ui; background: #f8f4ea; border: 1px solid #2f2a1f; box-shadow: 10px 10px 0 #2f2a1f;",
      header: "display: flex; justify-content: space-between; gap: 20px; align-items: flex-start;",
      eyebrow: "margin: 0 0 8px; text-transform: uppercase; letter-spacing: 0.16em; font-size: 12px;",
      title: "margin: 0; font-size: 42px; line-height: 1;",
      counter: "min-width: 120px; padding: 14px; color: #f8f4ea; background: #2f2a1f; text-align: center;",
      counter_value: "display: block; font-size: 34px;",
      intro: "margin: 22px 0; max-width: 620px;",
      create_panel: "margin: 22px 0; padding: 18px; background: #2f2a1f; color: #f8f4ea;",
      create_label: "display: block; margin-bottom: 8px; font-weight: 700;",
      create_input: "width: min(100%, 420px); padding: 10px; border: 1px solid #f8f4ea; margin-right: 8px;",
      create_button: "padding: 10px 14px; border: 1px solid #f8f4ea; background: #f2b84b; cursor: pointer;",
      feedback: "margin: 18px 0; padding: 12px 14px; border: 1px solid #2f2a1f; font-weight: 700;",
      feedback_notice: " background: #e6f2c4;",
      feedback_error: " background: #ffd8c8;",
      card: "margin-top: 14px; padding: 18px; background: #fffdf7; border: 1px solid #2f2a1f;",
      resolved_card: " opacity: 0.62;",
      task_title: "margin: 0 0 8px;",
      task_status: "margin: 0 0 14px;",
      action_button: "padding: 10px 14px; border: 1px solid #2f2a1f; background: #f2b84b; cursor: pointer;",
      resolved_label: "margin: 0; font-weight: 700;",
      activity_panel: "margin-top: 22px; padding: 18px; background: #fff6d8; border: 1px solid #2f2a1f;",
      activity_title: "margin: 0 0 12px; font-size: 18px;",
      activity_list: "margin: 0; padding-left: 20px;",
      activity_item: "margin-top: 8px;",
      activity_meta: "font-size: 12px; text-transform: uppercase; letter-spacing: 0.08em;",
      footer: "margin-top: 22px; font-size: 13px;",
      footer_text: "margin: 0;"
    }.freeze

    def self.style(name)
      STYLES.fetch(name)
    end

    def self.card_style(task)
      style = STYLES.fetch(:card).dup
      style << STYLES.fetch(:resolved_card) if task.status == :resolved
      style
    end

    def self.status_label(task)
      task.status == :resolved ? "Resolved" : "Awaiting operator"
    end

    def self.feedback_for(env)
      params = URI.decode_www_form(env.fetch("QUERY_STRING", "").to_s).to_h
      return notice_feedback(params) if params.key?("notice")
      return error_feedback(params) if params.key?("error")

      nil
    end

    def self.notice_feedback(params)
      case params.fetch("notice")
      when "task_created"
        feedback(:notice, "Task created.", "task_created")
      when "task_resolved"
        feedback(:notice, "Task resolved.", "task_resolved")
      end
    end

    def self.error_feedback(params)
      case params.fetch("error")
      when "blank_title"
        feedback(:error, "Task title cannot be blank.", "blank_title")
      when "task_not_found"
        feedback(:error, "Task not found.", "task_not_found")
      end
    end

    def self.feedback(kind, message, code)
      {
        kind: kind,
        code: code,
        message: message
      }.freeze
    end

    def self.feedback_style(feedback)
      "#{style(:feedback)}#{style(:"feedback_#{feedback.fetch(:kind)}")}"
    end

    def self.activity_label(event)
      case event.fetch(:kind)
      when :task_seeded
        "Seeded task"
      when :task_created
        "Created task"
      when :task_create_refused
        "Create refused"
      when :task_resolved
        "Resolved task"
      when :task_resolve_refused
        "Resolve refused"
      else
        event.fetch(:kind).to_s.tr("_", " ")
      end
    end

    def self.activity_task_id(event)
      event.fetch(:task_id) || "-"
    end

    def self.operator_board_mount
      application = Igniter::Web.application do
        root title: "Operator task board" do
          snapshot = assigns[:ctx].service(:task_board).call.snapshot(recent_limit: 5)
          feedback = InteractiveOperator::Web.feedback_for(assigns[:env])

          main class: "task-board",
               "data-ig-poc-surface": "operator_task_board",
               style: InteractiveOperator::Web.style(:shell) do
            header style: InteractiveOperator::Web.style(:header) do
              div do
                para "Interactive Igniter POC", style: InteractiveOperator::Web.style(:eyebrow)
                h1 "Operator task board", style: InteractiveOperator::Web.style(:title)
              end

              aside class: "open-count",
                    "data-open-count": snapshot.open_count,
                    style: InteractiveOperator::Web.style(:counter) do
                strong snapshot.open_count.to_s, style: InteractiveOperator::Web.style(:counter_value)
                span "open tasks"
              end
            end

            para "This page is rendered by igniter-web, reads app-owned state through MountContext, and submits a Rack POST back to the host.",
                 style: InteractiveOperator::Web.style(:intro)

            if feedback
              section class: "feedback #{feedback.fetch(:kind)}",
                      "data-ig-feedback": feedback.fetch(:kind),
                      "data-feedback-code": feedback.fetch(:code),
                      style: InteractiveOperator::Web.feedback_style(feedback) do
                para feedback.fetch(:message), style: "margin: 0;"
              end
            end

            section class: "create-task",
                    "data-ig-create-task": "form",
                    style: InteractiveOperator::Web.style(:create_panel) do
              form action: "/tasks/create", method: "post" do
                label "Create a task", for: "task-title", style: InteractiveOperator::Web.style(:create_label)
                input id: "task-title",
                      name: "title",
                      type: "text",
                      placeholder: "Review operator handoff",
                      required: true,
                      style: InteractiveOperator::Web.style(:create_input)
                button "Add task",
                       type: "submit",
                       "data-action": "create-task",
                       style: InteractiveOperator::Web.style(:create_button)
              end
            end

            snapshot.tasks.each do |task|
              section class: "task #{task.status}",
                      "data-task-id": task.id,
                      "data-task-state": task.status,
                      style: InteractiveOperator::Web.card_style(task) do
                h2 task.title, style: InteractiveOperator::Web.style(:task_title)
                para "Status: #{InteractiveOperator::Web.status_label(task)}",
                     style: InteractiveOperator::Web.style(:task_status)
                if task.status == :open
                  form action: "/tasks", method: "post" do
                    input type: "hidden", name: "id", value: task.id
                    button "Resolve",
                           type: "submit",
                           "data-action": "resolve-task",
                           style: InteractiveOperator::Web.style(:action_button)
                  end
                else
                  para "Resolved", class: "resolved", style: InteractiveOperator::Web.style(:resolved_label)
                end
              end
            end

            section class: "recent-activity",
                    "data-ig-activity": "recent",
                    "data-activity-count": snapshot.recent_events.length,
                    style: InteractiveOperator::Web.style(:activity_panel) do
              h2 "Recent activity", style: InteractiveOperator::Web.style(:activity_title)
              ol style: InteractiveOperator::Web.style(:activity_list) do
                snapshot.recent_events.each do |event|
                  task_id = InteractiveOperator::Web.activity_task_id(event)
                  li "data-activity-index": event.fetch(:index),
                     "data-activity-kind": event.fetch(:kind),
                     "data-activity-task-id": task_id,
                     "data-activity-status": event.fetch(:status),
                     style: InteractiveOperator::Web.style(:activity_item) do
                    span "#{InteractiveOperator::Web.activity_label(event)}: #{task_id}",
                         style: InteractiveOperator::Web.style(:activity_meta)
                  end
                end
              end
            end

            footer style: InteractiveOperator::Web.style(:footer) do
              para "Read endpoint: GET /events -> open=#{snapshot.open_count}",
                   style: InteractiveOperator::Web.style(:footer_text)
            end
          end
        end
      end

      Igniter::Web.mount(:operator_board, path: "/", application: application)
    end
  end
end
