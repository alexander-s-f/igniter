# frozen_string_literal: true

module Igniter
  module Frontend
    module App
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def frontend_assets(path: Assets::DEFAULT_SOURCE_PATH, mount: Assets::DEFAULT_MOUNT_PATH)
          @frontend_assets_config = Assets.build_config(
            root_dir: root_dir || Dir.pwd,
            source_path: path,
            mount_path: mount
          )

          route("GET", Assets.runtime_path(mount_path: @frontend_assets_config.fetch(:mount_path)), with: Assets.runtime_handler)
          route(
            "GET",
            Assets.javascript_route_pattern(mount_path: @frontend_assets_config.fetch(:mount_path)),
            with: Assets.javascript_handler(@frontend_assets_config)
          )
        end

        def frontend_assets_config
          @frontend_assets_config
        end

        def get(path, to: nil, with: nil, &block)
          frontend_route("GET", path, to: to || with, &block)
        end

        def post(path, to: nil, with: nil, &block)
          frontend_route("POST", path, to: to || with, &block)
        end

        def put(path, to: nil, with: nil, &block)
          frontend_route("PUT", path, to: to || with, &block)
        end

        def patch(path, to: nil, with: nil, &block)
          frontend_route("PATCH", path, to: to || with, &block)
        end

        def delete(path, to: nil, with: nil, &block)
          frontend_route("DELETE", path, to: to || with, &block)
        end

        def scope(path, &block)
          raise ArgumentError, "scope requires a block" unless block

          current_frontend_scope_stack << path.to_s
          instance_eval(&block)
        ensure
          current_frontend_scope_stack.pop
        end

        private

        def frontend_route(method, path, to: nil, &block)
          handler = to || block
          raise ArgumentError, "#{method} #{path} requires `to:` or a block" unless handler

          route(method, scoped_frontend_path(path), with: normalize_frontend_handler(handler))
        end

        def normalize_frontend_handler(handler)
          return handler if handler.respond_to?(:call)

          raise ArgumentError, "frontend route target must respond to #call"
        end

        def current_frontend_scope_stack
          @frontend_scope_stack ||= []
        end

        def scoped_frontend_path(path)
          segments = current_frontend_scope_stack + [path.to_s]
          normalized = segments.join("/")
          normalized = normalized.gsub(%r{/+}, "/")
          normalized = "/#{normalized}" unless normalized.start_with?("/")
          return "/" if normalized == "/"

          normalized.sub(%r{/\z}, "")
        end
      end
    end
  end
end
