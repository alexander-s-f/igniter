# frozen_string_literal: true

require "igniter"
require "igniter/tool_registry"

RSpec.describe Igniter::ToolRegistry do
  # Tool fixtures
  let(:search_tool) do
    Class.new(Igniter::Tool) do
      def self.name = "SearchWeb"
      description "Search the internet"
      param :query, type: :string, required: true
      requires_capability :web_access
      def call(query:) = [{ title: "Result", url: "https://example.com" }]
    end
  end

  let(:write_tool) do
    Class.new(Igniter::Tool) do
      def self.name = "WriteFile"
      description "Write a file"
      param :path, type: :string, required: true
      param :content, type: :string, required: true
      requires_capability :filesystem_write
      def call(path:, content:) = { written: true }
    end
  end

  let(:free_tool) do
    Class.new(Igniter::Tool) do
      def self.name = "Echo"
      description "Echo input"
      param :text, type: :string, required: true
      # no required capabilities
      def call(text:) = text
    end
  end

  after { described_class.clear! }

  # ── Registration ─────────────────────────────────────────────────────────────

  describe ".register" do
    it "registers a single tool" do
      described_class.register(search_tool)
      expect(described_class.all).to include(search_tool)
    end

    it "registers multiple tools at once" do
      described_class.register(search_tool, write_tool)
      expect(described_class.all).to include(search_tool, write_tool)
    end

    it "returns self for chaining" do
      expect(described_class.register(search_tool)).to be(described_class)
    end

    it "raises ArgumentError for non-Tool classes" do
      expect { described_class.register(String) }
        .to raise_error(ArgumentError, /must be an Igniter::Tool or Igniter::Skill subclass/)
    end

    it "raises ArgumentError for plain objects" do
      expect { described_class.register("not a class") }
        .to raise_error(ArgumentError)
    end
  end

  # ── Lookup ───────────────────────────────────────────────────────────────────

  describe ".find" do
    before { described_class.register(search_tool) }

    it "returns the tool class by snake_case name" do
      expect(described_class.find("search_web")).to be(search_tool)
    end

    it "returns nil for unknown names" do
      expect(described_class.find("does_not_exist")).to be_nil
    end
  end

  # ── All tools ────────────────────────────────────────────────────────────────

  describe ".all" do
    it "returns an empty array when nothing is registered" do
      expect(described_class.all).to eq([])
    end

    it "returns all registered tool classes" do
      described_class.register(search_tool, write_tool)
      expect(described_class.all).to contain_exactly(search_tool, write_tool)
    end
  end

  describe ".size and .empty?" do
    it "reports 0 and empty? true initially" do
      expect(described_class.size).to eq(0)
      expect(described_class.empty?).to be true
    end

    it "updates after registration" do
      described_class.register(search_tool)
      expect(described_class.size).to eq(1)
      expect(described_class.empty?).to be false
    end
  end

  # ── Capability filtering ─────────────────────────────────────────────────────

  describe ".tools_for" do
    before { described_class.register(search_tool, write_tool, free_tool) }

    it "returns tools whose caps are all satisfied" do
      result = described_class.tools_for(capabilities: [:web_access])
      expect(result).to include(search_tool, free_tool)
      expect(result).not_to include(write_tool)
    end

    it "includes tools with no required capabilities unconditionally" do
      result = described_class.tools_for(capabilities: [])
      expect(result).to include(free_tool)
      expect(result).not_to include(search_tool, write_tool)
    end

    it "returns all non-restricted tools when all caps are provided" do
      result = described_class.tools_for(capabilities: %i[web_access filesystem_write])
      expect(result).to contain_exactly(search_tool, write_tool, free_tool)
    end
  end

  # ── Schema generation ────────────────────────────────────────────────────────

  describe ".schemas" do
    before { described_class.register(search_tool, free_tool) }

    it "returns intermediate schemas by default" do
      schemas = described_class.schemas
      expect(schemas).to all(have_key(:name))
      expect(schemas).to all(have_key(:parameters))
    end

    it "returns Anthropic schemas" do
      schemas = described_class.schemas(:anthropic)
      expect(schemas).to all(have_key(:input_schema))
    end

    it "returns OpenAI schemas" do
      schemas = described_class.schemas(:openai)
      expect(schemas).to all(have_key(:type))
      expect(schemas.map { |s| s[:type] }).to all(eq("function"))
    end

    it "filters by capabilities when provided" do
      described_class.register(write_tool)
      schemas = described_class.schemas(capabilities: [:web_access])
      names = schemas.map { |s| s[:name] }
      expect(names).to include("search_web", "echo")
      expect(names).not_to include("write_file")
    end
  end

  # ── clear! ───────────────────────────────────────────────────────────────────

  describe ".clear!" do
    it "removes all registrations" do
      described_class.register(search_tool)
      described_class.clear!
      expect(described_class.all).to eq([])
    end

    it "returns self" do
      expect(described_class.clear!).to be(described_class)
    end
  end
end
