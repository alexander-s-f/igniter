# frozen_string_literal: true

require_relative "orchestration/plan"
require_relative "orchestration/followup_request"
require_relative "orchestration/planner"
require_relative "orchestration/lane_registry"
require_relative "orchestration/policy_registry"
require_relative "orchestration/policies"
require_relative "orchestration/routing_registry"
require_relative "orchestration/handler_registry"
require_relative "orchestration/handlers"
require_relative "orchestration/inbox"
require_relative "orchestration/inbox_query"
require_relative "orchestration/operator_query"
require_relative "orchestration/result"
require_relative "orchestration/runner"

Igniter::App::Orchestration::LaneRegistry.register(
  :open_interactive_session,
  lane: :interactive_sessions,
  queue: "interactive-sessions",
  channel: "inbox://interactive-sessions",
  policy: Igniter::App::Orchestration::Policies::InteractiveSessionPolicy.new,
  handler: Igniter::App::Orchestration::Handlers::InteractiveSessionHandler.new,
  description: "default interactive-session lane"
)
Igniter::App::Orchestration::LaneRegistry.register(
  :require_manual_completion,
  lane: :manual_completions,
  queue: "manual-completions",
  channel: "inbox://manual-completions",
  policy: Igniter::App::Orchestration::Policies::ManualCompletionPolicy.new,
  handler: Igniter::App::Orchestration::Handlers::CompletionHandler.new,
  description: "default manual-completion lane"
)
Igniter::App::Orchestration::LaneRegistry.register(
  :await_single_turn_completion,
  lane: :single_turn_completions,
  queue: "single-turn-completions",
  channel: "inbox://single-turn-completions",
  policy: Igniter::App::Orchestration::Policies::SingleTurnCompletionPolicy.new,
  handler: Igniter::App::Orchestration::Handlers::CompletionHandler.new,
  description: "default single-turn completion lane"
)
Igniter::App::Orchestration::LaneRegistry.register(
  :await_deferred_reply,
  lane: :deferred_replies,
  queue: "deferred-replies",
  channel: "inbox://deferred-replies",
  policy: Igniter::App::Orchestration::Policies::DeferredReplyPolicy.new,
  handler: Igniter::App::Orchestration::Handlers::CompletionHandler.new,
  description: "default deferred-reply lane"
)

Igniter::App::Orchestration::PolicyRegistry.register(
  :open_interactive_session,
  Igniter::App::Orchestration::Policies::InteractiveSessionPolicy.new
)
Igniter::App::Orchestration::PolicyRegistry.register(
  :require_manual_completion,
  Igniter::App::Orchestration::Policies::ManualCompletionPolicy.new
)
Igniter::App::Orchestration::PolicyRegistry.register(
  :await_single_turn_completion,
  Igniter::App::Orchestration::Policies::SingleTurnCompletionPolicy.new
)
Igniter::App::Orchestration::PolicyRegistry.register(
  :await_deferred_reply,
  Igniter::App::Orchestration::Policies::DeferredReplyPolicy.new
)

Igniter::App::Orchestration::RoutingRegistry.register(
  :open_interactive_session,
  queue: "interactive-sessions",
  channel: "inbox://interactive-sessions"
)
Igniter::App::Orchestration::RoutingRegistry.register(
  :require_manual_completion,
  queue: "manual-completions",
  channel: "inbox://manual-completions"
)
Igniter::App::Orchestration::RoutingRegistry.register(
  :await_single_turn_completion,
  queue: "single-turn-completions",
  channel: "inbox://single-turn-completions"
)
Igniter::App::Orchestration::RoutingRegistry.register(
  :await_deferred_reply,
  queue: "deferred-replies",
  channel: "inbox://deferred-replies"
)

Igniter::App::Orchestration::HandlerRegistry.register(
  :open_interactive_session,
  Igniter::App::Orchestration::Handlers::InteractiveSessionHandler.new
)
Igniter::App::Orchestration::HandlerRegistry.register(
  :require_manual_completion,
  Igniter::App::Orchestration::Handlers::CompletionHandler.new
)
Igniter::App::Orchestration::HandlerRegistry.register(
  :await_single_turn_completion,
  Igniter::App::Orchestration::Handlers::CompletionHandler.new
)
Igniter::App::Orchestration::HandlerRegistry.register(
  :await_deferred_reply,
  Igniter::App::Orchestration::Handlers::CompletionHandler.new
)
