# Experimental igc run Design-Only Boundary Pressure v0

Card: S3-R233-C3-X
Skill: IDD Agent Protocol
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Track: experimental-igc-run-design-only-boundary-pressure-v0
Route: REVIEW
Status: complete
Date: 2026-06-02

Depends on:
- S3-R233-C1-D
- S3-R233-C2-P1

---

## Inputs Read

- `igniter-lang/docs/tracks/experimental-igc-run-design-only-boundary-v0.md` (C1-D)
- `igniter-lang/docs/tracks/experimental-igc-run-current-surface-and-lab-signals-facts-v0.md` (C2-P1)
- `igniter-lang/docs/tracks/experimental-runtime-artifact-passport-manifest-proof-acceptance-decision-v0.md` (R232-C4-A)
- `igniter-lang/docs/tracks/stage3-round232-status-curation-v0.md`

---

## Compact Risk Table

| Risk | Assessment | C1-D / C2-P1 fence | Residual |
| --- | --- | --- | --- |
| Design card authorizes implementation | Zero | "This document does not authorize implementation"; next card is C1-A authorization review only | Zero |
| `igc run` becomes stable CLI/API promise | Very low | `--experimental` mandatory; `stable_api: false` in result packet; selector "may be removed before v1"; failure vocabulary is local-experimental | Very low |
| Passport treated as portability/certification authority | Very low | C1-D: "evidence/compatibility metadata only"; fail-closed on missing/mismatched passport; compiler passport emission remains closed | Very low |
| Delegated runtime selector implies Reference Runtime | Very low | Rejected selector list: `reference`, `official`, `production`, `stable`; selector labeled non-canonical / not package identity / not Reference Runtime identity | Very low |
| `igniter-tbackend` promoted to runtime authority | Zero | C1-D: backend/substrate vocabulary; "lab-only / unaccepted for Main Line runtime authority"; C2-P1 confirms Cargo.toml name = `igniter_tbackend_playground`; not in any igc run scope | Zero |
| benchmark-app creates public performance evidence | Zero | C2-P1: benchmark.rb targets TBackend TCP server, NOT igc run or language runtime; no result file emitted; not referenced by any public track/doc | Zero |
| RuntimeSmoke F-1 `"production-compiler-cli"` leaks into run result | Low | C2-P1 W-2: internal constant, not exposed; C1-D closes RuntimeSmoke productization; not invoked by CLI today; see AN-1 | Low — see AN-1 |
| `igniter-tbackend` F-2 `"production-grade"` / `"SparkCRM"` leaks | Low | C2-P1 W-3: lab README only; no mainline propagation; Cargo.toml name suffix `_playground`; see AN-2 | Low — see AN-2 |
| `.igbin` execution included in Slice 0 | Very low | C1-D: `.igbin` explicitly held; deferred output_contract gate is binding; C2-P1 confirms gap is REAL and LOCATED | Very low |
| Result packet conflicts with CompilerResult / CompilationReport | Very low | C1-D: result packet MUST NOT be CompilerResult/CompilationReport/CompatibilityReport/receipt sidecar; separate `kind: experimental_igc_run_v0_result` | Very low |
| Q-2 runtime selector resolution ambiguity | Medium | C2-P1 Q-2: AOT and resident passports both use same `runtime_implementation_id`; C1-D selector `delegated-experimental:ivm-proof` not mapped to specific substrate; see AN-3 | Medium — see AN-3 |
| RuntimeSmoke / Reference Runtime / Spark / production / stable API claims | Zero | Boundary matrix covers all; C2-P1 confirmed RuntimeSmoke is proof-backed and package-unavailable; all closed | Zero |

---

## Pressure Checks

**1. Design-only stayed design-only.**
C1-D explicitly names its status as `design-ready / implementation-authorization-review-next`. The word "design" appears in the card status, and the recommended next card is explicitly C1-A (authorization review), not C2-I (implementation). No code was written. PASS.

