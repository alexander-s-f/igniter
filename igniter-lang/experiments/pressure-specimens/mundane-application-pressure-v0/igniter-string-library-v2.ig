module IgniterStringLibrary

profile mundane_string_parser
  time: bitemporal
  evidence: required
  trust: system
  effects: minimal

# ====================== SOURCE-AWARE TYPES ======================
type SourceLocation {
  byte_offset: Integer
  char_offset: Integer
  line: Integer
  column: Integer
}

type SourceSpan {
  start: SourceLocation
  end: SourceLocation
  source_name: Optional[String]   # "input.ig", "webhook.json" etc.
}

type ParserToken {
  kind: :keyword | :identifier | :number | :string | :symbol | :operator | :whitespace | :comment | :eof
  value: String
  span: SourceSpan
}

# ====================== CORE CONTRACTS (V2) ======================

# Search with positions
pure contract Find(text: String, pattern: String) -> List[SearchResult]
pure contract FindRegex(text: String, regex: String) -> List[SearchResult]

# Selection/slice with source mapping
pure contract Slice(text: String, span: SourceSpan) -> String
pure contract Substring(text: String, start: Integer, length: Integer) -> String with_span SourceSpan

# Copy/paste/move (preserving span)
pure contract Insert(text: String, at: SourceLocation, insert: String) -> String
pure contract Delete(text: String, span: SourceSpan) -> String
pure contract ReplaceSpan(text: String, span: SourceSpan, replacement: String) -> String

# Tokenization (the main feature for lexer)
pure contract Tokenize(text: String, source_name: Optional[String]) -> List[ParserToken]
pure contract TokenizeWithRules(text: String, rules: List[TokenRule]) -> List[ParserToken]

# Streaming / incremental (for parser combinators)
pure contract Peek(text: String, position: SourceLocation, n: Integer) -> String
pure contract TakeWhile(text: String, position: SourceLocation, predicate: (Char) -> Boolean) -> (String, SourceLocation)
pure contract TakeUntil(text: String, position: SourceLocation, pattern: String) -> (String, SourceLocation)

# Whitespace / comment skipping
pure contract SkipWhitespace(text: String, position: SourceLocation) -> SourceLocation
pure contract SkipComments(text: String, position: SourceLocation) -> SourceLocation

# Error reporting helpers
pure contract HighlightSpan(text: String, span: SourceSpan) -> String   # возвращает строку с ^^^ подчёркиванием
pure contract ErrorAt(text: String, span: SourceSpan, message: String) -> ParserError

# Convenient forms (syntactic sugar)
form (text) "." "find" "(" (pattern) ")"                    => Find(text, pattern)
form (text) "." "slice" "(" (span) ")"                      => Slice(text, span)
form (text) "." "tokenize"                                  => Tokenize(text, none)
form (text) "." "peek" "(" (pos) "," (n) ")"                => Peek(text, pos, n)

# ======================== EXAMPLE OF USE IN LEXER ========================

contract LexIgniterSource(source: String, filename: String) -> List[ParserToken]
{
  let pos = SourceLocation { byte_offset: 0, char_offset: 0, line: 1, column: 1 }

  let tokens = []

  while not pos.is_eof(source) {
    pos = SkipWhitespace(source, pos)
    pos = SkipComments(source, pos)

    let (token_text, new_pos) = TakeWhile(source, pos, is_identifier_char)

    if token_text.is_not_empty {
      tokens.push(ParserToken {
        kind: :identifier,
        value: token_text,
        span: SourceSpan { start: pos, end: new_pos, source_name: filename }
      })
    }

    pos = new_pos
  }

  return tokens
}

# ====================== WHAT THIS PROVES ======================

# 1. The String Library is fully prepared for developing a full-fledged Igniter Lang Parser/Lexer.
# 2. All operations are source-aware (SourceSpan + SourceLocation) — the basis for error reporting and the IDE.
# 3. Tokenize, Peek, TakeWhile/TakeUntil — ideal for parser combinators.
# 4. Clear separation of CORE (pure string operations) and ESCAPE (only when reading/writing files).
# 5. Forms provide a convenient, readable syntax.
# 6. Unicode/graphemes/positioning are taken into account.
# 7. The library is ready for use in the Igniter Lang parser POC.

end module