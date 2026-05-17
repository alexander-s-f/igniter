# Compiler Blueprint Orientation v0

Status: done
Card: `S3-R64-C0-O`
Agent: [Org Architect Supervisor]
Role: org-architect-supervisor
Date: 2026-05-17
Output map: `igniter-lang/docs/org/indexes/compiler-code-and-experiment-map-v0.md`

---

## Summary

Created a compact compiler code and experiment orientation blueprint.

The map separates:

```text
production compiler spine
profile-related proof families
runtime/temporal/audit proof families
authority vs evidence vs implementation vs history
protected surfaces that need Architect approval
```

No compiler/runtime code, language semantics, role profiles, current status,
gates, proposals, specs, or archive movement were changed.

---

## Highest-Value Orientation Improvements

### 1. Production compiler spine is now path-indexed

Future agents can start from:

```text
IgniterLang.compile
  -> CompilerOrchestrator
  -> Parser
  -> Classifier
  -> TypeChecker
  -> SemanticIREmitter.emit_typed
  -> CompilationReport
  -> Assembler
  -> CompilerResult
```

instead of rediscovering the pipeline from scattered tracks.

### 2. PROP-036 and PROP-038 proof families are separated

PROP-036 is mapped as the compiler profile identity and transport lane.

PROP-038 is mapped as the compiler profile contract lane.

This helps avoid mixing release-ready PROP-036 CLI transport with still
authorization-sensitive PROP-038 implementation surfaces.

### 3. Summary/golden read order is explicit

The blueprint tells agents to read summaries and tracks before opening proof
scripts or golden outputs.

This should reduce broad rereads and accidental proof archaeology.

### 4. Authority boundaries are visible

The map explicitly labels `docs/gates`, `docs/proposals`, `docs/cards`, and
`current-status` as authority surfaces, while tracks/discussions/experiments are
evidence.

This protects against treating a proof output as implementation permission.

---

## Missing Map Gaps

```text
1. PROP-036 needs a small code-surface closure table.
2. PROP-038 needs an implementation-surface watch map before future code work.
3. Runtime/Gate 3 proof families are only family-level indexed.
4. Pressure specimens need a language pressure atlas.
5. Platform package bridge surfaces are visible but not yet indexed.
```

---

## Suggested Future Org Slices

Recommended order:

```text
1. prop038-implementation-surface-watch-map-v0
2. prop036-code-surface-closure-map-v0
3. runtime-proof-family-orientation-map-v0
4. language-pressure-specimen-atlas-v0
5. igniter-package-bridge-orientation-map-v0
```

Rationale: PROP-038 is current and authorization-sensitive, so its future code
surface should be watched before broader archaeology.

---

## Return Summary For Architect Supervisor

The org sidecar created a compact compiler blueprint at
`docs/org/indexes/compiler-code-and-experiment-map-v0.md`.

Highest-value outcome: future agents can distinguish production compiler code,
PROP-036 identity/transport proof families, PROP-038 contract proof families,
runtime/audit proof families, and authority/evidence/implementation layers
without broad rereads.

Recommendation: next org slice should map PROP-038 implementation surfaces
before any future implementation authorization, because that is the current
profile lane with the highest drift risk.
