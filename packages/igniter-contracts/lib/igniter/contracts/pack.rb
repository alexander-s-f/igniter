# frozen_string_literal: true

module Igniter
  module Contracts
    module Pack
      def install_into(_kernel)
        raise NotImplementedError
      end
    end
  end
end