**2. Implementation authorization timing is correctly bounded.**
The proposed sequencing is: design (this card) → authorization review (C1-A) → implementation (C2-I). The authorization review is the gate before implementation, not C4-A. C4-A's role is to accept the design and open the authorization review, not to authorize implementation itself. Correctly bounded.

**3. `igc run` wording risk.**
The design contains several layers of wording protection: `--experimental` mandatory flag, `stable_api: false` in result packet, `pre_v1: true` in result packet, runtime selector explicitly "not stable API," failure vocabulary is local-experimental only. This is stronger wording discipline than prior rounds. The three-runtime model distinction is present in the command vocabulary section. Safe.

**4. Passport as metadata vs authority.**
C1-D correctly positions the passport as an enabler for experimental use, not a certification or portability guarantee. The fail-closed logic (missing passport → blocked, digest mismatch → blocked, deferred output_contract → blocked) treats the passport as a validity gate, not a capability grant. Safe.

**5. `igniter-tbackend` classification.**
C2-P1 provides the most thorough classification yet: Cargo.toml name = `igniter_tbackend_playground`, all packs are opt-in and lab-only, benchmark.rb targets TBackend TCP not igc run, no surface appears in mainline. C1-D correctly classifies it as backend/substrate vocabulary. The observation in C2-P1 §7 that Auth/Query/Mcp packs "do not create public API authority" is well-reasoned with specific evidence. Safe.

**6. Benchmark-app signals.**
C2-P1 §8 is the strongest fact in the packet: benchmark.rb targets TBackend TCP server. It does NOT measure igc run, .igapp execution, compiler throughput, or language interpreter throughput. No result file is produced. No public track references it. This completely closes the performance-claim risk for benchmark-app. Safe.

---

## Market-Window vs Governance Balance

**Strongest market-window argument for moving faster:**

The alpha package (`0.1.0.alpha.1`) is published and installable. A developer today can run `igc compile add.ig --out Add.igapp` and produce a correct artifact. But they cannot execute it through any CLI command. The executable evidence exists (R223, sum=42). The passport evidence exists (R232, 16/16 PASS). `igc run` is the bridge between "I compiled something" and "I can try it." Every round without that bridge increases the gap between what Igniter promises and what a developer can actually observe. The design is bounded, well-labeled, and has strong fail-closed behavior. The authorization review gate is appropriate friction — it should be lightweight and fast.

**Strongest governance argument for holding implementation:**

Q-2 (runtime selector resolution) is unresolved: the command vocabulary specifies `delegated-experimental:ivm-proof` as the selector, but C2-P1 notes the AOT and resident passports use the same `runtime_implementation_id`. The authorization review must explicitly define what `delegated-experimental:ivm-proof` resolves to as an adapter path. If this is left implicit, an implementation could connect to the wrong substrate or silently expand scope. Q-1 (argument parsing architecture) also needs to be answered in C1-A, not discovered during implementation. These are not blockers for accepting the design, but they are prerequisites for a clean authorization review.

---

## Exact Overclaim Phrases to Forbid

Any future implementation track, release note, README, or public-facing document must not include:

```text
"igc run is available"         (without --experimental qualifier)
"stable run command"
"stable runtime API"
"production runtime support from igc run"
"igc run Reference Runtime path"
"igniter-tbackend integration via igc run"
"benchmark results for igc run performance"
"production-compiler-cli" in any machine-readable run result
"SparkCRM" in any igc run documentation or result packet
"igc run certified output"
"portable artifact verified by igc run"
```

Allowed alternatives:

```text
"experimental pre-v1 igc run command (--experimental required)"
"delegated experimental runtime invocation (non-canonical / evidence-only)"
"informational proof-local run result (not public runtime support)"
"research-signal run evidence (not stable API / not production)"
```

---

## Non-Blocking Acceptance Notes

**AN-1 — RuntimeSmoke F-1: `"production-compiler-cli"` label must not appear in run result output.**

