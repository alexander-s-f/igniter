# Mundane Application Pressure Specimens v0

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
- (hereinafter: CSV importer, HttpJsonApiClient, BillingCalculation, etc.)