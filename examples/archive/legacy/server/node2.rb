# frozen_string_literal: true

# Node 2 — simple sentiment analysis service on port 4568
# Run: ruby examples/server/node2.rb

require_relative "../../lib/igniter/server"

class SentimentAnalyzer < Igniter::Contract
  define do
    input :text
    compute :score,
            depends_on: :text,
            call: lambda { |text:|
              # Naive sentiment: longer text = more confident
              positive_words = %w[good great excellent amazing awesome love]
              words = text.downcase.split
              hits = words.count { |w| positive_words.include?(w) }
              (hits.to_f / [words.size, 1].max).round(2)
            }
    output :score
  end
end

Igniter::Server.configure do |c|
  c.port = 4568
  c.register "SentimentAnalyzer", SentimentAnalyzer
end

puts "Node 2 (SentimentAnalyzer) starting on port 4568..."
Igniter::Server.start
