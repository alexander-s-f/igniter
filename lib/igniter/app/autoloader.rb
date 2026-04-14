# frozen_string_literal: true

module Igniter
  class Application
    # Eagerly loads all .rb files matching a glob path.
    # Used by Application#executors_path / #contracts_path.
    class Autoloader
      def initialize(base_dir:)
        @base_dir = File.expand_path(base_dir)
      end

      def load_path(path)
        full = File.expand_path(path, @base_dir)
        Dir.glob("#{full}/**/*.rb").sort.each { |f| require f }
      end
    end
  end
end
