# frozen_string_literal: true

require_relative "core/legacy"
Igniter::Core::Legacy.require!("igniter/core")

require_relative "core/version"
require_relative "core/errors"
require_relative "core/type_system"
require_relative "core/executor"
require_relative "core/executor_registry"
require_relative "core/effect"
require_relative "core/effect_registry"
require_relative "core/model"
require_relative "core/compiler"
require_relative "core/events"
require_relative "core/runtime"
require_relative "core/dto"
require_relative "core/dsl"
require_relative "core/extensions"
require_relative "core/diagnostics"
require_relative "core/contract"
require_relative "core/stream_loop"
require_relative "core/tool"

module Igniter
end
