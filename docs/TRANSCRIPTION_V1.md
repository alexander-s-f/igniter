# Igniter — AI::Transcriber

`Igniter::AI::Transcriber` is a first-class Executor for audio-to-text conversion.
It plugs into the Contract graph exactly like any other compute node, giving you
caching, dependency resolution, and parallel execution for free.

This document covers the transcription part of Igniter's AI layer.

```
audio file / URL
      │
      ▼
 CallTranscriber          ← AI::Transcriber subclass
      │  TranscriptResult
      │   .text, .words, .speakers, .duration
      ▼
 CallExtractor            ← AI::Executor subclass
      │  Hash (structured JSON)
      ▼
  CRM / DB
```

---

## Quick start

```ruby
require "igniter/ai"

Igniter::AI.configure do |c|
  c.deepgram.api_key = ENV["DEEPGRAM_API_KEY"]
end

class MyTranscriber < Igniter::AI::Transcriber
  transcription_provider :deepgram
  model "nova-3"
  language "en"
  diarize true

  def call(audio_path:) = transcribe(audio_path)
end

result = MyTranscriber.call(audio_path: "meeting.mp3")
puts result.text
puts result.speakers.map { |s| "#{s.speaker}: #{s.text}" }.join("\n")
```

---

## Providers

### OpenAI Whisper / gpt-4o-mini-transcribe

| | |
|---|---|
| **Sync** | Yes — single POST, immediate response |
| **Diarization** | **No** |
| **Word timestamps** | Yes |
| **Languages** | 99+ (auto-detect or `language:`) |
| **Max file size** | 20 MB |
| **Pricing** | whisper-1: `$0.006/min` · gpt-4o-mini-transcribe: `$0.003/min` |

```ruby
class CallTranscriber < Igniter::AI::Transcriber
  transcription_provider :openai
  model "gpt-4o-mini-transcribe"   # or "whisper-1"
  language "en"

  def call(audio_url:) = transcribe(audio_url)
end
```

**Extra options:** `prompt:` — context hint to improve spelling/vocabulary accuracy.

---

### Deepgram Nova-3

| | |
|---|---|
| **Sync** | Yes — binary POST, immediate response |
| **Diarization** | Yes (`diarize true`) |
| **Word timestamps** | Yes (always included) |
| **Languages** | 99+ Nova-3 Multilingual · single-language Nova-3 |
| **Pricing** | `$0.0077/min` (includes diarization, per-second billing) |

```ruby
Igniter::AI.configure do |c|
  c.deepgram.api_key = ENV["DEEPGRAM_API_KEY"]
end

class CallTranscriber < Igniter::AI::Transcriber
  transcription_provider :deepgram
  model "nova-3"
  diarize true

  def call(audio_url:) = transcribe(audio_url)
end
```

**Extra options:**
```ruby
transcribe(audio_url,
  sentiment: true,   # per-sentence sentiment scores
  topics:    true,   # topic detection
  intents:   true,   # intent recognition
  summarize: true    # extractive summary
)
```

Results accessible via `result.raw["results"]["channels"][0]["alternatives"][0]`.

---

### AssemblyAI Universal-2

| | |
|---|---|
| **Sync** | **No** — async: upload → submit → poll |
| **Diarization** | Yes (`diarize true`) |
| **Word timestamps** | Yes (millisecond precision) |
| **Languages** | 99+ |
| **Pricing** | `$0.0025/min` base + `$0.0003/min` speaker labels ≈ `$0.0028/min` |
| **Free tier** | 333 hr/month |

```ruby
Igniter::AI.configure do |c|
  c.assemblyai.api_key      = ENV["ASSEMBLYAI_API_KEY"]
  c.assemblyai.poll_interval = 3    # seconds between status checks
  c.assemblyai.poll_timeout  = 600  # fail-safe timeout in seconds
end

class CallTranscriber < Igniter::AI::Transcriber
  transcription_provider :assemblyai
  diarize true
  poll_interval 3
  poll_timeout  600

  def call(audio_url:) = transcribe(audio_url)
end
```

