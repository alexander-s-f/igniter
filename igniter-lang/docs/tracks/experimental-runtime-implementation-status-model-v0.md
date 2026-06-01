# Experimental Runtime Implementation Status Model v0

Status: accepted / docs-status model
Date: 2026-06-01

Context:
- R223-R228 accepted delegated experimental runtime evidence around IVM,
  `.igapp -> IVM`, FFI, `.igbin`, and AOT file loading.
- Additional playground work now exists in `playgrounds/igniter-runtime/` and
  `playgrounds/igniter-tbackend/`.
- Without a status model, successful playground implementations can be
  misread as official runtime authority.

---

## Decision

Adopt the following implementation hierarchy as the current docs/status model:

```text
Igniter Specification
  -> Official Reference Implementation
  -> Delegated Experimental Runtimes
  -> Alternative Certified Implementations later
```

This model encourages multiple implementations while preserving the authority
of the specification and the official line.

---

## Meaning

### Igniter Specification

The specification is the normative contract.

It defines the language/runtime semantics, required invariants, bytecode or
artifact compatibility expectations when accepted, and portability boundaries
when those are later designed.

Current status:

```text
partially formalized
not yet a complete runtime portability specification
```

### Official Reference Implementation

The official implementation is the mainline implementation path maintained by
the Igniter project.

It may learn from playground implementations, but it is not replaced by them.
Code, APIs, CLI behavior, package surfaces, and public runtime claims enter the
official line only through explicit Main Line authorization.

Current status:

```text
mainline authority remains in igniter-lang controlled surfaces
Reference Runtime support remains closed
igc run implementation remains closed
stable API before v1 remains unpromised
```

### Delegated Experimental Runtimes

Delegated experimental runtimes are alternative implementation attempts that
try to execute or support Igniter semantics under a bounded contract.

They are encouraged. They may be faster, more specialized, more portable, or
more operationally useful than the official line for a given context. Their
purpose is to produce evidence, experience, architectural insight, and possible
future implementation material.

They do not become official authority by passing a proof.

Current status:

```text
accepted as implementation arena
evidence-producing
non-canonical
not public runtime support
not Reference Runtime support
not stable API
not release evidence
```

### Alternative Certified Implementations Later

Alternative certified implementations are a future category for external or
separate implementations that can claim compatibility with a named Igniter
specification and capability profile.

This category is not open yet. It will require a portability and certification
model.

Expected future fields:

```text
spec_version
artifact_format_version
compiled_by
target_runtime
runtime_implementation_id
capability_manifest
feature_set
accepted_by
verified_by
certification_level
```

Current status:

```text
future design only
no certified alternative implementation exists
no portability guarantee exists yet
```

---

## Current Implementation Arena

| Implementation | Current status | Accepted evidence | Not authority for |
| --- | --- | --- | --- |
| `playgrounds/igniter-runtime` IVM Add adapter | Delegated experimental runtime | R225 adapter-fit evidence | Reference Runtime, public runtime, `igc run` |
| `playgrounds/igniter-runtime` branch/comparison adapter | Delegated experimental runtime | R226 branch/comparison hardening evidence | Official runtime, RuntimeSmoke, stable API |
| `playgrounds/igniter-runtime` FFI native runner | Delegated experimental runtime | R227 native acceleration research evidence | Public performance claim, package/CLI surface |
| `playgrounds/igniter-runtime` `.igbin` AOT file loader | Delegated experimental runtime | R228 AOT bytecode file-loading research evidence | Public runtime support, release evidence |
| `playgrounds/igniter-runtime` resident supervisor | Sandbox candidate / needs intake | Not accepted by Main Line yet | Main Line routing, Reference Runtime |
| `playgrounds/igniter-runtime` C temporal backend | Sandbox candidate / needs intake | Not accepted by Main Line yet | Temporal runtime authority, public performance claim |
| `playgrounds/igniter-runtime` ESP32/mesh research | Speculative sandbox research | Not accepted by Main Line yet | Runtime roadmap authority, portability claim |
| `playgrounds/igniter-tbackend` Rust TBackend | Delegated storage/backend candidate / needs intake | Not accepted by Main Line yet | Official TBackend, runtime storage authority, public server claim |

---

## Rules

1. Multiple implementations are encouraged.

```text
More implementations are a strength, not a threat.
```

2. Implementation evidence is not authority.

```text
A proof, benchmark, demo, or playground commit can inform the official line.
It does not authorize mainline code, package, CLI, runtime, report, release, or
public claims by itself.
```

3. Playground implementations compete by contract.

```text
They should state the spec/profile/capability subset they implement.
They should produce proof matrices and failure behavior.
They should record non-claims.
```

4. Official implementation may borrow the best ideas.

```text
Main Line may adopt concepts, invariants, formats, algorithms, or code shapes
from delegated implementations after an explicit authorization decision.
```

5. Portability is a later gate.

```text
Compiled artifacts are not portable merely because they run in one
implementation. Portability requires a future artifact passport and
compatibility/certification boundary.
```

---

## Non-Claims

This document does not authorize:

```text
Reference Runtime implementation
public runtime support
igc run implementation
RuntimeSmoke productization
runtime/report/API/CLI/package changes
stable API before v1
production readiness
Spark integration
release execution
public performance claims
alternative implementation certification
artifact portability guarantees
```

---

## Recommended Next Use

R229 should use this status model as input.

Suggested route framing:

```text
experimental-runtime-implementations-and-portability-boundary-design-v0
```

R229 should decide:

- how experimental executable use names the implementation it runs on;
- whether `igc run` remains design-only or can later route to an authorization
  review;
- how playground runtime candidates are intaken without becoming authority;
- what minimal future artifact passport fields are needed;
- when resident supervisor, C temporal backend, and Rust TBackend need separate
  intake cards.
