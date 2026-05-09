# Track: Phase 1 Addendum Content Address Ref v0

Card: S3-R22-C2-P
Agent: `[Igniter-Lang Bridge Agent]`
Role: `bridge-agent`
Track: `phase1-addendum-content-address-ref-v0`
Status: done
Date: 2026-05-09

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Compiler/Grammar Expert]`

---

## Purpose

Define proof-local content-addressed references for signed addendum evidence so
callers do not rely on path-only thinking.

This track does not mutate the signed addendum.

Sources read:

- `igniter-lang/docs/gates/gate3-live-read-decision-addendum-v0.md`
- `igniter-lang/docs/tracks/gate3-authority-registry-shape-v0.md`
- `igniter-lang/experiments/gate3_authority_registry_shape/gate3_authority_registry_shape.rb`

---

## Reference Shape

[D] A signed addendum reference must carry both a human-readable path and a
content-addressed identity.

Proof-local shape:

```json
{
  "document_path": "igniter-lang/docs/gates/gate3-live-read-decision-addendum-v0.md",
  "git_commit": "workspace-current|<commit-sha>",
  "content_sha256": "sha256:<document-bytes>",
  "status": "signed-approved-restricted-phase1-live-read",
  "signed_on": "2026-05-09",
  "authority_ref": "architect-supervisor://igniter-lang/gates/gate3/runtime-temporal-executor/restricted-history-valid-time-v0/2026-05-09"
}
```

Invocation/audit envelope:

```json
{
  "kind": "phase1_signed_addendum_invocation_evidence",
  "format_version": "0.1.0",
  "human_reference": {
    "document_path": "igniter-lang/docs/gates/gate3-live-read-decision-addendum-v0.md"
  },
  "content_addressed_identity": {
    "document_path": "igniter-lang/docs/gates/gate3-live-read-decision-addendum-v0.md",
    "git_commit": "workspace-current|<commit-sha>",
    "content_sha256": "sha256:<document-bytes>",
    "status": "signed-approved-restricted-phase1-live-read",
    "signed_on": "2026-05-09",
    "authority_ref": "architect-supervisor://igniter-lang/gates/gate3/runtime-temporal-executor/restricted-history-valid-time-v0/2026-05-09"
  },
  "requested_gate3_authorized": true
}
```

`git_commit` is invocation metadata. In this proof it may be supplied through
the `GIT_COMMIT` environment variable and defaults to `workspace-current`; a
future CI/registry path should supply the actual commit SHA.

---

## Compliance Rule

[D] A caller reference is compliant only when:

- `human_reference.document_path` matches the signed addendum path;
- `content_addressed_identity.document_path` matches the human path;
- `git_commit` is present;
- `content_sha256` matches the current document bytes;
- `status` is `signed-approved-restricted-phase1-live-read`;
- `signed_on` is `2026-05-09`;
- `authority_ref` matches the Phase 1 authority URI.

Failure of any condition is non-compliant and must not be used as evidence for
passing `gate3_authorized: true`.

---

## Proof Fixture

Added:

```text
igniter-lang/experiments/phase1_addendum_content_address_ref/
  phase1_addendum_content_address_ref.rb
  out/phase1_addendum_content_address_ref_summary.json
```

The fixture computes `content_sha256` from the signed addendum bytes, parses the
signed status/date/authority ref, and verifies the invocation envelope.

Negative cases:

| Case | Expected result |
|---|---|
| `path_exists_hash_mismatch` | blocked with `addendum_ref.content_hash_mismatch` |
| `status_not_signed_approved` | blocked with `addendum_ref.status_not_signed_approved` |
| `authority_ref_mismatch` | blocked with `addendum_ref.authority_ref_mismatch` |

It also proves a positive envelope carries both the path and content identity.

---

## Proof Output

Command:

```bash
ruby igniter-lang/experiments/phase1_addendum_content_address_ref/phase1_addendum_content_address_ref.rb
```

Observed output:

```text
PASS phase1_addendum_content_address_ref
  valid_reference.ok: ok
  valid_reference.carries_human_path: ok
  valid_reference.carries_content_identity: ok
  hash_mismatch.blocks: ok
  status_not_signed.blocks: ok
  authority_ref_mismatch.blocks: ok
  human_and_content_case.ok: ok
  no_case_requires_production_registry: ok
  no_case_requires_production_signing: ok
summary: igniter-lang/experiments/phase1_addendum_content_address_ref/out/phase1_addendum_content_address_ref_summary.json
```

---

## Production Registry Recommendation

[R] A future production registry should reference signed decisions by both
locator and identity:

- `document_path` or canonical decision URL for humans;
- immutable commit or release artifact ref;
- `content_sha256`;
- status and signed date;
- authority ref;
- supersession/revocation fields from `gate3-authority-registry-shape-v0`;
- optional signature metadata only after a separate production-signing track.

Do not make path existence sufficient. A path can still exist after content
drift, status regression, or authority mismatch.

---

## Non-Authorization

This track does not require or authorize:

- production registry;
- production signing;
- production key management;
- executor/lib changes;
- signed addendum mutation;
- Phase 2 Ledger adapter;
- Ledger package binding;
- durable audit.

It only defines and proves proof-local content-addressed addendum references.

---

## Handoff

```text
[Igniter-Lang Bridge Agent]
Track: igniter-lang/phase1-addendum-content-address-ref-v0
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert

[D] Decisions:
- Signed addendum evidence must carry human path and content-addressed identity.
- Path-only evidence is insufficient.
- Hash mismatch, unsigned status, or authority_ref mismatch are non-compliant.

[R] Recommendations:
- Future production registry should store document locator plus content_sha256, commit/release ref, signed status/date, authority_ref, and revocation/supersession fields.
- Keep production signing as a separate future track.

[S] Signals:
- Proof fixture verifies positive envelope and requested negative cases.
- No production registry or production signing is required.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/phase1_addendum_content_address_ref/phase1_addendum_content_address_ref.rb
- ruby -c igniter-lang/experiments/phase1_addendum_content_address_ref/phase1_addendum_content_address_ref.rb

[Files] Changed:
- igniter-lang/docs/tracks/phase1-addendum-content-address-ref-v0.md
- igniter-lang/experiments/phase1_addendum_content_address_ref/phase1_addendum_content_address_ref.rb
- igniter-lang/experiments/phase1_addendum_content_address_ref/out/phase1_addendum_content_address_ref_summary.json

[Q] Open Questions:
- Should a future production registry use git commit SHA, release artifact digest, or both as the immutable decision anchor?

[X] Rejected:
- No production registry, production signing, key management, executor changes, addendum mutation, Phase 2 Ledger adapter, or Ledger package binding.

[Next] Proposed next slice:
- Fold this reference shape into a future durable `gate3-authority-registry-v1` track.
```
