# frozen_string_literal: true

require_relative "legacy"
Igniter::Extensions::Legacy.require!("igniter/extensions/introspection", replacement: "structured contracts introspection via CompilationReport/DiagnosticsReport")
require "igniter/core/extensions/introspection"
