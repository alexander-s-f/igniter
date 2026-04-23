# frozen_string_literal: true

require_relative "legacy"
Igniter::Extensions::Legacy.require!("igniter/extensions/invariants", replacement: "contracts validators or diagnostics contributors instead of global runtime patching")
require "igniter/core/extensions/invariants"
