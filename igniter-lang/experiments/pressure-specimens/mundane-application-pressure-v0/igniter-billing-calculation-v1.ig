module IgniterBillingCalculation

profile mundane_billing
  time: bitemporal
  evidence: required
  trust: system
  effects: minimal

type Money { amount: Decimal[4]; currency: String }

type InvoiceLine {
  description: String
  quantity: Decimal[2]
  unit_price: Money
  tax_rate: Decimal[2]          -- 0.20 = 20%
}

type Invoice {
  lines: List[InvoiceLine]
  subtotal: Money
  tax_total: Money
  total: Money
  idempotency_key: String
}

-- CORE: pure mathematics (no escapes)
pure contract CalculateLineTotal(line: InvoiceLine) -> Money

pure contract CalculateInvoice(lines: List[InvoiceLine]) -> Invoice
{
  let subtotal = lines.map(line => CalculateLineTotal(line)).sum()
  let tax_total = subtotal * lines.map(line => line.tax_rate).sum()
  let total = subtotal + tax_total

  return {
    lines: lines,
    subtotal: subtotal,
    tax_total: tax_total,
    total: total.round(half_up, 2),
    idempotency_key: request.headers["Idempotency-Key"]
  }
}

-- ESCAPE: only saving to the database
privileged contract PersistInvoice(invoice: Invoice)
  escape db_write
  output receipt: InvoiceReceipt

contract CreateInvoice(lines: List[InvoiceLine])
  -> receipt: InvoiceReceipt
{
  let invoice = CalculateInvoice(lines)          -- pure CORE
  return PersistInvoice(invoice)                 -- only here ESCAPE
}

-- ====================== WHAT THIS PROVES ======================
-- 1. Decimal arithmetic, rounding, and taxes look natural
-- 2. No boilerplate: calculation = regular function
-- 3. Idempotency and receipt appear automatically when writing
-- 4. Clear separation of CORE math and ESCAPE writing

end module