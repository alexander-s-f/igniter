# Igniter Embed Observed-Service Doc Sync v0

Status: done
Date: 2026-05-20
Card: RUBY-DOC-P2
Route: UPDATE
Track: igniter-embed-observed-service-doc-sync-v0
Guidance: PG-2026-05-20-01

## Purpose

Open the narrow `igniter-embed` observed-service docs sync using accepted Lang
Spark availability fixtures only as sanitized normalizer output examples.

This track is docs-only. It does not add Ruby API, package code, release
readiness claims, Rails generators, Spark adapters, durable queue APIs, or
shadow candidate implementation.

## Change Made

Updated `packages/igniter-embed/README.md` near the primary-only observed
service example.

The new docs now show:

- primary-only observed-service wrapper;
- host-owned normalizer;
- host-owned redaction allow-list;
- host-owned store adapter;
- sanitized aggregate availability payload as `receipt[:primary][:outputs]`;
- explicit separation between aggregate fixture vocabulary and Embed receipt
  envelope vocabulary;
- app-local boundary and optional Ledger stance.

## Fixture Usage Boundary

The accepted Lang fixture payload is used only as a normalizer aggregate output
example:

```text
receipt[:primary][:outputs]
```

It is not presented as:

- top-level Embed receipt envelope;
- `Igniter::Embed` receipt schema;
- public Lang canon;
- release-readiness evidence;
- Spark production integration evidence.

## Receipt Kind Boundary

The docs explicitly preserve the distinction:

```text
outputs[:receipt_kind] = "availability_slot_map_summary"
```

means fixture/example vocabulary inside the aggregate output payload.

```text
receipt[:receipt_kind] = :contractable_observation
```

remains the Embed observation envelope kind.

```text
event_receipt[:receipt_kind] = :contractable_event
```

remains the Embed event envelope kind.

## Preserved Closed Surfaces

- no Ruby API generalization;
- no package code;
- no package release or release-readiness claim;
- no Spark adapter;
- no Rails generator;
- no durable queue/outbox API;
- no shadow candidate implementation;
- no Ledger sidecar requirement;
- no source-of-truth shift to receipts.

## Recommended Next

Hold release-readiness review until a separate route opens it explicitly.

If more docs are needed, keep them narrow and generic: primary-only observed
service, app-local normalizer/redaction/store, and optional receipt sink.