C2-P1 W-2 identifies `DEFAULT_MACHINE_ID = "runtime-machine/production-compiler-cli"` in runtime_smoke.rb. RuntimeSmoke is closed for productization and is not invoked by the CLI today. The risk is: if a future Slice 0 implementation internally loads RuntimeSmoke in any code path, these constants could appear in machine-readable run result output, creating an implicit `"production"` claim.

The authorization review (C1-A) for Slice 0 must explicitly close RuntimeSmoke from any igc run code path. The forbidden phrase scan in the Slice 0 proof matrix should include `"production-compiler-cli"` as a forbidden string in run result output.

**AN-2 — TBackend F-2: `"production-grade"` / `"SparkCRM"` must not propagate.**

C2-P1 W-3 identifies these labels in `igniter-tbackend/README.md`. Currently bounded to the lab. If any future card references `igniter-tbackend` in a public track, release doc, or feature announcement, a wording audit of the README must precede that reference.

**AN-3 — Q-2: runtime selector resolution must be explicit in the authorization review.**

C1-D proposes `--runtime delegated-experimental:ivm-proof` as the Slice 0 selector. C2-P1 Q-2 notes that the AOT and resident passports both use `runtime_implementation_id: igniter.delegated.experimental.ivm.c_resident` — a single label for both substrates. The authorization review C1-A must define:
- what `delegated-experimental:ivm-proof` resolves to as a concrete adapter path;
- whether it uses the R223 quickstart harness, a new experimental adapter, or the resident supervisor path;
- whether it checks `execution_substrate` from the passport to select a substrate.

Leaving this implicit would let the implementation choose freely, which risks scope creep.

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| Accept / conditional accept / hold / redirect? | PASS — accept the design. Open S3-R234-C1-A as next. Carry forward AN-1/AN-2/AN-3 into the authorization review scope. |
| Strongest market-window argument for moving faster? | Alpha is published but has no executable CLI path. R223+R232 evidence is ready. The authorization review should be narrow and fast. |
| Strongest governance argument for holding implementation? | Q-2 (selector resolution) is open; if left implicit it risks substrate scope creep. Must be answered in C1-A. |
| Exact overclaim phrases to forbid? | Listed above. Key: "stable run command," "production runtime," "Reference Runtime," "igc run benchmark results," and "production-compiler-cli" in run result output. |
| C4-A blocker list? | None. Design is clean. Three acceptance notes for the authorization review. |

---

## Verdict

```text
PASS — accept design

C1-D igc run design-only boundary: accept
C2-P1 current surface and lab signals facts: accept as accurate facts basis
C4-A HOLD: release; proceed to final acceptance and open authorization review

No blockers.
3 acceptance notes for C1-A scope (AN-1, AN-2, AN-3).
```

---

## Recommendation for S3-R233-C4-A

```text
Card: S3-R233-C4-A (final acceptance)
Route: UPDATE
Mode: accept design / open authorization review next

Accept:
- C1-D experimental igc run design-only boundary
- C2-P1 current surface and lab signals facts as accurate facts basis
- Slice 0 boundary: .igapp only / explicit --passport / explicit --runtime /
  mandatory --experimental / machine-readable result packet

Open next:
  Card: S3-R234-C1-A
  Track: experimental-igc-run-slice0-implementation-authorization-review-v0
  Mode: bounded implementation authorization review (not implementation)

C1-A scope must include:
  AN-1: RuntimeSmoke closed in all igc run code paths;
        "production-compiler-cli" added to forbidden phrase scan in
        Slice 0 proof matrix
  AN-2: TBackend README wording audit gate before any future public reference
  AN-3: explicit definition of what "delegated-experimental:ivm-proof"
        selector resolves to as a concrete adapter path (Q-2 answer required)

Keep closed:
  - igc run implementation (until C1-A authorizes it)
  - .igbin Slice 0 input (deferred output_contract is a design gate)
  - compiler passport emission
  - RuntimeSmoke productization
  - igniter-tbackend as igc run surface
  - benchmark-app as performance evidence
  - Reference Runtime / public runtime / stable API / production / Spark /
    release claims
```
