module Fixture.ParserOOF.Invalid

contract MissingColon {
  input a Integer
  compute sum = a + 1
  output sum: Integer
}
