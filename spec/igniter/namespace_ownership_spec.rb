# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Igniter namespace ownership" do
  OWNERSHIP_ROOT = File.expand_path("../..", __dir__)

  NAMESPACE_RULES = {
    "Igniter::AI" => {
      roots: [
        "lib/igniter/sdk/ai.rb",
        "lib/igniter/sdk/ai/"
      ],
      patterns: [
        /module\s+Igniter::AI\b/,
        /class\s+Igniter::AI\b/,
        /module\s+Igniter\b\s*module\s+AI\b/m
      ]
    },
    "Igniter::Agents" => {
      roots: [
        "lib/igniter/sdk/agents.rb",
        "lib/igniter/sdk/agents/"
      ],
      patterns: [
        /module\s+Igniter::Agents\b/,
        /class\s+Igniter::Agents\b/,
        /module\s+Igniter\b\s*module\s+Agents\b/m
      ]
    },
    "Igniter::Channels" => {
      roots: [
        "lib/igniter/sdk/channels.rb",
        "lib/igniter/sdk/channels/"
      ],
      patterns: [
        /module\s+Igniter::Channels\b/,
        /class\s+Igniter::Channels\b/,
        /module\s+Igniter\b\s*module\s+Channels\b/m
      ]
    },
    "Igniter::Data" => {
      roots: [
        "lib/igniter/sdk/data.rb",
        "lib/igniter/sdk/data/"
      ],
      patterns: [
        /module\s+Igniter::Data\b/,
        /class\s+Igniter::Data\b/,
        /module\s+Igniter\b\s*module\s+Data\b/m
      ]
    },
    "Igniter::Rails" => {
      roots: [
        "lib/igniter/plugins/rails.rb",
        "lib/igniter/plugins/rails/"
      ],
      patterns: [
        /module\s+Igniter::Rails\b/,
        /class\s+Igniter::Rails\b/,
        /module\s+Igniter\b\s*module\s+Rails\b/m
      ]
    },
    "Igniter::Plugins::View" => {
      roots: [
        "lib/igniter/plugins/view.rb",
        "lib/igniter/plugins/view/"
      ],
      patterns: [
        /module\s+Igniter::Plugins::View\b/,
        /class\s+Igniter::Plugins::View\b/,
        /module\s+Igniter\b\s*module\s+Plugins\b\s*module\s+View\b/m
      ]
    }
  }.freeze

  def ruby_lib_files
    Dir.glob(File.join(OWNERSHIP_ROOT, "lib/**/*.rb")).sort
  end

  def relative_path(path)
    path.sub("#{OWNERSHIP_ROOT}/", "")
  end

  def uncommented_source_for(path)
    File.readlines(path, chomp: true)
        .reject { |line| line.lstrip.start_with?("#") }
        .join("\n")
  end

  def owned_by_roots?(relative_file, roots)
    roots.any? do |root|
      root.end_with?("/") ? relative_file.start_with?(root) : relative_file == root
    end
  end

  def offenders_for(rule)
    ruby_lib_files.each_with_object([]) do |file, offenders|
      relative_file = relative_path(file)
      next if owned_by_roots?(relative_file, rule.fetch(:roots))

      source = uncommented_source_for(file)
      next unless rule.fetch(:patterns).any? { |pattern| source.match?(pattern) }

      offenders << relative_file
    end
  end

  NAMESPACE_RULES.each do |namespace, rule|
    it "keeps #{namespace} definitions inside its canonical roots" do
      expect(offenders_for(rule)).to eq([]), <<~MSG
        #{namespace} must be defined only inside:
        #{rule.fetch(:roots).join("\n")}

        Offending files:
        #{offenders_for(rule).join("\n")}
      MSG
    end
  end
end
