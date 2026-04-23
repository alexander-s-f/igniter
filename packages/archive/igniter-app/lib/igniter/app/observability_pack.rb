# frozen_string_literal: true

module Igniter
  class App
    module ObservabilityPack
      class << self
        def install(app_class, path: "/api/operator", limit: 20, store: nil)
          replace_existing_route!(app_class, "GET", path, handler_class: Observability::OperatorOverviewHandler)

          app_class.route(
            "GET",
            path,
            with: Observability::OperatorOverviewHandler.new(
              app_class: app_class,
              limit: limit,
              store: store
            )
          )

          app_class
        end

        def install_actions(app_class, path: "/api/operator/actions", store: nil)
          replace_existing_route!(app_class, "POST", path, handler_class: Observability::OperatorActionHandler)

          app_class.route(
            "POST",
            path,
            with: Observability::OperatorActionHandler.new(
              app_class: app_class,
              store: store
            )
          )

          app_class
        end

        def install_surface(app_class, path: "/operator", api_path: "/api/operator", action_path: "/api/operator/actions", limit: 20, store: nil, title: nil)
          install(app_class, path: api_path, limit: limit, store: store)
          install_actions(app_class, path: action_path, store: store)
          replace_existing_route!(app_class, "GET", path, handler_class: Observability::OperatorConsoleHandler)

          app_class.route(
            "GET",
            path,
            with: Observability::OperatorConsoleHandler.new(
              app_class: app_class,
              api_path: api_path,
              action_path: action_path,
              title: title
            )
          )

          app_class
        end

        private

        def replace_existing_route!(app_class, method, path, handler_class:)
          routes = Array(app_class.instance_variable_get(:@custom_routes)).dup
          routes.reject! do |route|
            route[:method] == method &&
              route[:path] == path &&
              route[:handler].is_a?(handler_class)
          end
          app_class.instance_variable_set(:@custom_routes, routes)
        end
      end
    end
  end
end
