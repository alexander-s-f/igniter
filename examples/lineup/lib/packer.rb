# frozen_string_literal: true

require_relative "vocabulary"
require_relative "line_up"

module LineUp
  # Packs text into a LineUp Record.
  #
  # Handles two input formats:
  #   :compact  — the micro-format handoff (track:/status:/delta:/verify:/ready:/block:)
  #   :prose    — the traditional labeled handoff (Track: / Status: / Changed: / Needs:)
  #   :auto     — detect format automatically (default)
  #
  # The packer is deliberately rule-based (no LLM). It uses:
  #   1. Structural parsing (labeled fields)
  #   2. Vocabulary lookup (pattern → atom)
  #   3. Constraint recognition (prohibition patterns → named sets)
  #   4. Confidence scoring (how many required fields were found)

  class Packer
    COMPACT_MARKERS = %w[track: status: delta: verify: ready: block:].freeze
    PROSE_MARKERS   = ["Track:", "Status:", "Changed:", "Accepted:", "Verification:", "Needs:"].freeze

    def self.call(text, format: :auto)
      new(text, format: format).pack
    end

    def initialize(text, format: :auto)
      @text   = text.strip
      @format = format == :auto ? detect_format(@text) : format
    end

    def pack
      fields = @format == :compact ? parse_compact(@text) : parse_prose(@text)
      build_record(fields)
    end

    private

    # -------------------------------------------------------------------------
    # Format detection
    # -------------------------------------------------------------------------

    def detect_format(text)
      compact_score = COMPACT_MARKERS.count { |m| text.include?(m) }
      prose_score   = PROSE_MARKERS.count   { |m| text.include?(m) }
      compact_score >= prose_score ? :compact : :prose
    end

    # -------------------------------------------------------------------------
    # Compact format parser
    # -------------------------------------------------------------------------

    def parse_compact(text)
      fields = {}

      # Sender role from first line: [Agent Role / Codex]
      fields[:sender] = Vocabulary.lookup_role(text.lines.first.to_s)

      fields[:subject]   = extract_field(text, /^track:\s*(.+)/i)
      fields[:status]    = extract_field(text, /^status:\s*(.+)/i)
      fields[:delta]     = extract_multiline(text, "delta:")
      fields[:verify]    = extract_field(text, /^verify:\s*(.+)/i)
      fields[:ready]     = extract_field(text, /^ready:\s*(.+)/i)
      fields[:block]     = extract_field(text, /^block:\s*(.+)/i)

      fields
    end

    # -------------------------------------------------------------------------
    # Prose format parser
    # -------------------------------------------------------------------------

    def parse_prose(text)
      fields = {}

      # Sender role from first line: [Role / Codex]
      fields[:sender] = Vocabulary.lookup_role(text.lines.first.to_s)

      fields[:subject]   = extract_field(text, /^Track:\s*(.+)/i)
      fields[:status]    = extract_field(text, /^Status:\s*(.+)/i)
      fields[:changed]   = extract_section(text, "Changed:")
      fields[:accepted]  = extract_section(text, "Accepted:")
      fields[:verify]    = extract_section(text, "Verification:")
      fields[:needs]     = extract_section(text, "Needs:")

      fields
    end

    # -------------------------------------------------------------------------
    # Semantic field extraction (shared)
    # -------------------------------------------------------------------------

    def extract_field(text, pattern)
      m = text.match(pattern)
      m ? m[1].strip : nil
    end

    def extract_multiline(text, marker)
      lines = text.lines
      start = lines.index { |l| l.strip.downcase.start_with?(marker.downcase) }
      return [] unless start

      result = []
      lines[(start + 1)..].each do |line|
        break if line.match?(/^\w+:/) && !line.start_with?(" ", "\t", "+", "-", "~")
        result << line.strip unless line.strip.empty?
      end
      result
    end

    def extract_section(text, marker)
      lines = text.lines
      start = lines.index { |l| l.strip.start_with?(marker) }
      return [] unless start

      result = []
      lines[(start + 1)..].each do |line|
        break if PROSE_MARKERS.any? { |m| line.strip.start_with?(m) } && !line.strip.start_with?("-")
        content = line.strip.sub(/^-\s*/, "")
        result << content unless content.empty?
      end
      result.first(5) # cap to avoid noise
    end

    # -------------------------------------------------------------------------
    # LineUp assembly
    # -------------------------------------------------------------------------

    def build_record(fields)
      full_text = @text

      # Roles
      sender    = fields[:sender]
      recipient = infer_recipient(full_text, fields[:ready] || fields[:needs])
      roles     = { sender: sender, recipient: recipient }.compact

      # Subject — clean up track path
      subject = clean_subject(fields[:subject] || Vocabulary.detect_subject(full_text))

      # Task frame (what kind of event is this)
      status_text = [fields[:status]].flatten.join(" ")
      task   = infer_task(status_text, full_text)
      frames = Vocabulary.lookup_frames(status_text + " " + full_text[0..500])

      # Concepts from the whole text
      concepts = Vocabulary.lookup_concepts(full_text)

      # Evidence — from delta / changed / accepted / verify
      evidence = build_evidence(fields)

      # Constraints — split must vs forbid
      constraint_text = [
        fields[:accepted], fields[:needs], fields[:changed]
      ].flatten.compact.join(" ")
      from_text  = Vocabulary.recognize_constraints(constraint_text + " " + full_text)
      from_scope = infer_scope_constraints(full_text)
      must   = (from_text[:must]   + from_scope[:must]).uniq
      forbid = (from_text[:forbid] + from_scope[:forbid]).uniq

      # Next step
      next_step = infer_next(fields[:ready] || fields[:needs], sender)

      # Residue — anything critical that didn't compress
      residue = build_residue(fields, concepts)

      # Confidence: ratio of required fields successfully populated
      populated = [task, subject, roles, evidence, next_step].count { |v|
        v && !(v.respond_to?(:empty?) ? v.empty? : false)
      }
      confidence = (populated / 5.0).round(2)

      # Fold constraint lists into named sets where vocabulary allows
      must_folded   = Vocabulary.fold_constraints(must.uniq)
      forbid_folded = Vocabulary.fold_constraints(forbid.uniq)

      compact_must   = must_folded[:sets]   + must_folded[:remainder]
      compact_forbid = forbid_folded[:sets] + forbid_folded[:remainder]

      Record.new(
        task:       task,
        subject:    subject,
        roles:      roles,
        concepts:   concepts,
        frames:     frames,
        must:       compact_must,
        should:     [],
        forbid:     compact_forbid,
        evidence:   evidence,
        next_step:  next_step,
        confidence: confidence,
        residue:    residue.empty? ? nil : residue
      )
    end

    # -------------------------------------------------------------------------
    # Inference helpers
    # -------------------------------------------------------------------------

    def infer_task(status_text, full_text)
      return :completion   if status_text.match?(/landed|complete/i)
      return :needs_review if status_text.match?(/needs.review/i)
      return :blocked      if status_text.match?(/blocked/i)
      return :assignment   if full_text.match?(/Task \d|Owner:|assigned to/i)
      return :acceptance   if full_text.match?(/\[Architect Supervisor\].*Accepted/im)
      return :research     if full_text.match?(/research|proposal|hypothesis/i)
      return :handoff      if full_text.match?(/handoff|transfer/i)
      :update
    end

    def infer_recipient(full_text, ready_field)
      return nil unless ready_field

      ready_text = [ready_field].flatten.join(" ")
      role = Vocabulary.lookup_role(ready_text)
      return role if role

      # Try to find a role mentioned after "ready:" or in "Needs:"
      Vocabulary.all_roles(ready_text).first
    end

    def infer_next(ready_or_needs, sender)
      return [] unless ready_or_needs

      text = [ready_or_needs].flatten.join(" ")
      roles = Vocabulary.all_roles(text)
      roles.reject { |r| r == sender }.map { |r| :"#{r}_can_proceed" }
    end

    def infer_scope_constraints(full_text)
      # Look in explicit "out of scope" / "do not" sections — these are always :forbid
      sections = full_text.scan(/(?:out of scope|must not|do not add|forbidden)[:\s]*([^\n]+(?:\n[-•]\s*[^\n]+)*)/im)
      scope_text = sections.flatten.join(" ")
      return { must: [], forbid: [] } if scope_text.empty?

      result = Vocabulary.recognize_constraints(scope_text)
      # Everything found in an "out of scope" section is a prohibition
      { must: [], forbid: (result[:must] + result[:forbid]).uniq }
    end

    def build_evidence(fields)
      ev = []

      # From delta (compact format)
      if fields[:delta]
        [fields[:delta]].flatten.each do |line|
          ev << "file:#{line.sub(/^[+~-]\s*/, "").split(":").first.strip}" if line.match?(/\S/)
        end
      end

      # From changed (prose format)
      if fields[:changed]
        [fields[:changed]].flatten.first(3).each do |item|
          next if item.empty?

          ev << "change:#{item[0..60]}"
        end
      end

      # From verify
      verify_text = [fields[:verify], fields[:accepted]].flatten.compact.join(" ")
      if verify_text.match?(/passed|ok|0 offense|0 failure/i)
        ev << "verify:passed"
      elsif verify_text.match?(/fail|error|offense/i)
        ev << "verify:failed"
      end

      ev.first(5)
    end

    def build_residue(fields, concepts)
      residue = {}

      # If no concepts were recognized, preserve the subject as residue
      residue[:unrecognized_subject] = fields[:subject] if concepts.empty? && fields[:subject]

      # Preserve block reason if blocked
      block = fields[:block]
      residue[:blocker] = block if block && !block.match?(/^none$/i)

      residue
    end

    def clean_subject(raw)
      return nil unless raw

      raw.to_s
         .sub(%r{^docs/dev/}, "")
         .sub(/-track\.md$/, "")
         .sub(/\.md$/, "")
         .gsub("-", "_")
         .strip
    end
  end
end
