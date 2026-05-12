# Igniter-Lang Line Ups

Status: active compact-memory index
Owner: `[Igniter-Lang Line Up Summarizer]`

Line Ups are compact memory cards for bulky documents, discussions, tracks,
pressure specimens, and historical reports.

They are not canon. They are handles:

```text
short summary -> source path -> disposition -> next route
```

Use Line Ups when a future agent needs to know whether a source is worth reading
without loading the source into context by default.

---

## Read Rule

Default order:

1. `igniter-lang/docs/agent-context.md`
2. `igniter-lang/docs/current-status.md`
3. this index
4. a specific Line Up named by the card
5. source document only if exact evidence is needed

---

## Index

| Line Up | Source | Disposition | Status |
| --- | --- | --- | --- |
| [Stage 1 Close Transition Evidence](stage1-close-transition-evidence.md) | Stage 1 close snapshot README + `stage1-close-candidate-proof-v0.md` | `public_archive` | active memory card |
| [Stage 2 Close Proof Spine](stage2-close-proof-spine.md) | Stage 2 close snapshot README + `stage2-close-candidate-v0.md` | `active_reference` | active memory card |
| [Stage 2 Proof Surface Spine](stage2-proof-surface-spine.md) | Stage 2 History/BiHistory, stream, OLAP, invariant, parser OOF, SemanticIR, and runtime hook proof tracks | `active_reference` | active memory card |
| [Stage 2 Round Map And Status Curation](stage2-round-map-and-status-curation.md) | `stage2-round*-*.md` status/map tracks | `public_archive` | active memory card |
| [Stage 2 Compiler Package Spine](stage2-compiler-package-spine.md) | Stage 2 compiler extraction, orchestrator, package boundary, gem skeleton, and gem-native proof tracks | `active_reference -> public_archive candidate` | active memory card |
| [Stage 2 To Stage 3 Typed Switch Spine](stage2-to-stage3-typed-switch-spine.md) | Stale parity tracks, `orchestrator-emit-typed-switch-v0.md`, stale-header sweep, proposal lifecycle sync, and R6 spec sync tracks | `active_reference` / `public_archive` | active memory card |
| [Old Pre-Gate-3 Discussions Spine](old-discussions-pre-gate3-spine.md) | R2-R12 temporal/typed/runtime/Gate 3 completed discussions | `public_archive after summary` | active memory card |

---

## Disposition Labels

```text
hot_current
active_reference
public_archive
private_archive
external_archive
delete_candidate
do_not_move
needs_archaeology
needs_canon_decision
```

The Line Up Summarizer may recommend these labels. Archive/Form Expert and
History Curator own final fate and movement/link decisions.
