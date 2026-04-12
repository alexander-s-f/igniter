# frozen_string_literal: true

module Companion
  module Dashboard
    class TrainingCheckinSubmissionContract < Igniter::Contract
      define do
        input :view_id
        input :submission_id
        input :checkin

        compute :record,
                depends_on: %i[view_id submission_id checkin],
                call: lambda { |view_id:, submission_id:, checkin:|
                  Companion::Dashboard::TrainingCheckinStore.create(
                    view_id: view_id,
                    submission_id: submission_id,
                    checkin: checkin
                  )
                }

        output :record
      end
    end
  end
end
