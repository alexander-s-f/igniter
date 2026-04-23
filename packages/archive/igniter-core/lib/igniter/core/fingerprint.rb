# frozen_string_literal: true

require_relative "legacy"
Igniter::Core::Legacy.require!("igniter/core/fingerprint")
module Igniter
  # Mixin that enables stable cross-execution cache keys for objects used as
  # compute node dependencies (e.g. ActiveRecord models).
  #
  # Include this module in any class whose instances are passed as node deps:
  #
  #   class Trade < ApplicationRecord
  #     include Igniter::Fingerprint
  #   end
  #
  # The Rails Railtie includes this automatically in ApplicationRecord when
  # the igniter-rails integration is loaded.
  #
  # == Custom fingerprints
  #
  # Override #igniter_fingerprint for non-AR objects or custom invalidation logic:
  #
  #   class PricingConfig
  #     include Igniter::Fingerprint
  #
  #     def igniter_fingerprint
  #       "PricingConfig:#{version}:#{market}"
  #     end
  #   end
  module Fingerprint
    # Returns a stable string that uniquely identifies this object's state.
    # Changing the returned value invalidates any NodeCache entry that depends on it.
    #
    # Default: "{ClassName}:{id}:{updated_at_unix}" — works for any AR record.
    # Returns "{ClassName}:{id}" for objects without updated_at.
    def igniter_fingerprint
      if respond_to?(:updated_at) && updated_at
        "#{self.class.name}:#{id}:#{updated_at.to_i}"
      elsif respond_to?(:id)
        "#{self.class.name}:#{id}"
      else
        "#{self.class.name}:#{object_id}"
      end
    end
  end
end
