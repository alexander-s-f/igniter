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
      require "igniter/ai"

      Igniter::AI.configure do |config|
        config.default_provider = :ollama
        config.ollama.base_url = ENV.fetch("OLLAMA_URL", "http://localhost:11434")
      end
    end

    def load_main_sections(*sections)
      sections.each { |section| require_glob("apps/main/app/#{section}/**/*.rb") }
    end

    def load_inference_sections(*sections)
      sections.each { |section| require_glob("apps/inference/app/#{section}/**/*.rb") }
    end

    def load_main!
      load_main_sections("tools", "skills", "executors", "contracts", "agents")
    end

    def load_inference!
      load_inference_sections("executors", "contracts")
    end

    def load_demo!(real_llm: false)
      load_main_sections("tools", "skills")

      if real_llm
        configure_ai!
        load_main_sections("executors")
        load_inference_sections("executors")
      else
        activate_mock_executors!
      end

      load_main_sections("contracts", "agents")
      load_inference_sections("contracts")
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
        ChatExecutor: MockChatExecutor
      }.each do |name, executor|
        Companion.const_set(name, executor) unless Companion.const_defined?(name, false)
      end
    end
  end
end
