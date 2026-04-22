# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe "Igniter::Contracts pack completeness" do
  module IncompleteDslPack
    module_function

    def install_into(kernel)
      kernel.nodes.register(:dangling, Igniter::Contracts::NodeType.new(kind: :dangling))
      kernel.runtime_handlers.register(:dangling, :dangling_runtime_handler)
    end
  end

  module IncompleteRuntimePack
    module_function

    def install_into(kernel)
      kernel.nodes.register(:half_baked, Igniter::Contracts::NodeType.new(kind: :half_baked))
      kernel.dsl_keywords.register(:half_baked, Igniter::Contracts::DslKeyword.new(:half_baked, ->(name, builder:, **) {
        builder.add_operation(kind: :half_baked, name: name)
      }))
    end
  end

  module InternalOnlyPack
    module_function

    def install_into(kernel)
      kernel.nodes.register(
        :internal_marker,
        Igniter::Contracts::NodeType.new(
          kind: :internal_marker,
          metadata: {
            requires_dsl: false,
            requires_runtime: false
          }
        )
      )
    end
  end

  it "rejects packs that register a node without a DSL keyword" do
    kernel = Igniter::Contracts.build_kernel.install(IncompleteDslPack)

    expect { kernel.finalize }
      .to raise_error(Igniter::Contracts::IncompletePackError, /missing DSL keywords for: dangling/)
  end

  it "rejects packs that register a node without a runtime handler" do
    kernel = Igniter::Contracts.build_kernel.install(IncompleteRuntimePack)

    expect { kernel.finalize }
      .to raise_error(Igniter::Contracts::IncompletePackError, /missing runtime handlers for: half_baked/)
  end

  it "allows internal-only node kinds to skip DSL and runtime registration" do
    kernel = Igniter::Contracts.build_kernel.install(InternalOnlyPack)

    profile = kernel.finalize

    expect(profile.supports_node_kind?(:internal_marker)).to be(true)
  end
end
