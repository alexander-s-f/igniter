# Igniter Application Proposals

Date: 2026-04-26.
Perspective: product designer / distributed systems engineer.
Purpose: конкретные application proposals для обсуждения, POC реализации,
и запуска с реальной ценностью для конечного пользователя.

Критерий отбора — каждое приложение должно:
- Решать ощутимую боль реального пользователя (не демо-задачку)
- Работать в одном процессе, запускаться одной командой
- Быть готовым к использованию конечным пользователем в POC-форме
- Оставлять явные нити для развития — что можно взять и строить дальше

---

## Приложение 1: Dispatch — Commander для Production Инцидентов

### Слоган

> "Когда прод падает — это твой командный пункт."

### Боль

Production инцидент — это управляемый хаос. Сейчас команда собирается в
Slack, кто-то смотрит логи, кто-то метрики, кто-то пингует сервисы — всё
параллельно, без структуры. Решения принимаются под давлением, без
документирования. Пост-мортем пишется через неделю по туманным воспоминаниям.

Следствие: одни и те же ошибки повторяются. Audit trail отсутствует. Новые
инженеры в on-call боятся, потому что нет структуры — только Slack-паника.

### Почему именно Igniter

| Igniter feature | Применение |
|---|---|
| Contracts graph | Сбор evidence (логи, метрики, статусы сервисов) как validated dependency graph |
| Proactive agent | Мониторит health endpoints, инициирует инцидент при аномалии |
| Long-lived session | Инцидент может длиться часы, сессия переживает рестарты |
| Wizard flow | Структурированный путь: detect → acknowledge → diagnose → remediate → verify → close |
| Receipt chain | Инцидент закрывается структурированным отчётом с полным audit trail |
| `await` в distributed contracts | Ждёт подтверждения от человека перед критическим шагом |

Это не просто "AI смотрит логи". Это структурированный процесс, где агент
собирает evidence, предлагает диагноз, и **ждёт явного решения человека** перед
каждым мутирующим действием.

### MVP Сценарии

**Сценарий 1: Обнаружение и инициализация**

Dispatch агент периодически опрашивает configured endpoints (health checks,
error rate thresholds). Обнаружив аномалию — создаёт incident session и
выводит alert на surface:

```
🔴 INCIDENT DETECTED
Service: payments-api
Trigger: error_rate > 5% for 3m (currently 12.4%)
Started: 14:23:07
Status: AWAITING ACKNOWLEDGEMENT

[Acknowledge] [Dismiss as noise]
```

**Сценарий 2: Diagnosis Wizard**

После acknowledgement — пошаговый diagnosis flow:

```
Step 1/4: Evidence Collection
─────────────────────────────
Collecting: error logs [✓]
Collecting: DB connection pool status [✓]
Collecting: upstream service status [✓]
Collecting: recent deployments [✓ — deploy 14:18:03, 5m before incident]

AI Analysis:
  "Error pattern matches recent migration. payments-api v2.3.1 deployed 5 min
   before incident. Error logs show `PG::UndefinedColumn: column users.tier`.
   High confidence: breaking DB migration."

[Accept diagnosis] [I have different information] [Show raw evidence]
```

**Сценарий 3: Remediation с явным approval**

```
Proposed Remediation:
1. Rollback payments-api to v2.3.0
2. Run migration rollback
3. Notify dependent services

⚠️  Actions are IRREVERSIBLE. Review carefully.

[Approve step 1] [Skip and do manually] [Abort]
```

**Сценарий 4: Verification и Incident Receipt**

После remediation агент верифицирует восстановление и закрывает инцидент
структурированным receipt:

```
INCIDENT CLOSED — 14:47:31 (duration: 24m)
────────────────────────────────────────────
Root cause: breaking migration in v2.3.1
Resolved by: @alex via Dispatch
Action taken: rollback to v2.3.0
Evidence collected: 4 sources
Decisions made: 3 (all human-approved)
Export: [PDF] [Markdown] [JSON]
```

