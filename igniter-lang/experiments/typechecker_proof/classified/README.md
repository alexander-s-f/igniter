# TypeChecker ClassifiedProgram Boundary Fixtures

Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/typechecker-boundary-fixture-v0`

These files are the TypeChecker proof's owned ClassifiedProgram input fixtures.
They are a snapshot of the classifier boundary shape used by Stage 1:

```text
ClassifiedProgram JSON -> TypecheckerPass -> TypedProgram JSON
```

The TypeChecker proof must read from this directory by default. It may also be
given another ClassifiedProgram directory explicitly with:

```bash
ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb \
  --classified-dir igniter-lang/experiments/typechecker_proof/classified \
  --check-golden
```

These fixtures intentionally contain the minimal fields the TypeChecker needs:

- `kind: "classified_program"`
- `type_declarations`
- contract declarations with compute expression ASTs
- existing OOF diagnostics for blocked classified programs

They are not ParsedProgram fixtures and are not SemanticIR fixtures.
