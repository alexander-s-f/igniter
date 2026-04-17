/**
 * Companion Client — ESP32-A1S (Ai-Thinker) Audio Edge Node
 *
 * Hardware:
 *   - Ai-Thinker ESP32-A1S module
 *   - ES8388 audio codec (I2S + I2C)
 *   - Built-in microphone(s) via I2S
 *   - Speaker output via ES8388 DAC
 *
 * Libraries required (install via Arduino Library Manager):
 *   - ESP32-audioI2S  (schreibfaul1)
 *   - ArduinoJson     (bblanchon) v6+
 *   - ESP32 base64    (built-in via mbedtls)
 *
 * Wire button to GPIO 36 (input-only, active LOW with internal pull-up).
 *
 * Flow:
 *   1. Button press   → start recording (I2S DMA, 16kHz 16-bit mono)
 *   2. Button release → stop recording, encode Base64
 *   3. POST audio + history to orchestrator /v1/contracts/VoiceAssistantContract/execute
 *   4. Parse JSON response { outputs: { audio_response, response_text, transcript } }
 *   5. Decode Base64 WAV → play via ES8388 DAC
 */

#include <Arduino.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <driver/i2s.h>
#include <mbedtls/base64.h>

// ── Configuration ──────────────────────────────────────────────────────────
const char* WIFI_SSID       = "YOUR_WIFI_SSID";
const char* WIFI_PASSWORD   = "YOUR_WIFI_PASSWORD";
const char* ORCHESTRATOR_URL =
  "http://192.168.1.100:4567/v1/contracts/VoiceAssistantContract/execute";

const int   BUTTON_PIN      = 36;    // GPIO 36 (VP), active LOW
const int   MAX_RECORD_SECS = 8;     // max recording length
const int   SAMPLE_RATE     = 16000;
const int   I2S_BUFFER_SIZE = 512;

// ES8388 I2C address
const int   ES8388_ADDR = 0x10;

// I2S pins for ES8388 on ESP32-A1S
const int   I2S_BCLK = 27;
const int   I2S_LRC  = 25;
const int   I2S_DIN  = 35;   // microphone data in
const int   I2S_DOUT = 26;   // DAC data out
const int   I2S_MCLK = 0;    // master clock

// ── State ──────────────────────────────────────────────────────────────────
int16_t* recordBuffer   = nullptr;
size_t   recordSamples  = 0;
String   sessionId      = "";

// Conversation history — last 6 turns (3 exchanges)
struct Turn { String role; String content; };
Turn    history[6];
int     historyCount = 0;

// ── ES8388 I2C helpers ─────────────────────────────────────────────────────
#include <Wire.h>

void es8388Write(uint8_t reg, uint8_t val) {
  Wire.beginTransmission(ES8388_ADDR);
  Wire.write(reg);
  Wire.write(val);
  Wire.endTransmission();
}

void es8388Init() {
  Wire.begin(33, 32);  // SDA=33, SCL=32 on ESP32-A1S
  delay(100);

  // Power up
  es8388Write(0x08, 0x00);  // master mode
  es8388Write(0x00, 0x35);  // chip control: enable ADC/DAC
  es8388Write(0x01, 0x00);  // power management: normal op

  // ADC config (microphone input)
  es8388Write(0x09, 0x55);  // LINSEL=1 (MIC1 differential), RINSEL=1
  es8388Write(0x0A, 0x36);  // ADC vol
  es8388Write(0x0D, 0x06);  // ADC sample rate = 16kHz
  es8388Write(0x10, 0x00);  // ADC input select: LINPUT1
  es8388Write(0x11, 0x00);

  // DAC config (speaker output)
  es8388Write(0x17, 0x18);  // DAC sample rate = 16kHz
  es8388Write(0x1A, 0x00);  // DAC vol L
  es8388Write(0x1B, 0x00);  // DAC vol R

  // Output mixer
  es8388Write(0x26, 0x12);  // LOUT1VOL
  es8388Write(0x27, 0x12);  // ROUT1VOL
}

// ── I2S setup ──────────────────────────────────────────────────────────────
void i2sInitMic() {
  i2s_config_t cfg = {
    .mode                 = (i2s_mode_t)(I2S_MODE_MASTER | I2S_MODE_RX),
    .sample_rate          = SAMPLE_RATE,
    .bits_per_sample      = I2S_BITS_PER_SAMPLE_16BIT,
    .channel_format       = I2S_CHANNEL_FMT_ONLY_LEFT,
    .communication_format = I2S_COMM_FORMAT_STAND_I2S,
    .intr_alloc_flags     = ESP_INTR_FLAG_LEVEL1,
    .dma_buf_count        = 8,
    .dma_buf_len          = I2S_BUFFER_SIZE,
    .use_apll             = true,
    .tx_desc_auto_clear   = false,
    .fixed_mclk           = SAMPLE_RATE * 256
  };
  i2s_pin_config_t pins = {
    .mck_io_num   = I2S_MCLK,
    .bck_io_num   = I2S_BCLK,
    .ws_io_num    = I2S_LRC,
    .data_out_num = I2S_MODE_RX ? -1 : I2S_DOUT,
    .data_in_num  = I2S_DIN
  };
  i2s_driver_install(I2S_NUM_0, &cfg, 0, nullptr);
  i2s_set_pin(I2S_NUM_0, &pins);
}