### DSL Sketch

```ruby
App = Igniter.interactive_app :dispatch do
  service :incidents, Services::IncidentStore
  service :monitors,  Services::MonitorConfig

  agent :watchdog, Agents::WatchdogAgent do
    wakeup every: 30
    tools  CheckHealthTool, FetchLogsTool, CheckMetricsTool, CheckDeploysTool
  end

  agent :commander, Agents::CommanderAgent do
    tools  DiagnoseIssueTool, ProposeRemediationTool, VerifyRecoveryTool
  end

  surface :command_center, at: "/" do
    zone :active_incidents, label: "Active"
    zone :resolved_today,   label: "Resolved Today"
    chat :commander_chat,   with: :commander
  end

  flow :incident_resolution do
    step :acknowledge
    step :collect_evidence,  agent: :commander
    step :diagnose,          agent: :commander, requires_approval: true
    step :remediate,         requires_approval: true, confirmation: :explicit
    step :verify
    step :close,             produces: :incident_receipt
  end

  endpoint :stream, at: "/events", format: :sse
end
```

### POC Scope

- Configurable health checks (URL list с thresholds)
- Автодетект + создание incident session
- Wizard flow с 6 шагами
- AI diagnosis через LLM (Anthropic)
- Явный approval перед каждым мутирующим шагом
- Structured incident receipt в JSON/Markdown
- SSE live updates

Не включает в POC: реальные rollback команды (только dry-run), Slack интеграция,
мульти-сервисные зависимости.

### Нити для развития

- **Runbook automation**: агент предлагает конкретные shell команды из runbook
- **PagerDuty/Opsgenie webhook**: Dispatch инициируется внешним alert
- **Multi-team routing**: incident route к нужному on-call через capsule
- **Pattern learning**: Dispatch учится на закрытых инцидентах → улучшает diagnosis
- **Compliance export**: incident receipts → SOC2 audit trail
- **Cluster deployment**: Dispatch как shared service для всей инфра-команды

---

## Приложение 2: Lense — Агент Здоровья Кодовой Базы

### Слоган

> "AI, который смотрит за твоим кодом пока ты спишь."

### Боль

У каждой команды есть технический долг, который никто не понимает полностью.
Новые инженеры тратят недели на onboarding. Архитектурные решения теряются в
Slack-тредах. Метрики кода есть (покрытие, сложность, дубликаты) — но они
собираются редко, никто не реагирует на тренды, и нет AI чтобы объяснить
*почему* что-то — проблема и *что* с этим делать.

Rubocop сообщает об офенсах. Lense объясняет, что за ними стоит, и проводит
тебя через исправление.

### Почему именно Igniter

| Igniter feature | Применение |
|---|---|
| Contracts graph | Анализ кодовой базы как dependency graph (circular deps, coupling, coverage) |
| Proactive agent | Ночной анализ, alert при регрессии метрик |
| Web surface | Dashboard с трендами, а не просто текущим снимком |
| Wizard flow | Guided refactoring session — AI ведёт тебя через конкретные файлы |
| Provenance | Каждый вывод — след к конкретному файлу/методу/метрике |
| Long-lived session | Refactoring session может прерываться и возобновляться |

### MVP Сценарии

**Сценарий 1: Health Dashboard**

```
CODEBASE HEALTH — my_app
─────────────────────────────────────────────────────
Complexity    ████████░░  82/100  ↑ +3 this week
Test Coverage ████████░░  78%     → stable
Duplication   ██░░░░░░░░  23%     ↑ +5% this week ⚠
Coupling      █████░░░░░  52/100  ↓ improved

Top Issues This Week:
  ↑ services/payment_processor.rb — complexity 94/100 (was 88)
  ↑ 3 new duplicate blocks in models/user*.rb
  → 2 circular dependencies unchanged since last month

[Start Refactoring Session] [View Full Report] [Configure Thresholds]
```

**Сценарий 2: Guided Refactoring Wizard**

Пользователь кликает на проблему → начинается refactoring session:

