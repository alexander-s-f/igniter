# frozen_string_literal: true

# Node 1 — orchestrator that calls Node 2 via remote: DSL on port 4567
# Run: first start node2.rb, then start node1.rb in another terminal
#
# Test:
#   curl -s -X POST http://localhost:4567/v1/contracts/ArticleAnalysis/execute \
#        -H 'Content-Type: application/json' \
#        -d '{"inputs":{"article":"Ruby is great and awesome!"}}'

require_relative "../../lib/igniter/server"

class ArticleAnalysis < Igniter::Contract
  define do
    input :article

    # Call the SentimentAnalyzer running on node2
    remote :sentiment,
           contract: "SentimentAnalyzer",
           node:     "http://localhost:4568",
           inputs:   { text: :article }

    compute :summary,
            depends_on: :sentiment,
            call: lambda { |sentiment:|
              score = sentiment[:score]
              tone  = score > 0.5 ? "positive" : score > 0.2 ? "neutral" : "negative"
              { score: score, tone: tone }
            }

    output :summary
  end
end

Igniter::Server.configure do |c|
  c.port = 4567
  c.register "ArticleAnalysis", ArticleAnalysis
end

puts "Node 1 (ArticleAnalysis) starting on port 4567..."
puts "Calls Node 2 (SentimentAnalyzer) at http://localhost:4568"
Igniter::Server.start
