# frozen_string_literal: true

require "igniter/plugins/view"

module Companion
  module Dashboard
    module ViewSchemaCatalog
      module_function

      def store
        Igniter::Plugins::View::SchemaStore.new
      end

      def seed!
        canonical_schemas.each do |schema|
          store.put(schema) unless store.get(schema.fetch(:id))
        end
      end

      def canonical_schemas
        [
          training_checkin_schema,
          weekly_review_schema
        ]
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
                type: "notice",
                message: "Capture enough detail that tomorrow-you can quickly reconstruct the session.",
                tone: "info"
              },
              {
                type: "card",
                children: [
                  {
                    type: "form",
                    action: "submit_checkin",
                    children: [
                      {
                        type: "fieldset",
                        legend: "Session",
                        description: "Core session details plus a little context for future follow-up.",
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
                          {
                            type: "text",
                            text: "Use notes for cues, surprises, and anything worth carrying into the next session.",
                            tone: "muted"
                          }
                        ]
                      },
                      {
                        type: "actions",
                        children: [
                          { type: "submit", label: "Save Check-in" }
                        ]
                      }
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

      def weekly_review_schema
        {
          id: "weekly-review",
          version: 1,
          kind: "page",
          title: "Weekly Review",
          actions: {
            save_review: {
              method: "post",
              path: "/views/weekly-review/submissions"
            }
          },
          layout: {
            type: "stack",
            children: [
              {
                type: "section",
                children: [
                  { type: "heading", level: 1, text: "Weekly Review" },
                  {
                    type: "text",
                    text: "A lightweight reflection form that persists submissions without a contract.",
                    tone: "muted"
                  }
                ]
              },
              {
                type: "notice",
                message: "Keep answers short and concrete. The goal is to leave yourself a clean trail for next week.",
                tone: "notice"
              },
              {
                type: "card",
                children: [
                  {
                    type: "form",
                    action: "save_review",
                    children: [
                      {
                        type: "fieldset",
                        legend: "Signals",
                        description: "Capture the strongest signal from the week before details fade.",
                        children: [
                          {
                            type: "select",
                            name: "energy",
                            label: "Energy trend",
                            selected: "steady",
                            options: [
                              { label: "Rising", value: "rising" },
                              { label: "Steady", value: "steady" },
                              { label: "Dropping", value: "dropping" }
                            ]
                          },
                          {
                            type: "textarea",
                            name: "highlight",
                            label: "Highlight",
                            rows: 4,
                            placeholder: "What was the most useful moment this week?",
                            required: true
                          }
                        ]
                      },
                      {
                        type: "fieldset",
                        legend: "Next week",
                        description: "End with one clear adjustment instead of a long wish-list.",
                        children: [
                          {
                            type: "input",
                            name: "next_focus",
                            label: "Next focus",
                            placeholder: "Protect mornings for deep work",
                            required: true
                          },
                          {
                            type: "checkbox",
                            name: "share_summary",
                            label: "Share summary with the team",
                            value_type: "boolean",
                            checked: false
                          }
                        ]
                      },
                      {
                        type: "actions",
                        children: [
                          { type: "submit", label: "Save Review" }
                        ]
                      }
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
