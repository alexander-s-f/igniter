#!/usr/bin/env ruby
# frozen_string_literal: true

# Concept Miner — finds recurring concept patterns in the track corpus
# that don't yet have a single name in the vocabulary.
#
# Hypothesis: just as "митоз" and "мейоз" are compressed names for complex
# processes, agent interaction patterns that occur frequently enough
# deserve their own concept tokens.
#
# Method:
#   1. Read all .md files in docs/dev/
#   2. Extract concept sequences per document (using vocabulary)
#   3. Mine frequent N-grams of concepts
#   4. Find gaps: frequent N-grams that have no single name in the vocabulary
#   5. These gaps are candidates for new concept words

$LOAD_PATH.unshift File.join(__dir__, "lib")
require "vocabulary"

DOCS_DIR  = File.expand_path("../../docs/dev", __dir__)
MIN_FREQ  = 2     # min occurrences to report
MAX_NGRAM = 4     # max pattern length to consider

# =============================================================================
# Step 1: Read corpus
# =============================================================================

def read_corpus(dir)
  Dir[File.join(dir, "*.md")].map do |path|
    { path: path, name: File.basename(path, ".md"), text: File.read(path) }
  end
end

# =============================================================================
# Step 2: Extract concept sequences per document
# =============================================================================

def extract_concept_sequence(text)
  # Split into paragraphs/sections, extract concepts from each
  # This gives us an ordered sequence of concept atoms per document

  concepts = []

  # Roles (mark who's speaking at each section)
  text.scan(/\[([^\]]+)\s*\/\s*Codex\]/i) do |m|
    role = LineUp::Vocabulary.lookup_role(m[0])
    concepts << role if role
  end

  # Frames (event markers)
  frames = LineUp::Vocabulary.lookup_frames(text)
  concepts.concat(frames)

  # Concepts (domain concepts mentioned)
  domain = LineUp::Vocabulary.lookup_concepts(text)
  concepts.concat(domain)

  # Constraints
  constraints = LineUp::Vocabulary.recognize_constraints(text.gsub(/\s+/, " "))
  concepts.concat(constraints[:must])
  concepts.concat(constraints[:forbid].map { |c| :"no_#{c.to_s.sub(/^no_/, "")}" })

  concepts.uniq # per-document presence, not frequency
end

# =============================================================================
# Step 3: Mine frequent N-grams
# =============================================================================

def ngrams(arr, n)
  arr.each_cons(n).map { |g| g.sort } # sort for order-independence
end

def count_ngrams(corpus_sequences, n)
  counts = Hash.new(0)
  doc_presence = Hash.new { |h, k| h[k] = [] }

  corpus_sequences.each_with_index do |seq, idx|
    ngrams(seq, n).each do |gram|
      key = gram.freeze
      counts[key] += 1
      doc_presence[key] << idx
    end
  end

  counts.map { |gram, count|
    { gram: gram, count: count, doc_count: doc_presence[gram].uniq.length }
  }.select { |r| r[:doc_count] >= MIN_FREQ }
   .sort_by { |r| -r[:doc_count] }
end

# =============================================================================
# Step 4: Find vocabulary gaps
# =============================================================================

ALL_KNOWN_ATOMS = (
  LineUp::Vocabulary::ROLES.values +
  LineUp::Vocabulary::CONCEPTS.values +
  LineUp::Vocabulary::FRAMES.values +
  LineUp::Vocabulary::CONSTRAINT_PATTERNS.map { |_, atom, _| atom }
).uniq.freeze

def vocabulary_gap?(gram)
  gram.length > 1 &&
    !ALL_KNOWN_ATOMS.include?(:"#{gram.sort.join("_")}") &&
    !PATTERN_NAMES.key?(gram.sort)
end

# =============================================================================
# Step 5: Propose names
# =============================================================================

