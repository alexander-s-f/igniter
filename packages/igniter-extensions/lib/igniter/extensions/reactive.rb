# frozen_string_literal: true

require_relative "legacy"
Igniter::Extensions::Legacy.require!("igniter/extensions/reactive", replacement: "Igniter::Extensions::Contracts::ReactivePack")
require "igniter/core/extensions/reactive"
