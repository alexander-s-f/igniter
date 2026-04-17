# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe Companion::InferenceApp do
  it "uses apps/inference as its root directory" do
    expect(described_class.root_dir).to eq(File.expand_path("..", __dir__))
  end

  describe "voice pipeline contract shapes" do
    it "ASRContract exposes :transcript" do
      node = Companion::ASRContract.graph.fetch_node(:transcript)
      expect(node.name).to eq(:transcript)
    end

    it "IntentContract exposes :intent" do
      node = Companion::IntentContract.graph.fetch_node(:intent)
      expect(node.name).to eq(:intent)
    end

    it "TTSContract exposes :audio_response" do
      node = Companion::TTSContract.graph.fetch_node(:audio_response)
      expect(node.name).to eq(:audio_response)
    end
  end
end
