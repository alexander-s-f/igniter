# frozen_string_literal: true

require "rails/generators"

module Igniter
  module Rails
    module Generators
      class ContractGenerator < ::Rails::Generators::NamedBase
        source_root File.expand_path("templates", __dir__)
        desc "Creates an Igniter contract."

        class_option :correlate_by, type: :array, default: [], desc: "Correlation key names"
        class_option :inputs, type: :array, default: [], desc: "Input names"
        class_option :outputs, type: :array, default: ["result"], desc: "Output names"

        def create_contract
          template "contract.rb.tt", File.join("app/contracts", class_path, "#{file_name}_contract.rb")
        end
      end
    end
  end
end
