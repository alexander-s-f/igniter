# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe Igniter::Application::CredentialStore do
  around do |example|
    original = ENV.fetch("IGNITER_TEST_OPENAI_API_KEY", nil)
    ENV.delete("IGNITER_TEST_OPENAI_API_KEY")
    example.run
  ensure
    if original.nil?
      ENV.delete("IGNITER_TEST_OPENAI_API_KEY")
    else
      ENV["IGNITER_TEST_OPENAI_API_KEY"] = original
    end
  end

  it "reports missing required credentials without leaking values" do
    environment = Igniter::Application.build_kernel
                                      .credential(
                                        :openai_api_key,
                                        env: "IGNITER_TEST_OPENAI_API_KEY",
                                        required: true,
                                        description: "OpenAI API key"
                                      )
                                      .then { |kernel| Igniter::Application::Environment.new(profile: kernel.finalize) }

    expect(environment.credentials.ready?).to be(false)
    expect(environment.credentials.missing_required).to eq([:openai_api_key])
    expect(environment.credentials.status(:openai_api_key)).to include(
      name: :openai_api_key,
      source: :env,
      env: "IGNITER_TEST_OPENAI_API_KEY",
      required: true,
      configured: false,
      missing: true
    )
    expect do
      environment.credentials.fetch(:openai_api_key)
    end.to raise_error(
      Igniter::Application::MissingCredentialError,
      /IGNITER_TEST_OPENAI_API_KEY/
    )
  end

  it "fetches configured credentials but redacts them from profile and manifest data" do
    ENV["IGNITER_TEST_OPENAI_API_KEY"] = "sk-test-secret"

    environment = Igniter::Application.build_kernel
                                      .manifest(:assistant, root: "/tmp/assistant", env: :test)
                                      .credential(:openai_api_key, env: "IGNITER_TEST_OPENAI_API_KEY", required: true)
                                      .then { |kernel| Igniter::Application::Environment.new(profile: kernel.finalize) }

    expect(environment.credentials.fetch(:openai_api_key)).to eq("sk-test-secret")
    expect(environment.credentials.ready?).to be(true)
    expect(environment.credentials.status(:openai_api_key)).to include(
      configured: true,
      redacted: "[configured]"
    )

    profile_payload = environment.profile.to_h
    manifest_payload = environment.manifest.to_h

    expect(profile_payload.to_s).not_to include("sk-test-secret")
    expect(manifest_payload.to_s).not_to include("sk-test-secret")
    expect(profile_payload.fetch(:credentials)).to include(
      ready: true,
      credentials: [
        include(
          name: :openai_api_key,
          configured: true,
          redacted: "[configured]"
        )
      ],
      missing_required: []
    )
  end
end