```
REFACTORING SESSION: Payment Processor Complexity
──────────────────────────────────────────────────
File: services/payment_processor.rb (complexity: 94)

AI Analysis:
  "This method has 6 responsibilities: validation, fraud detection,
   currency conversion, DB write, event emission, and webhook call.
   Recommended: extract 3 separate services. I'll guide you through
   each extraction."

Step 1 of 3: Extract FraudDetectionService
  What to move: lines 45-89 (fraud_score, check_velocity, check_pattern)
  Suggested new file: services/fraud_detection_service.rb
  Test impact: 3 tests will need updating

[Show me the extraction] [I'll do it myself — mark as done] [Skip this step]
```

**Сценарий 3: Proactive Weekly Report**

Каждый понедельник агент генерирует отчёт и отправляет на configured email/webhook:

```
LENSE WEEKLY — week of Apr 21
─────────────────────────────
3 improvements this week 👍
2 regressions detected ⚠

Critical: duplication +5% in models/ — likely copy-paste from last sprint
Watch: payment_processor.rb complexity trend — 3rd week of growth

Suggested focus: 2h refactoring session on payment_processor.rb
[Open in Lense]
```

### DSL Sketch

```ruby
App = Igniter.interactive_app :lense do
  service :analysis_store,  Services::AnalysisStore
  service :codebase_config, Services::CodebaseConfig

  agent :analyzer, Agents::CodebaseAnalyzerAgent do
    wakeup :schedule, cron: "0 3 * * *"    # 3am nightly
    tools  MeasureComplexityTool, FindDuplicatesTool,
           CheckCoverageTool, DetectCircularDepsTool,
           ExplainIssueTool
  end

  agent :guide, Agents::RefactoringGuideAgent do
    tools  PlanExtractionTool, ShowDiffTool, EstimateImpactTool
  end

  surface :dashboard, at: "/" do
    zone :health_scores,  label: "Health"
    zone :trends,         label: "Trends"
    zone :top_issues,     label: "Issues"
  end

  surface :session, at: "/session/:id" do
    zone :current_step
    zone :ai_guidance
    chat :guide_chat, with: :guide
    stream :progress
  end

  flow :refactoring_session do
    step :select_target
    step :analyze,       agent: :guide
    step :plan_steps,    agent: :guide, requires_approval: true
    step :execute_steps, repeating: true
    step :verify
    step :close, produces: :refactoring_receipt
  end

  endpoint :stream, at: "/events", format: :sse
  endpoint :webhook, at: "/trigger", method: :post
end
```

### POC Scope

- Анализ Ruby проекта (rubocop metrics + custom complexity)
- Health score dashboard с трендами (последние 30 дней)
- Нарративный анализ через LLM — "вот почему это проблема"
- Guided refactoring wizard (3-5 шагов)
- Proactive alert если метрики ухудшились >10% за неделю
- Webhook для CI/CD интеграции

### Нити для развития

- **PR diff mode**: анализировать только изменённый код в PR
- **Custom rules**: команда добавляет свои architectural rules
- **Multi-repo**: Lense следит за несколькими репозиториями
- **Team metrics**: кто вносит улучшения, кто создаёт долг
- **Architecture diagram**: автогенерация из coupling analysis
- **"Ask about the code"**: chat с кодовой базой — "почему authentication работает так?"

---

## Приложение 3: Scout — Агент Исследования и Синтеза

### Слоган

> "От хаоса источников к структурированному пониманию — отслеживаемо и возобновляемо."

### Боль

Исследование сложной темы — это неструктурированный, трудоёмкий процесс.
Читаешь статьи, делаешь заметки, теряешь нити, начинаешь заново. Результат
зависит от того, какие источники попались случайно. Невозможно воспроизвести
или передать коллеге. Синтез занимает столько же времени, сколько само исследование.

Аналитик, консультант, технический lead, журналист, ученый — все чувствуют
эту боль ежедневно.

### Почему именно Igniter

