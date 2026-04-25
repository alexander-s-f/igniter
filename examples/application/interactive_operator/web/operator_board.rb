# frozen_string_literal: true

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
      card: "margin-top: 14px; padding: 18px; background: #fffdf7; border: 1px solid #2f2a1f;",
      resolved_card: " opacity: 0.62;",
      task_title: "margin: 0 0 8px;",
      task_status: "margin: 0 0 14px;",
      action_button: "padding: 10px 14px; border: 1px solid #2f2a1f; background: #f2b84b; cursor: pointer;",
      resolved_label: "margin: 0; font-weight: 700;",
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

    def self.operator_board_mount
      application = Igniter::Web.application do
        root title: "Operator task board" do
          board = assigns[:ctx].service(:task_board).call

          main class: "task-board",
               "data-ig-poc-surface": "operator_task_board",
               style: InteractiveOperator::Web.style(:shell) do
            header style: InteractiveOperator::Web.style(:header) do
              div do
                para "Interactive Igniter POC", style: InteractiveOperator::Web.style(:eyebrow)
                h1 "Operator task board", style: InteractiveOperator::Web.style(:title)
              end

              aside class: "open-count",
                    "data-open-count": board.open_count,
                    style: InteractiveOperator::Web.style(:counter) do
                strong board.open_count.to_s, style: InteractiveOperator::Web.style(:counter_value)
                span "open tasks"
              end
            end

            para "This page is rendered by igniter-web, reads app-owned state through MountContext, and submits a Rack POST back to the host.",
                 style: InteractiveOperator::Web.style(:intro)

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

            board.tasks.each do |task|
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

            footer style: InteractiveOperator::Web.style(:footer) do
              para "Read endpoint: GET /events -> open=#{board.open_count}",
                   style: InteractiveOperator::Web.style(:footer_text)
            end
          end
        end
      end

      Igniter::Web.mount(:operator_board, path: "/", application: application)
    end
  end
end
