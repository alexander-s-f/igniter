module IgniterCensorshipResistancePrimitives

profile censorship_primitives
  time: bitemporal
  evidence: required
  trust: system

# ====================== STEGANOGRAPHY — DETAILED MODEL ======================
type SteganographyCarrier {
  kind: :image_lsb | :audio_watermark | :dns_tunneling | :text_whitespace | :video_frame | :pdf_metadata | :tcp_header | :physical_pigeon_note
  capacity_bits_per_unit: Integer
  detectability_risk: Decimal[2]          # 0.0 = undetectable → 1.0 = easily detected
  current_status: :clean | :embedded | :detected | :compromised
  epistemic_kind: :observed | :inferred | :simulated
}

type SteganographyEmbedding {
  id: UUID
  carrier: SteganographyCarrier
  payload_hash: Hash
  method: :lsb | :spread_spectrum | :echo_hiding | :phase_shift | :custom
  redundancy_level: Integer               # how many copies of the payload
  extraction_key: Optional[KeyRef]        # for keyed steganography
  evidence_of_embedding: EvidenceBundle
  assumptions_used: AssumptionSet
}

type SteganographyExtractionAttempt {
  id: UUID
  carrier: SteganographyCarrier
  success: Boolean
  extracted_payload_hash: Optional[Hash]
  detection_method: List[:statistical | :ml_model | :human | :side_channel]
  evidence_bundle: EvidenceBundle
}

# ====================== CENSORSHIP + STEGANOGRAPHY ======================
type CommunicationChannel {
  id: UUID
  kind: :tcp | :udp | :mesh | :satellite | :bluetooth | :physical_pigeon | :steganography
  steganography_carrier: Optional[SteganographyCarrier]   # only for kind = :steganography
  reliability: Decimal[2]
  censorship_risk: Decimal[2]
  current_status: :open | :throttled | :blocked | :monitored | :injected
}

type CensorshipEvent { ... }   # as in V2, but can now refer to Steganography Embedding

# ====================== ASSUMPTIONS & CONSTRAINTS (Steganography-specific) ======================
assumptions steganography_dynamics {
  assumption modern_ml_can_detect_lsb {
    kind: :empirical
    statement "Modern ML models detect LSB steganography with a probability of 0.87 when analyzing"
    strength: 0.83
  }
  assumption physical_carriers_lower_detectability {
    kind: :heuristic
    statement "Physical media (pigeon, USB dead-drop) have detectability < 0.15"
    strength: 0.79
  }
}

constraints steganography_resistance {
  constraint no_silent_embedding_failure {
    kind: :ethical
    priority: 0.99
    statement "Each embedding/extraction must leave an auditable receipt."
  }
  constraint evidence_for_every_stego_attempt {
    kind: :epistemic
    priority: 1.0
    statement "Steganography Embedding and Extraction Attempt must have an evidence bundle"
  }
}

# ====================== PURE CONTRACTS — Steganography core ======================
pure contract EmbedViaSteganography
  input payload: MessagePacket
  input carrier: SteganographyCarrier
  uses assumptions steganography_dynamics
  output embedding: SteganographyEmbedding evidence [payload, carrier, assumptions]

pure contract AttemptSteganographyExtraction
  input carrier: SteganographyCarrier
  output attempt: SteganographyExtractionAttempt evidence [carrier]

pure contract EvaluateSteganographyRisk
  input embedding: SteganographyEmbedding
  output risk_score: Decimal[2] evidence [embedding]

receipt SteganographyReceipt { ... }

end module