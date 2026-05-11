module IgniterWebFrameworkPrimitives

profile web_primitives
  time: bitemporal
  evidence: required
  trust: system

-- ====================== FRAMEWORK CORE TYPES ======================
type HttpRequest {
  method: :get | :post | :put | :delete | :patch
  path: String
  headers: Map[String, String]
  query: Map[String, String]
  body: Optional[Bytes]
  timestamp: Timestamp
}

type HttpResponse {
  status: Integer
  headers: Map[String, String]
  body: Bytes
  content_type: String
}

type Route {
  method: :get | :post | :put | :delete | :patch
  path_pattern: String          -- поддержка :id, * и т.д.
  handler_contract: ContractRef
}

type Middleware {
  name: String
  before: Boolean
  after: Boolean
  handler: ContractRef
}

-- ====================== ASSUMPTIONS & CONSTRAINTS ======================
assumptions web_framework {
  assumption request_is_immutable {
    kind: :empirical
    statement "An HTTP request is never mutated after it arrives."
    strength: 0.95
  }
}

constraints web_framework {
  constraint every_request_audited {
    kind: :epistemic
    priority: 1.0
    statement "Each request must have an auditable receipt."
  }
  constraint no_silent_error {
    kind: :ethical
    priority: 0.99
    statement "All errors and exceptions must be explicitly recorded in the receipt."
  }
}

-- ====================== FRAMEWORK CONTRACTS ======================
pure contract MatchRoute
  input request: HttpRequest
  input registered_routes: List[Route]
  output matched: Optional[Route] evidence [request, registered_routes]

pure contract ExecuteHandler
  input request: HttpRequest
  input route: Route
  output response: HttpResponse evidence [request, route]

pure contract RunMiddlewareChain
  input request: HttpRequest
  input middlewares: List[Middleware]
  output processed_request: HttpRequest evidence [request]

receipt HttpRequestReceipt { ... }

end module