# frozen_string_literal: true

require_relative "legacy"
Igniter::Extensions::Legacy.require!("igniter/extensions/content_addressing", replacement: "a dedicated contracts effect/runtime pack for content-addressed reuse")
# Loading this file activates content-addressed caching for pure executors.
# The Resolver picks up content addressing via a guard clause when this constant is defined.
require "igniter/core/content_addressing"
