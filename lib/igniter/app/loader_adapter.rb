# frozen_string_literal: true

module Igniter
  class App
    # Abstract seam for application code loading.
    #
    # App declares which path groups exist, while the loader adapter owns
    # how those files are discovered and required.
    class LoaderAdapter
      def load!(base_dir:, paths:)
        raise NotImplementedError, "#{self.class} must implement #load!"
      end
    end
  end
end
