# frozen_string_literal: true

# Loading this file activates content-addressed caching for pure executors.
# The Resolver picks up content addressing via a guard clause when this constant is defined.
require "igniter/core/content_addressing"
