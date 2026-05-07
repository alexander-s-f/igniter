#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require_relative "../../lib/igniter_lang/parser"

if __FILE__ == $PROGRAM_NAME
  path = ARGV[0]
  abort "Usage: #{$0} <source.ig>" unless path

  source = File.read(path)
  pp_obj = IgniterLang::ParsedProgram.parse(source, source_path: path)
  if pp_obj.valid?
    puts JSON.pretty_generate(pp_obj.to_h)
  else
    $stderr.puts "Parse errors:"
    pp_obj.errors.each { |e| $stderr.puts "  Line #{e["line"]}: #{e["message"]}" }
    exit 1
  end
end
