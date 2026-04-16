# frozen_string_literal: true

require "json"
require "igniter/plugins/view"
require "igniter/plugins/view/tailwind"
require_relative "view_schema_catalog"
require_relative "view_shell"
require_relative "view_submission_store"

module Companion
  module Dashboard
    module ViewSubmissionHandler
      module_function

      def call(params:, body:, headers:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
        submission = ViewSubmissionStore.get(params[:id])
        return not_found(params[:id]) unless submission

        schema = ViewSchemaCatalog.store.get(submission.fetch("view_id"))
        page = render_submission_page(submission: submission, schema: schema)
        Igniter::Plugins::View::Response.html(page)
      end

      def render_submission_page(submission:, schema:)
        theme = Igniter::Plugins::View::Tailwind::UI::Theme.fetch(:companion)
        tokens = Igniter::Plugins::View::Tailwind::UI::Tokens

        Igniter::Plugins::View::Tailwind.render_page(
          title: "Submission #{submission.fetch("id")}",
          theme: :companion,
          main_class: "mx-auto flex min-h-screen w-full max-w-6xl flex-col gap-6 px-4 py-6 sm:px-6 lg:px-8"
        ) do |main|
          render_hero(main, submission: submission)
          main.tag(:section, class: "grid gap-5 xl:grid-cols-[minmax(0,0.9fr)_minmax(0,1.1fr)]") do |grid|
            grid.component(theme.panel(title: "Summary", subtitle: "Runtime-level context for this schema submission.") do |panel|
              panel.component(
                Igniter::Plugins::View::Tailwind::UI::KeyValueList.new(
                  rows: submission_rows(submission: submission, schema: schema)
                )
              )
            end)

            grid.component(theme.panel(title: "Replay", subtitle: "Replay the stored raw payload back into the originating schema action.") do |panel|
              replay_markup(panel, submission: submission, schema: schema, theme: theme, tokens: tokens)
            end)

            grid.component(theme.panel(title: "Raw Payload", subtitle: "Original form values as they were submitted.") do |panel|
              json_markup(panel, submission.fetch("raw_payload"), theme: theme)
            end)

            grid.component(theme.panel(title: "Normalized Payload", subtitle: "Payload after schema normalization and type coercion.") do |panel|
              json_markup(panel, submission.fetch("normalized_payload"), theme: theme)
            end)

            grid.component(theme.panel(title: "Normalization Diff", subtitle: "Field-level view of what changed between raw and normalized payloads.") do |panel|
              panel.component(
                theme.payload_diff(
                  raw_payload: submission.fetch("raw_payload"),
                  normalized_payload: submission.fetch("normalized_payload"),
                  empty_message: "No normalization differences were detected between raw and normalized payloads."
                )
              )
            end)

            grid.component(theme.panel(title: "Processing Result", subtitle: "Runtime result captured after submission processing.") do |panel|
              json_markup(panel, submission["processing_result"] || { ok: false, type: "pending" }, theme: theme)
            end)
          end
        end
      end

      def render_hero(view, submission:)
        hero_theme = Igniter::Plugins::View::Tailwind::UI::Theme.fetch(:companion).hero(:dashboard)

        view.tag(:section, class: hero_theme.fetch(:wrapper_class)) do |hero|
          hero.tag(:div, class: hero_theme.fetch(:glow_class))
          hero.tag(:div, class: hero_theme.fetch(:content_class)) do |content|
            content.tag(:p, "Submission Detail", class: hero_theme.fetch(:eyebrow_class))
            content.tag(:h1, "Submission #{submission.fetch("id")}", class: hero_theme.fetch(:title_class))
            content.tag(:p,
                        "Inspect stored payloads, processing output, and replay the original submission without leaving the companion dashboard.",
                        class: hero_theme.fetch(:body_class))
            content.tag(:div, class: hero_theme.fetch(:meta_class)) do |meta|
              meta.tag(:span, "view=#{submission.fetch("view_id")}")
              meta.tag(:span, "action=#{submission.fetch("action_id")}")
              meta.tag(:span, "status=#{submission.fetch("status")}")
            end
          end
        end
      end

      def submission_rows(submission:, schema:)
        {
          "Submission" => submission.fetch("id"),
          "View" => schema&.title || submission.fetch("view_id"),
          "View ID" => submission.fetch("view_id"),
          "Action" => submission.fetch("action_id"),
          "Status" => submission.fetch("status"),
          "Schema Version" => submission.fetch("schema_version"),
          "Created" => submission.fetch("created_at"),
          "Processed" => submission["processed_at"] || "pending",
          "Processing Type" => submission.dig("processing_result", "type") || "pending"
        }
      end

      def replay_markup(view, submission:, schema:, theme:, tokens:)
        action = schema&.actions&.dig(submission.fetch("action_id"))

        view.component(
          Igniter::Plugins::View::Tailwind::UI::ActionBar.new(class_name: "flex flex-wrap gap-2") do |bar|
            bar.tag(:a,
                    "Open submission source view",
                    href: "/views/#{submission.fetch("view_id")}",
                    class: tokens.action(variant: :soft, theme: :orange, size: :sm))
            bar.tag(:a,
                    "Open schema JSON",
                    href: "/api/views/#{submission.fetch("view_id")}",
                    class: tokens.action(variant: :ghost, theme: :orange, size: :sm))
          end
        )

        unless action && action["path"]
          view.tag(:p,
                   "Replay is unavailable because the source schema action could not be resolved.",
                   class: theme.empty_state_class)
          return
        end

        view.tag(:p,
                 "Replay will POST the stored raw payload back to #{action.fetch("path")}.",
                 class: theme.body_text_class(extra: "mt-4"))

        view.form(action: action.fetch("path"), method: action.fetch("method", "post"), class: "mt-4 grid gap-3") do |form|
          form.hidden("_action", submission.fetch("action_id"))
          hidden_fields_for_payload(form, submission.fetch("raw_payload"))
          form.submit("Replay Submission", class: tokens.action(variant: :primary, theme: :orange))
        end
      end

      def hidden_fields_for_payload(form, payload)
        payload.each do |name, value|
          next if name.to_s == "_action"

          case value
          when Array
            value.each { |entry| form.hidden(name, entry) }
          else
            form.hidden(name, value)
          end
        end
      end

      def json_markup(view, payload, theme:)
        view.tag(:pre, class: "#{theme.code_class} overflow-x-auto whitespace-pre-wrap") do |pre|
          pre.text(JSON.pretty_generate(payload))
        end
      end

      def not_found(submission_id)
        body = ViewShell.render_message_page(
          title: "Submission not found",
          eyebrow: "Submission Detail",
          message: "No stored submission is available for #{submission_id}.",
          detail: "submission_id=#{submission_id}",
          back_label: "Back to dashboard",
          back_path: "/"
        )

        Igniter::Plugins::View::Response.html(body, status: 404)
      end
    end
  end
end
