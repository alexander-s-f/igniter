# frozen_string_literal: true

require_relative "../../../lib/companion/shared/stack_overview"

module Companion
  module Main
    module Support
      module PlaygroundOpsAPI
        module_function

        def overview
          Companion::Shared::StackOverview.build
        end
      end
    end
  end
end
