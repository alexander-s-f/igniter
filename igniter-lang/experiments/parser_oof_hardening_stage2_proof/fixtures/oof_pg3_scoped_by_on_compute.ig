module ParserOOF.Stage2

contract ScopedCompute {
  input scope: String
  input a: Integer
  compute sum = a + 1
  scoped_by scope
  output sum: Integer
}
