module IgniterParserCombinators

include IgniterStringLibrary        # V4 (Parser<T>, SourceSpan, Rune/Grapheme и т.д.)
include IgniterFileIO               # V5 (for easy reading of source codes)

profile mundane_parser_combinators
  time: bitemporal
  evidence: required
  trust: system
  effects: minimal

# ====================== HIGH-LEVEL PARSER COMBINATORS (V6) ======================

# Basic high-level combinators
pure contract ManySepBy<T, Sep>(p: Parser<T>, sep: Parser<Sep>) -> Parser<List[T]>
pure contract Many1SepBy<T, Sep>(p: Parser<T>, sep: Parser<Sep>) -> Parser<List[T]>

pure contract Between<T>(open: Parser[Any], body: Parser<T>, close: Parser[Any]) -> Parser[T]
pure contract SurroundedBy<T>(delim: Parser[Any>, body: Parser<T>) -> Parser[T]

pure contract Option<T>(p: Parser<T>) -> Parser<Optional[T]>
pure contract Optional<T>(p: Parser<T>) -> Parser<T> with_default DefaultValue[T]

pure contract Skip<T>(p: Parser<T>) -> Parser[Unit]                  # ignore the result
pure contract SkipMany<T>(p: Parser<T>) -> Parser[Unit]
pure contract SkipMany1<T>(p: Parser<T>) -> Parser[Unit]

pure contract Eof() -> Parser[Unit]                                  # end of input

pure contract Label<T>(p: Parser<T>, label: String) -> Parser<T>     # for beautiful mistakes
pure contract Attempt<T>(p: Parser<T>) -> Parser<T>                  # try without consuming input on error

# Chains (left/right associative)
pure contract Chainl<T>(p: Parser<T>, op: Parser[(T,T)->T]) -> Parser[T]
pure contract Chainr<T>(p: Parser<T>, op: Parser[(T,T)->T]) -> Parser[T]

# Convenient predefined parsers
pure contract Keyword(kw: String) -> Parser[String]
pure contract Identifier() -> Parser[String]
pure contract IntegerLiteral() -> Parser[Integer]
pure contract DecimalLiteral() -> Parser[Decimal]
pure contract StringLiteral() -> Parser[String]                      # with escape sequences

# ====================== User-friendly forms (DSL) ======================
form (p) "*" (sep)                  => ManySepBy(p, sep)
form (p) "+" (sep)                  => Many1SepBy(p, sep)
form (open) "{" (body) "}" (close)  => Between(open, body, close)   # example: parens { body }
form (p) "!"                        => Skip(p)
form (p) "label" "(" (name) ")"     => Label(p, name)

# ====================== EXAMPLE: MINI-LEXER ON SUMMER PLAYERS ======================

contract IgniterLexer() -> Parser<List[ParserToken]>
{
  let whitespace = SkipMany(Satisfy(is_whitespace))

  let token = Choice([
    Keyword("contract").map(_ => ParserToken { kind: :keyword, value: "contract", ... }),
    Keyword("pure").map(_ => ParserToken { kind: :keyword, value: "pure", ... }),

    Identifier().map(id => ParserToken { kind: :identifier, value: id, ... }),

    IntegerLiteral().map(n => ParserToken { kind: :number, value: n.to_string(), ... }),

    StringLiteral().map(s => ParserToken { kind: :string, value: s, ... }),

    Satisfy(is_operator).map(op => ParserToken { kind: :operator, value: op.char, ... })
  ])

  return ManySepBy(token, whitespace) <* Eof()
}

# ====================== EXAMPLE OF USE WITH FILE ======================

contract ParseIgniterSourceFile(filename: String) -> List[ParserToken]
{
  let content = ReadTextFile(filename)                    # from IgniterFileIO V5

  let result = RunParser(IgniterLexer(), content, filename)

  match result.error {
    None     => return result.value
    Some(err) => {
      let highlighted = HighlightSpan(content, err.span)
      return ParserError { message: err.message + "\n" + highlighted }
    }
  }
}

# ====================== WHAT THIS PROVES (V6) ======================

# 1. A separate high-level Parser Combinators module—a ready-made foundation for a full-fledged Igniter Lang parser
# 2. Many familiar combinators (sep_by, between, chainl/chainr, label, attempt, etc.)
# 3. A beautiful DSL via forms (`p * sep`, `p + sep`, `open { body } close`)
# 4. Full integration with StringLibrary V4 (SourceSpan, Rune/Grapheme) and FileIO V5
# 5. Easy to write a lexer and recursive-descent/combinator parser
# 6. Error reporting with label and highlight—ready for IDEs and compilers
# 7. Everything remains clean, auditable, and Covenant-compliant

end module