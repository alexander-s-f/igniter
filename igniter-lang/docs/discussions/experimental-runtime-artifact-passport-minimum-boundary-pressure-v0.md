# Experimental Runtime Artifact Passport Minimum Boundary Pressure v0

Card: S3-R231-C3-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: architect-supervisor
Track: experimental-runtime-artifact-passport-minimum-boundary-pressure-v0

Depends on:
- S3-R231-C1-D (design output)
- S3-R231-C2-P1 (facts packet)
- S3-R230-C4-A (parent acceptance decision)
- S3-R229-C4-A (portability boundary decision)
- `playgrounds/igniter-runtime/out/resident_supervisor_candidate_intake/summary.json`

Date: 2026-06-01

---

## Verdict

**CONDITIONAL**

The minimum boundary is sound. C4-A may accept it. Three watchpoints must
travel forward into the manifest proof step; none are blockers here.

---

## Pressure Matrix

| Risk Axis | Finding | Severity |
|---|---|---|
| Authority drift | No implementation authority created. Design-only stance is explicit and consistent. | PASS |
| Portability guarantee vocabulary | C1-D correct; C2-P1 diagram and executive summary use elevated "Portability Passport" / "formal … Portability Boundary" language. | WATCH |
| igc run premature pressure | Correctly sequenced: passport design → manifest proof → then igc run design-only (held). output_contract "required before igc run design" is informational, not authorization. | PASS |
| Runtime/backend/app-consumer conflation | surface_dimension + three separate id fields prevent conflation. Separation is explicit in C1-D. | PASS |
| Rust TBackend as executable runtime | C1-D maps it temporal_backend, not executable_runtime. C2-P1 Q4 confirms. summary.json temporal_backend_kind is "none / excluded" for the resident supervisor. | PASS |
| acts-as-tbackend as public API support | C1-D correctly maps it app_consumer_bridge. C2-P1 Q5 confirms. No public Rails or API authority created. | PASS |
| Performance wording | C1-D requires "informational research-signal / proof-local timing only" and explicit "rough" / "informational-only" inline for ratios. C2-P1 flags Rust TBackend README claims (25,749 req/s, 4.78x) correctly. | PASS |
| igc run remains closed to implementation | Explicit throughout C1-D and parent decisions. Route Options table correctly holds igc run design-only until after one manifest proof. | PASS |
| Public/stable/production/Spark/release claims | All listed as closed in C1-D, C4-A, and non_claims block. summary.json non_claims: PASS. | PASS |
| Substrate gap (FFI vs TCP frame) | C2-P1 Risk 2 raises this. C1-D does not have an explicit substrate field; addresses it structurally through backend_implementation_id and surface_dimension separation. | WATCH |
| artifact_kind naming consistency | C1-D uses `igbin_file`; C2-P1 Q3 recommends `igbin_aot_binary`. Minor discrepancy between facts packet and design. | WATCH |
| runtime_implementation_id as evidence metadata | Explicitly bound in C4-A and maintained throughout C1-D. Evidence-only interpretation is not weakened. | PASS |
| Capability matching strength | 10 matching dimensions are sufficient to prevent accidental execution at the proof-manifest step. Not over-specified as certification. | PASS |

---

## Detailed Findings

### F1 — Authority Drift: PASS

C1-D is unambiguous: "this card defines the boundary with no implementation
authority." The candidate next boundary (S3-R232-C1-A) is correctly labeled
as an authorization review, not an implementation card. The write scope for
that future card is confined to `igniter-lang/experiments/...` (not mainline
lib, bin, gemspec, or public docs). The design-to-authorization-review-to-proof
pipeline has no gaps that would accidentally promote a design output into
implementation authority.

### F2 — Portability Vocabulary: WATCH

C1-D correctly names the passport as "evidence/compatibility metadata boundary"
and explicitly denies: portability guarantee, certification, runtime support,
stable API. The non-claims block is comprehensive.

C2-P1 introduces two instances of elevated framing that are inconsistent with
C1-D's boundary:

1. Executive summary (§1): "formal **Artifact Passport Portability Boundary**"
   — "formal" overstates the boundary status; "Portability Boundary" with
   capital letters implies a more durable guarantee than the design intends.

