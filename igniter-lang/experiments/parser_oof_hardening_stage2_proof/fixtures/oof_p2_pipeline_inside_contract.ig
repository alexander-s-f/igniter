module ParserOOF.Stage2

contract PipelineInsideContract {
  input a: Integer

  pipeline BadPipe[Integer, Integer, String] {
    step pass: Some.Step
  }

  output a: Integer
}
