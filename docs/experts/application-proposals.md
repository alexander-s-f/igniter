# Igniter Application Proposals

Date: 2026-04-26.
Perspective: product designer / distributed systems engineer.
Purpose: concrete application proposals for discussion, POC implementation,
and launch with real end-user value.

Selection criteria — each application must:
- Solve a tangible pain felt by real users (not a demo toy)
- Run in a single process, launched with a single command
- Be usable by an end user in POC form
- Leave clear threads for further development — things you can pick up and build on

---

## Application 1: Dispatch — Production Incident Commander

### Tagline

> "When prod breaks, this is your war room."

### Pain

A production incident is managed chaos. Today your team scrambles into Slack —
someone's reading logs, someone else is checking metrics, someone's pinging
services — all in parallel, with no structure. Decisions are made under pressure
with nothing documented. The post-mortem gets written a week later from hazy
recollections.

The consequence: the same mistakes repeat. No audit trail exists. Engineers new to
on-call are afraid, because there is no structure — just Slack panic.

### Why Igniter Specifically

| Igniter feature | Application |
|---|---|
| Contracts graph | Evidence collection (logs, metrics, service statuses) as a validated dependency graph |
| Proactive agent | Monitors health endpoints, initiates an incident when an anomaly is detected |
| Long-lived session | An incident can last hours; the session survives restarts |
| Wizard flow | Structured path: detect → acknowledge → diagnose → remediate → verify → close |
| Receipt chain | Incident closes with a structured report carrying a full audit trail |
| `await` in distributed contracts | Waits for human confirmation before each mutating step |

This is not simply "AI watches your logs." It is a structured process where the
agent collects evidence, proposes a diagnosis, and **waits for an explicit human
decision** before every action that changes state.

### MVP Scenarios

**Scenario 1: Detection and Initialization**

The Dispatch agent periodically polls configured endpoints (health checks, error
rate thresholds). When it detects an anomaly it creates an incident session and
surfaces an alert:

```
INCIDENT DETECTED
Service: payments-api
Trigger: error_rate > 5% for 3m (currently 12.4%)
Started: 14:23:07
Status: AWAITING ACKNOWLEDGEMENT

[Acknowledge] [Dismiss as noise]
```

**Scenario 2: Diagnosis Wizard**

After acknowledgement — a step-by-step diagnosis flow:

```
Step 1/4: Evidence Collection
─────────────────────────────
Collecting: error logs                         [done]
Collecting: DB connection pool status          [done]
Collecting: upstream service status            [done]
Collecting: recent deployments                 [done — deploy 14:18:03, 5m before incident]

AI Analysis:
  "Error pattern matches a recent migration. payments-api v2.3.1 was deployed
   5 minutes before the incident. Error logs show:
   `PG::UndefinedColumn: column users.tier`.
   High confidence: breaking DB migration."

[Accept diagnosis] [I have different information] [Show raw evidence]
```

**Scenario 3: Remediation with Explicit Approval**

```
Proposed Remediation:
  1. Rollback payments-api to v2.3.0
  2. Run migration rollback
  3. Notify dependent services

WARNING: These actions are IRREVERSIBLE. Review carefully.

[Approve step 1] [Skip — I'll do this manually] [Abort]
```

**Scenario 4: Verification and Incident Receipt**

After remediation, the agent verifies recovery and closes the incident with a
structured receipt:

