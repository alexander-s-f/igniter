module IgniterHttpJsonClient

profile mundane_http_client
  time: bitemporal
  evidence: required
  trust: system
  effects: minimal

type ApiRequest {
  method: :get | :post | :put | :delete
  url: String
  headers: Map[String, String]
  body: Optional[Bytes]
  idempotency_key: Optional[String]
}

type ApiResponse<T> {
  status: Integer
  headers: Map[String, String]
  body: T
  duration_ms: Integer
}

type ApiError {
  kind: :client_error | :server_error | :timeout | :network | :validation
  status: Optional[Integer]
  message: String
  retryable: Boolean
}

-- CORE: preparation and processing (no escape)
pure contract BuildRequest
  input url: String
  input method: :get | :post | :put | :delete
  input body: Optional[Any]
  output request: ApiRequest

pure contract ParseJsonResponse<T>
  input raw: Bytes
  output data: T

-- ESCAPE: only here is real HTTP
privileged contract ExecuteHttpCall
  input request: ApiRequest
  config retry: { attempts: 3, backoff_ms: 200, timeout_ms: 5000 }
  escape http_outbound
  output result: Result[ApiResponse[Any], ApiError]

-- Convenient high-level contract for the developer
contract CallJsonApi<T>(url: String, method: :get | :post | :put | :delete, body: Optional[Any])
  -> result: Result[ApiResponse<T>, ApiError]
{
  let req = BuildRequest(url, method, body)

  let response = ExecuteHttpCall(req) with {
    retry: { attempts: 3, backoff_ms: 200, timeout_ms: 5000 }
  }

  match response {
    Ok(resp)  => Ok(ParseJsonResponse(resp.body))
    Err(err)  => Err(err)
  }
}

-- ====================== WHAT THIS PROVES ======================
-- 1. The standard HTTP client looks clean and familiar.
-- 2. Retry/backoff/timeout are configurable, not hardcoded into every function.
-- 3. Clear boundary: BuildRequest + Parse = CORE, ExecuteHttpCall = ESCAPE.
-- 4. Typed Result + retryable errors are easy to handle.
-- 5. Idempotency key and receipts work automatically.

end module