void i2sInitDac() {
  i2s_config_t cfg = {
    .mode                 = (i2s_mode_t)(I2S_MODE_MASTER | I2S_MODE_TX),
    .sample_rate          = SAMPLE_RATE,
    .bits_per_sample      = I2S_BITS_PER_SAMPLE_16BIT,
    .channel_format       = I2S_CHANNEL_FMT_RIGHT_LEFT,
    .communication_format = I2S_COMM_FORMAT_STAND_I2S,
    .intr_alloc_flags     = ESP_INTR_FLAG_LEVEL1,
    .dma_buf_count        = 8,
    .dma_buf_len          = I2S_BUFFER_SIZE,
    .use_apll             = true,
    .tx_desc_auto_clear   = true
  };
  i2s_pin_config_t pins = {
    .mck_io_num   = I2S_MCLK,
    .bck_io_num   = I2S_BCLK,
    .ws_io_num    = I2S_LRC,
    .data_out_num = I2S_DOUT,
    .data_in_num  = -1
  };
  i2s_driver_install(I2S_NUM_0, &cfg, 0, nullptr);
  i2s_set_pin(I2S_NUM_0, &pins);
}

// ── WAV helpers ────────────────────────────────────────────────────────────
struct WavHeader {
  char     riff[4]      = {'R','I','F','F'};
  uint32_t chunkSize;
  char     wave[4]      = {'W','A','V','E'};
  char     fmt[4]       = {'f','m','t',' '};
  uint32_t subchunk1    = 16;
  uint16_t audioFormat  = 1;
  uint16_t numChannels  = 1;
  uint32_t sampleRate   = SAMPLE_RATE;
  uint32_t byteRate     = SAMPLE_RATE * 2;
  uint16_t blockAlign   = 2;
  uint16_t bitsPerSample = 16;
  char     data[4]      = {'d','a','t','a'};
  uint32_t dataSize;
};

// Returns Base64-encoded WAV from raw PCM buffer
String pcmToBase64Wav(const int16_t* samples, size_t count) {
  size_t   pcmBytes = count * sizeof(int16_t);
  WavHeader hdr;
  hdr.chunkSize = 36 + pcmBytes;
  hdr.dataSize  = pcmBytes;

  size_t  totalBytes = sizeof(WavHeader) + pcmBytes;
  uint8_t* wav       = (uint8_t*)malloc(totalBytes);
  if (!wav) return "";

  memcpy(wav, &hdr, sizeof(WavHeader));
  memcpy(wav + sizeof(WavHeader), samples, pcmBytes);

  size_t  b64Len = ((totalBytes + 2) / 3) * 4 + 1;
  uint8_t* b64   = (uint8_t*)malloc(b64Len);
  size_t   olen  = 0;
  mbedtls_base64_encode(b64, b64Len, &olen, wav, totalBytes);

  String result((char*)b64, olen);
  free(wav);
  free(b64);
  return result;
}

// ── Recording ──────────────────────────────────────────────────────────────
void recordAudio() {
  size_t maxSamples = SAMPLE_RATE * MAX_RECORD_SECS;
  if (recordBuffer) free(recordBuffer);
  recordBuffer  = (int16_t*)malloc(maxSamples * sizeof(int16_t));
  recordSamples = 0;

  i2s_driver_uninstall(I2S_NUM_0);
  i2sInitMic();

  Serial.println("Recording...");

  int16_t tmpBuf[I2S_BUFFER_SIZE];
  while (digitalRead(BUTTON_PIN) == LOW && recordSamples < maxSamples) {
    size_t bytesRead = 0;
    i2s_read(I2S_NUM_0, tmpBuf, sizeof(tmpBuf), &bytesRead, portMAX_DELAY);
    size_t samples = bytesRead / sizeof(int16_t);
    size_t toStore = min(samples, maxSamples - recordSamples);
    memcpy(recordBuffer + recordSamples, tmpBuf, toStore * sizeof(int16_t));
    recordSamples += toStore;
  }

  Serial.printf("Recorded %d samples (%.1f s)\n",
                recordSamples, (float)recordSamples / SAMPLE_RATE);
}

