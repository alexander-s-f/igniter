# frozen_string_literal: true

class AvailabilityController < ApplicationController
  def show
    result = Rails.application.config.x.availability_observer.call(
      request_ref: params.fetch(:request_ref, "req-demo"),
      company_ref: params.fetch(:company_ref, "company-demo"),
      service_area_ref: params.fetch(:service_area_ref, "area-demo"),
      trade_ref: params.fetch(:trade_ref, "trade-demo"),
      window_ref: params.fetch(:window_ref, "today-am"),
      raw_customer_payload: params[:raw_customer_payload],
      provider_token: params[:provider_token]
    )

    observation_id = SparkContractableReceiptStore.instance.latest_observation_id

    render json: {
      primary: result,
      observation_id: observation_id,
      observation_path: observation_path(observation_id)
    }
  end
end
