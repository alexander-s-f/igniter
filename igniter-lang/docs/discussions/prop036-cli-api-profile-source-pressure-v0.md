# Discussion: PROP-036 CLI/API Profile Source Pressure v0

Card: S3-R44-C5-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: runtime-pressure
Mode: discussion
Initiator: user
Track: prop036-cli-api-profile-source-pressure-v0

Depends on: S3-R44-C3-I delivered

Question:

Does the new public `compiler_profile_source` Ruby facade surface introduce any
hidden finalization, discovery, defaulting, or loader-status vocabulary leakage?
Does the invalid-source refusal fire before profiled artifact output? Does nil
remain legacy optional across all paths? Do refusal artifacts carry any
runtime-readiness or loader-status exact tokens?

Context:
- C1-P1 (Research Agent): Pre-authorization negative artifact scan — 49 JSON
  files, 0 exact forbidden-token hits; substring hits confirmed as validation
  vocabulary only; PASS 22/22, 19/19, 11/11 across prior proofs
- C2-A (Architect): Authorized Ruby facade exposure only; CLI held; 5-blocker
  CLI exposure checklist defined; nil/legacy optional preserved
- C3-I (Implementation Agent): Added `compiler_profile_source: nil` to
  `IgniterLang.compile`; 7/7 proof checks PASS; 29 JSON files, 0 exact hits
- C4-P2 (Research Agent): Post-C3 regression — 7 checks PASS; expanded scan:
  88 JSON files, 0 exact hits; nil/default confirmed legacy across 4 paths

---

[Agree]

1. **The five required checks all pass cleanly.**

   — *No finalization/discovery/defaulting in the public surface.* C3-I proves
   F6 (`facade_forwards_source_object_unchanged`: PASS) and the non-authorization
   record carries `profile_finalization_in_facade=false` and
   `profile_discovery_or_defaulting=false`. The facade is a pass-through; the
   orchestrator's existing validation is the sole refusal authority.

   — *Invalid source refuses before profiled artifact output.* F4
   (`invalid_source_refuses_before_artifact_output`: PASS) is explicit:
   `status=assembler_refused`, `refused_facade.igapp` is not written. F5 confirms
   the refusal uses the existing `compiler_profile_source.unfinalized` reason path
   — an assembler/orchestrator source-validation term, not a new public API error
   vocabulary or loader-status term.

   — *Nil/default stays legacy optional.* F2 PASS; C4-P2 regression confirms
   this across four independent paths: `facade_nil`, `cli_from_c3`,
   `orchestrator_nil`, and `production_cli` all report
   `compiler_profile_id_present=false`.

   — *No loader-status vocabulary leaks.* Post-C3 scan covers 88 JSON files
   (expanded from 49 in C1-P1 to include the C3 proof output and production CLI
   output). Exact forbidden-token hits: 0. Substring hits are confirmed validation
   vocabulary (`slot_order_mismatch`, `id_digest_mismatch`,
   `runtime_authority_granted=false`, `runtime_authority_forbidden`) — not loader
   status or runtime-readiness fields.

   — *No runtime/dispatch/production readiness implication.* C3-I non-authorization
   record: `runtime_machine_binding=false`, `dispatch_migration=false`,
   `production_behavior=false`. C2-A exclusion list explicitly enumerates
   RuntimeMachine, dispatch migration, Ledger/TBackend, production cache,
   CompatibilityReport profile section, and all other deferred surfaces.

2. **CLI surface is correctly held.** C2-A explains exactly why: a CLI flag
   would immediately require an explicit input shape decision (path vs inline JSON
   vs other), parse/refusal wording, a nil/no-flag legacy proof, and a fresh
   negative artifact scan. Holding CLI until all five are resolved is the right
   discipline. The 5-item CLI exposure blocker list in C2-A is well-specified.
   F7 (`existing_cli_compile_remains_legacy`: PASS) confirms no CLI surface leaked
   from the facade change.

3. **The expansion of the negative scan scope in C4-P2 is the correct post-
   implementation step.** Expanding from 49 files (pre-authorization scan over
   prior proof outputs) to 88 files (adding C3 proof output and `production_cli`
   output) means the scan now covers actual public-API-written artifacts, not just
   pre-authorization experiment outputs. This is a meaningful hardening of the
   vocabulary guard. The `production_compiler_cli` smoke test also confirms the
   production compile path still produces legacy manifests.

4. **The `compiler_profile_source.unfinalized` refusal reason path is clean.**
   The refusal vocabulary stays in the compiler-profile-source validation lane
   (`compiler_profile_source.unfinalized`), not in loader-status (`absent_legacy`,
   `present_verified`, `mismatch`, `malformed`, `missing_required`) or runtime-
   readiness (`runtime_ready`, `evaluation_ready`, `gate3_authorized`,
   `runtime_authority`, `production_ready`) vocabularies. The separation is
   maintained in the refusal artifact itself.

