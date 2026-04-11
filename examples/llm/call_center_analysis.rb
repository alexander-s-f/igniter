# frozen_string_literal: true

# Example: AI call-center pipeline — transcription + diarization + extraction
#
# Production context:
#   Rails SaaS CRM for appliance-repair call centers.
#   ~14 000 calls / ~27 000 minutes per month.
#   Recordings land in CallRail; future: own Asterisk PBX.
#
# ── Cost breakdown (27 000 min/month) ────────────────────────────────────────
#
#   Provider            | $/min  | Diarize | Monthly ($)
#   --------------------|--------|---------|------------
#   whisper-1 (OpenAI)  | 0.006  | No      |  162
#   gpt-4o-mini-trans.  | 0.003  | No      |   81   ← cheapest, no speakers
#   AssemblyAI Univ-2   | 0.0025 | +addon  |   68
#   + speaker_labels    | 0.0003 |  Yes    |  +9 ≈ 77  ← cheapest WITH speakers
#   Deepgram Nova-3     | 0.0077 | Yes     |  208
#
#   Analysis (gpt-4o-mini, ~1 000 tok/call × 14 000 calls):
#     input  14 M tok × $0.00015/1 K  ≈ $2.10
#     output  2.8 M tok × $0.00060/1 K ≈ $1.68
#                                     ≈ $4/month
#
#   Recommended total: AssemblyAI ($77) + gpt-4o-mini analysis ($4) ≈ $81/month
#
# ── Prerequisites ─────────────────────────────────────────────────────────────
#   export ASSEMBLYAI_API_KEY="..."   # or OPENAI_API_KEY for Whisper path
#   export OPENAI_API_KEY="..."       # for analysis step
#   gem install igniter               # or: $LOAD_PATH trick below
#
# Run: ruby examples/llm/call_center_analysis.rb
#
# Pass DEMO=1 to run with mock data (no real API calls):
#   DEMO=1 ruby examples/llm/call_center_analysis.rb

$LOAD_PATH.unshift File.join(__dir__, "../../lib")
require "igniter"
require "igniter/integrations/llm"
require "json"

# ── Configuration ──────────────────────────────────────────────────────────────

Igniter::LLM.configure do |c|
  # AssemblyAI: cheapest option WITH diarization
  c.assemblyai.api_key = ENV.fetch("ASSEMBLYAI_API_KEY", "demo")
  c.assemblyai.poll_interval = 3   # seconds; the service usually takes 30-60 s
  c.assemblyai.poll_timeout  = 600 # 10 minutes max for long calls

  # OpenAI: used for structured extraction (gpt-4o-mini)
  c.openai.api_key = ENV.fetch("OPENAI_API_KEY", "demo")
end

# ── Step 1: Transcription ──────────────────────────────────────────────────────
#
# Uses AssemblyAI with speaker diarization.
# Swap `transcription_provider :openai` + `model "gpt-4o-mini-transcribe"`
# if you don't need speaker labels and want the absolute lowest cost.

class CallTranscriber < Igniter::LLM::Transcriber
  transcription_provider :assemblyai
  # model "universal-2"          # default; or "best" for higher accuracy
  diarize true                   # speaker_labels — identifies Agent vs Customer
  language "en"                  # skip for auto-detection (adds ~100 ms)
  poll_interval 3
  poll_timeout  600

  # Called by the Contract graph with audio_url: from the call record.
  def call(audio_url:)
    transcribe(audio_url)
  end
end

# ── Step 2: Structured Extraction ──────────────────────────────────────────────
#
# Sends the transcript text to gpt-4o-mini with a JSON schema.
# Returns a plain Hash — downstream nodes and the CRM updater consume it.

EXTRACTION_SCHEMA = {
  name: "call_extraction",
  strict: true,
  schema: {
    type: "object",
    additionalProperties: false,
    properties: {
      conversion: {
        type: "boolean",
        description: "true if caller placed or confirmed a service order"
      },
      call_type: {
        type: "string",
        enum: %w[order support eta recall spam wrong_number other]
      },
      zip_codes: { type: "array",  items: { type: "string" } },
      addresses: { type: "array",  items: { type: "string" } },
      phones: { type: "array", items: { type: "string" } },
      service_names: { type: "array", items: { type: "string" } },
      scheduled_datetime: {
        type: %w[string null],
        description: "ISO 8601 if mentioned, otherwise null"
      },
      confidence: { type: "number", minimum: 0, maximum: 1 },
      notes: { type: "string" }
    },
    required: %w[
      conversion call_type zip_codes addresses phones
      service_names scheduled_datetime confidence notes
    ]
  }
}.freeze

