# frozen_string_literal: true

module Igniter
  class Error < StandardError; end
  class CompileError < Error; end
  class ValidationError < CompileError; end
  class CycleError < ValidationError; end
  class InputError < Error; end
  class ResolutionError < Error; end
  class CompositionError < Error; end
end
