# frozen_string_literal: true

# OOF/Fragment Registry internal validator.
#
# ISOLATION CONTRACT — this file must not:
#   - be required from lib/igniter_lang.rb
#   - integrate with any compiler pass (parser/classifier/TypeChecker/SemanticIR/assembler)
#   - emit public diagnostics
#   - write to report["diagnostics"] or top-level compilation reports
#   - add CompilerResult fields
#   - expose public API or CLI
#   - call runtime, Ledger/TBackend, Gate 3, cache, signing, or production behavior
#
# Authorized by: LANG-R102-A (registry validator)
#                LANG-R110-A (source-envelope helper)
# Tracks: oof-fragment-registry-implementation-boundary-proof-v0
#         oof-fragment-registry-source-envelope-helper-proof-v0
#
# R92 historical note: the shadow proof JSON at
#   experiments/oof_fragment_registry_shadow_proof/out/oof_descriptors.shadow_registry.json
# placed PINV-*/TINV-* inside oof_descriptors as historical proof evidence.
# That placement is NON-FORWARD. The forward shape (authorized by LANG-R98-A
# and LANG-R101-D1) places PINV-*/TINV-* exclusively under
# support_markers.invariant_support_markers. This validator enforces the
# forward shape.

require "set"

module IgniterLang
  class OOFFragmentRegistry
    FORMAT_VERSION = "0.1.0".freeze

    # Namespace prefixes that must be present in excluded_namespaces.
    REQUIRED_EXCLUDED_PREFIXES = %w[
      compiler_profile_contract.
      compiler_profile_contract_refusal.
    ].freeze

    # Support marker code pattern: only PINV-* and TINV-* are support markers.
    SUPPORT_MARKER_PATTERN = /\A(PINV|TINV)-/.freeze

    # Fragment row names that are guarded non-fragments (must have classification_kind "not_fragment_class").
    GUARDED_NON_FRAGMENT_NAMES = %w[olap progression].freeze

    # The special "oof" fragment row that must be non-loadable and capability-free.
    OOF_ROW_NAME = "oof".freeze

    # Acceptable public_code_stability values for support markers (non-public).
    SUPPORT_MARKER_STABILITY_VALUES = %w[non_public_support_marker proof_only].freeze

    # -------------------------------------------------------------------------
    # Source-envelope helper — accepted and held/rejected source modes.
    # Authorized by: LANG-R110-A
    # These constants are internal to this helper and are NOT public API.
    # -------------------------------------------------------------------------

    # Accepted source modes for validate_source_envelope.
    SOURCE_ACCEPTED_MODES = %w[proof_fixture caller_supplied].freeze

    # Held modes: recognized but not yet authorized for helper processing.
    SOURCE_HELD_MODES = %w[profile_candidate pack_descriptor_candidate].freeze

    # Accepted authority kinds for source envelope.
    SOURCE_ACCEPTED_AUTHORITY_KINDS = %w[proof_only design_accepted].freeze

    # Accepted (non-canon) canon_status values.
    SOURCE_ACCEPTED_CANON_STATUSES = %w[non_canon accepted_design].freeze

    # Source-envelope helper diagnostic codes.
    # These are internal helper diagnostics. They are NOT language OOF codes and
    # are NOT central IgniterLang::Diagnostics entries.
    SOURCE_DIAG_WRONG_KIND                 = "oof_registry.source.validation.wrong_kind".freeze
    SOURCE_DIAG_UNSUPPORTED_FORMAT_VERSION = "oof_registry.source.validation.unsupported_format_version".freeze
    SOURCE_DIAG_UNSUPPORTED_SOURCE_MODE    = "oof_registry.source.validation.unsupported_source_mode".freeze
    SOURCE_DIAG_HELD_SOURCE_MODE           = "oof_registry.source.validation.held_source_mode".freeze
    SOURCE_DIAG_INVALID_AUTHORITY_KIND     = "oof_registry.source.validation.invalid_authority_kind".freeze
    SOURCE_DIAG_CANON_STATUS_FORBIDDEN     = "oof_registry.source.validation.canon_status_forbidden".freeze
    SOURCE_DIAG_MISSING_AUTHORITY          = "oof_registry.source.validation.missing_authority".freeze
    SOURCE_DIAG_MISSING_AUTHORITY_REF      = "oof_registry.source.validation.missing_authority_ref".freeze
    SOURCE_DIAG_MISSING_REGISTRY           = "oof_registry.source.validation.missing_registry".freeze
    SOURCE_DIAG_SURFACE_OPEN               = "oof_registry.source.validation.surface_open".freeze

    # -------------------------------------------------------------------------
    # Internal validator diagnostic codes.
    # These are NOT public language OOF codes and are NOT central IgniterLang::Diagnostics entries.
    DIAG_MISSING_SECTION               = "oof_registry.validation.missing_section".freeze
    DIAG_WRONG_KIND                    = "oof_registry.validation.wrong_kind".freeze
    DIAG_DUPLICATE_CODE                = "oof_registry.validation.duplicate_code".freeze
    DIAG_ALIAS_COLLISION               = "oof_registry.validation.alias_collision".freeze
    DIAG_ALIAS_MISSING_REPLACEMENT     = "oof_registry.validation.alias_missing_replacement".freeze
    DIAG_EXCLUDED_NAMESPACE_COLLISION  = "oof_registry.validation.excluded_namespace_collision".freeze
    DIAG_SUPPORT_MARKER_IN_DESCRIPTORS = "oof_registry.validation.support_marker_in_oof_descriptors".freeze
    DIAG_SUPPORT_MARKER_PUBLIC         = "oof_registry.validation.support_marker_public".freeze
    DIAG_SUPPORT_MARKER_EMITTED        = "oof_registry.validation.support_marker_emitted".freeze
    DIAG_SUPPORT_MARKER_CODE_COLLISION = "oof_registry.validation.support_marker_code_collision".freeze
    DIAG_OOF_PROJECTION_LOADABLE       = "oof_registry.validation.oof_projection_loadable".freeze
    DIAG_OOF_PROJECTION_CAPABILITY     = "oof_registry.validation.oof_projection_capability".freeze
    DIAG_GUARDED_NON_FRAGMENT          = "oof_registry.validation.guarded_non_fragment_violation".freeze
    DIAG_OWNER_BOUNDARY_ABSENT         = "oof_registry.validation.owner_boundary_absent".freeze

    # Validate a registry hash against the R101 forward bucket shape.
    #
    # @param registry [Hash] The registry object to validate (caller-supplied).
    # @param installed_boundaries [Array<String>, nil]
    #   When supplied, rows owned by a boundary not in this list are recorded
    #   as inactive rows. Inactive rows are NOT silently skipped — they are
    #   recorded in the result. Inactive rows do not flip valid: false.
    #   When nil, boundary-absence checks are skipped.
    #
    # @return [Hash] Internal validation result.
    #   NEVER touches compiler state, reports, or public surfaces.
    def validate(registry, installed_boundaries: nil)
      diags        = []
      inactive_rows = []

      # Step 1 — top-level shape
      shape_diags = check_top_level_shape(registry)
      diags.concat(shape_diags)
      return build_result(false, diags, inactive_rows) unless shape_diags.empty?

      oof_descriptors     = Array(registry["oof_descriptors"])
      fragment_rows       = Array(registry["fragment_rows"])
      support_markers_arr = Array(registry.dig("support_markers", "invariant_support_markers"))
      excluded_namespaces = Array(registry["excluded_namespaces"])
      excluded_prefixes   = excluded_namespaces.map { |n| n["prefix"] }.compact

      # Pre-collect all canonical OOF codes + aliases for cross-collision detection
      all_oof_canonical = oof_descriptors.map { |d| d["code"] }.compact.to_set
      all_oof_aliases   = oof_descriptors.flat_map { |d| Array(d["aliases"]) }.to_set
      all_oof_code_set  = all_oof_canonical | all_oof_aliases

      # Step 2 — OOF descriptors
      diags.concat(check_oof_descriptors(oof_descriptors, excluded_prefixes, all_oof_canonical))

      # Step 3 — fragment rows
      diags.concat(check_fragment_rows(fragment_rows))

      # Step 4 — support markers
      diags.concat(check_support_markers(support_markers_arr, all_oof_code_set))

      # Step 5 — excluded namespaces
      diags.concat(check_excluded_namespaces(excluded_namespaces))

      # Step 6 — absent-owner inactive rows (recorded, not silently skipped)
      if installed_boundaries
        boundaries_set = installed_boundaries.to_set
        candidates = [
          *oof_descriptors.map   { |row| ["oof_descriptor",  row["code"] || row["name"],  row] },
          *fragment_rows.map     { |row| ["fragment_row",    row["name"],                  row] },
          *support_markers_arr.map { |row| ["support_marker", row["code"] || row["name"],  row] }
        ]
        candidates.each do |section_kind, row_id, row|
          owner = row["owner_pack_or_boundary"]
          next unless owner
          next if boundaries_set.include?(owner)

          inactive_rows << {
            "section"    => section_kind,
            "row_id"     => row_id,
            "owner"      => owner,
            "reason"     => "owner_pack_or_boundary_absent_from_installed_boundaries"
          }
        end
      end

      build_result(diags.empty?, diags, inactive_rows)
    end

    # Validate a source envelope and, if valid, validate its nested registry.
    #
    # This is an internal helper only. It is NOT a public API, NOT a loader,
    # NOT a compiler pass, and NOT a report surface. It is callable only from
    # proof-local harnesses via direct require of this file.
    #
    # Authorized by: LANG-R110-A
    # Design: oof-fragment-registry-source-envelope-helper-boundary-design-v0 (LANG-R109-D1)
    #
    # @param source_envelope [Hash] A source envelope describing where the registry
    #   hash comes from. Must have kind, format_version, source_mode, authority, registry.
    # @param installed_boundaries [Array<String>, nil]
    #   Forwarded to the nested registry validate call when source envelope passes.
    #
    # @return [Hash] Internal source-envelope validation result.
    #   - valid: true only when source-envelope validation AND nested registry validation pass.
    #   - source_mode: the source_mode from the envelope (or nil if envelope is malformed).
    #   - registry_present: whether the envelope contained a registry hash.
    #   - source_diagnostics: internal source-envelope diagnostics only.
    #   - registry_validation: the nested registry validation result, or nil if source invalid.
    #   - closed_surface_assertions: all false (machine-assertable).
    #   NEVER touches compiler state, reports, or public surfaces.
    def validate_source_envelope(source_envelope, installed_boundaries: nil)
      source_diags = []

      # Step 1 — envelope must be a Hash with correct kind
      unless source_envelope.is_a?(Hash)
        source_diags << source_diag(SOURCE_DIAG_WRONG_KIND,
          "source envelope must be a Hash, got #{source_envelope.class}")
        return build_source_result(false, nil, false, source_diags, nil)
      end

      if source_envelope["kind"] != "oof_fragment_registry_source"
        source_diags << source_diag(SOURCE_DIAG_WRONG_KIND,
          "source envelope kind must be 'oof_fragment_registry_source', " \
          "got #{source_envelope["kind"].inspect}")
      end

      # Step 2 — format version
      unless source_envelope["format_version"] == "0.1.0"
        source_diags << source_diag(SOURCE_DIAG_UNSUPPORTED_FORMAT_VERSION,
          "source envelope format_version must be '0.1.0', " \
          "got #{source_envelope["format_version"].inspect}")
      end

      # Step 3 — source mode
      source_mode = source_envelope["source_mode"]
      if SOURCE_HELD_MODES.include?(source_mode)
        source_diags << source_diag(SOURCE_DIAG_HELD_SOURCE_MODE,
          "source_mode #{source_mode.inspect} is known but held; " \
          "only 'proof_fixture' and 'caller_supplied' are accepted in this helper")
      elsif !SOURCE_ACCEPTED_MODES.include?(source_mode)
        source_diags << source_diag(SOURCE_DIAG_UNSUPPORTED_SOURCE_MODE,
          "source_mode #{source_mode.inspect} is not supported; " \
          "accepted: proof_fixture, caller_supplied")
      end

      # Step 4 — authority object
      authority = source_envelope["authority"]
      if authority.is_a?(Hash)
        # authority_ref must be present
        if authority["authority_ref"].to_s.strip.empty?
          source_diags << source_diag(SOURCE_DIAG_MISSING_AUTHORITY_REF,
            "authority.authority_ref is required and must be non-empty")
        end

        # authority_kind must be within proof/design scope
        authority_kind = authority["authority_kind"]
        unless SOURCE_ACCEPTED_AUTHORITY_KINDS.include?(authority_kind)
          source_diags << source_diag(SOURCE_DIAG_INVALID_AUTHORITY_KIND,
            "authority.authority_kind #{authority_kind.inspect} is outside proof/design scope; " \
            "accepted: proof_only, design_accepted")
        end

        # canon_status must not be canon
        canon_status = authority["canon_status"]
        if canon_status == "canon"
          source_diags << source_diag(SOURCE_DIAG_CANON_STATUS_FORBIDDEN,
            "canon-status source envelopes are forbidden in this helper; " \
            "authority.canon_status must not be 'canon'")
        elsif !SOURCE_ACCEPTED_CANON_STATUSES.include?(canon_status)
          source_diags << source_diag(SOURCE_DIAG_CANON_STATUS_FORBIDDEN,
            "authority.canon_status #{canon_status.inspect} is not an accepted non-canon status; " \
            "accepted: non_canon, accepted_design")
        end
      else
        source_diags << source_diag(SOURCE_DIAG_MISSING_AUTHORITY,
          "source envelope authority object is missing or not a Hash")
      end

      # Step 5 — nested registry must be present
      registry_present = source_envelope["registry"].is_a?(Hash)
      unless registry_present
        source_diags << source_diag(SOURCE_DIAG_MISSING_REGISTRY,
          "source envelope must contain a 'registry' Hash; nested registry is missing or invalid")
      end

      # Step 6 — closed-surface assertions must all be false
      envelope_assertions = source_envelope.fetch("closed_surface_assertions", nil)
      if envelope_assertions.is_a?(Hash) && !envelope_assertions.values.all?(false)
        open_keys = envelope_assertions.select { |_k, v| v }.keys
        source_diags << source_diag(SOURCE_DIAG_SURFACE_OPEN,
          "source envelope closed_surface_assertions must all be false; " \
          "open assertions: #{open_keys.inspect}")
      end

      # If source envelope has any diagnostics, do NOT call nested registry validator.
      if source_diags.any?
        return build_source_result(false, source_mode, registry_present, source_diags, nil)
      end

      # Source envelope passed — call existing nested registry validator.
      registry_result = validate(source_envelope["registry"], installed_boundaries: installed_boundaries)
      source_valid = registry_result.fetch("valid")

      build_source_result(source_valid, source_mode, true, [], registry_result)
    end

    private

    def check_top_level_shape(registry)
      diags = []

      unless registry.is_a?(Hash)
        diags << diag(DIAG_WRONG_KIND, "registry must be a Hash, got #{registry.class}")
        return diags
      end

      if registry["kind"] != "oof_fragment_registry"
        diags << diag(DIAG_WRONG_KIND,
          "registry.kind must be 'oof_fragment_registry', got #{registry["kind"].inspect}")
      end

      %w[oof_descriptors fragment_rows support_markers excluded_namespaces].each do |section|
        unless registry.key?(section)
          diags << diag(DIAG_MISSING_SECTION, "registry missing required section: #{section}")
        end
      end

      if registry.key?("support_markers")
        sm = registry["support_markers"]
        unless sm.is_a?(Hash) && sm.key?("invariant_support_markers") &&
               sm["invariant_support_markers"].is_a?(Array)
          diags << diag(DIAG_MISSING_SECTION,
            "registry.support_markers.invariant_support_markers must be an Array")
        end
      end

      diags
    end

    def check_oof_descriptors(descriptors, excluded_prefixes, all_canonical_codes)
      diags     = []
      seen_codes = Set.new
      seen_aliases = {}  # alias → canonical code that owns it

      descriptors.each do |desc|
        code = desc["code"]
        next unless code

        # Support marker codes must not appear in oof_descriptors
        if code.match?(SUPPORT_MARKER_PATTERN)
          diags << diag(DIAG_SUPPORT_MARKER_IN_DESCRIPTORS,
            "#{code.inspect} matches support marker pattern (PINV-*/TINV-*) and must not " \
            "appear in oof_descriptors; place under support_markers.invariant_support_markers")
          next
        end

        # Duplicate canonical code
        if seen_codes.include?(code)
          diags << diag(DIAG_DUPLICATE_CODE, "duplicate OOF descriptor code: #{code.inspect}")
        else
          seen_codes.add(code)
        end

        # Excluded namespace prefix
        excluded_prefixes.each do |prefix|
          if code.start_with?(prefix)
            diags << diag(DIAG_EXCLUDED_NAMESPACE_COLLISION,
              "OOF descriptor code #{code.inspect} is in excluded namespace #{prefix.inspect}")
          end
        end

        # Alias checks.
        # Rule: the same alias must not be claimed by two different descriptors.
        # Note: an alias may match a canonical descriptor code when that descriptor
        # is a compatibility alias (deprecated_by pointing back to this descriptor).
        # This is the standard backward-compatibility pattern and is allowed.
        Array(desc["aliases"]).each do |ali|
          if seen_aliases.key?(ali)
            diags << diag(DIAG_ALIAS_COLLISION,
              "alias #{ali.inspect} claimed by both #{code.inspect} and #{seen_aliases[ali].inspect}")
          else
            seen_aliases[ali] = code
          end
        end

        # Deprecated descriptors must name replacement
        if desc["deprecated"]
          rc = desc["replacement_code"]
          db = desc["deprecated_by"]
          if rc.nil? && db.nil?
            diags << diag(DIAG_ALIAS_MISSING_REPLACEMENT,
              "deprecated descriptor #{code.inspect} must set replacement_code or deprecated_by")
          elsif rc && !all_canonical_codes.include?(rc)
            diags << diag(DIAG_ALIAS_MISSING_REPLACEMENT,
              "descriptor #{code.inspect} replacement_code #{rc.inspect} not found among canonical codes")
          end
        end
      end

      diags
    end

    def check_fragment_rows(rows)
      diags = []

      rows.each do |row|
        name = row["name"]
        next unless name

        case name
        when OOF_ROW_NAME
          if row["loadable"] == true
            diags << diag(DIAG_OOF_PROJECTION_LOADABLE,
              "fragment row 'oof' must not be loadable " \
              "(status-primary/status-only projection; blocked, non-loadable, capability-free)")
          end
          if row["capability"] == true
            diags << diag(DIAG_OOF_PROJECTION_CAPABILITY,
              "fragment row 'oof' must not have capability: true (capability-free by design)")
          end

        when *GUARDED_NON_FRAGMENT_NAMES
          ck = row["classification_kind"]
          unless ck == "not_fragment_class"
            diags << diag(DIAG_GUARDED_NON_FRAGMENT,
              "fragment row #{name.inspect} is a guarded non-fragment; " \
              "classification_kind must be 'not_fragment_class', got #{ck.inspect}")
          end
          if row["loadable"] == true
            diags << diag(DIAG_GUARDED_NON_FRAGMENT,
              "guarded non-fragment row #{name.inspect} must not be loadable")
          end
        end
      end

      diags
    end

    def check_support_markers(markers, oof_code_set)
      diags = []

      markers.each do |marker|
        code = marker["code"]
        next unless code

        # Code must not collide with any OOF descriptor code or alias
        if oof_code_set.include?(code)
          diags << diag(DIAG_SUPPORT_MARKER_CODE_COLLISION,
            "support marker code #{code.inspect} collides with OOF descriptor code or alias; " \
            "support marker codes must be distinct from public OOF codes")
        end

        # Must be non-public
        stability = marker["public_code_stability"]
        unless SUPPORT_MARKER_STABILITY_VALUES.include?(stability)
          diags << diag(DIAG_SUPPORT_MARKER_PUBLIC,
            "support marker #{code.inspect} has public_code_stability #{stability.inspect}; " \
            "must be non_public_support_marker or proof_only (support markers are non-public)")
        end

        # Must not be emitted (no blocking_oof status_class, no emitted lifecycle_state)
        if marker["lifecycle_state"] == "emitted" || marker["status_class"] == "blocking_oof"
          diags << diag(DIAG_SUPPORT_MARKER_EMITTED,
            "support marker #{code.inspect} must not be emitted as a public diagnostic; " \
            "lifecycle_state/status_class must not indicate emission")
        end
      end

      diags
    end

    def check_excluded_namespaces(namespaces)
      diags = []
      present = namespaces.map { |n| n["prefix"] }.compact.to_set

      REQUIRED_EXCLUDED_PREFIXES.each do |required|
        unless present.include?(required)
          diags << diag(DIAG_MISSING_SECTION,
            "excluded_namespaces must include required prefix #{required.inspect}; " \
            "(compiler_profile_contract.* and compiler_profile_contract_refusal.* " \
            "are always excluded from OOF namespace)")
        end
      end

      diags
    end

    def source_diag(code, message)
      { "code" => code, "message" => message }
    end

    def build_source_result(valid, source_mode, registry_present, source_diags, registry_validation)
      {
        "kind"             => "oof_fragment_registry_source_validation",
        "format_version"   => "0.1.0",
        "valid"            => valid,
        "source_mode"      => source_mode,
        "registry_present" => registry_present,
        "source_diagnostics" => source_diags,
        "registry_validation" => registry_validation,
        "closed_surface_assertions" => {
          "static_data_file"              => false,
          "lib_igniter_lang_rb_require"   => false,
          "compiler_pass_integration"     => false,
          "public_api_cli"                => false,
          "top_level_report_diagnostics"  => false,
          "compiler_result_field"         => false,
          "loader_report"                 => false,
          "compatibility_report"          => false,
          "runtime_behavior"              => false,
          "igapp_mutation"                => false,
          "specs_canon_proposals"         => false
        }
      }
    end

    def diag(code, message)
      { "code" => code, "message" => message }
    end

    def build_result(valid, diags, inactive_rows)
      {
        "kind"                     => "oof_fragment_registry_validation",
        "format_version"           => FORMAT_VERSION,
        "valid"                    => valid,
        "registry_service_present" => true,
        "checked_sections"         => %w[
          oof_descriptors
          fragment_rows
          support_markers.invariant_support_markers
          excluded_namespaces
        ],
        "diagnostics"              => diags,
        "inactive_rows"            => inactive_rows,
        "closed_surface_assertions" => {
          "compiler_integration"          => false,
          "public_api_cli"                => false,
          "top_level_report_diagnostics"  => false,
          "compiler_result_field"         => false,
          "loader_report"                 => false,
          "compatibility_report"          => false,
          "runtime_behavior"              => false,
          "igapp_mutation"                => false
        }
      }
    end
  end
end