**Extra options:**
```ruby
transcribe(audio_url,
  sentiment_analysis: true,
  auto_chapters:      true,
  entity_detection:   true,
  pii_redact:         [:phone_number, :name, :email],
  custom_vocabulary:  ["Acme", "thermidor"]
)
```

---

## Provider comparison

| Need | Recommended |
|------|-------------|
| Lowest cost, no speakers | `openai` + `gpt-4o-mini-transcribe` — $0.003/min |
| Lowest cost WITH speakers | `assemblyai` — $0.0028/min |
| Fastest response (sync) | `deepgram` — typical < 2 s |
| Richest features | `assemblyai` — chapters, PII, entity detection |
| Real-time / WebSocket | `deepgram` — same price as REST |

---

## DSL reference

```ruby
class MyTranscriber < Igniter::AI::Transcriber
  # ── Required ──────────────────────────────────────────────────────────
  transcription_provider :openai   # :openai | :deepgram | :assemblyai

  # ── Optional ──────────────────────────────────────────────────────────
  model "nova-3"            # defaults: openai→whisper-1, deepgram→nova-3,
                            #          assemblyai→universal-2
  language "en"             # BCP-47; nil = auto-detect
  diarize true              # request speaker labels (not supported by OpenAI)
  word_timestamps true      # per-word start/end times (default: true)

  # AssemblyAI async polling
  poll_interval 3           # seconds between poll attempts (default: 2)
  poll_timeout  600         # max seconds to wait (default: 300)

  def call(**inputs)
    transcribe(inputs[:audio_url])
    # or with provider-specific extras:
    transcribe(inputs[:audio_url], sentiment: true, topics: true)
  end
end
```

---

## Result structure

```ruby
result = MyTranscriber.call(audio_url: "call.mp3")

result.text       # => "Hello, thank you for calling..."
result.language   # => "en"
result.duration   # => 243.5   (seconds)
result.provider   # => :assemblyai
result.model      # => "universal-2"
result.raw        # => Hash — original provider response

# Word-level timestamps
result.words.first
# => #<TranscriptWord word="Hello" start_time=0.0 end_time=0.4 confidence=0.99 speaker="A">

# Speaker segments (when diarize: true)
result.speakers
# => [
#   #<SpeakerSegment speaker="A" start_time=0.0  end_time=5.1  text="Hello, thank you...">,
#   #<SpeakerSegment speaker="B" start_time=5.3  end_time=12.4 text="Hi, I need help...">,
#   ...
# ]
```

> **Note:** AssemblyAI uses letter labels (`"A"`, `"B"`, ...).
> Deepgram uses integers (`0`, `1`, ...).
> OpenAI has no speaker labels — `speakers` is `nil`.

---

## In a Contract graph

Transcriber is a full `Igniter::Executor`. Use it as a `compute:` node
with `cache_ttl:` to avoid re-transcribing the same audio on retries:

```ruby
class CallAnalysisPipeline < Igniter::Contract
  define do
    input :audio_url
    input :recorded_at, required: false

    compute :transcript, call: CallTranscriber,
                         with: :audio_url,
                         cache_ttl: 86_400   # 24 h — same URL = free

    compute :extraction, call: CallExtractor,
                         with: %i[transcript recorded_at]

    output :transcript, from: :transcript
    output :extraction, from: :extraction
  end
end

result = CallAnalysisPipeline.call(
  audio_url:   "https://cdn.callrail.com/recordings/abc123.mp3",
  recorded_at: call.created_at.iso8601
)
result[:transcript]  # => TranscriptResult
result[:extraction]  # => Hash from LLM analysis
```

---

## Production: call-center CRM (Rails)

See `examples/llm/call_center_analysis.rb` for a complete runnable example.

### Volume / cost estimate (27 000 min/month)

```
AssemblyAI (transcript + diarization)   ≈  $77/month
gpt-4o-mini (extraction, 14 000 calls)  ≈   $4/month
                                         ─────────────
Total                                    ≈  $81/month
```

### Rails plugin sketch