```
INCIDENT CLOSED — 14:47:31 (duration: 24m)
────────────────────────────────────────────
Root cause:    breaking migration in payments-api v2.3.1
Resolved by:   @alex via Dispatch
Action taken:  rollback to v2.3.0
Evidence collected: 4 sources
Decisions made:     3 (all human-approved)

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

In scope:
- Configurable health checks (URL list with thresholds)
- Auto-detect and create an incident session
- Wizard flow with 6 steps
- AI diagnosis via LLM (Anthropic)
- Explicit approval before every mutating step
- Structured incident receipt in JSON and Markdown
- SSE live updates

Out of scope for POC: real rollback commands (dry-run only), Slack integration,
multi-service dependency graphs.

### Build Further

| Thread | What it unlocks |
|---|---|
| Runbook automation | Agent proposes concrete shell commands from a runbook |
| PagerDuty / Opsgenie webhook | Dispatch initiates from an external alert |
| Multi-team routing | Incident routes to the right on-call via capsule |
| Pattern learning | Dispatch learns from closed incidents, improves diagnosis |
| Compliance export | Incident receipts become a SOC 2 audit trail |
| Cluster deployment | Dispatch runs as a shared service for the whole infra team |

---

## Application 2: Lense — Codebase Intelligence Agent

### Tagline

> "The AI watching your codebase while you sleep."

### Pain

Every team carries technical debt that nobody fully understands. New engineers
spend weeks on onboarding. Architectural decisions evaporate into Slack threads.
Code metrics exist — coverage, complexity, duplication — but they are gathered
infrequently, nobody reacts to trends, and there is no AI to explain *why*
something is a problem and *what to do about it*.

RuboCop reports offenses. Lense explains what lies behind them and guides you
through the fix.

### Why Igniter Specifically

| Igniter feature | Application |
|---|---|
| Contracts graph | Codebase analysis as a dependency graph (circular deps, coupling, coverage) |
| Proactive agent | Nightly analysis; alerts on metric regressions |
| Web surface | Dashboard with trends, not just a current snapshot |
| Wizard flow | Guided refactoring session — AI leads you through specific files |
| Provenance | Every finding traces back to a concrete file, method, or metric |
| Long-lived session | A refactoring session can be paused and resumed |

### MVP Scenarios

**Scenario 1: Health Dashboard**

```
CODEBASE HEALTH — my_app
─────────────────────────────────────────────────────
Complexity    ████████░░  82/100  up +3 this week
Test Coverage ████████░░  78%     stable
Duplication   ██░░░░░░░░  23%     up +5% this week  [!]
Coupling      █████░░░░░  52/100  down — improved

Top Issues This Week:
  [up] services/payment_processor.rb — complexity 94/100 (was 88)
  [up] 3 new duplicate blocks in models/user*.rb
  [--] 2 circular dependencies unchanged since last month

[Start Refactoring Session] [View Full Report] [Configure Thresholds]
```

**Scenario 2: Guided Refactoring Wizard**

The user clicks on an issue — a refactoring session begins:

```
REFACTORING SESSION: Payment Processor Complexity
──────────────────────────────────────────────────
File: services/payment_processor.rb (complexity: 94)

AI Analysis:
  "This method has 6 responsibilities: validation, fraud detection,
   currency conversion, DB write, event emission, and webhook call.
   Recommended: extract 3 separate services.
   I'll guide you through each extraction."

Step 1 of 3: Extract FraudDetectionService
  What to move: lines 45–89 (fraud_score, check_velocity, check_pattern)
  Suggested new file: services/fraud_detection_service.rb
  Test impact: 3 tests will need updating

