# Igniter — AGENTS.md

## Project Overview

Igniter is a Ruby gem for declaring and executing business logic as validated dependency graphs with compile-time validation and intelligent runtime caching/invalidation.

## Commands

```bash
rake          # Run specs + RuboCop (default)
rake spec     # Run tests only
rake rubocop  # Lint only
rake build    # Build gem
rake release  # Release to rubygems.org
```

## Architecture

The system has clear compile-time / runtime boundaries:

- **Model** (`lib/igniter/model/`) — Immutable node types: Input, Compute, Composition, Branch, Collection, Output
- **Compiler** (`lib/igniter/compiler/`) — Validates graph, produces frozen `CompiledGraph` with resolution order
- **DSL** (`lib/igniter/dsl/contract_builder.rb`) — Fluent builder: `input`, `compute`, `output`, `compose`, `branch`, `collection`, `const`, `lookup`, `map`, `project`, `aggregate`, `guard`, `expose`, `export`, `effect`, `on_success`, `scope`, `namespace`
- **Runtime** (`lib/igniter/runtime/`) — Lazy resolution, cache, invalidation, planner, runners (inline/thread_pool/store)
- **Extensions** (`lib/igniter/extensions/`) — Auditing, reactive subscriptions, introspection/Mermaid
- **Diagnostics** (`lib/igniter/diagnostics/`) — Report building with text/markdown/structured formatters

## Key Conventions

- **Ruby >= 3.1.0** required
- **Zero production dependencies**
- Dev deps: `rake`, `rspec`, `rubocop`
- Double-quoted strings enforced by RuboCop
- All errors inherit from `Igniter::Error` with context metadata (graph, node, path, source)
- Frozen/immutable objects throughout model and compiler layers
- Version lives in `lib/igniter/version.rb`

## Key Files

| File | Purpose |
|------|---------|
| `lib/igniter/contract.rb` | Contract definition & execution API |
| `lib/igniter/dsl/contract_builder.rb` | All DSL keywords |
| `lib/igniter/compiler/graph_compiler.rb` | Compilation orchestrator |
| `lib/igniter/compiler/compiled_graph.rb` | Frozen compiled graph |
| `lib/igniter/runtime/execution.rb` | Runtime orchestration |
| `lib/igniter/runtime/resolver.rb` | Node resolution logic |
| `lib/igniter/type_system.rb` | Type validation |
| `lib/igniter/errors.rb` | Error hierarchy |

## Testing

- RSpec 3.x with `expect` syntax
- Test files in `spec/igniter/`
- Examples smoke-tested via `spec/igniter/example_scripts_spec.rb`
- No monkey patching in specs

## Documentation

Design docs live in `docs/` — key reads: `ARCHITECTURE_V2.md`, `EXECUTION_MODEL_V2.md`, `API_V2.md`, `PATTERNS.md`.