```ruby
# app/models/call_recording.rb
class CallRecording < ApplicationRecord
  after_create_commit :schedule_analysis, if: :audio_url?

  private

  def schedule_analysis = CallAnalysisJob.perform_later(id)
end

# app/jobs/call_analysis_job.rb
class CallAnalysisJob < ApplicationJob
  queue_as :transcription
  sidekiq_options retry: 3

  def perform(id)
    rec    = CallRecording.find(id)
    result = CallAnalysisPipeline.call(
      audio_url:   rec.audio_url,
      recorded_at: rec.created_at.iso8601
    )
    t = result[:transcript]
    e = result[:extraction]

    rec.update!(
      transcript_text:  t.text,
      duration_seconds: t.duration,
      speakers_json:    t.speakers&.map(&:to_h),
      conversion:       e["conversion"],
      call_type:        e["call_type"],
      zip_codes:        e["zip_codes"],
      addresses:        e["addresses"],
      phones:           e["phones"],
      service_names:    e["service_names"],
      scheduled_at:     e["scheduled_datetime"]&.then { Time.parse(_1) },
      ai_confidence:    e["confidence"],
      ai_notes:         e["notes"]
    )
  end
end
```

### Recommended PostgreSQL columns

```ruby
add_column :call_recordings, :transcript_text,  :text
add_column :call_recordings, :duration_seconds, :float
add_column :call_recordings, :speakers_json,    :jsonb,  default: []
add_column :call_recordings, :conversion,       :boolean
add_column :call_recordings, :call_type,        :string
add_column :call_recordings, :zip_codes,        :string, array: true, default: []
add_column :call_recordings, :addresses,        :string, array: true, default: []
add_column :call_recordings, :phones,           :string, array: true, default: []
add_column :call_recordings, :service_names,    :string, array: true, default: []
add_column :call_recordings, :scheduled_at,     :datetime
add_column :call_recordings, :ai_confidence,    :float
add_column :call_recordings, :ai_notes,         :text

# Useful indexes
add_index :call_recordings, :conversion
add_index :call_recordings, :call_type
add_index :call_recordings, :zip_codes,     using: :gin
add_index :call_recordings, :service_names, using: :gin
```

---

## Roadmap: Real-time operator assistance (Asterisk)

Once you own the Asterisk PBX, the path to live analysis:

```
Asterisk RTP stream
      │  (audio chunks via AGI/AMI)
      ▼
Deepgram WebSocket
      │  partial + final transcript events
      ▼
Igniter Actor (CallMonitorAgent)
      │  detects key events in real-time
      ▼
ActionCable → Operator UI
      │  "ZIP 77001 detected — pull nearby techs"
      │  "Customer says 'Samsung washer' — show checklist"
      │  "Sentiment dropping — offer discount code"
```

**Cost for real-time Deepgram:** same `$0.0077/min` (no surcharge vs REST).
Total with real-time: ~$212/month vs $81/month batch.
The premium pays for live operator assistance and reduced handle time.

### Agent sketch

```ruby
class CallMonitorAgent < Igniter::Agent
  on :transcript_chunk do |payload|
    text = payload[:text]
    next if text.length < 40   # wait for meaningful chunks

    hints = ContextExtractor.call(partial_text: text)
    next if hints.empty?

    broadcast(:operator_hint,
      call_id:     payload[:call_id],
      operator_id: payload[:operator_id],
      hints:       hints)
  end
end
```

---

## Configuration reference

```ruby
Igniter::AI.configure do |c|
  # OpenAI (used by both chat executors and openai transcription provider)
  c.openai.api_key  = ENV["OPENAI_API_KEY"]
  c.openai.base_url = "https://api.openai.com"  # override for Azure/proxy
  c.openai.timeout  = 120

  # Deepgram
  c.deepgram.api_key = ENV["DEEPGRAM_API_KEY"]
  c.deepgram.timeout = 300   # pre-recorded audio; allow for large files

  # AssemblyAI
  c.assemblyai.api_key       = ENV["ASSEMBLYAI_API_KEY"]
  c.assemblyai.poll_interval = 3    # start polling after N seconds
  c.assemblyai.poll_timeout  = 600  # raise ProviderError if not done in time
end
```
