# frozen_string_literal: true

require "igniter/application"

require_relative "web/api"
require_relative "web/application"
require_relative "web/record"

module Igniter
  module Web
    class << self
      def application(&block)
        Application.new.draw(&block)
      end

      def api(&block)
        Api.new.draw(&block)
      end
    end
  end
end
