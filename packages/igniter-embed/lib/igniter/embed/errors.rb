# frozen_string_literal: true

module Igniter
  module Embed
    Error = Class.new(StandardError)
    DuplicateContractError = Class.new(Error)
    InvalidContractRegistrationError = Class.new(Error)
    UnknownContractError = Class.new(Error)
    RailsIntegrationError = Class.new(Error)
  end
end
