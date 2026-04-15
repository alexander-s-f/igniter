# frozen_string_literal: true

module Companion
  module Boot
    module_function

    def root
      @root ||= File.expand_path("../..", __dir__)
    end

    def repo_root
      @repo_root ||= File.expand_path("../..", root)
    end

    def setup_load_path!
      [File.join(repo_root, "lib"), File.join(root, "lib")].each do |path|
        $LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
      end
    end

    def configure_ai!
      require "igniter/sdk/ai"

      Igniter::AI.configure do |config|
        config.default_provider = :ollama
        config.ollama.url = ENV.fetch("OLLAMA_URL", "http://localhost:11434")
      end
    end

    def load_sections(*sections)
      sections.each { |section| require_glob("app/#{section}/**/*.rb") }
    end

    def load_orchestrator!
      load_sections("tools", "skills", "executors", "contracts", "agents")
    end

    def load_inference_executors!
      require_glob("inference/executors/**/*.rb")
    end

    def load_inference_contracts!
      require_glob("inference/contracts/**/*.rb")
    end

    def load_inference!
      load_inference_executors!
      load_inference_contracts!
    end

    def load_demo!(real_llm: false)
      load_sections("tools", "skills")

      if real_llm
        configure_ai!
        load_sections("executors")
        load_inference_executors!
      else
        activate_mock_executors!
      end

      load_sections("contracts", "agents")
      load_inference_contracts!
      require_path("lib/companion/demo/local_pipeline_contract.rb")
    end

    def require_glob(pattern)
      Dir[File.join(root, pattern)].sort.each { |file| require file }
    end

    def require_path(relative_path)
      require File.join(root, relative_path)
    end

    def activate_mock_executors!
      require_path("lib/companion/demo/mock_executors.rb")

      {
        WhisperExecutor: MockWhisperExecutor,
        PiperExecutor: MockPiperExecutor,
        IntentExecutor: MockIntentExecutor,
        ChatExecutor: MockChatExecutor,
      }.each do |name, executor|
        Companion.const_set(name, executor) unless Companion.const_defined?(name, false)
      end
    end
  end
end
