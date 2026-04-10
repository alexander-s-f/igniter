#!/usr/bin/env ruby
# frozen_string_literal: true

# Thin wrapper — delegates to the canonical Application entrypoint.
# Kept for backward compatibility; prefer using application.rb directly.
load File.join(__dir__, "../application.rb")
