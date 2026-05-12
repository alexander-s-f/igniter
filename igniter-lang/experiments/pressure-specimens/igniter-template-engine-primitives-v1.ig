module IgniterTemplateEnginePrimitives

profile template_primitives
  time: bitemporal
  evidence: required
  trust: system

# ====================== TEMPLATE CORE TYPES ======================
type Template {
  id: UUID
  name: String                     # "users/index.html", "layouts/application.html"
  source: String                   # исходный шаблон (с формами)
  format: :html | :json | :xml | :markdown
  compiled_version: Integer
}

type RenderContext {
  variables: Map[String, Any]
  layout: Optional[String]
  partials: Map[String, Template]
  current_user: Optional[PoliticalActor]   # пример контекста
}

type RenderedOutput {
  content: Bytes
  content_type: String
  rendered_variables: Map[String, Any]
  evidence_bundle: EvidenceBundle
  assumptions_used: AssumptionSet
}

# ====================== ASSUMPTIONS & CONSTRAINTS ======================
assumptions template_engine {
  assumption auto_escaping_enabled {
    kind: :empirical
    statement "По умолчанию все переменные в HTML escaping'уются"
    strength: 0.98
  }
  assumption template_is_immutable {
    kind: :ethical
    statement "Шаблон не может быть изменён после компиляции"
    strength: 0.95
  }
}

constraints template_engine {
  constraint no_xss_in_render {
    kind: :security
    priority: 1.0
    statement "Каждый рендер обязан предотвращать XSS"
  }
  constraint every_render_audited {
    kind: :epistemic
    priority: 1.0
    statement "Каждый рендер шаблона обязан иметь auditable receipt"
  }
}

# ====================== TEMPLATE ENGINE CONTRACTS ======================
pure contract CompileTemplate
  input template: Template
  output compiled: Boolean evidence [template]

pure contract RenderTemplate
  input template: Template
  input context: RenderContext
  uses assumptions template_engine
  uses constraints template_engine
  output output: RenderedOutput evidence [template, context, assumptions]

pure contract RenderWithLayout
  input content: RenderedOutput
  input layout: Template
  output final: RenderedOutput evidence [content, layout]

receipt TemplateRenderReceipt { ... }

end module