class CallExtractor < Igniter::LLM::Executor
  provider  :openai
  model     "gpt-4o-mini"

  system_prompt <<~SYSTEM
    You are a precise data extractor for an appliance-repair CRM.
    Given a call transcript (possibly with speaker labels), extract structured data.
    Use the JSON schema provided. Never hallucinate — extract only what is explicitly stated.
    Confidence reflects your certainty about the extraction (0.0–1.0).
  SYSTEM

  def call(transcript:, recorded_at: nil)
    text = build_prompt(transcript, recorded_at)
    raw  = complete(text)
    JSON.parse(raw)
  rescue JSON::ParserError
    # Fallback: try to extract JSON from a longer LLM reply
    match = raw.match(/\{.*\}/m)
    raise Igniter::Error, "Extractor returned invalid JSON: #{raw[0..200]}" unless match

    JSON.parse(match[0])
  end

  private

  # Override to inject OpenAI structured output (JSON schema enforcement).
  # With json_schema mode the model is guaranteed to return valid JSON.
  def completion_options
    super.merge(
      response_format: { type: "json_schema", json_schema: EXTRACTION_SCHEMA }
    )
  end

  def build_prompt(transcript, recorded_at) # rubocop:disable Metrics/MethodLength
    parts = []
    parts << "Call recorded at: #{recorded_at}" if recorded_at
    parts << ""

    result = transcript
    parts << if result.respond_to?(:speakers) && result.speakers&.any?
               # Format with speaker labels: "Speaker A: ... \nSpeaker B: ..."
               result.speakers.map { |s| "Speaker #{s.speaker}: #{s.text}" }.join("\n")
             elsif result.respond_to?(:text)
               result.text
             else
               result.to_s
             end

    parts.join("\n")
  end
end

# ── Pipeline Contract ──────────────────────────────────────────────────────────
#
# Igniter compiles this to a validated dependency graph and executes both
# nodes in the right order. cache_ttl: 86400 means a re-run of the same
# audio_url within 24 hours skips the expensive transcription API call.

class CallAnalysisPipeline < Igniter::Contract
  define do
    input :audio_url
    input :recorded_at, required: false

    compute :transcript, call: CallTranscriber,
                         with: :audio_url,
                         cache_ttl: 86_400 # 24 h — re-running same URL is free

    compute :extraction, call: CallExtractor,
                         with: %i[transcript recorded_at]

    output :transcript, from: :transcript
    output :extraction, from: :extraction
  end
end

# ── Rails Integration Pattern ──────────────────────────────────────────────────
#
# # app/models/call_recording.rb
# class CallRecording < ApplicationRecord
#   after_create_commit :schedule_analysis, if: :audio_url?
#
#   private
#
#   def schedule_analysis
#     CallAnalysisJob.perform_later(id)
#   end
# end
#
# # app/jobs/call_analysis_job.rb
# class CallAnalysisJob < ApplicationJob
#   queue_as :transcription
#   sidekiq_options retry: 3, dead: false
#
#   def perform(call_recording_id)
#     rec      = CallRecording.find(call_recording_id)
#     pipeline = CallAnalysisPipeline.new(
#       audio_url:   rec.audio_url,
#       recorded_at: rec.created_at.iso8601
#     )
#     pipeline.resolve_all
#
#     transcript = pipeline.result.transcript
#     extraction = pipeline.result.extraction
#
#     rec.update!(
#       transcript_text:     transcript.text,
#       transcript_duration: transcript.duration,
#       speakers_json:       transcript.speakers&.map(&:to_h),
#       conversion:          extraction["conversion"],
#       call_type:           extraction["call_type"],
#       zip_codes:           extraction["zip_codes"],
#       addresses:           extraction["addresses"],
#       phones:              extraction["phones"],
#       service_names:       extraction["service_names"],
#       scheduled_at:        extraction["scheduled_datetime"]&.then { Time.parse(_1) },
#       ai_confidence:       extraction["confidence"],
#       ai_notes:            extraction["notes"]
#     )
#   end
# end
#
# # db/migrate/..._add_ai_fields_to_call_recordings.rb
# add_column :call_recordings, :transcript_text,     :text
# add_column :call_recordings, :transcript_duration, :float
# add_column :call_recordings, :speakers_json,       :jsonb,  default: []
# add_column :call_recordings, :conversion,          :boolean
# add_column :call_recordings, :call_type,           :string
# add_column :call_recordings, :zip_codes,           :string, array: true, default: []
# add_column :call_recordings, :addresses,           :string, array: true, default: []
# add_column :call_recordings, :phones,              :string, array: true, default: []
# add_column :call_recordings, :service_names,       :string, array: true, default: []
# add_column :call_recordings, :scheduled_at,        :datetime
# add_column :call_recordings, :ai_confidence,       :float
# add_column :call_recordings, :ai_notes,            :text
# add_index  :call_recordings, :conversion
# add_index  :call_recordings, :call_type
# add_index  :call_recordings, :zip_codes, using: :gin

