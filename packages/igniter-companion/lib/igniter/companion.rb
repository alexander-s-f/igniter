# frozen_string_literal: true

require_relative "companion/record"
require_relative "companion/history"
require_relative "companion/receipts"
require_relative "companion/store"

module Igniter
  module Companion
    # Dispatch on manifest storage shape → Record or History class.
    # `store:` is optional when the manifest carries `storage[:name]`.
    #
    #   klass = Igniter::Companion.from_manifest(manifest)
    #   # uses manifest[:storage][:name] as the store/history name
    #
    #   klass = Igniter::Companion.from_manifest(manifest, store: :override)
    #   # explicit override
    def self.from_manifest(manifest, store: nil)
      shape = manifest.dig(:storage, :shape)
      case shape
      when :store   then Record.from_manifest(manifest, store: store)
      when :history then History.from_manifest(manifest, store: store)
      else raise ArgumentError, "Unknown storage shape: #{shape.inspect}. Expected :store or :history"
      end
    end
  end
end
