# frozen_string_literal: true

require "uri"

module InteractiveOperator
  module Server
    class RackApp
      attr_reader :environment, :mount

      def initialize(environment:, mount:)
        @environment = environment
        @mount = mount.bind(environment: environment)
      end

      def call(env)
        case [env.fetch("REQUEST_METHOD", "GET"), env.fetch("PATH_INFO", "/")]
        in ["GET", "/"]
          mount.rack_app.call(env)
        in ["GET", "/events"]
          text_response("open=#{board.open_count}")
        in ["POST", "/tasks"]
          handle_task_post(env)
        else
          not_found
        end
      end

      private

      def handle_task_post(env)
        params = URI.decode_www_form(read_body(env)).to_h
        board.resolve(params.fetch("id", ""))
        [
          303,
          { "location" => "/", "content-type" => "text/plain; charset=utf-8" },
          ["See /"]
        ]
      end

      def read_body(env)
        input = env["rack.input"]
        input ? input.read.to_s : ""
      ensure
        input&.rewind
      end

      def board
        environment.service(:task_board).call
      end

      def text_response(body)
        [200, { "content-type" => "text/plain; charset=utf-8" }, [body]]
      end

      def not_found
        [404, { "content-type" => "text/plain; charset=utf-8" }, ["not found"]]
      end
    end
  end
end
