# Wizard Type Spec Architecture

Status: research response to
[Wizard Type Spec Research Request](./wizard-type-spec-research-request.md).
App-local direction only. Not accepted core API, package API, dynamic runtime
execution, migration system, or Igniter Lang grammar.

## Decision

`WizardTypeSpec` should be modeled as a durable spec registry cell:

```text
WizardTypeSpec ~= Store[ContractSpec]
WizardTypeSpecChange ~= History[ContractSpecChange]
```

The spec is data about a future or materialized contract shape. It is not
runtime code.

Static Ruby contracts remain the production execution shape. Wizard specs are
the lineage, export, parity, and future materialization input.

## Mental Model

Use three layers:

- Draft: wizard/configurator edits durable specs in a sandbox.
- Materialization plan: graph contracts lower specs to static record, history,
  relation, command, and capability requirements.
- Static shape: explicit Ruby contracts execute in production and are checked
  against the plan.

This avoids the dangerous shortcut where a user-authored JSON spec becomes live
runtime behavior.

## Canonical Spec

Minimum canonical form:

```ruby
{
  schema_version: 1,
  id: "article-comment",
  name: :Article,
  capability: :articles,
  kind: :record,
  storage: {
    shape: :store,
    key: :id,
    adapter: :sqlite
  },
  fields: [
    { name: :id, type: :string, required: true },
    { name: :title, type: :string, required: true },
    { name: :body, type: :string },
    { name: :created_at, type: :datetime },
    {
      name: :status,
      type: :enum,
      values: %i[draft published archived],
      default: :draft
    }
  ],
  indexes: [
    { name: :status, fields: [:status] }
  ],
  scopes: [
    { name: :drafts, where: { status: :draft } },
    { name: :published, where: { status: :published } }
  ],
  commands: [
    {
      name: :publish,
      operation: :record_update,
      changes: { status: :published }
    }
  ],
  histories: [
    {
      name: :Comment,
      capability: :comments,
      storage: {
        shape: :history,
        key: :index,
        adapter: :sqlite
      },
      fields: [
        { name: :index, type: :integer },
        { name: :article_id, type: :string },
        { name: :body, type: :string },
        { name: :created_at, type: :datetime }
      ],
      relation: {
        name: :comments_by_article,
        kind: :event_owner,
        from: :articles,
        to: :comments,
        join: { id: :article_id },
        cardinality: :one_to_many,
        integrity: :validate_on_append,
        consistency: :local,
        enforced: false
      }
    }
  ],
  metadata: {
    source: :wizard,
    materialized: false
  }
}
```

Compatibility aliases are allowed during the app-local proof:

- `persist` may lower to `storage: { shape: :store }`
- `history` may lower to `storage: { shape: :history }`

The canonical internal model should prefer `storage.shape` because it aligns
with `Store[T]`, `History[T]`, and future specialized shapes.

## Type Vocabulary

Keep the first type vocabulary small:

- `:string`
- `:integer`
- `:numeric`
- `:boolean`
- `:datetime`
- `:date`
- `:enum`
- `:json`

Do not add arbitrary Ruby classes to wizard specs yet. The bridge to Ruby
classes belongs in materialization, not in the portable spec.

## Change History

`WizardTypeSpecChange` should capture lineage, not only audit:

```ruby
{
  index: 12,
  spec_id: "article-comment",
  contract: "Article",
  change_kind: :wizard_edit,
  spec: { ...full_snapshot },
  created_at: "2026-04-29",
  actor: "user-or-agent",
  reason: "add published scope"
}
```

Use full snapshots first. Diffs can be added later as compression once repeated
history pressure exists.

## Export Rules

Dev export:

- includes latest specs
- includes full spec history
- includes materialization plan summaries
- may include parity status and mismatches
- is suitable for review, migration planning, and agent handoff

Prod export:

- includes latest specs only
- strips history by default
- strips actor/reason/debug metadata
- includes no executable code
- includes no write/git/restart capability
- may include static materialization status so deploy checks can refuse drift

## Materializer Boundary

A materializer is a future capability, not current behavior.

Allowed now:

- read persisted specs
- lower specs to materialization plans
- compare plans with static manifests
- export portable config
- report required capabilities

Still forbidden:

- write files
- run git
- restart app processes
- mutate core/package runtime
- execute dynamic specs as code
- run migrations
- create DB indexes or foreign keys

Future materializer capability should require explicit gates:

- `write`
- `test`
- `git`
- `restart`
- optional `migration_plan`

Parity must be clean before requesting any write/git/restart capability.

## Migration Planning

Spec history can become migration planning input, but not migration execution.

Safe near-term uses:

- detect added/removed/renamed fields
- detect index/scope/command changes
- detect relation shape changes
- classify changes as additive, destructive, or ambiguous
- emit review-only migration candidates

Deferred:

- automatic migrations
- database schema changes
- data backfills
- destructive operations
- runtime hot reload

## Lang Lowering

Future language interpretation:

```text
ContractSpec[Article]
Store[ContractSpec]
History[ContractSpecChange]
MaterializationPlan[ContractSpec]
ParityReport[MaterializationPlan, StaticManifest]
```

The important path:

```text
wizard JSON -> canonical ContractSpec -> Ruby static contracts
            -> future Igniter::Lang syntax
```

Do not make Ruby reflection the canonical source. Ruby contracts can sync into
the spec registry, but the portable form should stay host-neutral.

## Promotion Criteria

Do not promote yet.

Promotion needs:

- two or more real user-defined shapes
- a stable canonical spec shape across edits
- parity checks catching useful drift
- dev/prod export proving different audiences
- a materializer capability model accepted separately
- no dynamic execution needed for product value

## Smallest Next Experiment

App-local only:

1. Add `schema_version` and `storage.shape` to the seeded Article/Comment spec.
2. Keep `persist`/`history` aliases for current manifest compatibility.
3. Extend parity/export to surface `schema_version`.
4. Add one smoke marker proving prod export strips history and dev export keeps
   it.

This tightens the canonical model without changing runtime behavior.

## Handoff

```text
[Research / Codex]
Track: docs/research/wizard-type-spec-architecture.md
Status: research response delivered.
[D] WizardTypeSpec is best modeled as Store[ContractSpec]; WizardTypeSpecChange
is best modeled as History[ContractSpecChange].
[D] Dynamic specs are durable lineage/config data, not executable runtime code.
[R] Production execution stays static-contract-first until a separate
materializer capability model is accepted.
[R] Canonical specs should prefer host-neutral `storage.shape`; app-local
`persist` and `history` remain compatibility sugar.
[S] Companion already proves Article/Comment latest spec, spec history,
materialization plan, parity, and dev/prod export.
Next: add `schema_version` and `storage.shape` to the seeded spec and expose
that through export/parity without runtime behavior changes.
Block: no core/package promotion, no migrations, no dynamic execution.
```
