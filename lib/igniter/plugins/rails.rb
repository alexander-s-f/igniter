# frozen_string_literal: true

require_relative "../../igniter"
require_relative "rails/railtie" if defined?(::Rails::Railtie)
require_relative "rails/contract_job"
require_relative "rails/webhook_concern"
require_relative "rails/cable_adapter"

module Igniter
  module Rails
  end
end
