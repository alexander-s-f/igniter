module IgniterCsvImporter

profile mundane_csv_import
  time: bitemporal
  evidence: required
  trust: system
  effects: minimal

type CsvRow { raw: Map[String, String] }
type ImportRecord { ... }   -- your domain type

pure contract ParseCsvFile(content: Bytes) -> List[CsvRow]

pure contract MapAndValidateRow(row: CsvRow) -> Result[ImportRecord, List[ValidationError]]

pure contract BatchImport(records: List[ImportRecord])
  escape db_write_batch
  output receipt: ImportReceipt

contract ImportCsv(content: Bytes)
  -> receipt: ImportReceipt
{
  let rows = ParseCsvFile(content)

  let records = rows.map(MapAndValidateRow)
                    .filter(Ok)
                    .map(Ok.value)

  return BatchImport(records)
}

-- ====================== WHAT THIS PROVES ======================
-- 1. CSV parsing, column mapping, and validation look like a regular script.
-- 2. Result/Option ergonomics work well.
-- 3. Only BatchImport is a true escape.
-- 4. Full receipt + evidence for import.

end module