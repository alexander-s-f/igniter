# Track: Mundane Stdlib And OOF Signal Extraction v0

Card: S3-R36-C6-P
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `mundane-stdlib-and-oof-signal-extraction-v0`
Status: done
Date: 2026-05-11

---

## Goal

Extract actionable language signals from the blind external mundane application
pressure specimens.

Sources:

```text
docs/tracks/mundane-application-pressure-analysis-v0.md
experiments/pressure-specimens/README.md
experiments/pressure-specimens/mundane-application-pressure-v0/
```

This is an extraction map only. It is not implementation evidence.

---

## Explicit Non-Canon Statement

The specimens are non-canonical pressure evidence.

Do not treat any specimen syntax, type spelling, form spelling, profile shape,
receipt shape, generic syntax, stdlib function, or capability name as accepted
language canon.

This track does not authorize:

```text
stdlib implementation
parser implementation
runtime implementation
Effect Surface implementation
file/http/db capability binding
receipt syntax
form syntax
generic syntax
profile preset acceptance
production execution
```

---

## Specimens Read

```text
README.md
igniter-webhook-ingestor-v1.ig
igniter-http-json-client-v1.ig
igniter-csv-importer-v1.ig
igniter-billing-calculation-v1.ig
igniter-string-library-v1.ig
igniter-string-library-v2.ig
igniter-string-library-v3.ig
igniter-string-library-v4.ig
igniter-file-io-v1.ig
igniter-parser-combinators-v1.ig
igniter-lexer-v1.ig
igniter-parser-v1.ig
igniter-parser-v2.ig
```

---

## Extraction Table