[Show me the extraction] [I'll do it myself — mark as done] [Skip this step]
```

**Scenario 3: Proactive Weekly Report**

Every Monday morning the agent generates a report and delivers it to a
configured email address or webhook:

```
LENSE WEEKLY — week of Apr 21
─────────────────────────────
3 improvements this week
2 regressions detected  [!]

Critical: duplication +5% in models/ — likely copy-paste from last sprint
Watch:    payment_processor.rb complexity trend — 3rd consecutive week of growth

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
    step :analyze,        agent: :guide
    step :plan_steps,     agent: :guide, requires_approval: true
    step :execute_steps,  repeating: true
    step :verify
    step :close,          produces: :refactoring_receipt
  end

  endpoint :stream,   at: "/events",  format: :sse
  endpoint :webhook,  at: "/trigger", method: :post
end
```

### POC Scope

In scope:
- Analysis of a Ruby project (RuboCop metrics + custom complexity)
- Health score dashboard with trends (last 30 days)
- Narrative analysis via LLM — "here is why this is a problem"
- Guided refactoring wizard (3–5 steps)
- Proactive alert when metrics degrade more than 10% in a week
- Webhook for CI/CD integration

Out of scope for POC: multi-repo support, team-level contribution metrics.

### Build Further

| Thread | What it unlocks |
|---|---|
| PR diff mode | Analyze only the changed code in a pull request |
| Custom rules | Team adds its own architectural boundary rules |
| Multi-repo | Lense monitors several repositories from one dashboard |
| Team metrics | Who is paying down debt vs. accumulating it |
| Architecture diagram | Auto-generated from coupling analysis |
| "Ask about the code" | Chat with the codebase — "why does authentication work this way?" |

---

## Application 3: Scout — Research Synthesis Agent

### Tagline

> "From raw sources to structured insight — tracked and resumable."

### Pain

Researching a complex topic is an unstructured, time-consuming process. You read
articles, take notes, lose the thread, and start over. The result depends on
which sources happened to surface. It cannot be reproduced or handed off to a
colleague. Synthesis takes as long as the research itself.

Analysts, consultants, technical leads, journalists, and researchers all feel
this pain daily.

### Why Igniter Specifically

| Igniter feature | Application |
|---|---|
| Contracts graph | Research plan as a validated graph: what to collect, in what order, what to derive |
| Long-lived session | A research session can be paused and resumed over days |
| Wizard flow | Structured process with human checkpoints |
| Provenance extension | Every finding carries an explicit trail back to its source |
| Distributed contracts | `await` — the agent waits while the human adds an additional source |
| TTL cache | Data fetched once is not re-fetched |

### MVP Scenarios

**Scenario 1: Starting a Research Session**

```
NEW RESEARCH SESSION
────────────────────
Topic: "How are enterprise teams adopting AI coding assistants?"

Research Depth:  [Quick (30 min)]  [Standard (2h)]  [Deep (overnight)]

Starting points:
  + Recent papers (arXiv, ACM)
  + Industry surveys (Stack Overflow, JetBrains)
  + Your URLs:       [Add]
  + Custom sources:  [Configure]

[Start Research]
```

**Scenario 2: Live Progress**

```
SCOUT — Research in progress
─────────────────────────────────────────────────────────
"AI adoption in enterprise coding"         [Pause] [Add source]

Gathering:
  [done]    Stack Overflow Developer Survey 2025 — extracted 12 data points
  [done]    JetBrains Developer Ecosystem Report — extracted 8 data points
  [reading] GitHub Octoverse 2025
  [queued]  3 arXiv papers

Early findings (live):
  • 67% of enterprise teams now have an AI assistant policy (up from 31% in 2024)
  • Biggest barrier: security review of AI-generated code (58%)
  • Most valued feature: code explanation, not generation

[Each finding links to its exact source]
```

**Scenario 3: Checkpoint — Human in the Loop**

```
CHECKPOINT: Direction check
────────────────────────────
Scout found a significant split in the data:

  Large enterprises (>1000 engineers):  focused on governance and compliance
  Mid-size teams (50–1000 engineers):   focused on velocity and productivity

Which angle matters more for your research?
  ( ) Governance focus  (continue with compliance data)
  ( ) Velocity focus    (shift to productivity metrics)
  ( ) Both              (Scout covers both — session will run longer)
  ( ) Let me add a source about this

[Choose direction]
```

**Scenario 4: Structured Output**

```
RESEARCH COMPLETE — "AI adoption in enterprise"
Duration: 2h 14m  |  Sources: 23  |  Data points: 147

SYNTHESIS
──────────────────────────────────────────────────
Executive Summary:
  Enterprise AI coding tool adoption doubled in 2024–2025, but
  implementation approaches diverge sharply by company size.
  Large enterprises prioritize governance; mid-size teams prioritize speed.

Key Findings:
  1. Adoption rate: 67% (+36pp YoY)          [sources: SO2025, JB2025, GH-Octoverse]
  2. Main barrier: security review (58%)     [source: SO2025, p.34]
  3. ...

Evidence Map: [every claim linked to its source citation]

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
    zone :progress,         label: "Progress"
    zone :findings,         label: "Findings (live)"
    zone :synthesis,        label: "Synthesis"
    chat :researcher_chat,  with: :researcher
    stream :discovery_feed
  end

  flow :research_session do
    step :configure
    step :gather,      agent: :researcher, interruptible: true
    step :checkpoint,  requires_approval: true       # direction check
    step :synthesize,  agent: :synthesizer
    step :review,      requires_approval: true       # human reviews synthesis
    step :export,      produces: :research_receipt
  end

  endpoint :stream, at: "/events", format: :sse
end
```

### POC Scope

In scope:
- Collection from web URLs (fetch and extract)
- Search via one open-source academic index (e.g. Semantic Scholar)
- Live progress feed with discovered data points
- One human checkpoint for direction selection
- Synthesis via LLM with explicit citations
- Export to Markdown and JSON
- Provenance: every finding references its source

Out of scope for POC: RSS feeds, PDF upload, Notion/Google Docs connectors.

### Build Further

| Thread | What it unlocks |
|---|---|
| Source connectors | RSS, PDF upload, Notion, Google Docs, Zotero |
| Team research | Multiple people collaborating on one research session |
| Research library | Accumulated results, searchable across sessions |
| Contradiction detection | Scout warns when sources conflict with each other |
| Citation format | APA, MLA, Chicago — user picks the style |
| Re-research | Run the same session again next month; show what changed |

---

## Application 4: Aria — Structured Hiring Workflow

### Tagline

> "Hiring without chaos: structured, AI-assisted, auditable."

### Pain

Hiring at most companies is chaos hidden behind Google Docs and Slack. Every
interviewer has their own methodology. Questions are duplicated or skipped. Decisions
are made intuitively, without structured evidence. A month later it is impossible to
explain why candidate A was chosen over candidate B. Compliance requirements —
treating every candidate consistently — are technically unenforceable.

For engineering teams specifically: technical questions go stale, drift away from
the actual role, and depend on the random mood of whoever is in the room.

### Why Igniter Specifically

| Igniter feature | Application |
|---|---|
| Contracts graph | Hiring pipeline as a validated dependency graph (screening → technical → culture → offer) |
| Long-lived session | The interview process spans weeks; the session holds all context |
| Wizard flow | Structured interview — questions adapt to the candidate and role |
| Proactive agent | Reminds interviewers about pending feedback; alerts when a stage stalls |
| `await` | Waits for each interviewer's feedback before advancing to the next stage |
| Receipt | The hiring decision closes as a structured, immutable decision record |

### MVP Scenarios

**Scenario 1: Defining a Role**

```
NEW ROLE — Senior Ruby Engineer
────────────────────────────────
AI analyzes the job description and proposes an interview structure:

  Stage 1: Recruiter Screen (30 min)
    Focus: motivation, logistics, salary expectations
    Questions: 8 generated, 3 must-ask

  Stage 2: Technical Assessment
    Focus: Ruby, distributed systems, problem-solving
    Format: [Live coding]  [Take-home]
    Questions: 12 for live coding, 2 for take-home

  Stage 3: System Design (60 min)
    Focus: architecture decisions, trade-offs
    Scenario: [AI suggests based on work done at this company]

  Stage 4: Culture and Collaboration (45 min)
    Focus: teamwork, conflict, communication

[Review and Adjust] [Approve Structure]
```

**Scenario 2: Adaptive Interview Flow**

The interviewer conducts the interview through Aria — questions adapt as the
conversation unfolds:

```
TECHNICAL INTERVIEW — Candidate: Maria Chen
────────────────────────────────────────────
Current stage: Ruby & Systems (Stage 2 of 4)

Next question:
  "Tell me about a time you debugged a race condition in production."

AI context note:
  Maria mentioned working extensively with Sidekiq. Good follow-ups:
  → which concurrency primitives she has used
  → how she handles job failures

Your notes: [                              ]
Rating:  [Strong Yes]  [Yes]  [Neutral]  [No]  [Strong No]

[Next question]  [Skip]  [Deep dive on this]
```

**Scenario 3: Hiring Decision Room**

```
DECISION — Maria Chen | Senior Ruby Engineer
────────────────────────────────────────────
Interviews completed: 4 of 4

Feedback summary (AI synthesis):
  Technical: Strong (avg 4.2/5) — "excellent concurrency knowledge,
             some hesitation on distributed systems design"
  Culture:   Strong (avg 4.5/5) — "very collaborative, direct communicator"
  Overall:   Strong Yes from 3 of 4 interviewers

Potential concerns:
  → Alex rated "Neutral" on technical — no written explanation provided
  → Distributed systems gap noted independently by 2 interviewers

Required before a decision can be made:
  [ ] Alex must add written feedback          [Remind Alex]

[Make Offer]  [Continue to Next Round]  [Decline]  [Hold]
```

**Scenario 4: Hiring Decision Record**

```
HIRING DECISION RECORD — Maria Chen
────────────────────────────────────
Role:      Senior Ruby Engineer
Decision:  Offer Extended
Date:      2026-04-26

Interview stages completed: 4
Total interview time:        3h 45m
Interviewers:                Alex, Sarah, Tom, Lin

Decision rationale:
  Strong technical fundamentals, excellent culture fit.
  Distributed systems gap noted — mitigation: 2-month onboarding plan.

This record is immutable and retained for 3 years per HR policy.
[Export PDF]  [Export JSON]
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
    step :define_role,          agent: :coordinator
    step :screen_candidate,     requires_approval: true
    step :technical_interview,  interruptible: true
    step :culture_interview,    interruptible: true
    step :collect_feedback,     await: :all_interviewers
    step :decision_room,        requires_approval: true, minimum_participants: 2
    step :close,                produces: :hiring_decision_record
  end

  endpoint :stream, at: "/events", format: :sse
end
```

### POC Scope

In scope:
- Role creation with an AI-generated interview structure
- Adaptive interview flow (questions adjust as the conversation progresses)
- Feedback collection with per-interviewer require-approval gate
- AI synthesis of all feedback after all interviews complete
- Structured, immutable hiring decision record
- Proactive reminders for pending feedback

Out of scope for POC: ATS integration (Greenhouse/Lever), calendar sync, candidate portal.

### Build Further

| Thread | What it unlocks |
|---|---|
| ATS integration | Greenhouse, Lever, Workday — two-way sync |
| Calendar sync | Aria coordinates interview scheduling automatically |
| Candidate portal | Candidate sees their status and receives assignments |
| Bias detection | AI flags feedback containing known bias markers |
| Referral tracking | Who referred whom; what the conversion rate is |
| Interview quality metrics | Whose interviews best predict actual performance |

---

## Application 5: Chronicle — Decision Compass

### Tagline

> "Every decision tracked. Every contradiction detectable."

### Pain

Architectural decisions get made in Slack in ten minutes and live in the codebase
for five years. Nobody remembers why Redis was chosen over Memcached, or why API v2
behaves differently from v1. A new engineer makes a proposal without knowing it was
already discussed and rejected. Audit is impossible: "when was this decided, and by
whom?"

ADRs (Architectural Decision Records) are the right idea — but nobody maintains them
because creating and updating them by hand is painful.

### Why Igniter Specifically

| Igniter feature | Application |
|---|---|
| Contracts graph | Decision network as a dependency graph — decision A led to decision B |
| Wizard flow | Guided ADR creation — AI helps crystallize a decision into a record |
| Long-lived session | A discussion can span days; everything is persisted |
| Proactive agent | Detects potential conflicts when a new proposal is submitted |
| Receipt | A decision closes as an immutable decision record |
| `await` | Waits for required stakeholder sign-offs |

### MVP Scenarios

**Scenario 1: Conflict Detection**

A new engineer submits a proposal — Chronicle scans the decision library:

```
NEW PROPOSAL SCAN
──────────────────
"Switch from PostgreSQL to MongoDB for user data"

POTENTIAL CONFLICTS FOUND:

  Decision DR-041 (2024-11-12):
    "PostgreSQL chosen as primary data store for strong consistency
     requirements in billing. MongoDB evaluated and rejected due to
     transaction limitations."

  Decision DR-067 (2025-02-03):
    "All PII data must remain in an RDBMS per legal requirement (EU-2024-AI)."

These decisions may conflict with your proposal.
[View decisions]  [My proposal is different]  [Start discussion]
```

**Scenario 2: Guided ADR Creation**

```
CREATE DECISION RECORD
───────────────────────
AI interview with @alex (15 min):

"What problem are you solving?"
  → "Our search is too slow on datasets over 2M records."

"What options did you consider?"
  → "Elasticsearch, Meilisearch, PgSearch."

"Why did you choose Meilisearch?"
  → "Zero operational overhead, excellent Ruby client, sufficient for our scale."

"What are the known trade-offs?"
  → "No distributed mode, 10 GB index limit."

"Who was involved in this decision?"
  → "Alex, Sarah — CTO sign-off still needed."

Draft generated:
[Preview ADR]  [Edit]  [Send for review]
```

**Scenario 3: Decision Map**

```
DECISION MAP — Search and Data Layer
──────────────────────────────────────
DR-041  "PostgreSQL as primary store"  (2024-11)
  └── DR-067  "PII stays in RDBMS"                (2025-02)
  └── DR-089  "Redis for session cache"            (2025-07)
        └── DR-094  "Redis TTL policy"             (2025-09)

DR-103  "Meilisearch for full-text search"  (2026-01)
  Potential tension: → DR-041 (data consistency)
  Status: acknowledged, isolated scope

[Click any decision to view its full record and discussion]
```

**Scenario 4: Decision Record with Sign-offs**

```
DECISION RECORD DR-103
────────────────────────
Title:   Meilisearch for full-text search
Status:  ACCEPTED
Date:    2026-01-14

Decision:     Use Meilisearch for product catalog full-text search.
Context:      PostgreSQL full-text showing 800ms+ on 2M+ records.
Alternatives: Elasticsearch (unacceptable operational overhead),
              PgSearch (insufficient at this scale).
Trade-offs:   No distributed mode; 10 GB index limit (acceptable for 2026).
Related:      DR-041, DR-067 (isolated scope — conflict acknowledged).

Signatories:
  [signed] Alex       (proposer)   — 2026-01-14
  [signed] Sarah      (tech lead)  — 2026-01-15
  [signed] CTO                     — 2026-01-16

This record is immutable.  [Export]  [Link to PR]
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
    zone :decision_graph,   renderer: :graph_view
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
    step :conflict_check,      agent: :analyst
    step :interview,           agent: :guide
    step :draft_review,        requires_approval: true
    step :stakeholder_review,  await: :required_signatories
    step :close,               produces: :decision_record
  end

  endpoint :stream,   at: "/events", format: :sse
  endpoint :webhook,  at: "/import", method: :post   # import existing ADRs
end
```

### POC Scope

In scope:
- Markdown-based decision store (files in the repository)
- AI conflict detection when a new proposal is submitted
- Guided ADR creation wizard (interview-style, 5–7 questions)
- Decision graph visualization (simple SVG)
- Multi-stakeholder sign-off flow with notifications
- Import of existing ADR files

Out of scope for POC: GitHub PR integration, Slack bot, Confluence/Notion sync.

### Build Further

| Thread | What it unlocks |
|---|---|
| GitHub integration | Automatically creates a Decision PR |
| Slack bot | `@chronicle why did we choose X?` — AI answer with a link |
| Code link | Decision linked to the PR or commit where it was implemented |
| Decision health | Decisions older than N years flagged for re-review |
| Team analytics | Who makes the most decisions; what gets revisited most often |
| Confluence / Notion sync | Bidirectional sync with existing team wikis |

---

## Priority and Implementation Order

### Recommended sequence

| Order | Application | Rationale |
|---|---|---|
| **1** | **Lense** | Developer audience = early Igniter adopters; the most direct contracts-as-analysis-graph showcase; impressive in a 2-minute demo |
| **2** | **Scout** | Universal pain point; excellent demonstration of long-lived sessions and provenance; high viral potential |
| **3** | **Dispatch** | High pain, spectacular demo — but requires a more mature proactive agent wakeup mechanism |
| **4** | **Chronicle** | Smaller initial audience (architects and tech leads), but extremely sticky — teams do not leave |
| **5** | **Aria** | Good enterprise fit, but more niche than the others |

### Why Lense first

- Target audience: developers, who are Igniter's earliest adopters
- Demonstrates "contracts as an analysis graph" — the most direct showcase of the core concept
- `ruby lense/app.rb path/to/my_project` — a clear, single-step launch
- An impressive demo is achievable in under 2 minutes
- Requires no external services — it analyzes local code

### Why Scout second

- Universal pain — everyone does research
- Naturally shareable — people share the synthesis output with colleagues
- Demonstrates long-lived sessions and human checkpoints clearly
- A natural fit for the enthusiast and technical writer community

---

## General Technical Observations

### What the framework needs to make these apps possible

**Needed now (POC blockers):**
- `Igniter.interactive_app` facade — all 5 apps share a single entry point
- SSE endpoint as a first-class primitive — all 5 apps use live updates
- `flow` primitive with `requires_approval` and `await` — core to every wizard

**Needed for production quality:**
- Durable session store (file-backed for single-process; distributed later)
- Proactive agent wakeup (`wakeup every:` / `wakeup :schedule, cron:`)
- `produces: :receipt` — structured document output from a flow step

**Needed for enterprise growth:**
- Capsule packaging for each application
- Multi-tenant support (Dispatch and Aria in particular)
- Audit trail as built-in behavior, not opt-in

---

## The Common Meta-Pattern

All five applications are variations on a single meta-pattern:

```
A chaotic, unstructured process
  → Igniter structures it as a validated contracts graph
  → An agent collects evidence and proposes a resolution
  → A human gives explicit approval at key decision points
  → The process closes with a structured, immutable receipt
  → The receipt becomes the foundation for the next cycle
```

This is the Igniter way. Each of these five applications is the same principle
applied to a different domain. A user who tries one understands the pattern — and
already knows how to build the next one themselves.
