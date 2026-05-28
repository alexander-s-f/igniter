# frozen_string_literal: true

# IgniterLang::SemanticIRExpressionEvaluator
#
# Internal Slice 1 SemanticIR expression evaluator.
#
# Authorization: S3-R199-C1-A
# Track: branch-conditional-if-expr-live-runtime-evaluator-implementation-v0
#
# Boundary:
#   internal, direct-require-only, not root-required
#   supported expression kinds: literal, ref, if_expr
#   not integrated into RuntimeSmoke, CompilerOrchestrator, CompilerResult,
#   CompilationReport, Diagnostics, public API/CLI, release harness, or Spark
#
# Semantics:
#   if_expr evaluation is lazy:
#     1. Evaluate condition first.
#     2. Require runtime Bool exactly: true or false. No truthy/falsy coercion.
#     3. If condition is true, evaluate only then_branch.
#     4. If condition is false, evaluate only else_branch.
#     5. Return the selected branch value.
#     6. Apply same rules recursively for nested if_expr.
#
# Internal diagnostics (non-canonical, not OOF-RT-*, not Diagnostics/reports):
#   Reason labels are proof-debug/human-readable only.

module IgniterLang
  class SemanticIRExpressionEvaluator
    # -------------------------------------------------------------------------
    # Internal exception hierarchy
    # All internal to this class; not integrated with Diagnostics, CompilerResult,
    # CompilationReport, or public API/CLI surface.
    # -------------------------------------------------------------------------

    # Base class for all evaluator errors
    Error = Class.new(StandardError)

    # if_expr node is missing a required field (condition, then_branch, else_branch)
    MalformedIfExprError = Class.new(Error)

    # Condition value is not exactly true or false (no truthy/falsy coercion)
    ConditionNotBoolError = Class.new(Error)

    # Expression kind is not supported by this evaluator (selected-path only)
    UnsupportedExpressionKindError = Class.new(Error)

    # Referenced name is not present in the values hash
    MissingReferenceError = Class.new(Error)

    # -------------------------------------------------------------------------
    # Supported expression kinds (Slice 1)
    # -------------------------------------------------------------------------

    SUPPORTED_KINDS = %w[literal ref if_expr].freeze

    # -------------------------------------------------------------------------
    # Public interface
    # -------------------------------------------------------------------------

    # Evaluate a SemanticIR expression node.
    #
    # expr   - Hash representing a SemanticIR expression node.
    #          Must have a "kind" key.
    # values - Hash (String keys) of resolved node names to runtime values.
    #
    # Returns the evaluated value of the expression.
    #
    # The optional call_trace array, if provided, is appended with evaluated
    # expression kinds in order. It is proof/debug evidence only and must not
    # be treated as dependency authority.
    def evaluate(expr, values = {}, call_trace: nil)
      eval_expr(expr, values, call_trace)
    end

    private

    # Core recursive evaluator
    def eval_expr(expr, values, call_trace)
      unless expr.is_a?(Hash) && expr.key?("kind")
        raise MalformedIfExprError,
              "Expression must be a Hash with a 'kind' key; got #{expr.class}"
      end

      kind = expr.fetch("kind")
      call_trace&.push(kind)

      case kind
      when "literal"
        eval_literal(expr)

      when "ref"
        eval_ref(expr, values)

      when "if_expr"
        eval_if_expr(expr, values, call_trace)

      else
        # Unknown expression kind in selected path: fail closed.
        # This is reached only when the kind is actually selected for evaluation.
        raise UnsupportedExpressionKindError,
              "Unsupported expression kind in selected path: #{kind.inspect}. " \
              "Supported: #{SUPPORTED_KINDS.join(", ")}"
      end
    end

    # Evaluate a literal expression node.
    # Returns the static value embedded in the node.
    def eval_literal(expr)
      expr.fetch("value") do
        raise MalformedIfExprError,
              "Literal expression is missing 'value' key"
      end
    end

    # Evaluate a ref expression node.
    # Looks up the referenced name in the values hash.
    def eval_ref(expr, values)
      name = expr.fetch("name") do
        raise MalformedIfExprError, "Ref expression is missing 'name' key"
      end

      unless values.key?(name)
        raise MissingReferenceError,
              "Reference '#{name}' not found in values. " \
              "Available: #{values.keys.sort.inspect}"
      end

      values.fetch(name)
    end

    # Evaluate an if_expr expression node with lazy semantics.
    #
    # Structural proof of selected-branch-only evaluation (LRT-IF12):
    #   eval_if_expr passes ONLY the selected branch to eval_expr.
    #   - When cond_val == true, ONLY then_branch is passed (line A).
    #   - When cond_val == false, ONLY else_branch is passed (line B).
    #   The two Ruby `if` arms are mutually exclusive; the non-selected branch
    #   Hash is never passed to eval_expr in normal evaluation.
    #
    # This preserves the counterfactual audit stance: the explicit branch
    # structure is retained in the node, allowing a future audit layer to
    # inspect static branch metadata without requiring eager evaluation here.
    def eval_if_expr(expr, values, call_trace)
      # LRT-IF8: fail closed for malformed if_expr
      required_keys = %w[condition then_branch else_branch]
      missing = required_keys.reject { |k| expr.key?(k) }
      unless missing.empty?
        raise MalformedIfExprError,
              "Malformed if_expr node: missing required keys #{missing.inspect}. " \
              "Internal reason: runtime.if_expr_malformed"
      end

      # LRT-IF5: evaluate condition first; condition failure propagates before
      # any branch is touched
      cond_val = eval_expr(expr.fetch("condition"), values, call_trace)

      # LRT-IF7: runtime Bool guard; no truthy/falsy coercion
      unless cond_val == true || cond_val == false
        raise ConditionNotBoolError,
              "if_expr condition must evaluate to Bool (true or false); " \
              "got #{cond_val.class}: #{cond_val.inspect}. " \
              "Internal reason: runtime.if_expr_condition_not_bool"
      end

      # LRT-IF1 / LRT-IF2 / LRT-IF3 / LRT-IF4: lazy branch selection
      # Only the selected branch is passed to eval_expr.
      if cond_val == true
        eval_expr(expr.fetch("then_branch"), values, call_trace) # line A: then_branch only
      else
        eval_expr(expr.fetch("else_branch"), values, call_trace) # line B: else_branch only
      end
    end
  end
end
