# frozen_string_literal: true

require "strscan"

module Igniter
  module Cluster
    module Mesh
      # MeshQL — a declarative query language for the OLAP Point field.
      #
      # Parses a string query into a ParsedQuery that can be applied to an
      # ObservationQuery or run directly against a collection of NodeObservation.
      #
      # Syntax:
      #
      #   SELECT :capability [, :capability ...]   -- required; * means any
      #   [WHERE condition [AND condition ...]]
      #   [ORDER BY metric [ASC|DESC] [, metric [ASC|DESC] ...]]
      #   [LIMIT n]
      #
      # Conditions (case-insensitive keywords):
      #   TRUSTED                         — trust dimension
      #   HEALTHY                         — state dimension
      #   AUTHORITATIVE                   — provenance dimension
      #   TAGGED :tag                     — capabilities dimension (tag)
      #   NOT :capability                 — capabilities dimension (exclusion)
      #   IN ZONE  "string-or-identifier" — locality dimension
      #   IN REGION "string-or-identifier"
      #   load_cpu     < | <= | > | >= | = | != value
      #   load_memory  ...
      #   concurrency  ...
      #   queue_depth  ...
      #   confidence   ...
      #   hops         ...
      #
      # Orderable metrics (ORDER BY):
      #   load_cpu, load_memory, concurrency, queue_depth, confidence, hops
      #
      # Examples:
      #   MeshQL.parse("SELECT :database WHERE trusted AND load_cpu < 0.5 LIMIT 3")
      #   MeshQL.run("SELECT * WHERE healthy IN ZONE us-east-1a ORDER BY load_cpu", observations)
      #
      module MeshQL
        ParseError = Class.new(StandardError)

        METRICS = %w[
          load_cpu load_memory concurrency queue_depth confidence hops
        ].freeze

        OPERATORS = %w[<= >= != < > =].freeze

        KEYWORDS = %w[
          SELECT WHERE AND ORDER BY LIMIT NOT IN ZONE REGION
          ASC DESC TRUSTED HEALTHY AUTHORITATIVE TAGGED
        ].freeze

        module_function

        # Parse a MeshQL string into a ParsedQuery.
        def parse(source)
          tokens = Tokenizer.run(source.to_s)
          Parser.new(tokens).parse
        end

        # Parse and execute in one step.
        def run(source, observations)
          parse(source).to_query(observations).to_a
        end

        # ── Tokenizer ───────────────────────────────────────────────────────

        module Tokenizer
          module_function

          def run(source)
            tokens = []
            scanner = StringScanner.new(source.strip)

            until scanner.eos?
              scanner.skip(/\s+/)
              break if scanner.eos?

              token = scan_token(scanner)
              tokens << token
            end

            tokens
          end

          def scan_token(scanner)
            # Two-char operators first
            if (op = scanner.scan(/<=|>=|!=/))
              return [:op, op]
            end

            # Single-char operators and punctuation
            if (op = scanner.scan(/[<>=,*]/))
              return [:op, op]
            end

            # Quoted string
            if (str = scanner.scan(/"([^"]*)"/) || scanner.scan(/'([^']*)'/))
              return [:string, scanner[1]]
            end

            # Symbol :identifier (including hyphens for zone names like "rack-12")
            if (sym = scanner.scan(/:([a-z_][a-z0-9_-]*)/))
              return [:symbol, scanner[1].to_sym]
            end

            # Float before int
            if (num = scanner.scan(/\d+\.\d+/))
              return [:number, num.to_f]
            end

            if (num = scanner.scan(/\d+/))
              return [:number, num.to_i]
            end

            # Unquoted identifier / keyword — allows hyphens in zone names
            if (word = scanner.scan(/[A-Za-z_][A-Za-z0-9_.:-]*/))
              upper = word.upcase
              # If it's a known keyword, emit as keyword; else as bare string value
              if KEYWORDS.include?(upper) || METRICS.include?(word.downcase)
                return [:word, upper]
              else
                return [:string, word]
              end
            end

            raise ParseError, "Unexpected character '#{scanner.peek(1)}' near: #{scanner.rest.slice(0, 20).inspect}"
          end
        end

        # ── Parser ──────────────────────────────────────────────────────────

        class Parser
          def initialize(tokens)
            @tokens = tokens
            @pos    = 0
          end

          def parse
            expect_keyword("SELECT")
            capabilities = parse_capabilities

            conditions = []
            if peek_keyword?("WHERE")
              advance
              conditions = parse_conditions
            end

            orderings = []
            if peek_keyword?("ORDER")
              advance
              expect_keyword("BY")
              orderings = parse_orderings
            end

            limit = nil
            if peek_keyword?("LIMIT")
              advance
              limit = expect_number
            end

            ParsedQuery.new(capabilities: capabilities, conditions: conditions, orderings: orderings, limit: limit)
          end

          private

          # SELECT :database, :orders  |  SELECT *
          def parse_capabilities
            if peek_op?("*")
              advance
              return :all
            end

            caps = [expect_capability]
            while peek_op?(",")
              advance
              caps << expect_capability
            end
            caps
          end

          def expect_capability
            tok = current
            case tok&.first
            when :symbol
              advance
              tok[1]
            when :string
              advance
              tok[1].to_sym
            when :word
              # bare unquoted word used as capability name
              advance
              tok[1].downcase.to_sym
            else
              raise ParseError, "Expected capability (e.g. :database), got #{tok.inspect}"
            end
          end

          def parse_conditions
            conds = [parse_one_condition]
            while peek_keyword?("AND")
              advance
              conds << parse_one_condition
            end
            conds
          end

          def parse_one_condition
            tok = current

            case tok
            in [:word, "TRUSTED"]
              advance; { type: :trusted }
            in [:word, "HEALTHY"]
              advance; { type: :healthy }
            in [:word, "AUTHORITATIVE"]
              advance; { type: :authoritative }
            in [:word, "TAGGED"]
              advance
              { type: :tagged, value: expect_capability }
            in [:word, "NOT"]
              advance
              { type: :without, value: expect_capability }
            in [:word, "IN"]
              advance
              dim = expect_dimension_keyword(%w[ZONE REGION])
              value = expect_string_value
              { type: :locality, dimension: dim.downcase.to_sym, value: value }
            in [:word, metric_upper] if METRICS.include?(metric_upper.downcase)
              advance
              op    = expect_operator
              value = expect_number
              { type: :metric, metric: metric_upper.downcase.to_sym, op: op, value: value }
            else
              raise ParseError, "Unexpected WHERE condition: #{tok.inspect}"
            end
          end

          def parse_orderings
            ords = [parse_one_ordering]
            while peek_op?(",")
              advance
              ords << parse_one_ordering
            end
            ords
          end

          def parse_one_ordering
            tok = current
            unless tok&.first == :word && METRICS.include?(tok[1].downcase)
              raise ParseError, "Expected metric name for ORDER BY, got #{tok.inspect}"
            end

            metric = tok[1].downcase.to_sym
            advance

            direction = if peek_keyword?("ASC")
                          advance; :asc
                        elsif peek_keyword?("DESC")
                          advance; :desc
                        else
                          :asc
                        end

            { metric: metric, direction: direction }
          end

          # ── Token helpers ─────────────────────────────────────────────────

          def current
            @tokens[@pos]
          end

          def advance
            tok = @tokens[@pos]
            @pos += 1
            tok
          end

          def peek_keyword?(word)
            current&.then { |t| t[0] == :word && t[1] == word.upcase }
          end

          def peek_op?(op)
            current&.then { |t| t[0] == :op && t[1] == op }
          end

          def expect_keyword(word)
            tok = advance
            return tok if tok&.then { |t| t[0] == :word && t[1] == word.upcase }

            raise ParseError, "Expected #{word}, got #{tok.inspect}"
          end

          def expect_dimension_keyword(words)
            tok = advance
            upper = tok&.then { |t| t[0] == :word ? t[1] : nil }
            return upper if upper && words.include?(upper)

            raise ParseError, "Expected one of #{words.inspect}, got #{tok.inspect}"
          end

          def expect_operator
            tok = advance
            return tok[1] if tok&.first == :op && OPERATORS.include?(tok[1])

            raise ParseError, "Expected operator (<, <=, >, >=, =, !=), got #{tok.inspect}"
          end

          def expect_number
            tok = advance
            return tok[1] if tok&.first == :number

            raise ParseError, "Expected number, got #{tok.inspect}"
          end

          def expect_string_value
            tok = advance
            case tok&.first
            when :string then tok[1]
            when :symbol then tok[1].to_s
            when :word   then tok[1]
            else
              raise ParseError, "Expected string value, got #{tok.inspect}"
            end
          end
        end

        # ── ParsedQuery ─────────────────────────────────────────────────────

        # Typed result of MeshQL.parse. Can be applied to an ObservationQuery
        # and serialized back to a MeshQL string.
        class ParsedQuery
          attr_reader :capabilities, :conditions, :orderings, :limit

          def initialize(capabilities:, conditions:, orderings:, limit:)
            @capabilities = capabilities
            @conditions   = conditions.freeze
            @orderings    = orderings.freeze
            @limit        = limit
            freeze
          end

          # Apply this query to an ObservationQuery and return the result query.
          def apply(observation_query)
            q = observation_query

            unless @capabilities == :all
              q = q.with(*@capabilities) unless @capabilities.empty?
            end

            @conditions.each { |cond| q = apply_condition(q, cond) }
            @orderings.each  { |ord|  q = q.order_by(ord[:metric], direction: ord[:direction]) }
            q = q.limit(@limit) if @limit

            q
          end

          # Build a fresh ObservationQuery from a collection and run the query.
          def to_query(observations)
            apply(ObservationQuery.new(observations))
          end

          # Serialize back to a canonical MeshQL string.
          def to_meshql
            parts = ["SELECT #{caps_to_s}"]
            unless @conditions.empty?
              parts << "WHERE #{@conditions.map { |c| condition_to_s(c) }.join(' AND ')}"
            end
            unless @orderings.empty?
              parts << "ORDER BY #{@orderings.map { |o| "#{o[:metric]} #{o[:direction].upcase}" }.join(', ')}"
            end
            parts << "LIMIT #{@limit}" if @limit
            parts.join(' ')
          end

          private

          def apply_condition(query, cond)
            case cond[:type]
            when :trusted       then query.trusted
            when :healthy       then query.healthy
            when :authoritative then query.authoritative
            when :tagged        then query.tagged(cond[:value])
            when :without       then query.without(cond[:value])
            when :locality
              case cond[:dimension]
              when :zone   then query.in_zone(cond[:value])
              when :region then query.in_region(cond[:value])
              end
            when :metric
              apply_metric(query, cond[:metric], cond[:op], cond[:value])
            else
              query
            end
          end

          def apply_metric(query, metric, op, value)
            query.where do |obs|
              actual = case metric
                       when :load_cpu    then obs.load_cpu
                       when :load_memory then obs.load_memory
                       when :concurrency then obs.concurrency.to_f
                       when :queue_depth then obs.queue_depth.to_f
                       when :confidence  then obs.confidence
                       when :hops        then obs.hops.to_f
                       end

              next true if actual.nil? && op == "!="
              next false if actual.nil?

              case op
              when "<"  then actual < value
              when "<=" then actual <= value
              when ">"  then actual > value
              when ">=" then actual >= value
              when "="  then actual == value
              when "!=" then actual != value
              end
            end
          end

          def caps_to_s
            return "*" if @capabilities == :all

            @capabilities.map { |c| ":#{c}" }.join(", ")
          end

          def condition_to_s(cond)
            case cond[:type]
            when :trusted       then "TRUSTED"
            when :healthy       then "HEALTHY"
            when :authoritative then "AUTHORITATIVE"
            when :tagged        then "TAGGED :#{cond[:value]}"
            when :without       then "NOT :#{cond[:value]}"
            when :locality      then "IN #{cond[:dimension].upcase} #{quote(cond[:value])}"
            when :metric        then "#{cond[:metric]} #{cond[:op]} #{cond[:value]}"
            end
          end

          def quote(value)
            value.to_s.match?(/\s/) ? "\"#{value}\"" : value.to_s
          end
        end
      end
    end
  end
end
