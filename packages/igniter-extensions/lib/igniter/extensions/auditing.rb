# frozen_string_literal: true

require_relative "legacy"
Igniter::Extensions::Legacy.require!("igniter/extensions/auditing", replacement: "execution/diagnostics packs in igniter-contracts or igniter-extensions")
require "igniter/core/extensions/auditing"
