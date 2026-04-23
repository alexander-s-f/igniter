# frozen_string_literal: true

module Igniter
  module Cluster
    class PermissiveAdmission
      def admit(request:, route:)
        AdmissionResult.allowed(
          code: :accepted,
          metadata: {
            session_id: request.session_id,
            peer: route.peer.name
          },
          explanation: "permissive admission accepted #{request.session_id}"
        )
      end
    end
  end
end
