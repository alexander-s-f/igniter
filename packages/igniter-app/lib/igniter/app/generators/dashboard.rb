# frozen_string_literal: true

require "erb"

module Igniter
  class App
    module Generators
      class Dashboard
        TEMPLATE_ROOT = File.expand_path("templates/dashboard", __dir__)

        def initialize(name, minimal: false)
          @name = name.to_s
          @minimal = minimal
          @base = Igniter::App::Generator.new(name, minimal: minimal)
        end

        def generate
          @base.generate
          expand_stack_shape
          add_dashboard_app
          write "README.md", render_template("README.md.erb")
        end

        private

        attr_reader :base

        def expand_stack_shape
          create_dir "apps/dashboard/spec"
          create_dir "apps/dashboard/web/handlers"
          create_dir "apps/dashboard/web/views"
          create_dir "apps/dashboard/contexts"
          create_dir "apps/dashboard/support"
          create_dir "apps/dashboard/frontend"
          write "stack.rb", stack_rb
          write "spec/stack_spec.rb", stack_spec
          write "apps/dashboard/support/stack_overview.rb", render_template("support/stack_overview.rb.erb")
        end

        def add_dashboard_app
          write "apps/dashboard/app.rb", render_template("app.rb.erb")
          write "apps/dashboard/app.yml", dashboard_app_yml
          write "apps/dashboard/spec/spec_helper.rb", dashboard_spec_helper
          write "apps/dashboard/spec/dashboard_app_spec.rb", render_template("spec/dashboard_app_spec.rb.erb")
          write "apps/dashboard/contexts/home_context.rb", render_template("contexts/home_context.rb.erb")
          write "apps/dashboard/web/handlers/home_handler.rb", render_template("web/handlers/home_handler.rb.erb")
          write "apps/dashboard/web/views/home_page.rb", render_template("web/views/home_page.rb.erb")
          write "apps/dashboard/web/views/layout.arb", render_template("web/views/layout.arb.erb")
          write "apps/dashboard/web/views/home_page.arb", render_template("web/views/home_page.arb.erb")
          write "apps/dashboard/frontend/application.js", render_template("frontend/application.js.erb")
        end

        def path(rel)
          File.join(@name, rel)
        end

        def write(rel, content)
          File.write(path(rel), content)
        end

        def create_dir(rel)
          FileUtils.mkdir_p(path(rel))
        end

        def render_template(rel)
          template_path = File.join(TEMPLATE_ROOT, rel)
          ERB.new(File.read(template_path), trim_mode: "-").result(binding)
        end

        def module_name
          project_name.split(/[^a-zA-Z0-9]+/).reject(&:empty?).map(&:capitalize).join
        end

        def namespace_path
          project_name.strip.downcase.gsub(/[^a-z0-9]+/, "_").gsub(/\A_+|_+\z/, "")
        end

        def project_name
          File.basename(@name)
        end

        def stack_class_name
          "#{module_name}::Stack"
        end

        def stack_rb
          <<~RUBY
            # frozen_string_literal: true

            require "igniter/stack"
            require_relative "apps/main/app"
            require_relative "apps/dashboard/app"

            module #{module_name}
              class Stack < Igniter::Stack
                root_dir __dir__
                shared_lib_path "lib"

                app :main, path: "apps/main", klass: #{module_name}::MainApp, default: true
                app :dashboard, path: "apps/dashboard", klass: #{module_name}::DashboardApp

                mount :dashboard, at: "/dashboard"
              end
            end

            if $PROGRAM_NAME == __FILE__
              #{stack_class_name}.start_cli(ARGV)
            end
          RUBY
        end

        def stack_spec
          <<~RUBY
            # frozen_string_literal: true

            require_relative "spec_helper"

            RSpec.describe #{stack_class_name} do
              it "registers a mounted dashboard app" do
                expect(described_class.root_app).to eq(:main)
                expect(described_class.default_node).to eq(:main)
                expect(described_class.app(:main)).to be(#{module_name}::MainApp)
                expect(described_class.app(:dashboard)).to be(#{module_name}::DashboardApp)
                expect(described_class.mounts).to eq(dashboard: "/dashboard")
                expect(described_class.node_names).to eq([])
              end
            end
          RUBY
        end

        def dashboard_app_yml
          <<~YAML
            persistence:
              execution:
                adapter: memory
                path: var/dashboard_executions.sqlite3
          YAML
        end

        def dashboard_spec_helper
          <<~RUBY
            # frozen_string_literal: true

            require_relative "../../../spec/spec_helper"

            #{module_name}::DashboardApp.send(:build!)
          RUBY
        end
      end
    end
  end
end