2. Diagram label (§2): box titled "PORTABILITY PASSPORT" with subtitle "Future
   Metadata envelope establishing: Target profile capability matches /
   Cryptographic verification digests" — no non-claim wording inside the
   diagram; a future reader or agent scanning only the diagram could misread
   this as a portability claim.

Because C2-P1 is a facts packet (input evidence, not design authority), these
instances do not override C1-D's boundary. But they create a vocabulary leak
risk in downstream docs that cite C2-P1. The manifest proof step (S3-R232)
should use C1-D vocabulary only.

### F3 — igc run Pressure: PASS

The sequencing is correct and explicit:

```text
C1-D design (current) →
S3-R232-C1-A manifest proof authorization review →
one proof-local manifest exists →
then igc run design-only route may open
```

The `output_contract` field being "required before igc run design" is a forward
prerequisite note, not an authorization signal. No igc run implementation
pressure is introduced.

### F4 — Runtime/Backend/Consumer Separation: PASS

The passport schema separates three orthogonal identity fields:
`runtime_implementation_id`, `backend_implementation_id`,
`consumer_surface_id`. The `surface_dimension` field forces explicit
classification of each artifact. C1-D's candidate surface implications section
explicitly maps all four known surfaces (IVM/RSUP, Rust TBackend,
acts-as-tbackend, todolist) to their correct dimension.

The summary.json `temporal_backend_kind: "none / excluded"` correctly shows
the resident supervisor does not conflate runtime and backend concerns.

### F5 — Substrate Gap: WATCH

C2-P1 Risk 2 correctly identifies that FFI direct-memory pointers and TCP
socket frames are two distinct execution substrates. C1-D addresses this
through separate `backend_implementation_id` and `surface_dimension` fields
but does not include an explicit `substrate` field to record, for example,
`c_memory_history` versus `tcp_socket_framed`.

This is not a blocker at the design boundary step — the passport specifies
what will be required, and a single resident-supervisor proof artifact would
not cross both substrates. However, when Rust TBackend candidate intake opens,
the passport schema will need a substrate discriminator to prevent a runtime
from loading artifacts backed by an incompatible substrate. The manifest proof
step (S3-R232) should note this as a future field candidate rather than allow
it to remain implicit.

### F6 — artifact_kind Naming Consistency: WATCH

C1-D uses `igbin_file` as the artifact_kind value for AOT bytecode.
C2-P1 Q3 recommends `igbin_aot_binary` as a more descriptive tag.

Both are internally consistent within their own documents, but the discrepancy
means the first proof-local passport manifest could produce either string,
creating a naming fork at the earliest evidence point. The manifest proof step
should canonicalize one value before any artifact-reading logic depends on it.

Recommended canonical value: `igbin_aot_binary` (C2-P1's recommendation is
more self-documenting and less ambiguous than `igbin_file`, which could also
describe a non-AOT binary).

### F7 — Performance Wording: PASS with note

C1-D requires inline qualifiers for ratios. The summary.json records timing
as `timing_seconds` (raw values, no claim ratios) and marks
`performance_policy.status: PASS` with `public_speedup_claim: none`. This is
correct.

C2-P1 correctly identifies the Rust TBackend README claims as risk surfaces
(25,749 req/s, 4.78x). These are outside the C1-D design boundary (which is
read-only), so no action is required here. The README must be remediated before
any Rust TBackend candidate intake proceeds.

---

## Blocking Missing Passport Fields

None. The C1-D field matrix is complete for the minimum experimental boundary.

The `substrate` concept is a future-need that should be raised in the manifest
proof step, not a blocker on accepting the current design.

---

## Wording That Must Be Forbidden in Downstream Artifacts

The following phrases must not appear in C4-A's acceptance record, the manifest
proof track, or any track that cites S3-R231 as authority:

```text
"formal Artifact Passport Portability Boundary"   (→ use "minimum artifact passport boundary")
"PORTABILITY PASSPORT"                            (→ use "artifact passport (evidence/compatibility metadata)")
"cryptographic signature chains"                  (→ use "digest chain" or "artifact digest fields")
"portable artifact"                               (→ forbidden per C1-D non-claims)
"certified alternative implementation"            (→ forbidden per C1-D non-claims)
```

Performance ratios (e.g. 15.6x, 4.78x, 1.6x) must carry inline
"informational-only / rough" qualifier; a standalone caution block is
insufficient per C4-A AN-1.

---

