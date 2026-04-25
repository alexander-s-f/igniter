# frozen_string_literal: true

require "igniter/web"

module InteractiveOperator
  module Web
    def self.operator_board_mount
      application = Igniter::Web.application do
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

      Igniter::Web.mount(:operator_board, path: "/", application: application)
    end
  end
end