// ── Playback ───────────────────────────────────────────────────────────────
void playWav(const uint8_t* wav, size_t len) {
  // Skip 44-byte WAV header
  if (len < 44) return;
  const uint8_t* pcm     = wav + 44;
  size_t         pcmSize = len - 44;

  i2s_driver_uninstall(I2S_NUM_0);
  i2sInitDac();

  size_t written = 0;
  i2s_write(I2S_NUM_0, pcm, pcmSize, &written, portMAX_DELAY);

  delay(200);  // drain DMA
}

// ── Build JSON body ────────────────────────────────────────────────────────
String buildRequestBody(const String& audioB64) {
  DynamicJsonDocument doc(8192);
  JsonObject inputs  = doc.createNestedObject("inputs");
  inputs["audio_data"]  = audioB64;
  inputs["session_id"]  = sessionId;

  JsonArray hist = inputs.createNestedArray("conversation_history");
  for (int i = 0; i < historyCount; i++) {
    JsonObject turn  = hist.createNestedObject();
    turn["role"]    = history[i].role;
    turn["content"] = history[i].content;
  }

  String body;
  serializeJson(doc, body);
  return body;
}

// ── HTTP call to orchestrator ──────────────────────────────────────────────
struct Response {
  bool   success;
  String transcript;
  String responseText;
  String audioB64;
};

Response callOrchestrator(const String& audioB64) { // NOLINT
  HTTPClient http;
  http.begin(ORCHESTRATOR_URL);
  http.addHeader("Content-Type", "application/json");
  http.setTimeout(60000);  // 60 s for full pipeline

  String body   = buildRequestBody(audioB64);
  int    status = http.POST(body);

  if (status != 200) {
    Serial.printf("HTTP error: %d\n", status);
    http.end();
    return { false };
  }

  String payload = http.getString();
  http.end();

  DynamicJsonDocument doc(16384);
  if (deserializeJson(doc, payload) != DeserializationError::Ok) {
    Serial.println("JSON parse error");
    return { false };
  }

  if (String(doc["status"].as<const char*>()) != "succeeded") {
    Serial.println("Contract failed: " + String(doc["error"]["message"].as<const char*>()));
    return { false };
  }

  JsonObject outputs = doc["outputs"];
  return {
    true,
    outputs["transcript"].as<String>(),
    outputs["response_text"].as<String>(),
    outputs["audio_response"].as<String>()
  };
}

// ── History management ─────────────────────────────────────────────────────
void pushHistory(const String& transcript, const String& response) {
  // Shift if full
  if (historyCount >= 6) {
    for (int i = 0; i < 4; i++) history[i] = history[i + 2];
    historyCount = 4;
  }
  history[historyCount++] = { "user",      transcript };
  history[historyCount++] = { "assistant", response   };
}

// ── Arduino setup / loop ───────────────────────────────────────────────────
void setup() {
  Serial.begin(115200);
  Serial.println("Companion ESP32-A1S starting...");

  pinMode(BUTTON_PIN, INPUT_PULLUP);

  // Generate session ID
  sessionId = "esp32-" + String((uint32_t)esp_random(), HEX);

  // Init ES8388
  es8388Init();
  Serial.println("ES8388 codec initialised");

  // Wi-Fi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) { delay(500); Serial.print("."); }
  Serial.println("\nWiFi connected: " + WiFi.localIP().toString());
  Serial.println("Hold button to speak. Release to send.");
}

void loop() {
  if (digitalRead(BUTTON_PIN) != LOW) return;

  // Debounce
  delay(50);
  if (digitalRead(BUTTON_PIN) != LOW) return;

  // Record while button held
  recordAudio();

  if (recordSamples < SAMPLE_RATE / 2) {
    Serial.println("Too short, ignoring");
    return;
  }

  Serial.println("Encoding and sending...");
  String audioB64  = pcmToBase64Wav(recordBuffer, recordSamples);
  Response resp    = callOrchestrator(audioB64);

  if (!resp.success) {
    Serial.println("Pipeline failed");
    return;
  }

  Serial.println("Transcript:  " + resp.transcript);
  Serial.println("Response:    " + resp.responseText);

  // Decode audio and play
  size_t  wavLen  = (resp.audioB64.length() * 3) / 4 + 4;
  uint8_t* wavBuf = (uint8_t*)malloc(wavLen);
  size_t  olen    = 0;
  mbedtls_base64_decode(wavBuf, wavLen, &olen,
                        (const uint8_t*)resp.audioB64.c_str(),
                        resp.audioB64.length());

  playWav(wavBuf, olen);
  free(wavBuf);

  pushHistory(resp.transcript, resp.responseText);
}