| Igniter feature | Применение |
|---|---|
| Contracts graph | Research plan как validated graph: что собрать, в каком порядке, что вывести |
| Long-lived session | Исследование может прерываться и возобновляться через дни |
| Wizard flow | Структурированный процесс с human checkpoints |
| Provenance extension | Каждый вывод имеет явный trail к источнику |
| Distributed contracts | `await` — агент ждёт пока человек добавит дополнительный источник |
| TTL cache | Однажды извлечённые данные не перезапрашиваются |

### MVP Сценарии

**Сценарий 1: Запуск исследования**

```
NEW RESEARCH SESSION
────────────────────
Topic: "How are enterprise teams adopting AI coding assistants?"

Research Depth: [Quick (30min)] [Standard (2h)] [Deep (overnight)]

Starting points:
  + Recent papers (arxiv, ACM)
  + Industry surveys (Stack Overflow, JetBrains)
  + Your URLs: [Add]
  + Custom sources: [Configure]

[Start Research]
```

**Сценарий 2: Живой прогресс**

```
SCOUT — Research in progress
─────────────────────────────────────────────────────────
"AI adoption in enterprise coding"  [Pause] [Add source]

Gathering:
  ✓ Stack Overflow Developer Survey 2025 — extracted 12 data points
  ✓ JetBrains Developer Ecosystem Report — extracted 8 data points
  ↻ GitHub Octoverse 2025 — reading...
  ○ 3 ArXiv papers — queued

Early findings (live):
  • 67% of enterprise teams have AI assistant policies (up from 31% in 2024)
  • Biggest barrier: security review of AI-generated code (58%)
  • Most valued feature: code explanation, not generation

[Each finding links to its exact source]
```

**Сценарий 3: Checkpoint — Human-in-the-Loop**

```
CHECKPOINT: Direction check
────────────────────────────
Scout found a significant split in the data:

  Large enterprises (>1000 eng):  focused on governance & compliance
  Mid-size teams (50-1000 eng):   focused on velocity & productivity

Which angle matters more for your research?
  ○ Governance focus (continue with compliance data)
  ○ Velocity focus (shift to productivity metrics)
  ○ Both (Scout will cover both, session will be longer)
  ○ Let me add a source about this

[Choose direction]
```

**Сценарий 4: Structured Output**

```
RESEARCH COMPLETE — "AI adoption in enterprise"
Duration: 2h 14m  |  Sources: 23  |  Data points: 147

SYNTHESIS
──────────────────────────────────────────────────
Executive Summary (3 sentences):
  Enterprise AI coding tool adoption doubled in 2024-2025,
  but implementation approaches diverge sharply by company size.
  Large enterprises prioritize governance; mid-size teams prioritize speed.

Key Findings:
  1. Adoption rate: 67% (+36pp YoY) [sources: SO2025, JB2025, GH-Octoverse]
  2. Main barrier: security review (58%) [source: SO2025, p.34]
  3. ...

Evidence Map: [every claim → source citation]
Export: [Markdown] [PDF] [Structured JSON] [Notion]
```

### DSL Sketch

```ruby
App = Igniter.interactive_app :scout do
  service :sessions,  Services::ResearchSessionStore
  service :sources,   Services::SourceRegistry

  agent :researcher, Agents::ResearchAgent do
    tools  FetchWebPageTool, SearchArxivTool, ExtractDataPointsTool,
           SearchAcademicTool, SummarizeSourceTool
  end

  agent :synthesizer, Agents::SynthesisAgent do
    tools  ClusterFindingsTool, DetectContradictionsTool,
           GenerateNarrativeTool, BuildCitationsTool
  end

  surface :workspace, at: "/" do
    zone :active_sessions, label: "Active"
    zone :recent,          label: "Recent"
  end

  surface :session, at: "/session/:id" do
    zone :progress,   label: "Progress"
    zone :findings,   label: "Findings (live)"
    zone :synthesis,  label: "Synthesis"
    chat :researcher_chat, with: :researcher
    stream :discovery_feed
  end

  flow :research_session do
    step :configure
    step :gather,      agent: :researcher, interruptible: true
    step :checkpoint,  requires_approval: true          # direction check
    step :synthesize,  agent: :synthesizer
    step :review,      requires_approval: true           # human reviews synthesis
    step :export,      produces: :research_receipt
  end

  endpoint :stream, at: "/events", format: :sse
end
```

