# Credential Distribution And Propagation

This note captures the current working position for credentials across
multi-node Igniter deployments.

It is intentionally conservative.

The goal right now is not to pretend the final mechanism already exists.
The goal is to prevent accidental drift into an unsafe default while the
cluster, `ignite`, and assistant product tracks continue to evolve.

## Why This Needs An Explicit Position

Igniter is moving toward:

- multi-node `ignite`
- routed remote agents
- assistant products that can use local and external AI channels
- operator-visible execution and delivery workflows

That means the system will increasingly need to answer questions like:

- which node may hold which credentials?
- when is a secret allowed to move?
- should a remote node receive the real credential, a lease, or no secret at all?
- how are trust and admission related to secret propagation?

Without an explicit doctrine, it is easy to accidentally normalize the most
dangerous path: “copy the API key to every node that might need it”.

That must not become the default.

## Current Working Doctrine

The first implementation foundation for this now lives in `igniter-app`, not
only inside `companion`:

- `Igniter::App::Credentials::Credential`
- `Igniter::App::Credentials::CredentialPolicy`
- `Igniter::App::Credentials::Policies::LocalOnlyPolicy`
- `Igniter::App::Credentials::Policies::EphemeralLeasePolicy`
- `Igniter::App::Credentials::LeaseRequest`
- `Igniter::App::Credentials::Events::CredentialEvent`
- `Igniter::App::Credentials::Trail`

That is intentionally still conservative.

- it gives apps one canonical value-object layer for credential identity and
  propagation policy
- it now also gives apps the first shared policy family, instead of forcing
  every product to reinvent `local_only`
- it now also gives apps one canonical audit/event envelope for future
  credential lease and replication flows
- it now also gives stacks a canonical lease request vocabulary and simple
  `request / issue / deny / revoke` flow before any real secret transport exists
- it now also gives stacks one durable credential trail seam before full
  cross-node transport exists
- it now also gives the app/operator surface a request-level overview above
  raw credential audit events, so lease flows can be inspected as one logical request
- it does not yet pretend cluster-wide secret transport is solved
- app-specific products may adapt and subclass these objects, but should not
  invent unrelated credential/policy vocabularies when the shared layer fits

### 1. Default: credentials are node-local

The baseline rule is:

- a credential belongs to one node-local runtime boundary
- no automatic cross-node replication should happen by default
- a multi-node stack must remain correct even when every node has different local credential availability

This is the safe and honest default.

### 2. Prefer capability routing over credential copying

If one node has a credential and another does not, the first preferred solution
is usually:

- route the work to the node that already has the required capability and secret

not:

- replicate the secret to the second node

In other words:

- capability-aware execution should usually come before secret propagation

### 3. Untrusted or weakly trusted nodes should not receive long-lived secrets

If a node lives in a less trusted environment, such as:

- office hardware
- lab hardware
- edge hardware
- physically reachable or loosely administered machines

then the working assumption should be:

- do not place long-lived external API credentials on that node unless explicitly required and approved

This applies especially to:

- OpenAI API keys
- Anthropic API keys
- any credential that enables external spend or access to private data

### 4. Secret propagation must be policy-driven, not implicit

If Igniter eventually supports cross-node secret propagation, it should happen
through explicit policy, not by runtime convenience.

The policy surface should likely answer:

- what secret class is this?
- which nodes are eligible?
- is propagation persistent or ephemeral?
- does it require operator approval?
- what audit trail must exist?

### 5. Operator visibility is required

If a secret is:

- injected
- leased
- refreshed
- revoked
- denied

that should appear in an inspectable operator and audit surface.

Credential movement without operator visibility would be a serious design smell.

## Practical Secret Classes

These classes are useful even before a full implementation exists.

### A. `local_only`

Meaning:

- may exist only on one node
- never propagated automatically
- if another node needs the capability, route to the credential-owning node

Examples:

- external paid LLM API keys
- personal service tokens
- private production credentials

### B. `ephemeral_lease`

Meaning:

- may be issued temporarily to a node for a bounded operation
- should expire automatically
- should be auditable and revocable

Examples:

- short-lived bootstrap credentials
- one-time deployment/session tokens
- scoped remote execution credentials

This is a future direction, not a current default implementation.

In code, this is now represented as the shared declared policy
`Igniter::App::Credentials::Policies::EphemeralLeasePolicy`.

That does not mean full lease transport already exists.
It means apps can now describe and reason about that mode through one canonical
policy type while transport, trust, and audit layers catch up.

### C. `replicated_cluster_secret`

Meaning:

- intentionally shared across a trusted node set
- protected by stronger cluster policy
- rotation and revocation become mandatory design concerns

Examples:

- internal mesh tokens
- cluster-scoped service credentials

This should be treated as advanced and exceptional, not the baseline for normal
assistant/API credentials.

## Current Planning Bias For Companion And Home-Lab

For the current assistant product track:

- `companion` should treat external provider credentials as node-local
- `home-lab` should also treat them as node-local unless a specific stronger design is implemented
- local cluster imitation should not silently normalize credential sharing just because nodes run from one checkout

That means the current multi-node local development stance should remain:

- separate persistence per node
- separate runtime configuration per node
- no hidden secret fan-out across replicas

If a node cannot deliver through a given external provider, the honest behavior is:

- route elsewhere
- fall back
- or require operator/manual completion

## Relationship To Trust And Ignite

This topic is tightly coupled to:

- trust and admission policy
- node hardening
- `ignite`
- remote/routed agents

The likely dependency order is:

1. stronger trust/admission truth
2. clearer node trust classes
3. explicit credential policy surface
4. only then any serious cross-node propagation mechanism

Without that order, secret distribution would outrun the trust model.

## What We Should Avoid

These should be treated as anti-patterns unless there is a very strong reason:

- copying one `.env` or API key blob to every node during `ignite`
- hiding credential movement inside bootstrap scripts without audit
- treating all admitted nodes as equally trusted for secret placement
- storing long-lived external credentials on semi-trusted edge nodes by default
- making routing depend on secret replication instead of capability placement

## Open Design Questions

These are still unresolved and should stay explicit:

1. What is the canonical Igniter secret authority?

- environment variables only?
- app runtime store?
- OS keychain / vault integration?
- a future cluster secret service?

2. What should an ephemeral lease actually look like?

- encrypted envelope?
- signed token?
- one-time use session secret?

3. What is the right audit/event vocabulary?

- `credential_lease_issued`
- `credential_lease_used`
- `credential_replication_denied`
- `credential_revoked`

The shared app-level foundation now explicitly recognizes one canonical event
shape through `Igniter::App::Credentials::Events::CredentialEvent`, with the
current vocabulary:

- `lease_requested`
- `lease_issued`
- `lease_denied`
- `lease_used`
- `lease_revoked`
- `replication_requested`
- `replication_denied`
- `replication_revoked`
- `access_denied`

Those events can now also land in a durable app/stack-side trail through
`Igniter::App::Credentials::Trail`, so future lease and propagation work
already has a canonical audit destination. That trail is also now queryable
through the app-wide operator API, so policy/status/credential/target-node
filters do not have to wait for real cluster lease transport to exist.

4. How should rotation and revocation work across already-running nodes?

5. How should `ignite` represent secret policy during bootstrap?

- local-only
- lease-on-join
- explicit operator-approved replication

## Current Recommendation

Until a stronger implementation exists, Igniter should assume:

- credentials are local
- routing is preferred over replication
- weakly trusted nodes should not receive long-lived external API secrets
- any future propagation must be explicit, policy-driven, and auditable

That is the safest and most architecturally honest current position.