PATTERN_NAMES = {
  # Patterns we can already name from the corpus
  [:supervisor_acceptance, :research_activity, :documentation_only].sort =>
    { name: :doctrine_graduation, description: "research accepted into docs-only doctrine" },

  [:task_completion, :supervisor_acceptance, :ownership_transfer].sort =>
    { name: :track_closure, description: "agent lands task, supervisor accepts, work archived" },

  [:supervisor_acceptance, :research_activity, :documentation_only, :read_only_boundary].sort =>
    { name: :docs_only_acceptance, description: "supervisor accepts research as docs-only, read-only boundary" },

  [:task_completion, :verification_success, :ownership_transfer].sort =>
    { name: :verified_completion, description: "task landed with passing verification, ownership transferred" },

  [:research_activity, :documentation_only, :read_only_boundary].sort =>
    { name: :horizon_research, description: "speculative research, docs only, no runtime" },

  [:supervisor_acceptance, :blocker, :research_activity].sort =>
    { name: :deferred_research, description: "supervisor accepts but defers — research stays open" },

  [:task_completion, :research_activity, :doctrine_definition].sort =>
    { name: :doctrine_authored, description: "researcher produces doctrine document" },

  [:researcher, :supervisor, :task_completion].sort =>
    { name: :handoff_pair, description: "researcher → supervisor handoff, task complete" },

  [:researcher, :supervisor, :docs_only].sort =>
    { name: :research_handoff, description: "researcher → supervisor, docs-only work" },

  [:supervisor, :researcher, :docs_only, :read_only_boundary].sort =>
    { name: :bounded_assignment, description: "supervisor assigns with docs-only, read-only boundary" },

  [:pressure_testing, :task_completion, :verification_success].sort =>
    { name: :poc_cycle, description: "pressure test runs, verifies, completes" },

  [:agent_application, :agent_web, :task_completion].sort =>
    { name: :parallel_window_closure, description: "app+web agents both land tasks (parallel window)" },

  # === Corpus-discovered patterns (concept_miner 2026-04) ===

  # Rank 1 pair: 49x — supervisor accepts a completed task (the canonical gate)
  [:supervisor_acceptance, :task_completion].sort =>
    { name: :gate_passed, description: "supervisor accepts completed agent work — track gate cleared" },

  # Rank 2/3 pairs: 46x — the two parallel implementation agents
  [:agent_application, :agent_web].sort =>
    { name: :parallel_implementors, description: "both implementation agents active in parallel window" },

  # Rank 2/3 pairs: 46x — both runtimes in scope simultaneously
  [:igniter_application, :igniter_web].sort =>
    { name: :dual_runtime_scope, description: "both igniter runtimes (app + web) are in scope" },

  # Rank 4 pair: 44x — supervisor present with both implementation agents
  [:agent_application, :agent_web, :supervisor].sort =>
    { name: :standard_window, description: "canonical 3-role operating window: app+web agents + supervisor" },

  # Rank 5 pair: 40x — web agent task under supervisor acceptance
  [:agent_web, :supervisor_acceptance, :task_completion].sort =>
    { name: :web_gate_passed, description: "web agent lands task, supervisor accepts" },

  # Rank 6 pair: 33x — ownership transferred with read-only boundary
  [:ownership_transfer, :read_only_boundary].sort =>
    { name: :bounded_handoff, description: "ownership transferred but work is read-only (research/docs)" },

  # Rank 7 pair: 26x — the core poc isolation constraints (subset of interactive_poc_guardrails)
  [:no_cluster_placement, :no_sse].sort =>
    { name: :poc_isolation_core, description: "POC isolation: no cluster, no SSE (stateless, local-only)" },

  # Rank 13: 13x — supervisor accepts under read-only, transfer complete
  [:ownership_transfer, :read_only_boundary, :supervisor_acceptance].sort =>
    { name: :research_closure, description: "supervisor accepts read-only research, ownership transferred" },

  # Rank 13: 13x — docs handoff pattern
  [:documentation_only, :ownership_transfer, :read_only_boundary].sort =>
    { name: :docs_handoff, description: "research handed off as docs-only, read-only boundary" },

  # Rank 15: 15x — both runtimes in read-only scope (research window)
  [:igniter_application, :igniter_web, :read_only].sort =>
    { name: :dual_runtime_readonly, description: "both runtimes in scope but read-only (research/analysis track)" },
}.freeze

def name_pattern(gram)
  key = gram.sort
  PATTERN_NAMES[key]
end

# =============================================================================
# Rendering
# =============================================================================

DIVIDER = ("─" * 72).freeze

def print_section(title)
  puts "\n╔══ #{title} #{"═" * [0, 68 - title.length].max}╗"
end

