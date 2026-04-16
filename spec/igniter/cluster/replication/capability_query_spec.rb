# frozen_string_literal: true

require "spec_helper"
require "igniter/cluster"

RSpec.describe Igniter::Cluster::Replication::CapabilityQuery do
  describe ".normalize" do
    it "turns arrays into all_of queries" do
      query = described_class.normalize(%i[local_llm container_runtime])
      expect(query.all_of).to eq(%i[container_runtime local_llm])
    end

    it "turns symbols into named single-capability queries" do
      query = described_class.normalize(:local_llm)
      expect(query.name).to eq(:local_llm)
      expect(query.all_of).to eq([:local_llm])
    end
  end

  describe "#matches_profile?" do
    let(:profile) do
      Igniter::Cluster::Replication::NodeProfile.new(
        capabilities: %i[container_runtime local_llm ruby],
        tags: %i[linux x86_64]
      )
    end

    it "matches a profile that satisfies all constraints" do
      query = described_class.new(all_of: %i[container_runtime local_llm], tags: [:linux])
      expect(query.matches_profile?(profile)).to be true
    end

    it "rejects a profile missing one required capability" do
      query = described_class.new(all_of: %i[container_runtime embedded])
      expect(query.matches_profile?(profile)).to be false
    end
  end
end
