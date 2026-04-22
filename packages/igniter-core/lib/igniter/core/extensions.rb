# frozen_string_literal: true

require_relative "legacy"
Igniter::Core::Legacy.require!("igniter/core/extensions")
require_relative "extensions/auditing"
require_relative "extensions/reactive"
require_relative "extensions/introspection"

module Igniter
  module Extensions
  end
end
