# Experimental Loops/Recursion Proof Fixture v0

Card: `S3-R248-C2-I`
Agent: `[Compiler / Grammar Expert]`
Role: `compiler-grammar-expert`
Track: `experimental-loops-recursion-proof-fixture-v0`
Date: 2026-06-04
Status: proof-local fixture packet produced

## Boundary

This track creates proof-local loops/recursion specification fixtures only. The
packet is evidence for future language design and implementation review; it is
not compiler, parser, TypeChecker, SemanticIR, runtime, API, CLI, package,
public runtime, Reference Runtime, stable API, production, Spark, release,
performance, certification, portability, or lab-canon authority.

No `.igapp`, `.igbin`, compiler passport, RuntimeSmoke path, source fixture,
spec chapter, proposal, package, CLI, runtime, or public documentation surface
is created or changed by this card.

## Inputs Read

- `docs/tracks/experimental-loops-recursion-proof-fixture-authorization-review-v0.md`
- `docs/tracks/experimental-loops-recursion-spec-prop037-wording-sync-acceptance-decision-v0.md`
- `docs/spec/ch13-managed-recursion.md`
- `docs/spec/ch8-stdlib.md`
- `docs/language-covenant.md`
- `docs/proposals/PROP-037-external-progression-service-liveness-v0.md`
- `source/loops_and_recursion.ig`
- `playgrounds/igniter-lab/lab-docs/loops-and-recursion-pressure-package.md`
- `playgrounds/igniter-lab/lab-docs/loops-and-recursion-pressure-package-return.md`

## Created Packet

Under `experiments/experimental_loops_recursion_spec_fixtures_v0/`:

- `manifest.json`
- `out/summary.json`
- `fixtures/bounded_local_collection_loop.ig`
- `fixtures/recursion_decreases_fuel.ig`
- `fixtures/service_loop_clock_tick_time.ig`
- `fixtures/source_level_now_prohibited.ig`
- `fixtures/unnamed_loop_robustness.ig`
- `fixtures/break_deferred_unsupported.ig`
- `fixtures/clock_every_not_stream_evidence.md`

## Fixture Map

| Fixture | Evidence role | Authority boundary |
| --- | --- | --- |
| `bounded_local_collection_loop.ig` | Bounded local collection loop surface | Ch13 / future `PROP-039+` input only; not `fold_stream` |
| `recursion_decreases_fuel.ig` | Fuel-bounded recursion surface | Ch13 / future `PROP-039+` input only |
| `service_loop_clock_tick_time.ig` | Service-loop `clock.every` and `tick.time` surface | PROP-037 progression descriptor input only |
| `source_level_now_prohibited.ig` | Source-level `now()` negative fixture | Ch8 `OOF-L6` wording anchor only; no registry authority |
| `clock_every_not_stream_evidence.md` | `clock.every` non-stream evidence note | `clock.every` is not `Stream[DateTime]` |
| `unnamed_loop_robustness.ig` | Postulate 28 unnamed-loop pressure | Future diagnostic pressure only |
| `break_deferred_unsupported.ig` | `break` pressure | Deferred and unsupported by this slice |

## Lab Pressure Disposition

The igniter-lab return packet is useful frontier evidence, especially its split
between bounded stream reductions and unmanaged loop/recursion gaps. This proof
packet does not accept the lab's suggested draft implementation order as canon.
It preserves the accepted R247 wording:

- local loops and recursion remain Ch13 / future `PROP-039+` territory;
- service-loop liveness remains PROP-037 progression descriptor input;
- `tick.time` is explicit event-time binding;
- source-level `now()` remains prohibited through Ch8 `OOF-L6`;
- `clock.every` is not treated as `Stream[DateTime]`;
- OOF-L / OOF-R wording remains non-registry design pressure.

## LRF Matrix

| Check | Result | Evidence |
| --- | --- | --- |
| LRF-1 | PASS | Changed files are limited to the authorized experiment packet and this track doc. |
| LRF-2 | PASS | Fixtures live under `experiments/experimental_loops_recursion_spec_fixtures_v0/`, not `source/**`. |
| LRF-3 | PASS | Bounded local loop maps to Ch13 / future `PROP-039+` input only. |
| LRF-4 | PASS | Recursion / `decreases fuel` maps to Ch13 / future `PROP-039+` input only. |
| LRF-5 | PASS | Service-loop fixture maps to PROP-037 progression descriptor input only. |
| LRF-6 | PASS | `tick.time` is represented as explicit event-time binding. |
| LRF-7 | PASS | Source-level `now()` fixture maps to Ch8 `OOF-L6`. |
| LRF-8 | PASS | `clock.every` is explicitly not `Stream[DateTime]`. |
| LRF-9 | PASS | Postulate 28 unnamed-loop robustness is future diagnostic pressure only. |
| LRF-10 | PASS | `break` remains deferred and unsupported. |
| LRF-11 | PASS | OOF-L / OOF-R wording is not promoted into registry authority. |
| LRF-12 | PASS | Lab behavior remains frontier evidence only. |
| LRF-13 | PASS | Parser, TypeChecker, runtime, API, CLI, package, RuntimeSmoke, CompilerResult, and CompilationReport files remain untouched. |
| LRF-14 | PASS | No `igc run`, `.igbin`, `.igapp`, compiler passport, or RuntimeSmoke path is touched. |
| LRF-15 | PASS | Forbidden wording appears only as explicit non-claims or negative-scan vocabulary. |
| LRF-16 | PASS | Summary packet states no implementation, public, reference, stable, production, performance, certification, or portability claims. |

## Command Matrix

| Command | Result |
| --- | --- |
| `git diff --check -- igniter-lang/experiments/experimental_loops_recursion_spec_fixtures_v0 igniter-lang/docs/tracks/experimental-loops-recursion-proof-fixture-v0.md` | PASS |
| `find igniter-lang/experiments/experimental_loops_recursion_spec_fixtures_v0 -type f \| sort` | PASS |
| `ruby -rjson -e 'JSON.parse(File.read(ARGV.fetch(0)))' igniter-lang/experiments/experimental_loops_recursion_spec_fixtures_v0/out/summary.json` | PASS |

## C4-A Recommendation

Accept the proof-local fixture packet as bounded evidence for future loops and
recursion work. Keep implementation, parser, TypeChecker, SemanticIR, runtime,
API, CLI, package, `.igapp`, `.igbin`, compiler passport, RuntimeSmoke, public
runtime, Reference Runtime, stable API, production, Spark, release, performance,
certification, portability, and lab-canon claims closed.

Recommended next route: `C3-X` pressure review followed by `C4-A` acceptance or
redirect. If accepted, a later card may open a narrowly scoped `PROP-039+`
authoring/design route for managed local loops and recursion; that later route
should still avoid implementation authority unless separately approved.
