module ParserOOF.Stage2

contract TenantFreeCompute {
  input a: Integer
  compute sum = a + 1
  tenant_free
  output sum: Integer
}
