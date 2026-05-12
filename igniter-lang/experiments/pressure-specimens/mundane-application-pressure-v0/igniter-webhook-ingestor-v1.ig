module IgniterWebhookIngestor

profile mundane_webhook
  time: bitemporal
  evidence: required
  trust: system
  effects: minimal          # сspecially minimal profile for mundane work

# ====================== DOMAIN TYPES ======================
type WebhookPayload {
  event_type: String
  user_id: UUID
  amount: Decimal[4]
  metadata: Map[String, Any]
  occurred_at: Timestamp
}

type ValidatedEvent {
  payload: WebhookPayload
  normalized: WebhookPayload
  validation_errors: List[ValidationError]
}

type ProcessedEventReceipt {
  event_id: UUID
  status: :accepted | :rejected | :duplicate
  validation_errors: List[ValidationError]
  stored_record: Optional[DomainRecord]
}

# ====================== CORE PLUMBING ======================
pure contract ParseJsonWebhook
  input raw_body: Bytes
  output payload: WebhookPayload evidence [raw_body]   # CORE, without escape

pure contract ValidateAndNormalize
  input payload: WebhookPayload
  output result: ValidatedEvent                        # Result-like via typed record

pure contract DeduplicateEvent
  input payload: WebhookPayload
  output is_duplicate: Boolean

# ====================== ESCAPE (only here) ======================
privileged contract StoreEvent
  input validated: ValidatedEvent
  escape db_write
  output receipt: ProcessedEventReceipt
  idempotency_key: String

# ====================== MAIN HANDLER (looks like regular code) ======================
contract ProcessWebhook(raw_request: HttpRequest)
  -> receipt: ProcessedEventReceipt
{
  # Everything below is ordinary, understandable, "boring" code
  let payload = ParseJsonWebhook(raw_request.body)

  let validated = ValidateAndNormalize(payload)

  if validated.validation_errors.is_not_empty {
    return reject_with_errors(validated.validation_errors)
  }

  let is_duplicate = DeduplicateEvent(validated.normalized)

  if is_duplicate {
    return { status: :duplicate, receipt: duplicate_receipt() }
  }

  # Only here does the real effect appear.
  let stored = StoreEvent(validated) with {
    idempotency_key: raw_request.headers["Idempotency-Key"]
  }

  return stored
}

# ====================== WHAT THIS PROVES ======================

# 1. Mundane workflow looks clean and pleasant (Parse → Validate → Store)
# 2. Clear boundaries: everything up to StoreEvent is pure CORE, without escapes
# 3. JSON parsing, Decimal, validation errors, and idempotency all work naturally
# 4. Receipt is created automatically and contains full evidence
# 5. No philosophical ceremony at every step—only where an auditable effect is truly needed
# 6. The developer can write "regular" code and still achieve full observability

end module