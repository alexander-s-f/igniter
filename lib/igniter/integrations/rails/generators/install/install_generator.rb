# frozen_string_literal: true

require "rails/generators"

module Igniter
  module Rails
    module Generators
      class InstallGenerator < ::Rails::Generators::Base
        source_root File.expand_path("templates", __dir__)
        desc "Creates an Igniter initializer in your application."

        def copy_initializer
          template "igniter.rb.tt", "config/initializers/igniter.rb"
        end

        def create_contracts_directory
          empty_directory "app/contracts"
          create_file "app/contracts/.keep"
        end

        def show_readme
          say "", :green
          say "✓ Igniter installed!", :green
          say ""
          say "Next steps:"
          say "  1. Configure your store in config/initializers/igniter.rb"
          say "  2. Generate a contract: rails g igniter:contract YourContractName"
          say ""
        end
      end
    end
  end
end