def run
  corpus = read_corpus(DOCS_DIR)
  puts "Corpus: #{corpus.length} documents, #{corpus.sum { |d| d[:text].length }} chars"

  sequences = corpus.map { |doc| extract_concept_sequence(doc[:text]) }
  nonempty  = sequences.count { |s| s.length >= 2 }
  puts "Documents with ≥2 concepts: #{nonempty}/#{corpus.length}"

  # All atoms across corpus
  all_atoms = sequences.flatten.tally.sort_by { |_, c| -c }

  print_section("Most Frequent Single Concepts (Corpus Vocabulary)")
  all_atoms.first(15).each do |atom, count|
    bar = "█" * [count, 40].min
    puts "  #{atom.to_s.ljust(35)} #{count.to_s.rjust(3)}x  #{bar}"
  end

  print_section("Frequent 2-Concept Patterns")
  pairs = count_ngrams(sequences, 2)
  pairs.first(12).each do |r|
    named = name_pattern(r[:gram])
    label = named ? " → :#{named[:name]}" : " ← GAP"
    puts "  [#{r[:gram].join(", ")}]"
    puts "    #{r[:doc_count]}x in #{r[:doc_count]} docs#{label}"
    puts "    \"#{named[:description]}\"" if named
    puts
  end

  print_section("Frequent 3-Concept Patterns (Unnamed Gaps)")
  triples = count_ngrams(sequences, 3)
  gaps = triples.select { |r| vocabulary_gap?(r[:gram]) }
  named = triples.reject { |r| vocabulary_gap?(r[:gram]) || !name_pattern(r[:gram]) }

  puts "\nNamed patterns:"
  named.first(6).each do |r|
    n = name_pattern(r[:gram])
    puts "  :#{n[:name].to_s.ljust(30)} #{r[:doc_count]}x — #{n[:description]}"
  end

  puts "\nVocabulary gaps (unnamed high-frequency triples):"
  gaps.first(10).each do |r|
    puts "  [#{r[:gram].join(", ")}]  — #{r[:doc_count]}x"
  end

  print_section("Vocabulary Gap Analysis")
  total_ngrams    = (2..MAX_NGRAM).sum { |n| count_ngrams(sequences, n).length }
  gap_ngrams      = (2..MAX_NGRAM).sum { |n| count_ngrams(sequences, n).count { |r| vocabulary_gap?(r[:gram]) } }
  named_count     = PATTERN_NAMES.length
  coverage        = total_ngrams > 0 ? ((total_ngrams - gap_ngrams).to_f / total_ngrams * 100).round(1) : 0

  puts "  Total frequent N-grams found:  #{total_ngrams}"
  puts "  Vocabulary gaps (unnamed):     #{gap_ngrams}"
  puts "  Named patterns in registry:    #{named_count}"
  puts "  Current vocabulary coverage:   #{coverage}%"
  puts "  Compression potential:         each named gap saves ~20–60 tokens/occurrence"

  print_section("Proposed New Concept Names (Vocabulary Extensions)")

  candidates = triples.select { |r| vocabulary_gap?(r[:gram]) }.first(8)
  puts "\nTop candidates for naming:"
  candidates.each_with_index do |r, i|
    puts "  #{i + 1}. [#{r[:gram].join(", ")}] — #{r[:doc_count]}x"
    puts "     Suggested name: :#{suggest_name(r[:gram])}"
    puts
  end

  print_section("The Deeper Question")
  puts <<~TEXT

    The "митоз повторяет мейоз" insight asks: do these patterns have
    a LATENT STRUCTURE that is lower-dimensional than their parts?

    Three experimental directions:

    1. STATISTICAL: mine this corpus for patterns (done above).
       Finding: #{gaps.count { |r| r[:doc_count] >= MIN_FREQ }} unnamed patterns occur ≥#{MIN_FREQ}x.
       These are vocabulary gaps — patterns that already exist but lack a name.

    2. GEOMETRIC: embed all handoff messages, cluster in vector space.
       Clusters that don't align with existing vocabulary atoms are "latent concepts"
       — things the LLM already knows but that have no word yet.
       Requires: embedding API (Anthropic / local model).

    3. GENERATIVE: ask an LLM to name the gaps, then measure whether
       the new names compress future messages. This is accelerated Zipf:
       instead of waiting for vocabulary to emerge naturally over years,
       we mine it deliberately.

    The hypothesis is that LLM training has already compressed these patterns
    internally — the model "knows" :doctrine_graduation as a coherent concept
    even if the word doesn't exist. Naming it makes the compression explicit.

  TEXT
end

def suggest_name(gram)
  # Heuristic name suggestion from atom combination
  parts = gram.sort.map(&:to_s)

  # Remove "no_" prefix atoms for naming
  positive = parts.reject { |p| p.start_with?("no_") }

  if positive.length >= 2
    # Take the two most "noun-like" atoms and combine
    a, b = positive.first(2).map { |p| p.gsub(/_(activity|boundary|ance|ion)$/, "") }
    "#{a}_#{b}_pattern"
  else
    "#{parts.first}_complex"
  end
end

run
