# frozen_string_literal: true

require "igniter/view"

module Companion
  module Dashboard
    module ViewSchemaCatalog
      module_function

      def store
        Igniter::Plugins::View::SchemaStore.new
      end

      def seed!
        store.put(training_checkin_schema) unless store.get("training-checkin")
      end

      def training_checkin_schema
        {
          id: "training-checkin",
          version: 1,
          kind: "page",
          title: "Daily Training Check-in",
          actions: {
            submit_checkin: {
              type: "contract",
              target: "Companion::Dashboard::TrainingCheckinSubmissionContract",
              method: "post",
              path: "/views/training-checkin/submissions",
              input_mapping: {
                view_id: "$view.id",
                submission_id: "$submission.id",
                "checkin.mood" => "mood",
                "checkin.duration_minutes" => "duration_minutes",
                "checkin.notes" => "notes",
                "checkin.share_with_coach" => "share_with_coach"
              }
            }
          },
          layout: {
            type: "stack",
            children: [
              {
                type: "section",
                children: [
                  { type: "heading", level: 1, text: "Daily Training Check-in" },
                  {
                    type: "text",
                    text: "A schema-driven form the agent could create, persist, update, and re-render later.",
                    tone: "muted"
                  }
                ]
              },
              {
                type: "card",
                children: [
                  {
                    type: "form",
                    action: "submit_checkin",
                    children: [
                      {
                        type: "select",
                        name: "mood",
                        label: "How do you feel?",
                        selected: "good",
                        options: [
                          { label: "Great", value: "great" },
                          { label: "Good", value: "good" },
                          { label: "Tired", value: "tired" }
                        ]
                      },
                      {
                        type: "input",
                        name: "duration_minutes",
                        label: "Duration (minutes)",
                        value_type: "integer",
                        placeholder: "45",
                        required: true
                      },
                      {
                        type: "textarea",
                        name: "notes",
                        label: "Notes",
                        rows: 4,
                        placeholder: "What worked well today?"
                      },
                      {
                        type: "checkbox",
                        name: "share_with_coach",
                        label: "Share this entry with a coach",
                        value_type: "boolean",
                        checked: true
                      },
                      { type: "submit", label: "Save Check-in" }
                    ]
                  }
                ]
              }
            ]
          },
          meta: {
            lang: "en"
          }
        }
      end
    end
  end
end
