# frozen_string_literal: true

require "igniter/stack"
require_relative "apps/main/app"
require_relative "apps/dashboard/app"

module Companion
  class Stack < Igniter::Stack
    root_dir __dir__
    shared_lib_path "lib"

    app :main, path: "apps/main", klass: Companion::MainApp, default: true
    app :dashboard, path: "apps/dashboard", klass: Companion::DashboardApp

    mount :dashboard, at: "/dashboard"
  end
end

if $PROGRAM_NAME == __FILE__
  Companion::Stack.start_cli(ARGV)
end