## Answers to Explicit Pressure Questions

**Whether minimum passport fields are enough to prevent drift:**
Yes, with the watchpoints noted. The field matrix is comprehensive for the
experimental boundary. Substrate separation and artifact_kind canonicalization
should be resolved at the manifest proof step, not deferred further.

**Whether passport vocabulary accidentally creates portability guarantees:**
C1-D's vocabulary does not. C2-P1's "Portability Passport" diagram label and
"formal … Portability Boundary" executive summary wording create a minor leak
risk in downstream citations. C4-A should note this in its acceptance record
and prohibit that vocabulary in the manifest proof step.

**Whether runtime_implementation_id is still evidence metadata only:**
Yes. The binding established in S3-R229-C4-A and confirmed in S3-R230-C4-A is
maintained without weakening throughout C1-D and summary.json.

**Whether capability matching is too weak or over-specified:**
Matching dimensions are appropriate: 10 fields, concrete enough to prevent
accidental cross-runtime loading, not broad enough to become certification.
No over-specification found.

**Whether Rust TBackend is being confused with an executable runtime:**
No. C1-D explicitly maps it temporal_backend. Summary.json records
`temporal_backend_kind: "none / excluded"` for the resident supervisor,
correctly separating the concerns.

**Whether acts-as-tbackend is being confused with public API support:**
No. C1-D maps it app_consumer_bridge and explicitly states it "does not
create public Rails/API support."

**Whether performance wording remains non-public:**
Yes. C1-D requires inline qualifiers. Summary.json confirms no public speedup
claim. Rust TBackend README is correctly flagged as a future remediation item.

**Whether igc run remains closed to implementation:**
Yes. Sequenced correctly behind manifest proof authorization review.

**Whether public/stable/production/Spark/release claims remain closed:**
Yes. All remain closed per C1-D, C4-A, and S3-R229-C4-A.

---

## C4-A Recommendation

**Accept the minimum artifact passport boundary.**

Accept with the following carry-forward notes that must appear in C4-A's
acceptance record:

1. C2-P1 "Portability Passport" / "formal Portability Boundary" vocabulary is
   not accepted as canonical. C1-D vocabulary governs. Manifest proof step
   must use C1-D wording exclusively.

2. artifact_kind for AOT bytecode should be canonicalized as `igbin_aot_binary`
   (not `igbin_file`) before the first passport manifest is written.

3. Substrate discriminator (`c_memory_history` vs `tcp_socket_framed`) is a
   known future-field candidate. Manifest proof step should note it as
   deferred-required for Rust TBackend intake, not silently omit it.

Then open the manifest proof authorization review (S3-R232-C1-A) as designed.

---

[Agree]
- Minimum field matrix is complete and appropriate for experimental boundary.
- surface_dimension + three separate id fields prevent runtime/backend/consumer
  conflation.
- igc run sequencing is correct: held behind manifest proof.
- Non-claim block in C1-D is comprehensive and matches prior binding decisions.
- runtime_implementation_id remains evidence metadata throughout.
- Performance wording discipline is explicitly required and correctly scoped.

[Challenge]
- C2-P1's "Portability Passport" diagram label and "formal … Portability
  Boundary" executive summary language are elevated above what C1-D establishes.
  C2-P1 is a facts input, not design authority — but downstream citations of
  C2-P1 will encounter this vocabulary. The acceptance record should explicitly
  name C1-D vocabulary as canonical.
- The artifact_kind naming split (`igbin_file` vs `igbin_aot_binary`) must be
  resolved before any artifact-reading logic is written, not left to the first
  manifest proof to decide informally.

[Missing]
- Explicit substrate discriminator field (or explicit decision that it is
  deferred to Rust TBackend intake). C1-D's current fields are sufficient for
  resident supervisor only; the substrate gap will become a real ambiguity when
  Rust TBackend intake opens.
- Prohibition language for C2-P1 elevated vocabulary in the manifest proof
  track scope.

[Sharper Question]
- Before the manifest proof step (S3-R232-C1-A): should the authorization
  review include a vocabulary checkpoint that explicitly forbids C2-P1's
  "Portability Passport" wording from appearing in any experiments/ artifact
  or track output?

[Route]
- track: accept boundary → open S3-R232-C1-A manifest proof authorization
  review, carrying the three watchpoints above into its scope constraints.
