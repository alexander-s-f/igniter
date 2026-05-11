# Track: Mundane Application Pressure Analysis v0

Card: S3-R35-SIDECAR
Agent: [Architect Supervisor / Codex]
Role: architect-supervisor
Track: mundane-application-pressure-analysis-v0
Status: routed-pressure-specimen
Date: 2026-05-11

---

## Goal

Prevent the external mundane application pressure specimens from becoming
zombie experiments by assigning them an explicit status, route, and extraction
model.

Source directory:

```text
experiments/pressure-specimens/mundane-application-pressure-v0/
```

Source context:

```text
The specimens were authored by an external/blind agent that did not have
repository or implementation access. The agent received only language-facing
material such as the Covenant, specification excerpts, and selected proposals.
```

Therefore these files are **not canon** and **not implementation evidence**.
They are pressure specimens: UX/design probes showing what a competent external
agent expects Igniter-Lang to express.

---

## Disposition

```text
Status: active pressure specimen
Authority: non-canonical
Implementation authority: none
Parser authority: none
Runtime authority: none
Route: extract signals -> classify gaps -> promote only through PROP/spec tracks
```

The specimens should remain readable and preserved until their signals are
extracted. They should not be silently deleted, silently promoted, or treated as
accepted syntax.

---

## Specimens Reviewed

| File | Pressure Surface |
|------|------------------|
| `igniter-webhook-ingestor-v1.ig` | JSON webhook -> validation -> domain record -> receipt |
| `igniter-http-json-client-v1.ig` | HTTP request/response, retry config, typed errors |
| `igniter-csv-importer-v1.ig` | CSV parsing, validation, batch import |
| `igniter-billing-calculation-v1.ig` | Decimal/Money arithmetic, idempotency, persistence |
| `igniter-string-library-v1..v4.ig` | String stdlib, spans, Unicode, parser combinators |
| `igniter-file-io-v1.ig` | File read/write/mmap/stream capability boundary |
| `igniter-parser-combinators-v1.ig` | Generic parser combinators and forms |
| `igniter-lexer-v1.ig` | Lexer built from parser combinators, spans, errors |

---

## Strong Signals

[S] Igniter-Lang is legible as a general-purpose application language, not only
as a temporal/audit research language.

[S] External readers naturally separate:

```text
parse / validate / calculate -> CORE
http / file / db / write      -> ESCAPE or privileged capability
```

[S] A practical stdlib/capability layer appears immediately:

```text
String
Unicode / Rune / Grapheme
FileIO
HTTP JSON client
CSV
Money / Decimal
Parser / Lexer
Result / Option
Receipts
```

[S] Parser combinators are a high-value pressure point for generics,
higher-order functions, forms, source spans, and error reporting.

[S] `profile` is understood as a developer-facing ergonomics tool, not only as
a compiler-internal concept.

---

## Friction / Gap Signals

[G] Type vocabulary drift:

```text
List[T] vs Array[T]
Optional[T] vs Option[T]
Map[K,V] / Any / Bytes / UUID / Timestamp
```

[G] Syntax pressure that is not currently canon:

```text
include
receipt
form
config
with { ... }
privileged contract ... escape ...
generic contract syntax such as contract CallJsonApi<T>(...)
```

[G] Ambient context OOF candidates appeared naturally:

```text
pure CalculateInvoice reads request.headers
```

This should become a useful OOF fixture for "ambient request context in pure
contract".

[G] Effect annotation confusion appeared naturally:

```text
pure contract BatchImport(...) escape db_write_batch
```

This should become a useful OOF fixture for "pure contract cannot declare or
perform escape".

[G] The default profile shape in specimens often uses `time: bitemporal` and
`evidence: required`, which may be too heavy for mundane application code. This
suggests future lightweight profile presets or capability-specific defaults.

---

## Candidate Extraction Backlog

These are not approved semantics. They are candidate routes for future cards.

| Candidate | Route |
|-----------|-------|
| Mundane stdlib pressure map | Research/Meta track: classify String/File/HTTP/CSV/Money/Parser into candidate packs |
| Ambient-context OOF fixture | Compiler/Grammar track: pure contract must not read request/environment unless explicit input/capability |
| Pure-with-escape OOF fixture | Compiler/Grammar track: pure contract cannot declare escape or call privileged effect without boundary |
| Capability stdlib sketch | Research track: file/http/db capability descriptors, receipts, idempotency, retry policy |
| Parser combinator pressure | Compiler/Grammar or Research track: generics/forms/higher-order function requirements |
| Profile preset ergonomics | Research/Meta track: `mundane_core`, `mundane_effect`, `audit_required` style profile presets |
| Type vocabulary alignment | Compiler/Grammar track: choose aliases or canonical names for Option/List/Map/Result/Bytes/etc. |

---

## Non-Authorizations

This analysis does not authorize:

- parser syntax from the specimens;
- stdlib implementation;
- Effect Surface implementation;
- file/http/db capabilities;
- receipt syntax;
- form syntax;
- generic syntax changes;
- profile preset acceptance;
- runtime execution or production behavior.

---

## Recommended Next Slice

Create a focused agent track:

```text
mundane-stdlib-and-oof-signal-extraction-v0
```

Acceptance for that slice:

1. inventory candidate stdlib packs from the specimens;
2. classify each signal as syntax / type / effect / OOF / profile / stdlib;
3. identify 3-5 minimal OOF fixtures worth formalizing;
4. recommend which items belong to existing PROPs and which require new
   proposal intake;
5. preserve specimen status as non-canonical pressure evidence.

---

## Compact Summary

The mundane pressure specimens are valuable and should remain active. They show
that external readers can use Igniter-Lang for ordinary application work, while
also exposing important syntax, type, effect, and profile gaps. Their route is
signal extraction, not canon promotion.
