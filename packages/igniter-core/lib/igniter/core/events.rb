# frozen_string_literal: true

require_relative "legacy"
Igniter::Core::Legacy.require!("igniter/core/events")
require_relative "events/event"
require_relative "events/bus"

module Igniter
  module Events
  end
end
