# frozen_string_literal: true

require_relative "../../lib/igniter_lang/diagnostics"

module ProductionCompilerCLI
  Diagnostics = IgniterLang::Diagnostics unless const_defined?(:Diagnostics, false)
end
