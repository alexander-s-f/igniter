#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"

module CompilerKernelOrderedRulePrecedence
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  OUT_DIR = ROOT / "igniter-lang/experiments/compiler_kernel_ordered_rule_precedence/out"
  SUMMARY_PATH = OUT_DIR / "compiler_kernel_ordered_rule_precedence_summary.json"

  FORMAT_VERSION = "0.1.0"
  TRACK = "compiler-kernel-ordered-rule-precedence-v0"

  class RegistryError < StandardError; end
  class DuplicateRuleError < RegistryError; end
  class DuplicateStrictKeyError < RegistryError; end
  class MissingRuleReferenceError < RegistryError; end
  class RuleCycleError < RegistryError; end
  class FrozenRegistryError < RegistryError; end

  class OrderedRuleRegistry
    Rule = Struct.new(:id, :owner, :priority, :before, :after, :payload, keyword_init: true)

    def initialize(name)
      @name = name
      @rules = {}
      @frozen = false
    end

    def register(id:, owner:, priority: 100, before: [], after: [], payload: {})
      raise FrozenRegistryError, "#{@name} is frozen" if @frozen

      normalized = id.to_s
      raise DuplicateRuleError, "#{@name} already has rule #{normalized}" if @rules.key?(normalized)

      @rules[normalized] = Rule.new(
        id: normalized,
        owner: owner.to_s,
        priority: priority,
        before: Array(before).map(&:to_s),
        after: Array(after).map(&:to_s),
        payload: payload
      )
    end

    def ordered_ids
      ordered_rules.map(&:id)
    end

    def ordered_rules
      validate_rule_references!
      graph = @rules.keys.to_h { |id| [id, []] }
      indegree = @rules.keys.to_h { |id| [id, 0] }

      @rules.each_value do |rule|
        rule.before.each { |target| add_edge(graph, indegree, rule.id, target) }
        rule.after.each { |target| add_edge(graph, indegree, target, rule.id) }
      end

      remaining = @rules.keys.to_h { |id| [id, true] }
      result = []

      until remaining.empty?
        available = remaining.keys
          .select { |id| indegree.fetch(id).zero? }
          .sort_by { |id| [@rules.fetch(id).priority, id] }
        raise RuleCycleError, "#{@name} rule ordering contains a cycle" if available.empty?

        id = available.first
        remaining.delete(id)
        result << @rules.fetch(id)
        graph.fetch(id).each { |target| indegree[target] -= 1 }
      end

      result
    end

    def entries
      @rules.transform_values do |rule|
        {
          "owner" => rule.owner,
          "priority" => rule.priority,
          "before" => rule.before,
          "after" => rule.after,
          "payload" => rule.payload
        }
      end
    end

    def freeze!
      @frozen = true
      @rules.freeze
      self
    end

    private

    def validate_rule_references!
      @rules.each_value do |rule|
        (rule.before + rule.after).each do |target|
          next if @rules.key?(target)

          raise MissingRuleReferenceError, "#{@name} rule #{rule.id} references missing rule #{target}"
        end
      end
    end

    def add_edge(graph, indegree, from, to)
      return if graph.fetch(from).include?(to)

      graph.fetch(from) << to
      indegree[to] += 1
    end
  end

  class StrictRegistry
    def initialize(name)
      @name = name
      @entries = {}
      @frozen = false
    end

    def register(key, owner)
      raise FrozenRegistryError, "#{@name} is frozen" if @frozen

      normalized = key.to_s
      if @entries.key?(normalized)
        previous = @entries.fetch(normalized)
        raise DuplicateStrictKeyError, "#{@name} #{normalized} already owned by #{previous}"
      end

      @entries[normalized] = owner.to_s
    end

    def entries
      @entries.dup
    end

    def freeze!
      @frozen = true
      @entries.freeze
      self
    end
  end

  class CompilerKernel
    attr_reader :ordered_registries, :strict_registries

    def initialize
      @ordered_registries = {
        "parser_rules" => OrderedRuleRegistry.new("parser_rules"),
        "classifier_rules" => OrderedRuleRegistry.new("classifier_rules"),
        "typechecker_rules" => OrderedRuleRegistry.new("typechecker_rules")
      }
      @strict_registries = {
        "oof_descriptors" => StrictRegistry.new("oof_descriptors"),
        "fragment_classes" => StrictRegistry.new("fragment_classes")
      }
    end

    def install(manifest)
      owner = manifest.fetch("name")
      manifest.fetch("ordered_rules", {}).each do |registry_name, rules|
        registry = ordered_registries.fetch(registry_name)
        rules.each do |rule|
          registry.register(
            id: rule.fetch("id"),
            owner: owner,
            priority: rule.fetch("priority", 100),
            before: rule.fetch("before", []),
            after: rule.fetch("after", []),
            payload: rule.fetch("payload", {})
          )
        end
      end
      manifest.fetch("strict_keys", {}).each do |registry_name, keys|
        registry = strict_registries.fetch(registry_name)
        keys.each { |key| registry.register(key, owner) }
      end
      self
    end

    def finalize
      ordered = ordered_registries.transform_values(&:ordered_ids)
      ordered_registries.each_value(&:freeze!)
      strict_registries.each_value(&:freeze!)
      payload = {
        "kind" => "ordered_rule_profile_spike",
        "format_version" => FORMAT_VERSION,
        "track" => TRACK,
        "dispatch_mode" => "ordered_registry_only_no_compiler_dispatch",
        "ordered_registries" => ordered,
        "strict_registries" => strict_registries.transform_values(&:entries),
        "igapp_manifest_changes" => []
      }
      payload.merge("profile_id" => CompilerKernelOrderedRulePrecedence.profile_id(payload))
    end
  end

  MANIFESTS = [
    {
      "name" => "CoreLanguagePack",
      "ordered_rules" => {
        "parser_rules" => [
          { "id" => "core.parse_contract_decl", "priority" => 100 }
        ],
        "classifier_rules" => [
          { "id" => "core.contract_fragment_default", "priority" => 100 }
        ],
        "typechecker_rules" => [
          { "id" => "core.typecheck_contract", "priority" => 100 }
        ]
      },
      "strict_keys" => {
        "fragment_classes" => ["core"],
        "oof_descriptors" => %w[OOF-P0 OOF-P1 OOF-TY0]
      }
    },
    {
      "name" => "EscapeBoundaryPack",
      "ordered_rules" => {
        "classifier_rules" => [
          {
            "id" => "escape.classify_escape_boundary",
            "priority" => 120,
            "after" => ["core.contract_fragment_default"]
          }
        ]
      },
      "strict_keys" => {
        "fragment_classes" => ["escape"],
        "oof_descriptors" => []
      }
    },
    {
      "name" => "ContractModifiersPack",
      "ordered_rules" => {
        "parser_rules" => [
          {
            "id" => "contract_modifiers.parse_modifier_prefix",
            "priority" => 80,
            "before" => ["core.parse_contract_decl"]
          }
        ],
        "classifier_rules" => [
          {
            "id" => "contract_modifiers.modifier_fragment_widening",
            "priority" => 200,
            "after" => ["escape.classify_escape_boundary"],
            "before" => ["temporal.temporal_precedence"]
          },
          {
            "id" => "contract_modifiers.oof_m1_pure_escape",
            "priority" => 210,
            "after" => ["contract_modifiers.modifier_fragment_widening"]
          }
        ],
        "typechecker_rules" => [
          {
            "id" => "contract_modifiers.propagate_oof_m1",
            "priority" => 200,
            "after" => ["core.typecheck_contract"]
          }
        ]
      },
      "strict_keys" => {
        "fragment_classes" => [],
        "oof_descriptors" => ["OOF-M1"]
      }
    },
    {
      "name" => "TemporalPack",
      "ordered_rules" => {
        "classifier_rules" => [
          {
            "id" => "temporal.temporal_precedence",
            "priority" => 300,
            "after" => ["contract_modifiers.modifier_fragment_widening"]
          }
        ],
        "typechecker_rules" => [
          {
            "id" => "temporal.typecheck_temporal_access",
            "priority" => 300,
            "after" => ["contract_modifiers.propagate_oof_m1"]
          }
        ]
      },
      "strict_keys" => {
        "fragment_classes" => ["temporal"],
        "oof_descriptors" => %w[OOF-H1 OOF-BT1]
      }
    }
  ].freeze

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    positive_profile = build_profile(MANIFESTS)
    reversed_profile = build_profile(MANIFESTS.reverse)
    negative_results = build_negative_results
    checks = build_checks(positive_profile, reversed_profile, negative_results)
    summary = {
      "kind" => "compiler_kernel_ordered_rule_precedence_summary",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "positive_profile" => positive_profile,
      "reversed_install_profile" => {
        "profile_id" => reversed_profile.fetch("profile_id"),
        "ordered_registries" => reversed_profile.fetch("ordered_registries")
      },
      "negative_results" => negative_results,
      "checks" => checks,
      "policy" => {
        "strict_registries" => %w[oof_descriptors fragment_classes],
        "ordered_registries" => %w[parser_rules classifier_rules typechecker_rules],
        "tie_break" => "priority_then_rule_id",
        "missing_references" => "error",
        "cycles" => "error"
      },
      "non_goals" => [
        "No compiler pass dispatch.",
        "No production CompilerKernel implementation.",
        "No .igapp manifest changes."
      ]
    }
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def build_profile(manifests)
    kernel = CompilerKernel.new
    manifests.each { |manifest| kernel.install(manifest) }
    kernel.finalize
  end

  def build_negative_results
    {
      "missing_before_reference" => capture_error do
        build_profile([
          {
            "name" => "BrokenPack",
            "ordered_rules" => {
              "classifier_rules" => [
                { "id" => "broken.rule", "before" => ["missing.rule"] }
              ]
            },
            "strict_keys" => {}
          }
        ])
      end,
      "cycle_rejected" => capture_error do
        build_profile([
          {
            "name" => "CyclePack",
            "ordered_rules" => {
              "classifier_rules" => [
                { "id" => "cycle.a", "after" => ["cycle.b"] },
                { "id" => "cycle.b", "after" => ["cycle.a"] }
              ]
            },
            "strict_keys" => {}
          }
        ])
      end,
      "duplicate_ordered_rule_rejected" => capture_error do
        build_profile([
          {
            "name" => "DuplicateOrderedPack",
            "ordered_rules" => {
              "parser_rules" => [
                { "id" => "dup.rule" },
                { "id" => "dup.rule" }
              ]
            },
            "strict_keys" => {}
          }
        ])
      end,
      "duplicate_strict_oof_rejected" => capture_error do
        build_profile([
          {
            "name" => "OOFA",
            "ordered_rules" => {},
            "strict_keys" => { "oof_descriptors" => ["OOF-X1"] }
          },
          {
            "name" => "OOFB",
            "ordered_rules" => {},
            "strict_keys" => { "oof_descriptors" => ["OOF-X1"] }
          }
        ])
      end
    }
  end

  def capture_error
    yield
    { "raised" => false, "class" => nil, "message" => nil }
  rescue RegistryError => e
    { "raised" => true, "class" => e.class.name.split("::").last, "message" => e.message }
  end

  def build_checks(positive_profile, reversed_profile, negative_results)
    {
      "positive.dispatch_ordered_registry_only" => positive_profile.fetch("dispatch_mode") == "ordered_registry_only_no_compiler_dispatch",
      "positive.parser_modifier_before_contract" => positive_profile.dig("ordered_registries", "parser_rules") == %w[
        contract_modifiers.parse_modifier_prefix core.parse_contract_decl
      ],
      "positive.classifier_temporal_after_modifier" => positive_profile.dig("ordered_registries", "classifier_rules") == %w[
        core.contract_fragment_default
        escape.classify_escape_boundary
        contract_modifiers.modifier_fragment_widening
        contract_modifiers.oof_m1_pure_escape
        temporal.temporal_precedence
      ],
      "positive.typechecker_order" => positive_profile.dig("ordered_registries", "typechecker_rules") == %w[
        core.typecheck_contract
        contract_modifiers.propagate_oof_m1
        temporal.typecheck_temporal_access
      ],
      "positive.strict_oof_ownership" => positive_profile.dig("strict_registries", "oof_descriptors", "OOF-M1") == "ContractModifiersPack",
      "positive.strict_fragment_ownership" => positive_profile.dig("strict_registries", "fragment_classes", "temporal") == "TemporalPack",
      "positive.no_igapp_manifest_changes" => positive_profile.fetch("igapp_manifest_changes").empty?,
      "determinism.install_order_independent" => positive_profile.fetch("ordered_registries") == reversed_profile.fetch("ordered_registries"),
      "determinism.profile_id_stable_for_same_rules" => positive_profile.fetch("profile_id") == reversed_profile.fetch("profile_id"),
      "negative.missing_reference_rejected" => error_class?(negative_results, "missing_before_reference", "MissingRuleReferenceError"),
      "negative.cycle_rejected" => error_class?(negative_results, "cycle_rejected", "RuleCycleError"),
      "negative.duplicate_ordered_rule_rejected" => error_class?(negative_results, "duplicate_ordered_rule_rejected", "DuplicateRuleError"),
      "negative.duplicate_strict_oof_rejected" => error_class?(negative_results, "duplicate_strict_oof_rejected", "DuplicateStrictKeyError")
    }
  end

  def error_class?(negative_results, key, expected_class)
    result = negative_results.fetch(key)
    result.fetch("raised") == true && result.fetch("class") == expected_class
  end

  def profile_id(payload)
    "ordered_rule_profile/sha256:#{Digest::SHA256.hexdigest(canonical_json(payload))[0, 24]}"
  end

  def canonical_json(value)
    JSON.generate(sort_value(value))
  end

  def sort_value(value)
    case value
    when Hash
      value.keys.sort.each_with_object({}) { |key, result| result[key] = sort_value(value.fetch(key)) }
    when Array
      value.map { |item| sort_value(item) }
    else
      value
    end
  end

  def write_json(path, value)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} compiler_kernel_ordered_rule_precedence"
    summary.fetch("checks").each do |label, ok|
      puts "#{label}: #{ok ? "ok" : "FAIL"}"
    end
    puts "profile_id: #{summary.fetch("positive_profile").fetch("profile_id")}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = CompilerKernelOrderedRulePrecedence.run
exit(success ? 0 : 1)