### POC Scope

- Сбор из web URLs (fetch + extract)
- Search через один open source index (e.g. Semantic Scholar для academic)
- Live progress feed с найденными data points
- Один human checkpoint для direction check
- Synthesis через LLM с explicit citations
- Export в Markdown и JSON
- Provenance: каждый вывод ссылается на источник

### Нити для развития

- **Source connectors**: RSS, PDF upload, Notion, Google Docs, Zotero
- **Team research**: несколько людей работают над одной research session
- **Research library**: накапливает результаты, поиск по ним
- **Contradiction detection**: Scout предупреждает когда источники противоречат
- **Citation format**: APA, MLA, Chicago — выбор стиля
- **Re-research**: запустить повторно через месяц, показать что изменилось

---

## Приложение 4: Aria — Структурированный Hiring Workflow

### Слоган

> "Hiring без хаоса: структурированный, AI-ассистированный, аудируемый."

### Боль

Hiring в большинстве компаний — это chaos скрытый за Google Docs и Slack. У
каждого интервьюера своя методология. Вопросы дублируются или пропускаются.
Решения принимаются интуитивно, без structured evidence. Через месяц невозможно
объяснить почему выбрали кандидата А, а не Б. Compliance-требования (одинаковое
обращение с кандидатами) технически невыполнимы.

Для engineering-команд: технические вопросы устаревают, не соответствуют роли,
и зависят от случайного настроения интервьюера.

### Почему именно Igniter

| Igniter feature | Применение |
|---|---|
| Contracts graph | Hiring pipeline как validated dependency graph (screening → technical → culture → offer) |
| Long-lived session | Interview process длится недели, сессия сохраняет весь контекст |
| Wizard flow | Структурированное интервью — вопросы адаптированы под кандидата и роль |
| Proactive agent | Напоминает интервьюерам о pending feedback, alerts при застревании |
| `await` | Ждёт feedback от каждого интервьюера перед переходом к следующему этапу |
| Receipt | Hiring decision закрывается структурированным decision record |

### MVP Сценарии

**Сценарий 1: Создание роли**

```
NEW ROLE — Senior Ruby Engineer
────────────────────────────────
AI анализирует job description и предлагает interview structure:

  Stage 1: Recruiter Screen (30min)
    Focus: motivation, logistics, salary expectations
    Questions: 8 generated, 3 must-ask

  Stage 2: Technical Assessment
    Focus: Ruby, distributed systems, problem-solving
    Format: live coding OR take-home (choose)
    Questions: 12 generated for live, 2 for take-home

  Stage 3: System Design (60min)
    Focus: architecture decisions, trade-offs
    Scenario: [AI suggests based on actual work at company]

  Stage 4: Culture & Collaboration (45min)
    Focus: teamwork, conflict, communication

[Review & Adjust] [Approve Structure]
```

**Сценарий 2: Adaptive Interview Flow**

Интервьюер ведёт интервью через Aria — вопросы адаптируются по ходу:

```
TECHNICAL INTERVIEW — Candidate: Maria Chen
────────────────────────────────────────────
Current: Ruby & Systems (Stage 2/4)

Next question:
  "Tell me about a time you debugged a race condition in production."

AI context note:
  Maria mentioned working with Sidekiq extensively. Follow up on:
  → concurrency primitives she's used
  → how she handles job failures

Your notes: [                              ]
Rating: [Strong Yes] [Yes] [Neutral] [No] [Strong No]
[Next question] [Skip] [Deep dive on this]
```

**Сценарий 3: Hiring Decision Room**

