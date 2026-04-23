# frozen_string_literal: true

require_relative "legacy"
Igniter::Extensions::Legacy.require!("igniter/extensions/invariants", replacement: "Igniter::Extensions::Contracts::InvariantsPack")
require "igniter/core/extensions/invariants"
