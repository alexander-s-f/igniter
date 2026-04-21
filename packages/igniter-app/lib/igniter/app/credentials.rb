# frozen_string_literal: true

require_relative "credentials/credential_policy"
require_relative "credentials/credential"
require_relative "credentials/config_loader"
require_relative "credentials/lease_request"
require_relative "credentials/policies"
require_relative "credentials/events"
require_relative "credentials/trail"
require_relative "credentials/store"
require_relative "credentials/stores/file_store"

module Igniter
  class App
    module Credentials
    end
  end
end
