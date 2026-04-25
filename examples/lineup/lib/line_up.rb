# frozen_string_literal: true

module LineUp
  # Core value object — the compact structured representation of any context unit.
  #
  # A LineUp replaces verbose prose with a precise, typed, inspectable structure.
  # Every field has a defined role; nothing is narrative filler.
  #
  # Fields follow the 8-field semantic contract from the research:
  #   task, roles, concepts, frames, must, forbid, evidence, next
  # Plus: confidence (compression quality), residue (uncompressible critical detail).

  Record = Struct.new(
    :task,        # Symbol — what kind of event this is (:completion, :assignment, :research, ...)
    :subject,     # String — the named thing being acted on (track name, doc, concept)
    :roles,       # Hash { sender: Symbol, recipient: Symbol }
    :concepts,    # Array<Symbol> — key domain concepts mentioned
    :frames,      # Array<Symbol> — event frame labels (:ownership_transfer, :docs_only, ...)
    :must,        # Array<Symbol|String> — required constraints
    :should,      # Array<Symbol|String> — preferred constraints
    :forbid,      # Array<Symbol|String> — prohibited actions
    :evidence,    # Array<String> — what proves the state (files, verifications)
    :next_step,   # Array<Symbol|String> — who or what acts next
    :confidence,  # Float 0.0–1.0 — compression quality score
    :residue,     # Hash — critical details that couldn't be approximated
    keyword_init: true
  ) do
    # Required fields for semantic preservation scoring
    REQUIRED = %i[task subject roles must forbid evidence next_step].freeze

    def present?(field)
      v = send(field)
      v && !(v.respond_to?(:empty?) ? v.empty? : false)
    end

    # --- Rendering ---

    def to_lineup
      lines = ["lineup("]
      lines << "  task:       #{task.inspect},"
      lines << "  subject:    #{subject.inspect},"            if present?(:subject)
      lines << "  roles:      #{format_hash(roles)},"        if present?(:roles)
      lines << "  concepts:   #{format_list(concepts)},"     if present?(:concepts)
      lines << "  frames:     #{format_list(frames)},"       if present?(:frames)
      lines << "  must:       #{format_list(must)},"         if present?(:must)
      lines << "  should:     #{format_list(should)},"       if present?(:should)
      lines << "  forbid:     #{format_list(forbid)},"       if present?(:forbid)
      lines << "  evidence:   #{format_list(evidence)},"     if present?(:evidence)
      lines << "  next:       #{format_list(next_step)},"    if present?(:next_step)
      lines << "  residue:    #{format_hash(residue)},"      if present?(:residue)
      lines << "  confidence: #{confidence&.round(2)}"
      lines << ")"
      lines.join("\n")
    end

    def to_prose
      parts = []
      parts << "[#{role_name(roles&.dig(:sender))} → #{role_name(roles&.dig(:recipient))}]"
      parts << "Task: #{task}"
      parts << "Subject: #{subject}"                if present?(:subject)
      parts << "Concepts: #{concepts.join(", ")}"   if present?(:concepts)
      parts << "Must: #{must.join("; ")}"           if present?(:must)
      parts << "Forbid: #{forbid.join("; ")}"       if present?(:forbid)
      parts << "Evidence: #{evidence.join("; ")}"   if present?(:evidence)
      parts << "Next: #{next_step.join("; ")}"      if present?(:next_step)
      parts << "Confidence: #{(confidence * 100).round}%" if confidence
      parts.join("\n")
    end

    # --- Token accounting ---

    def token_count
      # Approximate: chars / 4 (standard rough estimate)
      (to_lineup.length / 4.0).ceil
    end

    private

    def format_list(arr)
      return "[]" if arr.nil? || arr.empty?

      items = arr.map { |v| v.is_a?(Symbol) ? v.inspect : v.to_s.inspect }
      items.length <= 3 ? "[#{items.join(", ")}]" : "[\n    #{items.join(",\n    ")}\n  ]"
    end

    def format_hash(h)
      return "{}" if h.nil? || h.empty?

      pairs = h.map { |k, v| "#{k}: #{v.inspect}" }
      "{ #{pairs.join(", ")} }"
    end

    def role_name(sym)
      return "?" unless sym

      sym.to_s.split("_").map(&:capitalize).join(" ")
    end
  end
end
