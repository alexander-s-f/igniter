# frozen_string_literal: true

require_relative "loader_adapter"
require_relative "autoloader"

module Igniter
  class Application
    # Default eager file-system-backed code loader for application path groups.
    class FilesystemLoaderAdapter < LoaderAdapter
      LOAD_ORDER = %i[executors contracts tools agents skills].freeze

      def load!(base_dir:, paths:)
        loader = Autoloader.new(base_dir: base_dir)

        LOAD_ORDER.each do |group|
          Array(paths[group]).each { |path| loader.load_path(path) }
        end
      end
    end
  end
end