# ── Demo ──────────────────────────────────────────────────────────────────────

module DemoMode
  # Fake transcript returned by the mock transcriber
  TRANSCRIPT_TEXT = <<~TEXT.strip
    Hello, thank you for calling Acme Appliance Repair. My name is Mike, how can I help you today?
    Hi Mike! I'm calling because my washer stopped working. I'm in Houston, zip code 77001.
    Of course! What's your address?
    It's 123 Main Street, Houston TX 77001.
    And a phone number where we can reach you?
    Sure, that's 713-555-0142.
    Great, and what brand is the washer?
    It's a Samsung front-loader. Been making a loud banging noise and then shut off.
    We can schedule a Samsung washer repair visit. Does Thursday the 15th at 2pm work?
    Perfect, that works great!
    Wonderful, you're all set. Expect a call from our technician the morning of your appointment.
  TEXT

  def self.seg(speaker, start_time, end_time, text)
    Igniter::LLM::Transcription::SpeakerSegment.new(
      speaker: speaker, start_time: start_time, end_time: end_time, text: text
    )
  end

  def self.mock_transcript # rubocop:disable Metrics/MethodLength
    speakers = [
      seg("A", 0.0, 5.1,
          "Hello, thank you for calling Acme Appliance Repair. My name is Mike, how can I help you today?"),
      seg("B", 5.3, 12.4, "Hi Mike! I'm calling because my washer stopped working. I'm in Houston, zip code 77001."),
      seg("A", 12.6, 14.0, "Of course! What's your address?"),
      seg("B", 14.2, 17.8, "It's 123 Main Street, Houston TX 77001."),
      seg("A", 18.0, 19.5, "And a phone number where we can reach you?"),
      seg("B", 19.7, 22.1, "Sure, that's 713-555-0142."),
      seg("A", 22.3, 24.0, "Great, and what brand is the washer?"),
      seg("B", 24.2, 29.5, "It's a Samsung front-loader. Been making a loud banging noise and then shut off."),
      seg("A", 29.7, 34.8, "We can schedule a Samsung washer repair visit. Does Thursday the 15th at 2pm work?"),
      seg("B", 35.0, 36.5, "Perfect, that works great!"),
      seg("A", 36.7, 41.0,
          "Wonderful, you're all set. Expect a call from our technician the morning of your appointment.")
    ]
    Igniter::LLM::Transcription::TranscriptResult.new(
      text: TRANSCRIPT_TEXT, words: [], speakers: speakers,
      language: "en", duration: 41.0, provider: :assemblyai, model: "universal-2", raw: {}
    )
  end

  def self.mock_extraction(_transcript) # rubocop:disable Metrics/MethodLength
    puts "  [demo] Skipping real LLM call — using mock extraction"
    {
      "conversion" => true,
      "call_type" => "order",
      "zip_codes" => ["77001"],
      "addresses" => ["123 Main Street, Houston TX 77001"],
      "phones" => ["713-555-0142"],
      "service_names" => ["Samsung washer repair", "front-loader"],
      "scheduled_datetime" => "2025-04-15T14:00:00",
      "confidence" => 0.97,
      "notes" => "Customer reporting loud banging noise before shutdown. " \
                  "Appointment confirmed for Thursday 15th at 2pm."
    }
  end
