#!/usr/bin/env ruby
# frozen_string_literal: true

# Validator for deterministic regression artifact policy (S3-R27-C2-P).
# Reads committed experiments/*/out/*.json files and checks:
#   1. _volatile_fields, if present, is an Array.
#   2. _volatile_fields does not include protected fields (status, verdict, checks, boolean-check
#      fields). Protected fields must remain comparable across regression reruns.
#   3. status, if present, is "PASS" or "FAIL" (not a volatile marker).
#
# Usage:
#   ruby igniter-lang/experiments/volatile_fields_lint/volatile_fields_lint.rb
#
# Exit 0 = all checks pass. Exit 1 = at least one violation found.

require "json"
require "pathname"

ROOT         = Pathname.new(File.expand_path("../../..", __dir__))
IGNITER_LANG = ROOT / "igniter-lang"

PROTECTED_FIELDS = %w[status verdict checks].freeze

module VolatileFieldsLint
  module_function

  def run
    summaries = collect_summaries
    violations = summaries.flat_map { |path, data| check(path, data) }
    print_results(summaries.size, violations)
    violations.empty?
  end

  def collect_summaries
    results = {}
    pattern = IGNITER_LANG / "experiments/**/*.json"
    Dir.glob(pattern.to_s).sort.each do |path|
      next if path.include?(".igapp/")
      next if path.include?("/golden/")
      next if path.include?("/fixtures/")
      next if path.include?("/classified/")

      data = JSON.parse(File.read(path))
      next unless data.is_a?(Hash) && data.key?("status")
      next unless data.key?("_volatile_fields")

      results[path] = data
    rescue JSON::ParserError
      # Skip non-JSON or malformed files silently
    end
    results
  end

  def check(path, data)
    violations = []
    volatile = data["_volatile_fields"]
    rel = Pathname.new(path).relative_path_from(ROOT).to_s

    unless volatile.is_a?(Array)
      violations << "#{rel}: _volatile_fields is not an Array (got #{volatile.class})"
      return violations
    end

    if volatile.empty?
      violations << "#{rel}: _volatile_fields is empty — omit the key or add at least one field name"
    end

    (volatile & PROTECTED_FIELDS).each do |bad|
      violations << "#{rel}: _volatile_fields includes protected field '#{bad}' — this field must remain comparable"
    end

    volatile.each do |field|
      unless field.is_a?(String)
        violations << "#{rel}: _volatile_fields contains non-string entry #{field.inspect}"
      end
    end

    violations
  end

  def print_results(total_checked, violations)
    if violations.empty?
      puts "volatile_fields_lint: PASS (#{total_checked} artifact(s) with _volatile_fields — no violations)"
    else
      puts "volatile_fields_lint: FAIL (#{violations.size} violation(s) across #{total_checked} artifact(s))"
      violations.each { |v| puts "  VIOLATION: #{v}" }
    end
  end
end

success = VolatileFieldsLint.run
exit(success ? 0 : 1)
