# frozen_string_literal: true

require_relative "legacy"
Igniter::Extensions::Legacy.require!("igniter/extensions/auditing", replacement: "Igniter::Extensions::Contracts::AuditPack")
require "igniter/core/extensions/auditing"
