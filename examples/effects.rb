# frozen_string_literal: true

# examples/effects.rb
#
# Demonstrates the Igniter Effect system — first-class side-effect nodes
# that participate fully in the computation graph.
#
# Run with: bundle exec ruby examples/effects.rb

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "igniter"
require "igniter/extensions/saga"
require "igniter/extensions/execution_report"

# ── 1. Define effect adapters ──────────────────────────────────────────────────

class UserRepository < Igniter::Effect
  effect_type :database
  idempotent  false

  # Simulate a DB lookup
  def call(user_id:)
    raise "User #{user_id} not found" if user_id == "missing"

    { id: user_id, name: "Alice", tier: "premium" }
  end

  # Built-in rollback: undo any changes made by this effect
  compensate do |**|
    puts "  [compensate] Rolling back user lookup (no-op for reads)"
  end
end

class AuditLogger < Igniter::Effect
  effect_type :audit
  idempotent  true

  def call(user_id:, action: "lookup")
    puts "  [audit] #{action} performed for user #{user_id}"
    { logged_at: Time.now.iso8601, action: action }
  end
end

class EmailNotifier < Igniter::Effect
  effect_type :notification

  def call(user:, action: "welcome")
    raise "Email delivery failed" if user[:tier] == "suspended"

    message = "#{action.to_s.tr("_", " ")} for #{user[:name]}"
    puts "  [email] Sending '#{message}' to #{user[:name]}"
    { delivered: true, recipient: user[:name], message: message }
  end

  compensate do |inputs:, **|
    puts "  [compensate] Cancelling email to #{inputs[:user]&.dig(:name)}"
  end
end

# ── 2. Define a contract using effects ────────────────────────────────────────

class WelcomeWorkflow < Igniter::Contract
  define do
    input :user_id
    input :action, default: "welcome"

    effect :user,   uses: UserRepository, depends_on: :user_id
    effect :log,    uses: AuditLogger,    depends_on: %i[user_id action]
    effect :email,  uses: EmailNotifier,  depends_on: %i[user action]

    compute :summary, depends_on: %i[user email] do |user:, email:|
      "Welcomed #{user[:name]}: email=#{email[:delivered]}"
    end

    output :summary
    output :user
    output :log
  end
end

# ── 3. Register an effect in the registry (optional, enables symbol lookup) ───

Igniter.register_effect(:user_repo, UserRepository)
Igniter.register_effect(:audit_log, AuditLogger)

class RegistryWorkflow < Igniter::Contract
  define do
    input :user_id

    # Uses registered names instead of class references
    effect :user_data, uses: :user_repo, depends_on: :user_id
    effect :log_entry, uses: :audit_log, depends_on: [:user_id]

    output :user_data
  end
end

# ── 4. Run the happy path ──────────────────────────────────────────────────────

puts "=" * 60
puts "HAPPY PATH"
puts "=" * 60

contract = WelcomeWorkflow.new(user_id: "u42", action: "onboarding")
contract.resolve_all

puts
puts "  summary: #{contract.result.summary.inspect}"
puts "  user:    #{contract.result.user.inspect}"
puts "  log:     #{contract.result.log.inspect}"
puts

# Execution report
report = contract.execution_report
puts report.explain
puts

# ── 5. Run via registry ────────────────────────────────────────────────────────

puts "=" * 60
puts "REGISTRY LOOKUP"
puts "=" * 60
puts

rw = RegistryWorkflow.new(user_id: "u99")
rw.resolve_all
puts "  user_data: #{rw.result.user_data.inspect}"
puts

# ── 6. Saga with built-in compensation ────────────────────────────────────────

puts "=" * 60
puts "SAGA — effect failure triggers built-in compensation"
puts "=" * 60
puts

class FailingWorkflow < Igniter::Contract
  define do
    input :user_id

    effect :user,    uses: UserRepository, depends_on: :user_id
    effect :notify,  uses: EmailNotifier,  depends_on: :user

    output :user
  end
end

# Build a user that has "suspended" tier to trigger EmailNotifier failure
class SuspendedUserRepo < Igniter::Effect
  effect_type :database

  def call(user_id:)
    { id: user_id, name: "Bob", tier: "suspended" }
  end

  compensate do |value:, **|
    puts "  [compensate] Undoing user fetch for #{value[:name]}"
  end
end

class FailingWorkflow2 < Igniter::Contract
  define do
    input :user_id

    effect :user,   uses: SuspendedUserRepo, depends_on: :user_id
    effect :notify, uses: EmailNotifier,     depends_on: :user

    output :user
    output :notify
  end
end

saga_result = FailingWorkflow2.new(user_id: "u_suspended").resolve_saga
puts
puts "Success: #{saga_result.success?}"
puts "Failed node: #{saga_result.failed_node}"
puts "Error: #{saga_result.error.message}"
puts
puts "Compensations:"
saga_result.compensations.each do |record|
  status = record.success? ? "ok" : "FAILED: #{record.error.message}"
  puts "  :#{record.node_name} → #{status}"
end
puts
puts saga_result.explain