```
DECISION — Maria Chen | Senior Ruby Engineer
────────────────────────────────────────────
Interviews completed: 4/4

Feedback summary (AI synthesis):
  Technical: Strong (avg 4.2/5) — "excellent concurrency knowledge,
             hesitation on distributed systems design"
  Culture: Strong (avg 4.5/5) — "very collaborative, direct communicator"
  Overall: Strong Yes from 3/4 interviewers

Potential concerns:
  → Alex rated "Neutral" on technical — no written explanation
  → Distributed systems gap noted by 2 interviewers

Required before decision:
  □ Alex must add written feedback  [Remind Alex]

[Make Offer] [Continue to Next Round] [Decline] [Hold]
```

**Сценарий 4: Decision Receipt**

```
HIRING DECISION RECORD — Maria Chen
────────────────────────────────────
Role: Senior Ruby Engineer
Decision: Offer Extended
Date: 2026-04-26

Interview stages: 4 completed
Total interview time: 3h 45m
Interviewers: Alex, Sarah, Tom, Lin

Decision rationale:
  Strong technical fundamentals, excellent culture fit.
  Distributed systems gap noted — mitigation: 2-month onboarding plan.

This record is immutable and retained for 3 years per HR policy.
[Export PDF] [Export JSON]
```

### DSL Sketch

```ruby
App = Igniter.interactive_app :aria do
  service :candidates,  Services::CandidateStore
  service :roles,       Services::RoleStore
  service :feedback,    Services::FeedbackStore

  agent :coordinator, Agents::HiringCoordinatorAgent do
    wakeup every: 3600
    tools  CheckPendingFeedbackTool, SendReminderTool, SynthesizeFeedbackTool
  end

  agent :interviewer_guide, Agents::InterviewGuideAgent do
    tools  GenerateQuestionsTool, AdaptQuestionsTool, SuggestFollowUpTool
  end

  surface :pipeline, at: "/" do
    zone :active_roles
    zone :candidates_by_stage
    stream :activity_feed
  end

  surface :interview, at: "/interview/:session_id" do
    zone :current_question
    zone :candidate_context
    zone :notes
    chat :guide_chat, with: :interviewer_guide
  end

  surface :decision, at: "/decision/:candidate_id" do
    zone :feedback_summary
    zone :concerns
    zone :required_actions
  end

  flow :hiring_process do
    step :define_role,        agent: :coordinator
    step :screen_candidate,   requires_approval: true
    step :technical_interview, interruptible: true
    step :culture_interview,  interruptible: true
    step :collect_feedback,   await: :all_interviewers
    step :decision_room,      requires_approval: true, minimum_participants: 2
    step :close,              produces: :hiring_decision_record
  end

  endpoint :stream, at: "/events", format: :sse
end
```

### POC Scope

- Создание роли с AI-generated interview structure
- Adaptive interview flow (вопросы адаптируются по ходу)
- Feedback collection с require-approval per interviewer
- AI synthesis feedback после всех интервью
- Structured hiring decision record
- Proactive reminders для pending feedback

### Нити для развития

- **ATS integration**: Greenhouse, Lever, Workday
- **Calendar sync**: Aria координирует scheduling интервью
- **Candidate portal**: кандидат видит статус, получает задания
- **Bias detection**: AI предупреждает если feedback содержит bias-markers
- **Referral tracking**: кто рекомендовал, какой conversion rate
- **Interview quality metrics**: чьи интервью лучше predict performance

---

## Приложение 5: Chronicle — Компас Архитектурных Решений

### Слоган

> "Каждое решение — отслеживаемо. Каждое противоречие — обнаружимо."

### Боль

Архитектурные решения принимаются в Slack за 10 минут, а живут в коде 5 лет.
Никто не помнит почему выбрали Redis вместо Memcached, или почему API v2
отличается от v1. Новый engineer делает предложение, не зная что такое уже
обсуждалось и было отклонено. Аудит невозможен: "а когда и кем это было решено?"

