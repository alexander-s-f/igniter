# frozen_string_literal: true

module Igniter
  module Contracts
    NodeType = Struct.new(:kind, :metadata, keyword_init: true) do
      def initialize(kind:, metadata: {})
        super(kind: kind.to_sym, metadata: metadata.freeze)
      end
    end
  end
end
