# Mundane Application Pressure Specimens v0

**Status**

```text
active pressure specimen
non-canonical
not parser authority
not runtime authority
not stdlib implementation
```

Architect disposition:

```text
docs/tracks/mundane-application-pressure-analysis-v0.md
```

**Track Goal**
To test how conveniently and ergonomically Igniter Lang solves **common application work**—that same "boring mechanics" that makes up 80% of real-world applications.

Here we **don't** stress Progression, Service Loops, Overton Window, or complex epistemic models.

We stress:

- Clean and convenient CORE data plumbing
- A clear boundary between regular code and auditable ESCAPE/effect
- Ergonomics of Result/Option, typed errors, Decimal, DateTime
- Ease of writing JSON ↔ Domain Record ↔ Validation ↔ Calculation ↔ Response
- Minimal boilerplate while maintaining full observability

The main question:
> Where does regular CORE code end and where does auditable ESCAPE begin?

Each specimen in this track should look like "normal" code in a modern language (Ruby, TypeScript, Elixir), but underneath it all, it's pure Igniter with receipts and evidence.

**Current specimens**
- `igniter-webhook-ingestor-v1.ig` — JSON webhook → validation → domain record → receipt
- `igniter-http-json-client-v1.ig` — request building → HTTP escape → typed response/error
- `igniter-csv-importer-v1.ig` — CSV parsing → row validation → batch import
- `igniter-billing-calculation-v1.ig` — Decimal/Money calculations → persistence receipt
- `igniter-string-library-v1..v4.ig` — string operations, spans, Unicode, parser-combinator pressure
- `igniter-file-io-v1.ig` — file read/write/mmap/stream capability pressure
- `igniter-parser-combinators-v1.ig` — generics/forms/higher-order parser pressure
- `igniter-lexer-v1.ig` — lexer pressure built from parser combinators

**Extraction route**

These files should be mined for:

- candidate stdlib/capability packs;
- CORE vs ESCAPE ergonomics;
- OOF fixtures such as ambient request access inside pure contracts;
- OOF fixtures such as `pure` contracts declaring `escape`;
- type vocabulary alignment (`Option`/`Optional`, `Array`/`List`, `Map`, `Result`, `Bytes`);
- profile preset pressure for ordinary application code.

Do not treat syntax in these files as accepted canon without a follow-up
proposal/spec track.
