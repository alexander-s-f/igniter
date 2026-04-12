# frozen_string_literal: true

module Igniter
  module Plugins
    module View
      module Response
        module_function

        def html(body, status: 200, headers: {})
          {
            status: status,
            body: body,
            headers: { "Content-Type" => "text/html; charset=utf-8" }.merge(headers)
          }
        end
      end
    end
  end
end
