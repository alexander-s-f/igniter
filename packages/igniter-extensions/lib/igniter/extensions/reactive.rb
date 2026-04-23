# frozen_string_literal: true

require_relative "legacy"
Igniter::Extensions::Legacy.require!("igniter/extensions/reactive", replacement: "contracts-side subscriptions or diagnostics packs instead of core extension hooks")
require "igniter/core/extensions/reactive"
