# Companion — AI Voice Assistant Demo

A distributed voice AI assistant built with `Igniter::Application`. Demonstrates how Igniter orchestrates a multi-stage inference pipeline across heterogeneous hardware.

```
ESP32 mic → [HTTP] → Orchestrator → ASR → Intent → Chat (LLM) → TTS → [HTTP] → ESP32 speaker
```

---

## Architecture

| Node | Hardware | Role |
|------|----------|------|
| Orchestrator | HP t740 (x86_64, 32 GB) | `VoiceAssistantContract` + `ChatContract` (llama3.1:8b) |
| Inference | Raspberry Pi 5 (ARM64) | `ASRContract` + `IntentContract` + `TTSContract` |
| Edge | ESP32-A1S | Audio capture → HTTP → playback |

In single-node mode all contracts run locally. In distributed mode (k3s cluster) each node runs a separate `Igniter::Application`.

---

## Quick Start — Demo Mode

No hardware or API keys required. Uses mock executors that simulate each pipeline stage.

```bash
# From the igniter project root:
bundle exec ruby examples/companion/demo.rb
```

Expected output per turn:

```
── Turn 1 ────────────────────────────────────────────
  [ASR mock]    → "Hello, are you there?"
  [Intent mock] → question
  [Chat mock]   → "I'd need a moment to look that up..."
  [TTS mock]    → synthesising 76 chars
  Heard:    "Hello, are you there?"
  Intent:   question (92%)
  Response: "I'd need a moment to look that up..."
  Audio:    4328 chars (Base64 WAV)

  Press Enter for next turn, or Ctrl+C to exit...
```

---

## Quick Start — Real Ollama Mode

Requires [Ollama](https://ollama.com) running locally with two models pulled:

```bash
ollama pull llama3.1:8b     # chat model
ollama pull qwen2.5:1.5b    # intent classification (small, fast)
```

Then:

```bash
COMPANION_REAL_LLM=1 bundle exec ruby examples/companion/demo.rb
```

---

## Orchestrator Server

Start the orchestrator node (handles `VoiceAssistantContract` and `ChatContract`):

```bash
# Local dev (MemoryStore, default port 4567)
bundle exec ruby examples/companion/application.rb

# With Redis store and JSON logging
REDIS_URL=redis://localhost:6379 \
LOG_FORMAT=json \
bundle exec ruby examples/companion/application.rb
```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ORCHESTRATOR_PORT` | `4567` | HTTP port |
| `INFERENCE_NODE_URL` | `http://localhost:4568` | URL of the inference node (RPi) |
| `CHAT_NODE_URL` | `http://localhost:4567` (self) | URL of the chat node |
| `CHAT_MODEL` | `llama3.1:8b` | Ollama model for chat |
| `OLLAMA_URL` | `http://localhost:11434` | Ollama API base URL |
| `REDIS_URL` | *(none — MemoryStore)* | Redis connection URL |
| `LOG_FORMAT` | `text` | `text` or `json` (Loki/ELK) |

---

## Inference Server

Start the inference node (RPi — handles `ASRContract`, `IntentContract`, `TTSContract`):

```bash
bundle exec ruby examples/companion/servers/inference_server.rb
```

Requires:
- [faster-whisper](https://github.com/SYSTRAN/faster-whisper) HTTP server on port 8000 (or set `WHISPER_URL`)
- [piper](https://github.com/rhasspy/piper) binary on `PATH` (or set `PIPER_BIN`)

---

## Distributed Deployment (k3s)

Recommended cluster layout for the hardware above:

```
HP t740 (x86_64) — k3s control plane + orchestrator node
  └── runs: application.rb (port 4567)
  └── runs: ollama serve (llama3.1:8b)
  └── runs: redis-server

RPi 5 #1 (ARM64) — k3s worker + inference node
  └── runs: inference_server.rb (port 4568)
  └── runs: faster-whisper HTTP (port 8000)
  └── runs: piper TTS binary

RPi 5 #2 (ARM64) — k3s worker (scale-out)
  └── optionally runs a second inference_server.rb replica
```

### k3s Quick Install

```bash
# HP t740 — control plane
curl -sfL https://get.k3s.io | sh -

# Get join token
sudo cat /var/lib/rancher/k3s/server/node-token

# RPi #1 — worker
curl -sfL https://get.k3s.io | K3S_URL=https://<t740-ip>:6443 K3S_TOKEN=<token> sh -
```

### Kubernetes Deployment

```yaml
# orchestrator-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: companion-orchestrator
spec:
  replicas: 1
  selector:
    matchLabels: { app: companion-orchestrator }
  template:
    metadata:
      labels: { app: companion-orchestrator }
    spec:
      nodeSelector:
        kubernetes.io/arch: amd64
      containers:
        - name: orchestrator
          image: your-registry/companion:latest
          command: ["ruby", "examples/companion/application.rb"]
          ports:
            - containerPort: 4567
          env:
            - name: INFERENCE_NODE_URL
              value: "http://companion-inference:4568"
            - name: REDIS_URL
              valueFrom:
                secretKeyRef: { name: redis-secret, key: url }
            - name: LOG_FORMAT
              value: json
          livenessProbe:
            httpGet: { path: /v1/live, port: 4567 }
            initialDelaySeconds: 5
          readinessProbe:
            httpGet: { path: /v1/ready, port: 4567 }
            initialDelaySeconds: 5
```

---

## ESP32 Client

Firmware for the ESP32-A1S audio kit is in [`esp32/companion_client.ino`](esp32/companion_client.ino).

**Features:**
- Records 16 kHz 16-bit mono PCM via I2S DMA while button is held
- Encodes audio as Base64 WAV, POSTs to orchestrator
- Decodes WAV response, plays via ES8388 DAC

**Required Arduino libraries:**
- `ESP32 Arduino` core
- `Audio` (ESP32-audioI2S) — for WAV playback
- `ArduinoJson` — for session history serialization

**Required Arduino board config:**
- Board: `ESP32 Dev Module`
- CPU Frequency: 240 MHz
- Flash Size: 4 MB

**Configure before flashing:**

```cpp
// esp32/companion_client.ino
const char* ssid           = "YourWiFiSSID";
const char* password       = "YourWiFiPassword";
const char* ORCHESTRATOR   = "http://192.168.1.x:4567";  // HP t740 IP
```

---

## File Structure

```
examples/companion/
├── application.rb          ← Igniter::Application entry point (orchestrator)
├── application.yml         ← base config (port, log_format, drain_timeout)
├── demo.rb                 ← single-process demo with mock executors
├── contracts/
│   ├── asr_contract.rb
│   ├── intent_contract.rb
│   ├── chat_contract.rb
│   ├── tts_contract.rb
│   └── voice_assistant_contract.rb
├── executors/
│   ├── whisper_executor.rb   ← faster-whisper HTTP client
│   ├── intent_executor.rb    ← Ollama qwen2.5:1.5b (JSON classification)
│   ├── chat_executor.rb      ← Ollama llama3.1:8b (multi-turn chat)
│   ├── piper_executor.rb     ← piper TTS subprocess
│   └── mock_executors.rb     ← stubs for demo mode
├── servers/
│   ├── orchestrator_server.rb  ← delegates to application.rb
│   └── inference_server.rb     ← RPi node (ASR + Intent + TTS)
└── esp32/
    └── companion_client.ino    ← Arduino firmware
```
