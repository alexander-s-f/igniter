module IgniterStringLibrary

profile mundane_string_parser
  time: bitemporal
  evidence: required
  trust: system
  effects: minimal

# ====================== UNICODE-AWARE TYPES (V3) ======================
type Rune {
  codepoint: Integer          # U+0000 .. U+10FFFF
  char: String               # single character as a string
}

type Grapheme {
  value: String               # what a person sees (there may be several runes)
  runic_length: Integer       # how many runes are inside
  span: SourceSpan            # binding to the source text
}

type NormalizationForm {
  :nfc | :nfd | :nfkc | :nfkd
}

# ====================== NEW CORE CONTRACTS (V3) ======================

# Rune / Grapheme level API
pure contract Runes(text: String) -> List[Rune]
pure contract Graphemes(text: String) -> List[Grapheme]

pure contract RuneAt(text: String, byte_offset: Integer) -> Optional[Rune]
pure contract GraphemeAt(text: String, grapheme_index: Integer) -> Optional[Grapheme]

pure contract GraphemeLength(text: String) -> Integer      # length in user characters
pure contract RuneLength(text: String) -> Integer          # length in code points

# Unicode Normalization
pure contract Normalize(text: String, form: NormalizationForm) -> String
pure contract IsNormalized(text: String, form: NormalizationForm) -> Boolean

# Safe operations at the grapheme level
pure contract GraphemeSlice(text: String, start_grapheme: Integer, length: Integer) -> String
pure contract GraphemeSubstring(text: String, start: Integer, end: Integer) -> String

# Unicode-aware search and replace
pure contract GraphemeIndexOf(text: String, pattern: String) -> Optional[Integer]
pure contract GraphemeReplace(text: String, old: String, new: String) -> ReplaceResult

# Iterators (for parser combinators)
pure contract TakeGraphemes(text: String, position: SourceLocation, count: Integer)
  -> (List[Grapheme], SourceLocation)

pure contract TakeRunes(text: String, position: SourceLocation, count: Integer)
  -> (List[Rune], SourceLocation)

# ======================= UPDATED FORMS (convenient syntax) ========================
form (text) "." "graphemes"                     => Graphemes(text)
form (text) "." "runes"                         => Runes(text)
form (text) "." "normalize" "(" (form) ")"      => Normalize(text, form)
form (text) "." "grapheme_slice" "(" (start) "," (len) ")" => GraphemeSlice(text, start, len)

# ======================== EXAMPLE OF USE IN LEXER / PARSER =========================

contract LexIgniterSourceWithUnicode(source: String, filename: String) -> List[ParserToken]
{
  let pos = SourceLocation { byte_offset: 0, char_offset: 0, line: 1, column: 1 }

  let tokens = []

  while not pos.is_eof(source) {
    pos = SkipWhitespaceAndComments(source, pos)

    # We take the next grapheme (so that emoji and combined symbols don't break)
    let (graphemes, new_pos) = TakeGraphemes(source, pos, 1)

    match graphemes[0] {
      g if g.value.is_identifier_start => {
        let (ident, after) = TakeWhileGraphemes(source, new_pos, is_identifier_char)
        tokens.push(ParserToken {
          kind: :identifier,
          value: ident.join(""),
          span: SourceSpan { start: pos, end: after, source_name: filename }
        })
        pos = after
      }
      # ... other tokens
      _ => pos = new_pos
    }
  }

  return tokens
}

# Example of normalization (important for identifiers)
contract NormalizeIdentifier(id: String) -> String
{
  return id.normalize(:nfkc)   # canonical form for comparing identifiers
}

# ====================== WHAT THIS PROVES (V3) ======================

# 1. Full Unicode support at the Rune and Grapheme level — critical for a modern parser
# 2. Safe text splitting into custom characters (emoji, flags, combining accents)
# 3. Unicode Normalization (NFC/NFKC) — mandatory for correct work with identifiers
# 4. All operations are source-aware and preserve SourceSpan
# 5. The lexical analyzer can now correctly work with any Unicode code
# 6. The library remains convenient for mundane work, but is already ready for the Igniter Lang parser
# 7. The clear boundary between pure CORE and ESCAPE is preserved

end module