#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../lib/igniter_lang/temporal_access_runtime"

TemporalAccessRuntime = IgniterLang::TemporalAccessRuntime unless Object.const_defined?(:TemporalAccessRuntime, false)
