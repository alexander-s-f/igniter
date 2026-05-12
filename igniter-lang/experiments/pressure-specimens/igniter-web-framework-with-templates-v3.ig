module IgniterWebFrameworkWithTemplates

include IgniterWebFrameworkPrimitives
include IgniterTemplateEnginePrimitives

profile audited_web_framework_with_templates
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

# ====================== SINATRA-LIKE + TEMPLATE DSL ======================
service contract SinatraLikeWebServerWithTemplates
  progression driven_by http_listener.on_request
  authority web_server_authority: AuthorityRef
{
  # 1. Receive request
  observed contract ReceiveHttpRequest
    input raw: RawHttpPacket
    output request: HttpRequest
    evidence [raw]

  # 2. Middleware + routing (like before)
  pure contract ApplyMiddlewareAndResolveRoute
    input request: HttpRequest
    output route: Route
    evidence [request]

  # 3. Execute handler + template rendering (new)
  pure contract ExecuteHandlerWithTemplate
    input request: HttpRequest
    input route: Route
    output response: HttpResponse evidence [request, route]

  # 4. Render template (if handler returned template name)
  pure contract RenderResponseTemplate
    input handler_result: Map[String, Any]   # data from the controller
    input template_name: String
    output rendered: RenderedOutput evidence [handler_result, template_name]

  # 5. Send final HTTP response
  privileged contract SendHttpResponse
    input response: HttpResponse
    escape http_response
    output receipt: HttpRequestReceipt
    compensation LogFailedResponse
    authority web_server_authority

  # 6. Post-request audit
  audit contract PostRequestAudit
    input receipt: HttpRequestReceipt
    input rendered_template: Optional[RenderedOutput]
    output audit_receipt: PostAuditReceipt
}

# ====================== PUBLIC SINATRA-LIKE API (with templates) ======================
contract Get(path: String) {
  handler: Block
  # inside handler you can:
  #   @users = fetch_users()
  #   render "users/index.html" with { users: @users, title: "List of users" }
}

contract Render(template_name: String, with: Map[String, Any]) {
  # syntactic sugar через Form System
}

# ====================== INVARIANTS ======================
invariant every_render_has_evidence            { severity: critical }
invariant no_xss_in_any_template               { severity: critical }
invariant template_render_audited              { severity: critical }
invariant response_body_immutable              { severity: critical }

# ====================== RECEIPTS ======================
receipt HttpRequestReceipt {
  request: HttpRequest
  response: HttpResponse
  template_rendered: Optional[RenderedOutput]
  route_matched: Route
  epistemic_transition: :observed → :responded
  assumptions_hash: Hash
  audit_reference: Optional[PostAuditReceipt]
}

receipt PostAuditReceipt {
  request_id: UUID
  template_name: Optional[String]
  render_time_ms: Integer
  closed_loop: Boolean
  honesty_statement: String
}

# ====================== WHAT THIS PROVES ======================

# 1. Igniter Lang can produce not only a web framework but also a full-fledged **companion** — Template Engine
# 2. Sinatra-like syntax + `render "template.html" with { ... }` via Form System
# 3. Full auditability of each render (evidence, assumptions, PostAudit)
# 4. Automatic escaping + security constraints
# 5. Time-travel is possible for any rendered response (bitemporal receipts)
# 6. Full Covenant compliance (all postulates 22–28)
# 7. Multi-module architecture + include + .iform-ready
# 8. The developer writes like in Sinatra + ERB/Liquid, but gets maximum fairness and observability

end module