ADR (Architectural Decision Records) — правильная идея, но их никто не ведёт
потому что создавать и поддерживать их вручную мучительно.

### Почему именно Igniter

| Igniter feature | Применение |
|---|---|
| Contracts graph | Сеть решений как dependency graph — решение A привело к решению B |
| Wizard flow | Guided ADR creation — AI помогает оформить решение |
| Long-lived session | Процесс обсуждения может занять дни — всё сохраняется |
| Proactive agent | Детектирует потенциальные противоречия при новых предложениях |
| Receipt | Решение закрывается как immutable decision record |
| `await` | Ждёт signoff от нужных stakeholders |

### MVP Сценарии

**Сценарий 1: Conflict Detection**

Новый инженер предлагает решение → Chronicle проверяет библиотеку:

```
NEW PROPOSAL SCAN
──────────────────
"Switch from PostgreSQL to MongoDB for user data"

⚠️  Potential conflicts found:

  Decision DR-041 (2024-11-12):
    "PostgreSQL chosen as primary data store for strong consistency
     requirements in billing. MongoDB evaluated, rejected due to
     transaction limitations."

  Decision DR-067 (2025-02-03):
    "All PII data must remain in RDBMS per legal requirement (EU-2024-AI)"

These decisions may conflict with your proposal.
[View decisions] [My proposal is different] [Start discussion]
```

**Сценарий 2: Guided ADR Creation**

```
CREATE DECISION RECORD
───────────────────────
AI Interview with @alex (15 min):

"What problem are you solving?" →
  "Our search is too slow on large datasets"

"What options did you consider?" →
  "Elasticsearch, Meilisearch, PgSearch"

"Why did you choose Meilisearch?" →
  "Zero ops overhead, excellent Ruby client, sufficient for our scale"

"What are the known trade-offs?" →
  "No distributed mode, 10GB index limit"

"Who was involved in this decision?" →
  "Alex, Sarah, CTO sign-off needed"

Draft generated:
  [Preview ADR] [Edit] [Send for review]
```

**Сценарий 3: Decision Map**

```
DECISION MAP — Search & Data Layer
────────────────────────────────────
DR-041 "PostgreSQL as primary" (2024-11)
  └── DR-067 "PII stays in RDBMS" (2025-02)
  └── DR-089 "Redis for session cache" (2025-07)
        └── DR-094 "Redis TTL policy" (2025-09)

DR-103 "Meilisearch for full-text" (2026-01)
  Potential tension: → DR-041 (data consistency)
  Status: acknowledged, isolated scope

[Click any decision to see full record and discussion]
```

**Сценарий 4: Decision Receipt с Signoff**

```
DECISION RECORD DR-103
────────────────────────
Title: Meilisearch for full-text search
Status: ACCEPTED
Date: 2026-01-14

Decision: Use Meilisearch for product catalog full-text search
Context: PostgreSQL full-text showing 800ms+ on 2M+ records
Alternatives: Elasticsearch (ops overhead), PgSearch (insufficient)
Trade-offs: no distributed mode, 10GB limit (acceptable for 2026)
Related: DR-041, DR-067 (isolated scope acknowledged)

Signatories:
  ✓ Alex (proposer) — 2026-01-14
  ✓ Sarah (tech lead) — 2026-01-15
  ✓ CTO — 2026-01-16

This record is immutable. [Export] [Link to PR]
```

### DSL Sketch

```ruby
App = Igniter.interactive_app :chronicle do
  service :decisions,  Services::DecisionStore
  service :graph,      Services::DecisionGraph

  agent :analyst, Agents::DecisionAnalystAgent do
    tools  SearchDecisionsTool, DetectConflictsTool, FindRelatedTool
  end

  agent :guide, Agents::ADRGuideAgent do
    tools  InterviewForContextTool, DraftADRTool, SuggestRelatedTool
  end

  surface :map, at: "/" do
    zone :search
    zone :decision_graph, renderer: :graph_view
    zone :recent_decisions
    stream :conflict_alerts
  end

  surface :decision, at: "/decision/:id" do
    zone :record
    zone :signoffs
    zone :related_decisions
    zone :timeline
  end

  flow :create_decision do
    step :conflict_check,    agent: :analyst
    step :interview,         agent: :guide
    step :draft_review,      requires_approval: true
    step :stakeholder_review, await: :required_signatories
    step :close,             produces: :decision_record
  end

  endpoint :stream, at: "/events", format: :sse
  endpoint :webhook, at: "/import", method: :post  # import existing ADRs
end
```