| Signal | Evidence | Classification | Route |
| --- | --- | --- | --- |
| Ambient request access inside pure contract | `CalculateInvoice` is pure but reads `request.headers["Idempotency-Key"]` | OOF candidate; syntax pressure | Compiler/Grammar OOF fixture: pure code must not read ambient request/environment; idempotency key must be explicit input or effect/capability metadata |
| Pure contract declaring escape | `pure contract BatchImport(...)` declares `escape db_write_batch` | OOF candidate; Effect Surface pressure | Compiler/Grammar OOF fixture: `pure` cannot declare/perform `escape`; use `privileged`/effect boundary or non-pure orchestration |
| File metadata modeled as pure | `FileExists`, `FileSize`, `FileMetadata` are pure but observe filesystem state | OOF candidate; capability pack candidate | Decide whether filesystem metadata is `file_read_metadata` ESCAPE or a declared snapshot input; likely not CORE |
| JSON parse as pure data transform | `ParseJsonWebhook(raw_body: Bytes) -> WebhookPayload`; `ParseJsonResponse<T>` | stdlib/capability pack candidate; type vocabulary drift | Candidate `JsonPack` / stdlib module; parse bytes/string into typed record with validation errors, no network/file effect |
| CSV parse/map/validate as pure | `ParseCsvFile(content: Bytes)`, `MapAndValidateRow`, `Result[ImportRecord, List[ValidationError]]` | stdlib/capability pack candidate; type vocabulary drift | Candidate `CsvPack` / data import stdlib; keep DB batch import as effect boundary |
| HTTP request execution | `ExecuteHttpCall` is `privileged`, uses `escape http_outbound`, retry/backoff/timeout config | stdlib/capability pack candidate; file/http/db receipt pressure | Candidate `HttpClientCapabilityPack`; requires request/response/error/receipt/retry/idempotency descriptor |
| File read/write/mmap/stream | `ReadFile`, `ReadLines`, `StreamFile`, `MemoryMapFile`, `WriteFile` all return receipts | stdlib/capability pack candidate; file/http/db receipt pressure | Candidate `FileIOCapabilityPack`; requires read/write/mmap/stream capability descriptors and receipt shape |
| DB write and batch import | `StoreEvent`, `PersistInvoice`, `BatchImport` use `db_write` / `db_write_batch` and idempotency | stdlib/capability pack candidate; receipt pressure; Effect Surface pressure | Candidate `DbWriteCapabilityPack` or Effect Surface integration; requires idempotency and receipt semantics |
| Money/Decimal arithmetic | `Money`, `Decimal[4]`, rounding `half_up`, tax calculation | stdlib pack candidate; type vocabulary drift | Candidate `MoneyDecimalPack`; define Decimal scale, currency, rounding mode, and cross-currency refusal |
| Result/Option ergonomics | `Result[T,E]`, `Ok/Err`, `Optional[T]`, `Option<T>` combinator | type vocabulary drift; syntax pressure | Canonical vocabulary decision needed: `Option` vs `Optional`, `Result`, `Ok`, `Err`, `None`, `Some` |
| Array/List vocabulary drift | README calls out `Array/List`; specimens mostly use `List[T]` | type vocabulary drift | Decide canonical collection names and aliases; do not accept specimen spellings by default |
| Map/Any/Bytes/UUID/Timestamp | Used throughout webhook/http/parser/file examples | type vocabulary drift; stdlib candidate | Type vocabulary alignment card should classify primitives, aliases, and forbidden loose `Any` contexts |
| String stdlib | Search, replace, regex, split, tokenize, spans, Unicode, normalization | stdlib pack candidate; syntax pressure | Candidate `StringUnicodePack`; define pure operations, Unicode/grapheme model, regex capability status |
| SourceSpan and error highlighting | `SourceLocation`, `SourceSpan`, `HighlightSpan`, parser errors | stdlib pack candidate; compiler diagnostics pressure | Candidate `SourceTextPack`; useful for parser, diagnostics, editor tooling |
| Parser combinators | `Parser<T>`, `ParseResult<T>`, `Many`, `Choice`, `Then`, `Lookahead`, `Chainl`, `RunParser` | future proposal candidate; parser combinator/generic/forms pressure | Needs formal generics/higher-order/function-type decision before any parser POC |
| Forms over stdlib/combinators | `form (text) "." "replace"...`, `form (p) "?"`, `form (p1) "|" (p2)` | syntax pressure; future proposal candidate | Forms need separate grammar/authority lane; do not infer accepted syntax |
| Generic contract syntax | `ParseJsonResponse<T>`, `CallJsonApi<T>`, `Parser<T>`, `ManySepBy<T, Sep>` | syntax pressure; type vocabulary drift | Generic syntax and higher-order type functions need Compiler/Grammar design |
| Profile presets for mundane work | `profile mundane_*` with `time: bitemporal`, `evidence: required`, `effects: minimal` | profile preset pressure | Future `mundane_core`, `mundane_effect`, `audit_required` presets; avoid making bitemporal/evidence-heavy defaults mandatory |
| Config block ergonomics | `config retry: { attempts, backoff_ms, timeout_ms }` and call-site `with { retry: ... }` | syntax pressure; capability descriptor pressure | Retry/timeout should likely be capability policy metadata, not arbitrary syntax accepted from specimen |
| Ordinary orchestration contract | `ProcessWebhook`, `ImportCsv`, `CreateInvoice`, `CallJsonApi` compose pure transforms and privileged effects | future proposal candidate; profile preset pressure | Clarify non-pure orchestration contract shape: it may call CORE and effect boundaries, but must not hide ambient context |

---

## OOF Candidate Details

### OOF-MA1: Ambient Context In Pure Contract

Specimen pressure:

```text
pure CalculateInvoice(...) reads request.headers["Idempotency-Key"]
```

Candidate rule:

```text
A pure contract may not read ambient request, environment, clock, filesystem,
network, database, runtime context, or authority state unless the value is an
explicit input.
```

Likely fix shape:

```text
CalculateInvoice(lines, idempotency_key)
```

or:

```text
CreateInvoice(...) obtains idempotency via request/capability boundary and passes
it explicitly into pure calculation.
```

### OOF-MA2: Pure Contract Declares Or Performs Escape

Specimen pressure:

```text
pure contract BatchImport(...)
  escape db_write_batch
```

Candidate rule:

```text
`pure` contracts cannot declare `escape`, call privileged/effectful operations,
or return effect receipts as if they were CORE values.
```

Likely fix shape:

```text
privileged contract BatchImport(...)
  escape db_write_batch
```

or a non-pure orchestration contract calls a privileged capability boundary.

### OOF-MA3: Filesystem Observation Marked Pure

Specimen pressure:

```text
pure FileExists(path)
pure FileSize(path)
pure FileMetadata(path)
```

Candidate rule:

```text
Filesystem state observation is not CORE unless the file metadata was provided
as an explicit immutable input/snapshot.
```

This should be routed together with file capability descriptors.

---

## Stdlib / Capability Pack Candidates

