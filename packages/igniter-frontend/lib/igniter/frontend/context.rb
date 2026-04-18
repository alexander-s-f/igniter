# frozen_string_literal: true

module Igniter
  module Frontend
    class Context
      class << self
        def build(**kwargs)
          new(**kwargs)
        end
      end

      attr_reader :request, :app_access, :response, :handler

      def initialize(request: nil, app_access: nil, response: nil, handler: nil, **attributes)
        @request = request
        @app_access = app_access
        @response = response
        @handler = handler
        @attributes = attributes.transform_keys(&:to_sym)
      end

      def base_path
        request&.script_name.to_s
      end

      def route(suffix)
        [base_path.sub(%r{/+\z}, ""), suffix.to_s].join
      end

      def [](key)
        @attributes[key.to_sym]
      end

      def fetch(key, *args)
        @attributes.fetch(key.to_sym, *args)
      end

      def to_h
        @attributes.dup
      end

      def method_missing(name, *args, &block)
        return @attributes.fetch(name) if args.empty? && block.nil? && @attributes.key?(name)

        super
      end

      def respond_to_missing?(name, include_private = false)
        @attributes.key?(name.to_sym) || super
      end
    end
  end
end