### POC Scope

- Markdown-based decision store (файлы в репозитории)
- AI conflict detection при создании нового предложения
- Guided ADR creation wizard (interview-style, 5-7 вопросов)
- Decision graph visualization (простая d3-like SVG)
- Multi-stakeholder signoff flow с notifications
- Import существующих ADR-файлов

### Нити для развития

- **GitHub integration**: автоматически создаёт Decision PR
- **Slack bot**: `@chronicle why did we choose X?` → AI ответ с ссылкой
- **Code link**: решение → PR/commit где оно реализовано
- **Decision health**: решения старше N лет помечаются для re-review
- **Team analytics**: кто принимает больше решений, что пересматривается чаще
- **Confluence/Notion sync**: двустороннее sync с существующими wiki

---

## Приоритет и Порядок Реализации

### Рекомендуемый порядок

| Место | Приложение | Обоснование |
|---|---|---|
| **1** | **Lense** | Developer-audience, самый прямой showcase Igniter contracts для анализа, быстро впечатляет |
| **2** | **Scout** | Универсальный pain, хорошо демонстрирует long-lived sessions и provenance, viral potential |
| **3** | **Dispatch** | Высокая боль, впечатляющее demo, но нужен более зрелый agent proactive wakeup |
| **4** | **Chronicle** | Меньшая аудитория (архитекторы), но очень sticky — команды не уходят |
| **5** | **Aria** | Хороший enterprise fit, но более нишевый чем другие |

### Почему Lense первым

- Целевая аудитория: разработчики = ранние адопторы Igniter
- Демонстрирует "contracts как analysis graph" — самый прямой showcase
- `ruby lense/app.rb path/to/my_project` — понятный одношаговый запуск
- Можно сделать впечатляющий demo за 2 минуты
- Не требует внешних сервисов (анализирует локальный код)

### Почему Scout вторым

- Универсальная боль — каждый делает research
- Провоцирует "покажи друзьям" — люди делятся результатами
- Хорошо демонстрирует long-lived sessions и human checkpoints
- Natural fit для enthusiast community

---

## Общие Технические Наблюдения

### Что нужно фреймворку для реализации этих apps

**Нужно сейчас (блокирует POC):**
- `Igniter.interactive_app` facade — все 5 apps используют одну точку входа
- SSE endpoint как первый класс — все 5 apps используют live updates
- `flow` primitive с `requires_approval` и `await` — core для каждого wizard

**Нужно для production-качества:**
- Durable session store (file-backed для single-process, distributed позже)
- Proactive agent wakeup (`wakeup every:` / `wakeup :schedule, cron:`)
- `produces: :receipt` → structured document output

**Нужно для enterprise growth:**
- Capsule packaging каждого приложения
- Multi-tenant поддержка (Dispatch/Aria)
- Audit trail как встроенное поведение, не opt-in

### Общая нить для всех пяти apps

Все пять приложений — это вариации одной метапаттерны:

```
Проблема с хаотичными, неструктурированными процессами
→ Igniter структурирует как validated graph
→ Агент собирает evidence и предлагает решение
→ Человек даёт явное approval в ключевых точках
→ Процесс закрывается структурированным receipt
→ Receipt становится основой для следующего цикла
```

Это и есть Igniter-way. Каждое из этих приложений — демонстрация одного принципа
на разной предметной области. Пользователь, попробовав одно, понимает паттерн и
уже знает как строить следующее сам.
