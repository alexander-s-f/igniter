# frozen_string_literal: true

module Igniter
  module Contracts
    Error = Class.new(StandardError)
    ValidationError = Class.new(Error)
    FrozenKernelError = Class.new(Error)
    FrozenRegistryError = Class.new(Error)
    DuplicateRegistrationError = Class.new(Error)
    UnknownDslKeywordError = Class.new(Error)
    UnknownNodeKindError = Class.new(Error)
    ProfileMismatchError = Class.new(Error)
  end
end
