#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))

require "igniter/contracts"

# This file shows pack composition in one place:
# 1. a foundational pack adds a node kind (`slug`)
# 2. a higher-level pack depends on it and adds a richer DSL keyword

module ExampleSlugPack
  class << self
    def manifest
      Igniter::Contracts::PackManifest.new(
        name: :example_slug_foundation,
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
        message: "slug sources are not defined: #{missing.map(&:to_s).join(', ')}",
        subjects: missing
      )]
    end

    def handle_slug(operation:, state:, **)
      source_name = operation.attributes.fetch(:from).to_sym
      state.fetch(source_name)
           .to_s
           .downcase
           .gsub(/[^a-z0-9]+/, "-")
           .gsub(/\A-+|-+\z/, "")
    end
  end
end

module ExampleSeoPack
  class << self
    def manifest
      Igniter::Contracts::PackManifest.new(
        name: :example_seo,
        requires_packs: [ExampleSlugPack],
        registry_contracts: [
          Igniter::Contracts::PackManifest.dsl_keyword(:canonical_page)
        ]
      )
    end

    def install_into(kernel)
      kernel.dsl_keywords.register(:canonical_page, canonical_page_keyword)
      kernel
    end

    def canonical_page_keyword
      Igniter::Contracts::DslKeyword.new(:canonical_page) do |name = :canonical_url, title:, host:, slug_name: :slug, builder:|
        slug_name = slug_name.to_sym
        host = host.to_s

        builder.add_operation(kind: :slug, name: slug_name, from: title.to_sym)
        builder.add_operation(
          kind: :compute,
          name: name,
          depends_on: [slug_name],
          callable: lambda do |**values|
            "#{host}/#{values.fetch(slug_name)}"
          end
        )
      end
    end
  end
end

environment = Igniter::Contracts.with(ExampleSeoPack)

result = environment.run(inputs: { title: "Hello, Pack Composition!" }) do
  input :title
  canonical_page title: :title, host: "https://docs.example.test"
  output :canonical_url
end

puts "composed_pack_profile=#{environment.profile.pack_names.join(',')}"
puts "composed_pack_has_slug=#{environment.profile.supports_node_kind?(:slug)}"
puts "composed_pack_url=#{result.output(:canonical_url)}"