---

[Challenge]

1. **The public facade has no caller-facing documentation for what constitutes a
   valid `compiler_profile_source` (runtime-pressure lens).** The facade signature
   accepts `compiler_profile_source: nil` and the C2-A authorized boundary states:
   "Caller supplies the already-finalized source object/hash accepted by the
   existing assembler/orchestrator validation path." But the public-facing API
   (`IgniterLang.compile`) has no inline documentation or type annotation
   describing what a finalized source looks like, how to construct one, or why
   passing a path string would be refused. The safety contract is correct — invalid
   inputs are refused before artifact output — but a public API caller who does not
   have access to the internal finalization proof documentation will encounter
   `assembler_refused` with `compiler_profile_source.unfinalized` with no clear
   path to constructing a valid source. This is an API ergonomics gap, not a
   safety gap. Non-blocker; NB.

2. **The "transport-only" contract between facade and orchestrator is implicit,
   not declared (runtime-pressure lens).** C3-I states the facade "forwards the
   keyword unchanged to `CompilerOrchestrator#compile`." This means the
   orchestrator's validation is the sole gate for what is accepted. If a future
   card relaxes the orchestrator's validation rules without a separate facade
   review, the facade's transport-only contract automatically inherits that
   relaxation. The facade itself contains no validation logic and carries no
   explicit declaration like `TRANSPORT_ONLY = true` or a contract comment that
   would make the contract machine-visible or reviewable in isolation. A future
   reviewer reading only `lib/igniter_lang.rb` could not determine from that file
   alone whether the facade is intended to be transport-only or whether it was
   simply not yet implemented with validation. Non-blocker; NB.

3. **The 5-item CLI exposure blocker list from C2-A has no tracking item.**
   C2-A names the five requirements that must be met before CLI exposure can be
   authorized: exact input shape, parse/refusal wording, nil/no-flag behavior
   proof, negative vocabulary scan, and pressure review. These are correctly held,
   but they live only in C2-A's gate document. If CLI exposure is proposed in a
   future round without explicitly citing C2-A, a card could be authorized without
   all five being confirmed satisfied. Non-blocker for the current surface; NB for
   future routing.

---

[Missing]

1. **The public `IgniterLang.compile` API documentation for `compiler_profile_source`
   is absent.** The facade keyword exists as of C3-I, but there is no caller-
   facing guidance on how to construct a valid source. The refusal message
   (`compiler_profile_source.unfinalized`) is meaningful to someone who knows the
   internal finalization model, but opaque to an external caller. This gap will
   grow as the feature progresses through loader/report and CompatibilityReport
   surfaces.

2. **C4-P2's open question about CLI exposure model is unresolved.** The question
   "Should CLI exposure reuse the Ruby facade source object model, or define a
   separate file/path input contract with its own refusal vocabulary?" is
   important. The Ruby facade model takes a finalized object — fine for
   programmatic callers but not directly usable for CLI users who naturally supply
   file paths. This question should be answered in a design card before a CLI
   exposure authorization, not during it.

---

[Sharper Question]

The facade forwards `compiler_profile_source` "unchanged" to the orchestrator,
and the orchestrator's existing validation is the sole refusal authority for
invalid sources. If the orchestrator's validation logic is extended or loosened
in a future PROP-036 card, does the transport-only facade automatically inherit
that change — including any new accepted source shapes — without requiring a
separate facade review? Or does the facade's "transport-only" status imply it is
immune to such changes since it adds no validation of its own?

---

[Route]

**Verdict: proceed-with-notes.**

All five required checks pass. Implementation is correctly bounded and the
negative artifact scan is robust (88 files, 0 exact hits). Non-blockers are API
ergonomics and future-routing concerns, not safety or vocabulary-leak issues.

Blockers: none.

Non-blockers (NB):
- NB-1: No caller-facing documentation for valid `compiler_profile_source`
  shape in `IgniterLang.compile`; refusal is the safety net but integration
  ergonomics are poor for external callers unfamiliar with the finalization model
- NB-2: Facade "transport-only" contract is implicit and not machine-visible or
  comment-declared; a future orchestrator validation relaxation would silently
  widen the facade's accepted input without a facade-specific review gate
- NB-3: C2-A's 5-item CLI exposure blocker list has no P-item tracking number;
  risk that a future CLI authorization card does not explicitly re-verify all five
  blockers — recommend assigning a tracking item before CLI exposure is requested

Next recommended surface (single bounded slice):
- CLI exposure — requires answering the file/path vs inline JSON vs facade-object
  model question first; C4-P2 open question should be a design card
- Loader/report `compiler_profile_id` status implementation
- CompatibilityReport compiler-profile section
