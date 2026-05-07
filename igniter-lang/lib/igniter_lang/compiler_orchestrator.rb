# frozen_string_literal: true

require "fileutils"
require "json"
require "pathname"

require_relative "assembler"
require_relative "classifier"
require_relative "compilation_report"
require_relative "compiler_result"
require_relative "parser"
require_relative "semanticir_emitter"
require_relative "typechecker"

module IgniterLang
  class CompilerOrchestrator
    FORMAT_VERSION = SemanticIREmitter::FORMAT_VERSION

    def initialize(
      classifier: Classifier.new,
      typechecker: TypeChecker.new,
      emitter: SemanticIREmitter.new,
      assembler: Assembler.new
    )
      @classifier = classifier
      @typechecker = typechecker
      @emitter = emitter
      @assembler = assembler
    end

    def compile(source_path:, out_path:, sample_input: nil, sample_input_resolver: nil, runtime_smoke: nil)
      source_path = Pathname.new(source_path)
      out_path = Pathname.new(out_path)
      parsed = ParsedProgram.parse(File.read(source_path), source_path: source_path.to_s).to_h
      return parse_failure(parsed, source_path, out_path) unless parsed.fetch("parse_errors").empty?

      resolved_sample_input = sample_input || resolve_sample_input(parsed, sample_input_resolver)
      classified = @classifier.classify(parsed, sample_input: resolved_sample_input)
      typed = @typechecker.typecheck(classified)
      compilation = @emitter.emit(parsed, sample_input: resolved_sample_input)
      report = CompilationReport.enrich(
        report: compilation.fetch("compilation_report"),
        parsed: parsed
      )
      semantic_ir = compilation.fetch("semantic_ir")

      return refusal(report, source_path, out_path) unless report.fetch("pass_result") == "ok"

      assembled = @assembler.assemble_artifacts(
        case_name: case_name_for(source_path, parsed),
        report: report,
        semantic_ir: semantic_ir,
        target_dir: out_path
      )
      smoke = runtime_smoke&.call(out_path: out_path, sample_input: resolved_sample_input)

      if smoke && !smoke.fetch("trusted")
        smoke_report = CompilationReport.runtime_smoke_failure(
          report: report,
          smoke: smoke,
          source_path: source_path
        )
        return refusal(smoke_report, source_path, out_path, status: "runtime_smoke_failed")
      end

      {
        "status" => "ok",
        "result" => CompilerResult.ok(
          format_version: FORMAT_VERSION,
          semantic_ir: semantic_ir,
          source_path: source_path,
          report: report,
          igapp_path: out_path,
          contracts: assembled.fetch("contracts"),
          runtime_smoke: smoke
        ),
        "parsed_program" => parsed,
        "classified_program" => classified,
        "typed_program" => typed,
        "semantic_ir" => semantic_ir,
        "compilation_report" => report,
        "assembled" => assembled,
        "sample_input" => resolved_sample_input
      }
    rescue AssemblyRefused => e
      report = CompilationReport.internal_error(
        format_version: FORMAT_VERSION,
        source_path: source_path,
        rule: "assembler_refused",
        error: e
      )
      refusal(report, source_path, out_path, status: "assembler_refused")
    rescue => e
      report = CompilationReport.internal_error(
        format_version: FORMAT_VERSION,
        source_path: source_path,
        rule: "compiler_error",
        error: e
      )
      refusal(report, source_path, out_path, status: "error")
    end

    private

    def parse_failure(parsed, source_path, out_path)
      report = CompilationReport.parse_failure(
        format_version: FORMAT_VERSION,
        parsed: parsed,
        source_path: source_path
      )
      refusal(report, source_path, out_path, status: "error")
    end

    def refusal(report, source_path, out_path, status: "oof")
      report_path = report_path_for(out_path)
      write_json(report_path, report)
      {
        "status" => status,
        "result" => CompilerResult.refusal(
          format_version: FORMAT_VERSION,
          status: status,
          report: report,
          source_path: source_path,
          report_path: report_path
        ),
        "compilation_report" => report,
        "report_path" => report_path.to_s
      }
    end

    def report_path_for(out_path)
      raw = out_path.to_s
      if raw.end_with?(".igapp")
        Pathname.new(raw.delete_suffix(".igapp") + ".compilation_report.json")
      else
        Pathname.new("#{raw}.compilation_report.json")
      end
    end

    def write_json(path, value)
      FileUtils.mkdir_p(Pathname.new(path).dirname)
      File.write(path, "#{JSON.pretty_generate(value)}\n")
    end

    def resolve_sample_input(parsed, sample_input_resolver)
      return sample_input_resolver.call(parsed) if sample_input_resolver

      default_sample_input(parsed.fetch("contracts").fetch(0, {}))
    end

    def default_sample_input(contract)
      contract.fetch("body", []).each_with_object({}) do |node, inputs|
        next unless node.fetch("kind") == "input"

        inputs[node.fetch("name")] = sample_value_for(node.fetch("type_annotation"))
      end
    end

    def sample_value_for(type_annotation)
      type_name = if type_annotation.is_a?(Hash)
                    type_annotation.fetch("name", "Unknown")
                  else
                    type_annotation.to_s
                  end
      case type_name
      when "Integer" then 1
      when "Float" then 1.0
      when "Bool" then true
      when "String" then "synthetic"
      else {}
      end
    end

    def case_name_for(source_path, parsed)
      basename = File.basename(source_path.to_s, ".ig")
      return basename unless basename.empty?

      parsed.fetch("contracts").fetch(0).fetch("name").downcase
    end
  end
end
