# frozen_string_literal: true

require "spec_helper"
require "igniter/app"

RSpec.describe Igniter::App::Credentials do
  describe Igniter::App::Credentials::CredentialPolicy do
    it "serializes and restores a canonical local-only policy" do
      policy = described_class.new(
        name: :local_only,
        label: "Local Only",
        secret_class: :local_only,
        propagation: :disabled,
        route_over_replicate: true,
        weak_trust_behavior: :deny,
        operator_approval_required: true,
        description: "Keep credentials on one node."
      )

      restored = described_class.from_h(policy.to_h)

      expect(restored.to_h).to eq(policy.to_h)
      expect(restored.local_only?).to be(true)
      expect(restored.allows_scope?(:local)).to be(true)
      expect(restored.allows_scope?(:remote)).to be(false)
    end

    it "preserves subclasses when deriving a policy with overrides" do
      subclass = Class.new(described_class)
      policy = subclass.new(
        name: :local_only,
        label: "Local Only",
        secret_class: :local_only,
        propagation: :disabled,
        route_over_replicate: true,
        weak_trust_behavior: :deny,
        operator_approval_required: true
      )

      derived = policy.with(description: "Still local-only")

      expect(derived).to be_a(subclass)
      expect(derived.description).to eq("Still local-only")
    end
  end

  describe Igniter::App::Credentials::Credential do
    it "wraps a credential with a policy object and preserves it through serialization" do
      policy = Igniter::App::Credentials::CredentialPolicy.new(
        name: :local_only,
        label: "Local Only",
        secret_class: :local_only,
        propagation: :disabled,
        route_over_replicate: true,
        weak_trust_behavior: :deny,
        operator_approval_required: true
      )

      credential = described_class.new(
        key: :openai_api,
        label: "OpenAI API",
        provider: :openai,
        scope: :local,
        node: "main",
        policy: policy,
        metadata: { model: "gpt-4o" }
      )

      restored = described_class.from_h(credential.to_h)

      expect(restored.to_h).to eq(credential.to_h)
      expect(restored.allowed_in_scope?(:local)).to be(true)
      expect(restored.allowed_in_scope?(:remote)).to be(false)
    end

    it "preserves credential subclasses when deriving with overrides" do
      subclass = Class.new(described_class)
      policy = Igniter::App::Credentials::CredentialPolicy.new(
        name: :local_only,
        label: "Local Only",
        secret_class: :local_only,
        propagation: :disabled,
        route_over_replicate: true,
        weak_trust_behavior: :deny,
        operator_approval_required: true
      )

      credential = subclass.new(
        key: :openai_api,
        label: "OpenAI API",
        provider: :openai,
        scope: :local,
        policy: policy
      )

      derived = credential.with(metadata: { model: "gpt-4o" })

      expect(derived).to be_a(subclass)
      expect(derived.metadata[:model]).to eq("gpt-4o")
    end
  end

  describe Igniter::App::Credentials::Policies::LocalOnlyPolicy do
    it "provides a canonical node-local policy type" do
      policy = described_class.new

      expect(policy.name).to eq(:local_only)
      expect(policy.local_only?).to be(true)
      expect(policy.allows_scope?(:local)).to be(true)
      expect(policy.allows_scope?(:remote)).to be(false)
      expect(policy.metadata[:notes]).to include("No automatic cross-node credential propagation.")
    end
  end

  describe Igniter::App::Credentials::Policies::EphemeralLeasePolicy do
    it "provides a declared cross-node lease policy without normalizing full replication" do
      policy = described_class.new

      expect(policy.name).to eq(:ephemeral_lease)
      expect(policy.local_only?).to be(false)
      expect(policy.allows_scope?(:local)).to be(true)
      expect(policy.allows_scope?(:remote)).to be(true)
      expect(policy.operator_approval_required).to be(true)
      expect(policy.metadata[:lease_mode]).to eq(:ephemeral)
      expect(policy.metadata[:declared_only]).to be(true)
    end
  end
end
