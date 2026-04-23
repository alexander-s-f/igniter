# frozen_string_literal: true

require "json"

module Igniter
  module Frontend
    class Response
      class << self
        def html(body, status: 200, headers: {})
          {
            status: status,
            body: body,
            headers: { "Content-Type" => "text/html; charset=utf-8" }.merge(stringify_keys(headers))
          }
        end

        def json(body, status: 200, headers: {})
          {
            status: status,
            body: JSON.generate(body),
            headers: { "Content-Type" => "application/json; charset=utf-8" }.merge(stringify_keys(headers))
          }
        end

        def text(body, status: 200, headers: {})
          {
            status: status,
            body: body.to_s,
            headers: { "Content-Type" => "text/plain; charset=utf-8" }.merge(stringify_keys(headers))
          }
        end

        def redirect(location, status: 303, headers: {})
          {
            status: status,
            body: "",
            headers: { "Location" => location.to_s }.merge(stringify_keys(headers))
          }
        end

        private

        def stringify_keys(headers)
          headers.to_h.each_with_object({}) do |(key, value), memo|
            memo[key.to_s] = value
          end
        end
      end

      def html(...)
        self.class.html(...)
      end

      def json(...)
        self.class.json(...)
      end

      def text(...)
        self.class.text(...)
      end

      def redirect(...)
        self.class.redirect(...)
      end
    end
  end
end
