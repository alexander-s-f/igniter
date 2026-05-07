# frozen_string_literal: true

require "json"
require "pathname"

require_relative "../igniter_lang"

module IgniterLang
  module CLI
    module_function

    def run(argv)
      command = argv.shift
      unless command == "compile"
        warn "Usage: igc compile SOURCE --out OUT.igapp"
        return false
      end

      source_path, out_path = parse_compile_args(argv)
      orchestration = IgniterLang.compile(source_path: source_path, out_path: out_path)
      puts JSON.pretty_generate(CompilerResult.public_result(orchestration.fetch("result")))
      orchestration.fetch("status") == "ok"
    rescue ArgumentError => e
      warn e.message
      false
    end

    def parse_compile_args(argv)
      source = argv.shift
      raise ArgumentError, "Usage: igc compile SOURCE --out OUT.igapp" unless source

      out_flag = argv.shift
      out = argv.shift
      raise ArgumentError, "Usage: igc compile SOURCE --out OUT.igapp" unless out_flag == "--out" && out

      [Pathname.new(source), Pathname.new(out)]
    end
  end
end
