# Discussion: PROP-036 CLI Exposure Design Pressure v0

Card: S3-R45-C4-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: runtime-pressure
Mode: discussion
Initiator: user
Track: prop036-cli-exposure-design-pressure-v0

Depends on: S3-R45-C3-A delivered

Question:

Does the approved CLI exposure design route introduce any accidental profile
discovery/defaulting, loader-status or runtime-readiness vocabulary leakage, or
runtime authority implication? Is nil/no-flag legacy behavior protected? Does
refusal fire before profiled artifact output? Is the blocker checklist complete
and executable?

Context:
- C1-P1 (Research Agent): Four-option CLI input shape comparison; explicit-path
  option recommended; inline JSON rejected; named artifact lookup not ready;
  implementation held; 10-item blocker list
- C2-P1 (Compiler/Grammar Expert): Dev-contract hardening for R44 NB-1/NB-2;
  finalized `compiler_profile_id_source` shape documented; transport-only wording
  proposed; B7/B8 addressed at dev-contract level; guide/API docs still pending
- C3-A (Architect): Approved `--compiler-profile-source PATH.json` as future CLI
  route; implementation held; 9 named blockers (PROP036-CLI-B1..B9); inline JSON
  and named lookup explicitly rejected
- R44 C3/C4/C5: Ruby facade transport-only exposure PASS 7/7; regression PASS
  88 files / 0 exact hits; pressure verdict proceed-with-notes with NB-1/NB-2/NB-3

---

[Agree]

1. **The approved CLI design route is discovery-free and authority-clean.** The
   `--compiler-profile-source PATH.json` shape requires an explicit, caller-
   provided file path. C3-A's rejection list explicitly closes every discovery/
   defaulting vector: auto-discovery from cwd, auto-discovery from source
   sidecar, ENV/config based profile selection, profile finalization inside CLI,
   inline JSON, and named generated artifact lookup are all listed as rejected
   for the first CLI implementation. C1-P1's future CLI contract formalizes:
   "No flag → legacy_optional → compile as today → manifest.compiler_profile_id
   absent." No discovery surface is introduced by this design.

2. **The refusal-before-artifact guarantee is structurally maintained.** C3-A's
   blocker PROP036-CLI-B5 requires proving "invalid parsed source refuses before
   profiled `.igapp` output." C1-P1's refusal table lists "No `.igapp`" for all
   refusal conditions — missing path, unreadable file, invalid JSON, non-object
   JSON, and invalid source object. The design correctly separates CLI-owned
   file/path/parse refusals (new) from assembler/orchestrator source-object
   refusal (existing), and routes the latter through the already-proven
   `assembler_refused` / `compiler_profile_source.*` path.

3. **Nil/no-flag legacy behavior is explicitly protected at every layer.** C3-A
   states: "No flag: preserve legacy_optional; compile exactly as today;
   manifest.compiler_profile_id absent." PROP036-CLI-B4 requires a proof.
   C1-P1's proposed contract repeats the same guarantee. The four-path nil
   confirmation from C4-P2 (`facade_nil`, `cli_from_c3`, `orchestrator_nil`,
   `production_cli` all report `compiler_profile_id_present=false`) gives
   regression backing to the design intent.

4. **Inline JSON is correctly rejected.** C3-A rejects `--compiler-profile-
   source-json JSON` explicitly. C1-P1's analysis of Option B identifies the
   shell-history/log exposure risk, report redaction complexity, and multi-shell
   quoting test burden as making inline JSON higher-risk than the safety benefit
   warrants. The explicit-path option avoids all of these while remaining
   composable with future generator commands.

5. **NB-1 and NB-2 from R44 are addressed at dev-contract level by C2-P1.**
   C2-P1 documents the finalized `compiler_profile_id_source` object shape with
   all required fields. The transport-only contract wording is now written:
   "the facade forwards the object unchanged; the facade does not validate,
   finalize, discover, infer, load, parse, normalize, or default compiler profile
   sources." These are no longer implicit gaps — they are explicit dev-contract
   language waiting for a guide/API docs destination.

6. **The validation/refusal vocabulary separation is clean.** C2-P1 enumerates
   eleven `compiler_profile_source.*` reason codes owned by the
   assembler/orchestrator. None are loader-status vocabulary (`absent_legacy`,
   `present_verified`, `mismatch`, `malformed`, `missing_required`) or runtime-
   readiness vocabulary (`runtime_ready`, `evaluation_ready`, `gate3_authorized`,
   `runtime_authority`, `production_ready`). The boundary is explicit. PROP036-
   CLI-B6 requires a formal negative-token scan over CLI-written artifacts before
   any implementation is accepted.

7. **The CLI shape cannot imply runtime authority.** The path-based CLI
   translates a file to the same Ruby object the facade already transports. No
   new authority chain is introduced. C2-P1's "What Callers Must Not Assume"
   section explicitly lists: "`compiler_profile_id` grants runtime readiness,"
   Gate 3, Ledger, TBackend, stream/OLAP, BiHistory, production cache, and
   production execution authority. The design boundary matches the runtime-
   pressure concern directly.

---

[Challenge]

1. **B1 ("standalone source artifact contract") has no defined closure
   criterion (runtime-pressure lens).** C3-A requires: "Define or prove a
   standalone finalized `compiler_profile_id_source` JSON artifact contract."
   C1-P1 notes: "That is evidence of shape, not a standalone caller artifact
   contract." But neither C3-A nor C1-P1 specifies what a "standalone caller
   artifact contract" is. Is it a dedicated JSON file produced by a proof run?
   A PROP/spec section with normative language? A codified JSON Schema? A named
   generator command + output file? Without a closure criterion, a future
   implementation authorization card could point to C2-P1's source-shape example
   (lines 83–116) and claim B1 closed — while no standalone artifact file or
   normative spec has ever been produced. Non-blocker for this design decision;
   NB.

