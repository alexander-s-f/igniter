# frozen_string_literal: true

require "igniter/core/errors"
require "igniter/core/effect"

module Igniter
  module Channels
    class Error < Igniter::Error; end
    class DeliveryError < Error; end
  end
end

require_relative "channels/message"
require_relative "channels/delivery_result"
require_relative "channels/base"
require_relative "channels/telegram"
require_relative "channels/webhook"
