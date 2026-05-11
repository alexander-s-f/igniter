module IgniterStringLibrary

profile mundane_string
  time: bitemporal
  evidence: required
  trust: system
  effects: minimal          -- Almost everything is pure, escape only when necessary

-- ====================== CORE STRING TYPES ======================
type SearchResult {
  position: Integer
  match: String
  captured: Optional[List[String]]   -- for regex groups
}

type ReplaceResult {
  new_string: String
  replacements_made: Integer
}

type Token {
  value: String
  kind: :word | :number | :punctuation | :whitespace | :symbol
  position: Integer
}

-- ====================== PURE CONTRACTS — main library ======================

-- Search
pure contract Search(text: String, pattern: String) -> List[SearchResult]
pure contract Contains(text: String, substring: String) -> Boolean
pure contract IndexOf(text: String, substring: String) -> Optional[Integer]
pure contract RegexSearch(text: String, regex: String) -> List[SearchResult]

-- Replacement
pure contract Replace(text: String, old: String, new: String) -> ReplaceResult
pure contract ReplaceAll(text: String, old: String, new: String) -> ReplaceResult
pure contract RegexReplace(text: String, regex: String, replacement: String) -> ReplaceResult

-- Selection / Extraction
pure contract Substring(text: String, start: Integer, length: Integer) -> String
pure contract Slice(text: String, from: Integer, to: Integer) -> String
pure contract ExtractBetween(text: String, start_marker: String, end_marker: String) -> Optional[String]

-- Copy/paste/move (splice-style)
pure contract Insert(text: String, position: Integer, insert: String) -> String
pure contract Delete(text: String, start: Integer, length: Integer) -> String
pure contract Move(text: String, from: Integer, length: Integer, to: Integer) -> String

-- Tokenization
pure contract Split(text: String, delimiter: String) -> List[String]
pure contract Tokenize(text: String) -> List[Token]          -- умная токенизация
pure contract Words(text: String) -> List[String]

-- Convenient forms (via Form System - look like regular code)
form (text) "." "search" "(" (pattern) ")"      => Search(text, pattern)
form (text) "." "replace" "(" (old) "," (new) ")" => Replace(text, old, new)
form (text) "." "replace_all" "(" (old) "," (new) ")" => ReplaceAll(text, old, new)
form (text) "." "slice" "(" (from) "," (to) ")" => Slice(text, from, to)
form (text) "." "insert" "(" (pos) "," (what) ")" => Insert(text, pos, what)

-- ====================== USAGE EXAMPLE (as the developer will write) ======================

contract ProcessUserComment(comment: String) -> ProcessedComment
{
  -- Plain, readable code
  let cleaned = comment
    .replace_all("<script>", "")
    .replace_all("</script>", "")

  let tokens = cleaned.tokenize()

  let mentions = tokens.filter(t => t.kind == :symbol && t.value.starts_with("@"))

  let result = if cleaned.contains("http") {
    "Contains a link - moderation required"
  } else {
    "OK"
  }

  return {
    original: comment,
    cleaned: cleaned,
    tokens: tokens,
    mentions: mentions,
    status: result
  }
}

-- ====================== WHAT THIS PROVES ======================

-- 1. Working with strings feels natural and pleasant—like in Ruby/Python/JS
-- 2. All operations are pure contracts, no escapes until the actual effect is achieved
-- 3. Forms provide convenient "syntactic sugar" without violating contractuality
-- 4. Tokenize, Search, ReplaceAll, Slice, etc. are fully typed and auditable
-- 5. Clear boundary CORE (strings) ↔ ESCAPE (only when writing to a file/DB)
-- 6. The library is easily extensible by the user (you can add your own forms)
-- 7. Mundane pressure is successfully overcome: boring string mechanics require no ceremony

end module