2. **B3 ("path/parse refusal wording") is not fully executable as written.**
   C1-P1's refusal table uses informal column labels ("CLI argument refusal,"
   "CLI argument/input refusal") and does not resolve: (a) whether a path/parse
   refusal produces a `CompilationReport` JSON file or only an exit code with
   stderr text, and (b) what exact stdout/stderr message format is required. C1-P1
   explicitly leaves this open: "Should CLI parse/path refusals live as CLI
   argument errors only, or produce `CompilationReport` JSON when `--out` is
   available?" That question is in C1-P1's open questions, unresolved. An
   implementation card cannot meaningfully close B3 without first deciding
   (a) and (b), since the negative-token scan surface (B6) depends on knowing
   which artifacts are written. Non-blocker for design; requires resolution before
   implementation authorization opens. NB.

3. **B7/B8 closure ambiguity: "Add or route" allows self-assertion.** B7 says
   "Add or route public API/guide docs explaining the finalized source object,
   nil behavior, and non-authorized assumptions." B8 says "Add or route explicit
   contract wording so future orchestrator validation widening does not silently
   become public facade policy without review." C2-P1 produced the right wording
   and designates itself as the dev contract. But C2-P1 is a track doc, not a
   public API guide and not a source comment in `lib/igniter_lang.rb`. A future
   implementation card could argue B7 is closed by routing to C2-P1 without a
   guide landing, and B8 is closed by the same. C2-P1's own handoff says:
   "NB-1 closes for dev contract wording, but public API docs still need a
   docs-only card." The blocker criteria should distinguish "dev contract wording
   exists" (C2-P1: done) from "guide/API docs updated" (pending) to prevent
   premature closure claims. Non-blocker for design; NB.

---

[Missing]

1. **B1 closure criterion is absent.** The blocker is well-motivated but its
   required closure is under-specified: "Define or prove a standalone finalized
   `compiler_profile_id_source` JSON artifact contract." A future implementation
   authorization needs a clear statement of what artifact or document satisfies
   B1 — e.g., "a dedicated proof output file at a named path, generated by a
   named command, that a CLI caller can use as `PATH.json`" vs "a normative
   source-shape section in a PROP-036 errata or sub-proposal." Specifying the
   closure form before implementation is requested prevents negotiation at the
   gate.

2. **B3 open question on refusal report shape is unresolved and blocks B6
   scan-surface definition.** C1-P1 asks: should CLI path/parse refusals produce
   a `CompilationReport` JSON? The answer determines whether the B6 negative-
   token scan must include a CLI-produced refusal report or only a stdout/stderr
   check. If the decision is "yes, produce a refusal report," the report must
   avoid the forbidden token list — and that scan surface must be explicitly
   added to B6. If "no," then only the refusal exit path and message format need
   to avoid forbidden vocabulary. The B3→B6 dependency should be made explicit.

3. **B7 and B8 lack a stated completion bar distinguishing dev-contract from
   guide/API doc.** C2-P1 recommends "open a docs-only API guide card." That
   card has not been opened. B7 and B8 should either explicitly require the
   guide card to land before implementation authorization, or explicitly state
   that dev-contract wording in C2-P1 is sufficient for the implementation gate
   and the guide card is post-implementation. As written, B7/B8 are ambiguous
   across the two interpretations.

---

[Sharper Question]

Four of the nine blockers (B1, B3, B7, B8) have underspecified closure
criteria. Before any implementation authorization is requested, should each
blocker carry an explicit closure form — "closed when: [named artifact/doc/proof
exists]" — so that a future Architect review cannot accept self-asserted closure?
Or is the current "define or prove / add or route" language sufficient to prevent
premature gate passage?

---

[Route]

**Verdict: proceed-with-notes.**

The approved CLI design route is sound and correctly bounded. No discovery,
defaulting, loader-status vocabulary, or runtime authority surface is introduced.
The design-level decision (C3-A) does not authorize implementation, so the blocker
list is not being "closed" here — it is a future gate, not a current pass/fail.
The three non-blockers are closure-criterion gaps that should be tightened before
the next implementation authorization is requested.

Blockers: none.

Non-blockers (NB):
- NB-1: B1 ("standalone source artifact contract") has no defined closure
  criterion; a future implementation card could self-assert closure against
  C2-P1's source-shape example without producing a standalone artifact file or
  normative spec
- NB-2: B3 ("path/parse refusal wording") is not fully executable — the
  `CompilationReport` JSON vs stderr-only question from C1-P1 is unresolved and
  must be answered before B3 can be closed; the answer also determines B6 scan
  surface
- NB-3: B7/B8 closure ambiguity — "Add or route" language allows premature
  self-assertion against C2-P1 dev-contract wording; the completion bar should
  distinguish dev-contract-exists (done) from guide/API-docs-updated (pending)

Next recommended surface (single bounded slice):
- Close B1 closure criterion in a design card: specify what "standalone
  `compiler_profile_id_source` caller artifact" means and what command produces it
- Close B3 open question: decide whether CLI path/parse refusal produces a
  `CompilationReport` JSON or exit-code + stderr only
- Open the docs-only guide/API card for `IgniterLang.compile` recommended in
  C2-P1, targeting B7 closure with a clear landing target
- Implementation authorization should remain held until B1/B3/B7/B8 closure
  criteria are resolved
