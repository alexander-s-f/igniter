#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))

require "igniter/contracts"

# This file is intentionally self-contained. It shows the smallest useful shape
# of a custom external pack:
# 1. declare a manifest
# 2. register a node kind + DSL keyword
# 3. add a validator
# 4. add a runtime handler
module SlugPack
  class << self
    def manifest
      Igniter::Contracts::PackManifest.new(
        name: :example_slug,
        node_contracts: [Igniter::Contracts::PackManifest.node(:slug)],
        registry_contracts: [Igniter::Contracts::PackManifest.validator(:slug_sources)]
      )
    end

    def install_into(kernel)
      kernel.nodes.register(:slug, Igniter::Contracts::NodeType.new(kind: :slug, metadata: { category: :text }))
      kernel.dsl_keywords.register(:slug, slug_keyword)
      kernel.validators.register(:slug_sources, method(:validate_slug_sources))
      kernel.runtime_handlers.register(:slug, method(:handle_slug))
      kernel
    end

    def slug_keyword
      Igniter::Contracts::DslKeyword.new(:slug) do |name, from:, builder:|
        builder.add_operation(kind: :slug, name: name, from: from.to_sym)
      end
    end

    def validate_slug_sources(operations:, profile: nil) # rubocop:disable Lint/UnusedMethodArgument
      available = operations.reject(&:output?).map(&:name)
      missing = operations.select { |operation| operation.kind == :slug }
                          .map { |operation| operation.attributes.fetch(:from).to_sym }
                          .reject { |name| available.include?(name) }
                          .uniq
      return [] if missing.empty?

      [Igniter::Contracts::ValidationFinding.new(
        code: :missing_slug_sources,
        message: "slug sources are not defined: #{missing.map(&:to_s).join(", ")}",
        subjects: missing
      )]
    end

    def handle_slug(operation:, state:, **)
      source_name = operation.attributes.fetch(:from).to_sym
      value = state.fetch(source_name).to_s

      value
        .downcase
        .gsub(/[^a-z0-9]+/, "-")
        .gsub(/\A-+|-+\z/, "")
    end
  end
end

environment = Igniter::Contracts.with(SlugPack)

result = environment.run(inputs: { title: "Hello, Igniter Contracts!" }) do
  input :title
  slug :permalink, from: :title
  output :permalink
end

report = environment.validation_report do
  slug :permalink, from: :missing_title
  output :permalink
end

puts "custom_pack_profile=#{environment.profile.pack_names.join(",")}"
puts "custom_pack_slug=#{result.output(:permalink)}"
puts "custom_pack_findings=#{report.findings.map(&:code).join(",")}"
