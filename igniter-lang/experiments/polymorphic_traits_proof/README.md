# Proof & Integration Package: Polymorphic Traits and Monomorphization

This directory contains the proof of implementation for monomorphizing polymorphic contract templates and resolving trait method overloads in the Igniter compiler.

## Structure

- [patches.rb](file:///igniter-lang/experiments/polymorphic_traits_proof/patches.rb) - Unified monkey-patches resolving all compiler phases in the Ruby platform.
- [tests/conformance/conformance_runner.rb](file:///igniter-lang/tests/conformance/conformance_runner.rb) - Integration test harness showcasing how these patches are verified dynamically.

## Adopting in Mainline (`lib/igniter_lang/`)

To merge these changes permanently into `lib/igniter_lang/`, adopt the logic from `patches.rb` into the corresponding files in the codebase:

### 1. AST Monomorphization
- **Source**: `IgniterLang::ParsedProgram.monomorphize_parsed_program`
- **Target**: `lib/igniter_lang/parsed_program.rb` inside `parse` method.
- **Details**: Detects generic contracts with `type_params`, locates matching trait implementations (`impls`), and specializes them to concrete `name[Type]` contracts. It copies and type-substitutes parameters from the matching contract shape.

### 2. SemanticIR Metadata Propagation
- **Source**: `IgniterLang::SemanticIREmitter.typed_contract_ir` and `typed_semantic_ir_program`
- **Target**: `lib/igniter_lang/compiler/semantic_ir_emitter.rb`
- **Details**: Inserts `"specialization_of"`, `"type_args"`, `"shapes"`, and `"implements"` arrays into specialized concrete contracts' Semantic IR outputs. Adds root-level `"shape_descriptors"` and `"lowering_invariants"` to the program.

### 3. Trait Method Lowering
- **Source**: `IgniterLang::SemanticIREmitter.lower_expr` and `semantic_expr`
- **Target**: `lib/igniter_lang/compiler/semantic_ir_emitter.rb`
- **Details**: Rewrites generic trait calls (e.g. `stdlib.numeric.add`) into type-specific operator implementations (e.g. `stdlib.integer.add` or `stdlib.float.add`) based on type inferences.

### 4. Classification Metadata Propagation
- **Source**: `IgniterLang::Classifier.classify_contract`
- **Target**: `lib/igniter_lang/compiler/classifier.rb`
- **Details**: Ensures `"specialization_of"`, `"type_args"`, and `"implements"` fields bypass classifier validation and propagate cleanly.

### 5. Typechecking Support
- **Source**: `IgniterLang::TypeChecker.infer_call`
- **Target**: `lib/igniter_lang/compiler/type_checker.rb`
- **Details**: Ensures calls to `stdlib.numeric.add` infer type correctly based on the type of their first argument.

### 6. Specialization Manifest Generation
- **Source**: `IgniterLang::Assembler.write_artifact_to`
- **Target**: `lib/igniter_lang/compiler/assembler.rb`
- **Details**: Emits a `specialization_manifest.json` outlining all generated generic-to-concrete contract mappings, and updates `manifest.json` with the appropriate template and reference configurations.
