module IgniterFileIO

profile mundane_file_io
  time: bitemporal
  evidence: required
  trust: system
  effects: minimal          -- everything that concerns real I/O is clearly escape

-- ====================== FILE TYPES ======================
type FileHandle {
  path: String
  mode: :read | :write | :append | :read_write
  encoding: Optional[String]          -- "utf-8", "utf-16", etc.
}

type FileChunk {
  data: Bytes
  offset: Integer
  length: Integer
  source_span: SourceSpan             -- connection with StringLibrary
}

type Line {
  number: Integer
  content: String
  span: SourceSpan
  trailing_newline: Boolean
}

-- ====================== PURE CONTRACTS (metadata, no I/O) ======================
pure contract FileExists(path: String) -> Boolean
pure contract FileSize(path: String) -> Integer
pure contract FileMetadata(path: String) -> Map[String, Any]

-- ====================== ESCAPE CONTRACTS (real I/O) ======================

-- Simply reading the entire file
privileged contract ReadFile(path: String)
  escape file_read
  output content: Bytes
  receipt: FileReadReceipt

-- Line-by-line reading (ideal for parsing)
privileged contract ReadLines(path: String, encoding: Optional[String])
  escape file_read
  output lines: List[Line]
  receipt: FileReadReceipt

-- Streaming / chunked reading (for large files)
privileged contract StreamFile(path: String, chunk_size: Integer)
  escape file_read
  output chunks: Stream[FileChunk]          -- lazy stream
  receipt: FileReadReceipt

-- Memory-mapped (the most efficient way for a parser)
privileged contract MemoryMapFile(path: String)
  escape file_read_mmap
  output mapped: MemoryMappedBuffer
  receipt: FileReadReceipt

-- Recording (if needed for tests/cache)
privileged contract WriteFile(path: String, content: Bytes)
  escape file_write
  output receipt: FileWriteReceipt

-- ====================== CONVENIENT HIGH-LEVEL CONTRACTS ======================

contract ReadTextFile(path: String) -> String
{
  let bytes = ReadFile(path)
  return bytes.to_string_utf8()          -- uses StringLibrary
}

contract ReadLinesWithSpans(path: String) -> List[Line]
{
  return ReadLines(path, "utf-8")
}

contract StreamLines(path: String) -> Stream[Line]
{
  -- streaming version for very large files
  let chunks = StreamFile(path, 64 * 1024)
  return chunks.flat_map(chunk => chunk.data.to_lines_with_spans())
}

-- ====================== RECEIPTS ======================
receipt FileReadReceipt {
  path: String
  bytes_read: Integer
  lines_read: Optional[Integer]
  duration_ms: Integer
  memory_mapped: Boolean
  evidence_bundle: EvidenceBundle
}

receipt FileWriteReceipt {
  path: String
  bytes_written: Integer
  idempotency_key: Optional[String]
  evidence_bundle: EvidenceBundle
}

-- ====================== EXAMPLE OF USE IN THE PARSER ======================

contract ParseIgniterFile(filename: String) -> List[ParserToken]
{
  -- 1. Memory-mapped (the fastest way)
  let mapped = MemoryMapFile(filename)

  -- 2. Passing to StringLibrary
  let source = mapped.as_string()

  -- 3. Run lexer/parser combinators from V4
  let tokens = RunParser(SimpleIgniterLexer(), source, filename)

  return tokens.value
}

-- ====================== WHAT THIS PROVES (V5) ======================

-- 1. A full-fledged FileIO library, ready for use in the Igniter Lang parser
-- 2. Clear separation: ReadFile / MemoryMapFile / StreamFile = ESCAPE, everything else = CORE
-- 3. Support for line-by-line reading, streaming, and memory-mapped data (important for large source files)
-- 4. All operations return receipts + evidence
-- 5. Full compatibility with IgniterStringLibrary V4 (SourceSpan, Rune/Grapheme, Parser combinators)
-- 6. The developer can write "normal" file reading code without unnecessary ceremony
-- 7. Ready for the next step – a full-fledged Lexer + Parser POC

end module