| Candidate pack | Owns | Notes |
| --- | --- | --- |
| `StringUnicodePack` | string search/replace/slice/tokenize, Rune/Grapheme, normalization | Mostly CORE; regex may need separate deterministic policy |
| `SourceTextPack` | SourceLocation, SourceSpan, highlighting, parser diagnostics helpers | Useful for compiler diagnostics and userland parsers |
| `JsonPack` | parse/encode JSON, typed decode, validation errors | CORE when input bytes/string are explicit |
| `CsvPack` | parse CSV bytes/string, row mapping, validation | CORE when input bytes/string are explicit |
| `MoneyDecimalPack` | Decimal scale, Money, rounding modes, tax-safe arithmetic | Needs currency and rounding refusal rules |
| `HttpClientCapabilityPack` | outbound HTTP, request/response/error, retry/backoff/timeout, receipts | ESCAPE/privileged |
| `FileIOCapabilityPack` | read/write/read lines/stream/mmap metadata, receipts | ESCAPE/privileged; metadata likely ESCAPE |
| `DbWriteCapabilityPack` | db_write, db_write_batch, idempotency, persistence receipts | ESCAPE/privileged; may depend on Effect Surface |
| `ParserCombinatorPack` | Parser<T>, ParseResult<T>, combinators, labels, lookahead | Future proposal; blocked on generics/function types/forms |

---

## Profile Preset Pressure

The blind specimens repeatedly use:

```text
time: bitemporal
evidence: required
trust: system
effects: minimal
```

Signal:

```text
External authors want a lightweight mundane profile, but they over-default to
bitemporal/evidence-heavy settings because no ergonomic profile preset exists.
```

Candidate presets, pressure-only:

```text
mundane_core      # pure data plumbing, explicit inputs, no runtime effects
mundane_effect    # ordinary app orchestration with declared capability effects
audit_required    # receipt/evidence-heavy mode for regulated workflows
```

Do not promote these names without a profile proposal.

---

## Recommended Follow-Up Cards

1. `mundane-oof-fixture-plan-v0`

```text
Goal: design minimal OOF fixtures for ambient context in pure, pure-with-escape,
and filesystem observation marked pure. No compiler implementation yet.
Owner: Compiler/Grammar Expert with Research fixture pressure.
```

2. `mundane-stdlib-pack-candidate-map-v0`

```text
Goal: classify StringUnicode, SourceText, Json, Csv, MoneyDecimal, and validation
as CORE stdlib pack candidates with dependencies and non-goals.
Owner: Research Agent / Meta Expert.
```

3. `mundane-capability-receipt-descriptor-pressure-v0`

```text
Goal: map file/http/db capability descriptors, receipt fields, retry/backoff,
timeouts, idempotency, and effect boundaries without runtime binding.
Owner: Research Agent; Bridge Agent later only if approved.
```

4. `type-vocabulary-alignment-mundane-v0`

```text
Goal: decide canonical or alias policy for Option/Optional, List/Array, Map,
Result, Bytes, UUID, Timestamp, Any, Unit, Decimal.
Owner: Compiler/Grammar Expert.
```

5. `parser-combinator-and-forms-pressure-boundary-v0`

```text
Goal: extract generics, higher-order function, Parser<T>, SourceSpan, and form
syntax requirements from parser specimens without accepting parser syntax.
Owner: Compiler/Grammar Expert with Research evidence.
```

---

## Handoff

```text
Card: S3-R36-C6-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: mundane-stdlib-and-oof-signal-extraction-v0
Status: done

[D] Decisions
- Specimens remain non-canonical pressure evidence.
- Extracted signals split into stdlib/capability packs, syntax pressure, type vocabulary drift, OOF candidates, profile preset pressure, and future proposal candidates.
- Ambient request access in pure, pure-with-escape, and filesystem metadata-as-pure are the highest-value OOF candidates.

[S] Signals
- Mundane app pressure strongly supports CORE data plumbing + explicit ESCAPE capability boundary.
- File/http/db operations want receipt-bearing capability descriptors.
- Parser combinators/forms/generics are substantial but should stay proposal-only.

[T] Tests / Proofs
- No code or proof changes in this slice.
- Source read: mundane pressure analysis + 14 mundane pressure specimen files.

[R] Risks / Recommendations
- Do not canonize specimen syntax.
- Route follow-up cards before any stdlib/parser/runtime/Effect Surface implementation.

[Next]
- Start with mundane-oof-fixture-plan-v0 or mundane-capability-receipt-descriptor-pressure-v0.
```
