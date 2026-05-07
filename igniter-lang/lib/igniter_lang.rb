# frozen_string_literal: true

require_relative "igniter_lang/compiler_orchestrator"

module IgniterLang
  module_function

  def compile(source_path:, out_path:, sample_input: nil, sample_input_resolver: nil, runtime_smoke: nil,
              orchestrator: CompilerOrchestrator.new)
    orchestrator.compile(
      source_path: source_path,
      out_path: out_path,
      sample_input: sample_input,
      sample_input_resolver: sample_input_resolver,
      runtime_smoke: runtime_smoke
    )
  end
end
