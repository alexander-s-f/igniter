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
end