end

if ENV["DEMO"] == "1"
  puts "=" * 70
  puts "DEMO MODE — no real API calls"
  puts "=" * 70

  # Patch executors to return mock data
  CallTranscriber.define_method(:call) do |audio_url:|
    puts "  [demo] Transcribing: #{audio_url}"
    puts "  [demo] AssemblyAI poll complete (41 s audio, 2 speakers detected)"
    DemoMode.mock_transcript
  end

  CallExtractor.define_method(:call) do |transcript:, recorded_at: nil| # rubocop:disable Lint/UnusedBlockArgument
    DemoMode.mock_extraction(transcript)
  end

  pipeline = CallAnalysisPipeline.new(
    audio_url: "https://cdn.callrail.com/recordings/abc123.mp3",
    recorded_at: "2025-04-11T14:32:00-05:00"
  )
  pipeline.resolve_all

  t = pipeline.result.transcript
  e = pipeline.result.extraction

  puts "\n── Transcript (#{t.duration.round(1)} s) " + "─" * 40
  puts "Language : #{t.language}  |  Provider: #{t.provider}  |  Speakers: #{t.speakers&.size}"
  puts
  t.speakers.each { |s| puts "  Speaker #{s.speaker} [#{s.start_time.round(1)}s–#{s.end_time.round(1)}s]: #{s.text}" }

  puts "\n── Extraction #{"─" * 55}"
  puts "Conversion    : #{e["conversion"]} (#{(e["confidence"] * 100).round}% confidence)"
  puts "Call type     : #{e["call_type"]}"
  puts "ZIP codes     : #{e["zip_codes"].join(", ")}"
  puts "Addresses     : #{e["addresses"].join("; ")}"
  puts "Phones        : #{e["phones"].join(", ")}"
  puts "Services      : #{e["service_names"].join(", ")}"
  puts "Scheduled     : #{e["scheduled_datetime"]}"
  puts "Notes         : #{e["notes"]}"
  puts

  puts "✓ Would save to CallRecording##{rand(10_000..99_999)}"
  puts "  → conversion=#{e["conversion"]}  call_type=#{e["call_type"]}  confidence=#{e["confidence"]}"
else
  # Real run — requires valid API keys
  audio_url = ARGV[0] || raise("Usage: ruby call_center_analysis.rb <audio_url>\n" \
                                "       OR: DEMO=1 ruby call_center_analysis.rb")
  pipeline  = CallAnalysisPipeline.new(audio_url: audio_url, recorded_at: Time.now.iso8601)
  pipeline.resolve_all
  puts JSON.pretty_generate({ transcript_preview: pipeline.result.transcript.text[0..200],
                              extraction: pipeline.result.extraction })
end

# ── Future: Real-time analysis with Asterisk ──────────────────────────────────
#
# For real-time operator assistance once you own the Asterisk PBX:
#
# 1. Asterisk AGI streams RTP audio → Deepgram WebSocket
#    (deepgram supports WebSocket for real-time Nova-3 transcription)
#
# 2. An Igniter Agent subscribes to the Deepgram transcript stream:
#
#      class CallMonitorAgent < Igniter::Agent
#        on :transcript_chunk do |payload|
#          text = payload[:text]
#          next unless text.length > 50   # wait for meaningful chunks
#
#          hints = ContextExtractor.call(partial_text: text)
#          next if hints.empty?
#
#          deliver(:operator_hint, call_id: payload[:call_id], hints: hints)
#        end
#      end
#
# 3. Operator UI (ActionCable) receives hints in real-time:
#    - "ZIP code detected: 77001 — pull up nearby technicians"
#    - "Customer mentioned Samsung washer — show repair checklist"
#    - "Customer says 'cancel' — load cancellation flow"
#
# 4. Final analysis runs post-call (same CallAnalysisPipeline) for CRM save.
#
# Cost delta for real-time (Deepgram WebSocket):
#   Nova-3 streaming: same $0.0077/min — no surcharge vs pre-recorded REST
#   Total with real-time: ~$208 + $4 analysis = ~$212/month
#   (vs $81/month batch) — the premium pays for live operator assistance.
