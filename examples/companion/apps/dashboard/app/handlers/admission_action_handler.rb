# frozen_string_literal: true

require "uri"

module Companion
  module Dashboard
    # Handles operator approve/reject actions on pending admission requests.
    #
    # POST /admin/admission?action=admit&request_id=<id>
    # POST /admin/admission?action=reject&request_id=<id>
    #
    # After the action, redirects back to the dashboard home page.
    module AdmissionActionHandler
      module_function

      def call(params:, body:, headers:, env:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
        qs = URI.decode_www_form(env.fetch("QUERY_STRING", "")).to_h
        action     = (qs["action"] || body["action"] || "").to_s
        request_id = (qs["request_id"] || body["request_id"] || "").to_s

        case action
        when "admit"
          Igniter::Cluster::Mesh.approve_admission!(request_id)
        when "reject"
          Igniter::Cluster::Mesh.reject_admission!(request_id)
        end

        base_path = base_path_for(env)
        location  = [base_path, ""].reject(&:empty?).join("/") + "/?admission=#{action}"

        { status: 303, body: "", headers: { "Location" => location } }
      end

      def base_path_for(env)
        env["SCRIPT_NAME"].to_s.sub(%r{/+z}, "")
      end
    end
  end
end
