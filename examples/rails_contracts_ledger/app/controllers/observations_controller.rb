# frozen_string_literal: true

class ObservationsController < ApplicationController
  def show
    receipt = SparkContractableReceiptStore.instance.observation(params.fetch(:id))
    return render json: { error: "not found" }, status: :not_found unless receipt

    render json: {
      observation: receipt,
      events: SparkContractableReceiptStore.instance.events_for(params.fetch(:id))
    }
  end
end
