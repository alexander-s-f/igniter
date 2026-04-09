# frozen_string_literal: true

# Actor system for Igniter — stateful message-driven agents with supervision.
#
# Usage:
#   require "igniter/integrations/agents"
#
# Provides:
#   Igniter::Agent      — base class for stateful actors
#   Igniter::Supervisor — supervises and restarts child agents
#   Igniter::Registry   — thread-safe name → Ref lookup
#   Igniter::StreamLoop — continuous contract-in-a-tick-loop
#

require_relative "../agent"
require_relative "../supervisor"
require_relative "../registry"
require_relative "../stream_loop"
