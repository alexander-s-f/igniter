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

    it "normalizes metadata order clauses" do
      query = described_class.normalize(
        all_of: [:local_llm],
        order_by: [
          { metadata: "trust.score", direction: "desc" },
          { metadata: %w[load avg1m], direction: :asc, nulls: "first" }
        ]
      )

      expect(query.order_by).to eq([
                                     { metadata: %i[trust score], direction: :desc, nulls: :last },
                                     { metadata: %i[load avg1m], direction: :asc, nulls: :first }
                                   ])
    end
  end

  describe "#matches_profile?" do
    let(:profile) do
      Igniter::Cluster::Replication::NodeProfile.new(
        capabilities: %i[container_runtime local_llm ruby],
        tags: %i[linux x86_64],
        metadata: {
          trust: { score: 0.92, tier: "gold" },
          health: { freshness_seconds: 12 },
          region: "eu-central"
        }
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

    it "matches metadata using exact and operator predicates" do
      query = described_class.new(
        all_of: [:local_llm],
        metadata: {
          trust: { score: { min: 0.9 }, tier: { in: %w[gold platinum] } },
          health: { freshness_seconds: { max: 30 } },
          region: "eu-central"
        }
      )

      expect(query.matches_profile?(profile)).to be true
    end

    it "rejects metadata that does not satisfy the predicate" do
      query = described_class.new(
        all_of: [:local_llm],
        metadata: { trust: { score: { min: 0.99 } } }
      )

      expect(query.matches_profile?(profile)).to be false
    end
  end

  describe "#compare_profiles" do
    let(:query) do
      described_class.new(
        all_of: [:local_llm],
        order_by: [
          { metadata: "trust.score", direction: :desc },
          { metadata: "load.avg1m", direction: :asc }
        ]
      )
    end

    let(:stronger_profile) do
      Igniter::Cluster::Replication::NodeProfile.new(
        capabilities: %i[local_llm container_runtime],
        metadata: {
          trust: { score: 0.98 },
          load: { avg1m: 0.40 }
        }
      )
    end

    let(:weaker_profile) do
      Igniter::Cluster::Replication::NodeProfile.new(
        capabilities: %i[local_llm container_runtime],
        metadata: {
          trust: { score: 0.91 },
          load: { avg1m: 0.10 }
        }
      )
    end

    let(:equal_trust_lower_load) do
      Igniter::Cluster::Replication::NodeProfile.new(
        capabilities: %i[local_llm container_runtime],
        metadata: {
          trust: { score: 0.98 },
          load: { avg1m: 0.15 }
        }
      )
    end

    it "prefers higher values for desc order clauses" do
      expect(query.compare_profiles(stronger_profile, weaker_profile)).to eq(-1)
      expect(query.compare_profiles(weaker_profile, stronger_profile)).to eq(1)
    end

    it "uses later clauses as tie-breakers" do
      expect(query.compare_profiles(equal_trust_lower_load, stronger_profile)).to eq(-1)
    end

    it "builds a stable ranking fingerprint" do
      expect(query.ranking_fingerprint(equal_trust_lower_load)).to eq([0.98, 0.15])
    end
  end
end
