module IgniterWebFrameworkSinatraLike

include IgniterWebFrameworkPrimitives

profile audited_web_framework
  time: bitemporal
  lifecycle: service
  backend: http_server
  consistency: causal
  evidence: required
  trust: system
  effects: privileged
  receipts: immutable
  loop: service_progression
  authority: explicit

# ====================== SINATRA-LIKE DSL (forms) ======================
# The user writes exactly this:
# get "/users/:id" { ... }   ← через Form System (BlockMethodForm)

# ====================== EXTERNAL PROGRESSION — HTTP request loop ======================
service contract SinatraLikeWebServer
  progression driven_by http_listener.on_request
  authority web_server_authority: AuthorityRef
{
  # 1. Observe incoming request
  observed contract ReceiveHttpRequest
    input raw_request: RawHttpPacket
    output request: HttpRequest
    evidence [raw_request]

  # 2. Middleware chain
  pure contract ApplyMiddleware
    input request: HttpRequest
    output processed: HttpRequest evidence [request]

  # 3. Route matching + handler execution
  pure contract ResolveAndExecute
    input request: HttpRequest
    uses assumptions web_framework
    uses constraints web_framework
    output response: HttpResponse evidence [request]

  # 4. Act — send response (privileged)
  privileged contract SendHttpResponse
    input response: HttpResponse
    escape http_response
    output receipt: HttpRequestReceipt
    compensation LogFailedResponse
    authority web_server_authority

  # 5. Post-request audit (Postulate 26)
  audit contract PostRequestAudit
    input receipt: HttpRequestReceipt
    input later_observation: Optional[HttpResponse]
    output audit_receipt: PostAuditReceipt
}

# ====================== PUBLIC SINATRA-LIKE API (for users) ======================
# The user registers these contracts through forms.

contract Get(path: String) {
  handler: Block
  # inside the block is pure Igniter code with evidence
}

contract Post(path: String) {
  handler: Block
}

contract Put(path: String)   { handler: Block }
contract Delete(path: String){ handler: Block }

# ====================== INVARIANTS ======================
invariant every_request_has_receipt          { severity: critical }
invariant no_silent_http_error               { severity: critical }
invariant route_match_evidence               { severity: legal }
invariant response_immutable                 { severity: critical }

# ====================== RECEIPTS ======================
receipt HttpRequestReceipt {
  request: HttpRequest
  response: HttpResponse
  route_matched: Route
  middlewares_applied: List[Middleware]
  epistemic_transition: :observed → :responded
  assumptions_hash: Hash
  audit_reference: Optional[PostAuditReceipt]
}

receipt PostAuditReceipt {
  request_id: UUID
  status_code: Integer
  latency_ms: Integer
  closed_loop: Boolean
  honesty_statement: String
}

# ====================== WHAT THIS PROVES ======================

# 1. Igniter Lang can be a full-fledged web framework developer
# 2. Sinatra-like syntax via Form System (get "/path" { ... })
# 3. Full request lifecycle with evidence, middleware, and routing
# 4. External Progression as an HTTP request loop
# 5. Full Covenant compliance (Postulates 22–28): assumptions, constraints, PostAudit, no silent errors
# 6. Each request is an auditable artifact with receipt and PostAudit
# 7. Multi-module architecture + include + .iform-ready
# 8. The developer writes like Sinatra, but gets maximum integrity and observability

end module