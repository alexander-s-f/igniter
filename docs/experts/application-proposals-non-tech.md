# Igniter Application Proposals — Non-Technical Audiences

Date: 2026-04-26.
Perspective: product designer / market strategist.
Purpose: application proposals for three non-technical audiences — end users,
creators/media, enterprise business. The IT-developer audience is covered in
`application-proposals.md`.

---

## Key Principle

The proposals in this document differ fundamentally from the IT-facing version:

- **The user does not know about Igniter, and does not need to**
- Igniter is what the developer uses under the hood
- The user's experience: an application that works proactively, remembers
  context, guides through complex processes, and delivers tangible results
- The analogy: WordPress is built on PHP — users think about their websites,
  not about PHP

---

# Audience 1: End User

> "I use it. It helps me. If I need something customized, I'll call a developer."
> Domains: health, fitness, self-development, learning, personal productivity.

---

## App 1.1: Forma — Personal AI Health & Fitness Coach

### Tagline

> "A trainer that knows you. Works while you sleep. Adapts when life changes."

### Pain

People want to be fit and healthy. But between intention and a working system
lies a gap that most tools fail to close.

Tracking apps collect data but offer no meaningful guidance. Personal trainers
are expensive and available only during scheduled sessions. YouTube workout
programs go stale after two weeks when life shifts. The problem is not
motivation — it is that every existing tool either knows you or works for you,
but not both at once.

Forma is a trainer that never clocks out. It sees that you missed two workouts,
knows why (you logged "business trip"), and has already rebuilt the plan. On
Wednesday morning it sends: "Today was supposed to be legs, but you slept
poorly last night — here is a lighter version."

### How It Looks to the User

**First launch — 10 minutes**

Forma walks the user through an intake wizard:

```
Hello! I'll be your coach. I need to get to know you first.

How old are you? 34
What's your main goal? ○ Lose weight  ● Get in shape  ○ General health
How many days per week can you train? ○ 2  ● 3–4  ○ 5+
Any limitations? Lower back — L4-L5 disc herniation
What have you tried before? Gym, two years ago, dropped it

Analyzing your profile and building a plan. [Let's start]
```

Within a minute: a personalized program with an explanation of every choice
("removed deadlifts because of your back, replaced with Romanian deadlifts —
safer with disc issues"), and a month-long schedule.

**Daily life**

In the morning Forma sends a notification: "Today is Workout A — shoulders and
core. 45 minutes. Open?"

During the workout — a step-by-step guide with timers, technique videos, and
real-time adjustments ("90-second rest consistently works better for you than
60 seconds").

Afterward — a short check-in: how do you feel? what is sore?

**Proactive signals**

```
Forma notices:
→ You have missed 3 workouts over the past 2 weeks (your usual rate: 1)
→ Your "fatigue" check-in ratings have increased

"It looks like the load is too high, or something is going on.
 Want to switch to a maintenance mode for two weeks?"

[Yes, ease up]  [Let me explain what's happening]  [All good, keep going]
```

**Progress over time**

```
Month 3 with Forma
────────────────────────────
Workouts completed: 36 of 40 planned  (90%)
Skipped due to illness: 3
Average weight: −2.4 kg
Strength: seated press +15 kg

Your personal records this month:
  → Plank: 2:15  (was 0:45 at the start)
  → Push-ups: 24 reps  (was 9)

[View full breakdown]  [Share]
```

### Igniter Under the Hood

| Concern | How Igniter handles it |
|---|---|
| Plan generation | Contract graph: goals → available days → constraints → progression → weekly plan |
| Adaptation | Proactive agent monitors patterns, initiates adjustments without user prompt |
| Long-lived context | Full training history, progression, and personal notes survive for months |
| Wizard flows | Intake, per-workout, and monthly review — each modeled as a guided session |
| Compile-time safety | Contradictory parameters (disc herniation + heavy compound lifts) caught before the plan is created |

### Build Further

```
Base Forma                              Extensions the developer can add
─────────────────────────────────────── ────────────────────────────────────
Built-in exercise library            → Integrate your own exercise database
Single user                          → Family / multi-user accounts
Manual data entry                    → Apple Health / Garmin / Fitbit sync
General nutrition guidance           → Personalized macro calculator
                                     → Cronometer / MyFitnessPal integration
Weekly summaries                     → Physician / nutritionist integration
Standard programs                    → Coach-authored custom programs
Single language                      → Multilingual support
```

Igniter's capsule model lets each extension ship as a separate package without
touching the core.

---

## App 1.2: Meridian — Skill Learning Companion

### Tagline

> "Learn when you can. The system remembers where you stopped and why."

### Pain

Online courses show 90% dropout rates — not because people are lazy, but
because courses do not adapt to life. You start a Python course, a busy week
at work breaks the streak, you lose the thread, you quit. Flashcards are
tedious. Traditional textbooks never explain why any of it matters.

Meridian is a tutor that understands your context, explains things in terms of
your life, and knows how to wait. Waiting — patiently, without judgment — is a
superpower no other learning tool possesses.

### How It Looks to the User

**Choosing a direction**

```
What do you want to learn?

[Language]  [Programming]  [Career skill]  [Hobby]  [Something else]

Selected: Spanish
Goal: trip in 4 months — survival level, basic conversation
Time per day: 15–20 minutes

Meridian will build a plan and explain the reasoning behind it.
```

**Adaptive sessions**

Meridian does not play the next video in a queue. Every 15-minute session is a
dialogue. The tutor decides what to cover today based on:

- What you have forgotten since last time (spaced repetition without flashcards)
- What your specific goal actually requires (travel → transport, food, navigation)
- Your current state (you said "tired" today → light review, no new material)

```
Meridian: "Three days ago we worked on numbers. Want to play a game?
          I'll say a price — you write how much that is in euros."

You: cuarenta y dos

Meridian: "Correct! Now — the cashier gives you change and says
          'son tres euros con veinte'. How much is that?"
```

**Waiting is a feature, not a bug**

```
After 18 days away:

Meridian: "Welcome back. Eighteen days — no judgment, no guilt.
          Just a note: your trip is in 3 months and 11 days.
          Want to pick up where we left off? I'll remind you
          where we stopped and we'll start with something easy."

[Yes, let's go]  [Move the goal]  [Change intensity]
```

**Monthly story — progress as narrative**

```
April — your Meridian story
────────────────────────────
You studied 19 out of 30 days.
Covered: 143 new words, 8 grammar structures.
Hardest moment: the subjunctive (took 4 sessions).
Fastest win: numbers and prices — you got it in one session.

Days until your trip: 89.
Meridian's forecast: at your current pace — comfortable tourist-level conversation.
Add 5 minutes per day — conversational fluency.

[Add 5 minutes]  [Keep as is]  [Tell a friend]
```

### Build Further

```
Base Meridian                           Extensions the developer can add
─────────────────────────────────────── ────────────────────────────────────
Languages (built-in content)         → Custom knowledge domains / courses
Text-based dialogue                  → Voice sessions (speech recognition)
Single learner                       → Family / group / classroom mode
Standard goals                       → Corporate training (team accounts)
                                     → Instructor-created courses
                                     → LMS integration (Moodle, Canvas)
In-app notifications                 → WhatsApp / Telegram bot mode
Self-assessment                      → Live tutor check-in (weekly)
```

---

# Audience 2: Advanced User — Creators / Media / Marketing

> "They know what they need. They know what outcome looks like. They can hire
> developers when necessary."
> Domains: blogging, podcasts, newsletters, influencer, social media, content
> marketing, sales.

---

## App 2.1: Studio — Content Command Center

### Tagline

> "From idea to results — one process. AI does the heavy lifting. You make the decisions."

### Pain

A content creator lives in permanent chaos: ideas in Notion, drafts in Docs,
scheduled posts in Buffer, analytics in a spreadsheet, conversations in Slack.
Every piece of content is assembled by hand from six separate tools. AI tools
exist, but each handles one step — Claude writes, Canva makes images, Buffer
publishes. The stitching is manual.

Studio is a process, not a tool. An idea goes in, content comes out. Everything
in between is a managed, AI-assisted pipeline with clear decision points.

### How It Looks to the User

**Idea intake**

```
NEW IDEA
──────────────────────────────────────────
"Write about how I stopped reading books and switched to audio summaries —
 and why six months later I went back to reading the old-fashioned way"

Studio analyzes:
  Type: personal story + practical insight
  Potential: high (emotional hook, unexpected turn)
  Related content: your post "How I went notification-free" got 847 shares
  Recommended formats:
    ● Newsletter (primary) — long form, personal tone
    ○ Twitter thread — 12 tweets, story → insight structure
    ○ LinkedIn — reframed for professional audience

[Choose formats]  [Edit the idea]  [Add to queue]
```

**Research step**

```
Studio gathers context:

  ✓ Your previous posts on the topic of reading (found: 3)
  ✓ Research: retention audio vs. text (found: 2 studies)
  ✓ Similar experiences from other writers (found: 5 references)
  ✓ Your audience's comments on the topic (from previous posts)

Key insights:
  • Your audience splits 30/70 (audio-first vs. readers)
  • Most common comment theme: "speed vs. depth"
  • MIT study: comprehension −23% for audio vs. text

[View everything]  [Proceed to structure]
```

**Structure as a checkpoint**

```
STRUCTURE DRAFT
────────────────────────────────────────
Hook: "For six months I listened to books instead of reading them.
       Then I stopped."
(AI note: strong open hook — it raises the question "why?")

Section 1: Why I switched to audio  (context + rationale)
Section 2: The first three months — productivity euphoria
Section 3: What started to go wrong  (the turn)
Section 4: The decision to go back + what I learned
CTA: Poll — what about you?

[Approve structure]  [Reorder sections]  [Add a section]
```

After approval, Studio writes the draft. It does not publish. It shows you.

**Review and edit**

```
DRAFT — Newsletter #47
──────────────────────────────────────────────────────
[Draft text with inline AI annotations]

AI flags:
  ⚡ Section 2 is long — 340 words (your usual average: 180 words per section)
  ⚡ "MIT study" — a source link is needed
  💡 Consider adding? A personal quote from your notebook — would strengthen Section 3

[Edit]  [Accept all AI suggestions]  [Approve for publishing]
```

**Distribution planning**

```
PUBLISHING PLAN
────────────────────────────────────────────────────────
Newsletter:      Wednesday 08:00  (your best historical open-rate day)

Twitter thread:  Wednesday 10:30  (2.5 hours after newsletter — your pattern)
  → Studio adapted automatically (12 tweets, different tone)

LinkedIn:        Friday 09:00
  → Studio adapted for professional tone

[Preview all versions]  [Adjust schedule]  [Launch]
```

**7-day results**

```
RESULTS — Newsletter #47
────────────────────────────────────────────
Open rate: 34.2%  (+4.1 pp vs. your average)
Clicks: 847  (best result in 3 months)
Replies: 23  (your usual: 6–8)
Twitter: 1,247 impressions, 89 retweets

What worked:
  → Open-ended hook showed best CTR in subject line test (A/B: +22%)
  → Section 3 (the turn) — 67% read to the end vs. 41% normally

Next post: want to follow up on this topic?
(Your audience asked: "what specifically pulled you back to reading?")
```

### Build Further

```
Base Studio                             Extensions the developer can add
─────────────────────────────────────── ────────────────────────────────────
Newsletter + social                  → Podcast show-notes automation
Manual idea input                    → Ideas surfaced from comments / questions
One email platform                   → Substack, Ghost, Beehiiv, ConvertKit
Text content only                    → AI image generation (DALL-E / Midjourney)
Single author                        → Team mode (editor + writer)
Post-publish analytics               → Predictive scoring before publishing
Manual trend input                   → Automated trend monitoring
                                     → CRM integration for sales content
```

---

## App 2.2: Signal — Audience Intelligence & Growth Insights

### Tagline

> "Your audience is already telling you what to do. Signal translates."

### Pain

Every creator and marketer has data. Plenty of it. Open rates, click-throughs,
comments, polls, sales numbers. But data is not insight. You stare at the
numbers and think "open rate went up 3%" — so what does that mean? What do you
do with it?

The typical creator makes decisions by gut feel ("this topic seems to be
landing") or by one loud outlier post ("that one exploded, let's do more").
Signal does what a dedicated analyst at $5,000 a month would do — automatically
and continuously.

### How It Looks to the User

**Command Center**

```
SIGNAL — Week 17 / 2026
────────────────────────────────────────────────────────────────────
Audience health: ████████░░  82/100  → stable

3 important signals this week:

  ● URGENT: Unsubscribe rate rose to 1.8%  (normal: 0.4%)
           Pattern: 73% of unsubscribers had opened the last 3 emails
           Signal's read: this does not look like fatigue — it looks like
           an expectation mismatch
           [Investigate]

  ● OPPORTUNITY: "Joined in the last 30 days" segment shows 2.3× higher CTR
           They respond to "how I did it" content, not "what to do" advice
           [View segment]

  ● GROWTH: "Personal story" posts — 67% retention vs. 31% for other formats
           Your 3 best-performing posts of the year: all personal narratives
           [See the pattern]
```

**Deep dive into a segment**

```
SEGMENT: "Paying subscribers — active"
─────────────────────────────────────────────────────
Size: 234 people  (8% of audience, 71% of revenue)

How they differ from everyone else:
  → Read 82% of emails  (vs. 31% for full list)
  → Click "practical" content at 4× the rate
  → Average tenure: 14 months
  → Source: 67% came through a single email (your note-taking system post)

What they want more of:
  → Comments: 41 mentions of "practical examples"
  → Polls: top topic — "your workflow"

Recommendation:
  "A 'My Workflow' series — one tool every two weeks.
   Projected retention uplift: +12% for this segment."

[Start the series]  [View full data]  [Challenge the forecast]
```

**Growth experiment wizard**

```
EXPERIMENT #12: Subject line testing
──────────────────────────────────────────────────────────
Hypothesis: questions in the subject line improve open rate

Signal suggests:
  Version A: "Why I stopped listening to audiobooks"     (your style)
  Version B: "Do you do this too?"                       (question)
  Version C: "Six months of audio — here's what happened" (intrigue)

Send to: 20% of list first; winner goes to the rest
Winner metric: open rate at 4 hours

[Approve experiment]  [Edit options]  [Skip]

← 3 days later →

Result: Version A won  (34.2% vs. 28.1% and 31.7%)
Insight: your audience responds to personal narrative, not questions.
         This matches the pattern from signal #3 last week.

Signal updated the model.  [View]
```

### Build Further

```
Base Signal                             Extensions the developer can add
─────────────────────────────────────── ────────────────────────────────────
Email analytics                      → Social analytics (Instagram, TikTok)
Newsletter metrics                   → Podcast analytics (Spotify, Apple)
Basic segmentation                   → Predictive churn (who is about to leave)
Manual experiments                   → Automatic continuous testing
On-demand insights                   → Proactive alerts (something just changed)
                                     → Competitor benchmarking
                                     → CRM integration (HubSpot, Pipedrive)
                                     → Revenue attribution (which content sells)
```

---

# Audience 3: Business — Enterprise

> "Developer teams are in place. The challenge is delivery: compliance,
> integrations, scale. Compared against BPMN tools, SAP, Oracle."

---

## App 3.1: Blueprint — AI-Native Business Process Platform

### Tagline

> "BPMN for the AI era: business processes as validated dependency graphs
>  with agents, audit trail, and explainable decisions."

### Pain

Large organizations run on processes. Customer onboarding, contract approval,
leave requests, procurement — everything is a process. Today those processes
live in one of three places:

1. **Expensive enterprise software (SAP, ServiceNow)** — it works, but costs
   millions, takes six months to configure, and requires dedicated specialists.

2. **Self-built in Jira / Confluence** — cheap, but it does not scale, has no
   validation, no audit trail, no AI.

3. **Email and spreadsheets** — everyone has it, everyone hates it.

AI does not fix any of these. ChatGPT does not know where a process is stuck or
why. Copilot writes code but does not manage approvals.

Blueprint is developer-delivered BPMN with AI agents as first-class participants —
not plugins, not integrations, but native members of every process step.

### Why This Is Different

Traditional BPMN tools (Camunda, Activiti, IBM BPM):
- XML-based process definitions — nobody outside IT works directly with these
- AI as bolt-on integrations — added on top, not inherent to the model
- No compile-time validation — schema errors surface at runtime
- Expensive licenses or heavy Java infrastructure

Blueprint built on Igniter:
- Processes described as Ruby contracts — developers know how to write these
- AI agents are participants like humans and services — no special treatment
- Compile-time validation — an invalid process cannot be deployed
- Receipt chain — every decision, every action, leaves an immutable record
- Zero production dependencies — runs wherever Ruby runs

### How It Looks to the Business Owner (Not the Developer)

**Process designer view**

The developer describes the process in code. The business owner sees:

```
PROCESS: Client Contract Approval
─────────────────────────────────────────────────────────────
Status: Active | 14 instances in progress

Flow:
  Contract received
    ↓
  AI Pre-Review  ← agent checks for standard risks  (automatic)
    ↓
  Legal review  [HUMAN — waiting for action: 3 contracts]
    ↓
  CFO approval  [HUMAN — for amounts above $100k]
    ↓
  Signature and archiving

Metrics:
  Average cycle time: 4.2 days  (target: <5 days)  ✓
  Current bottleneck: legal review  (avg 2.1 days)
  AI pre-review impact: legal review time down 34%
                        (caught 67% of standard issues automatically)
```

**An AI participant in the process**

```
INSTANCE #2847 — Contract with Acme Corp  ($340,000)
─────────────────────────────────────────────────────────
Current step: AI Pre-Review  [automatic]

AI found:
  ● STOP: Clause 7.3 — unlimited liability  (non-standard; usually capped at 2×)
  ● NOTE: Payment terms — Net 60  (your standard: Net 30)
  ● OK: Confidentiality, IP, termination — all standard

AI recommendation:
  "Route to legal review with flags. Clause 7.3 requires a
   conversation with the client before proceeding."

Next step:  → Legal review  (Sarah Mitchell)
Documents:  → Original contract + AI analysis report
ETA:        → Based on history: approx. 1.8 days

[View full AI analysis]  [Override AI review]  [Instance history]
```

**Compliance report**

```
QUARTERLY COMPLIANCE — Q1 2026
────────────────────────────────────────────────────────
Contracts processed: 247
  Without issues: 198  (80%)
  Flagged by AI: 49 — corrected before signing: 43

Compliance violations: 0
  (every contract passed mandatory review)

Average cycle time: 4.1 days
  vs. Q1 2025 (before Blueprint): 11.3 days

AI participation:
  34% of contracts — issues caught at the pre-review stage
  $2.1M — estimated risk prevented  (liability clause corrections)

Audit export: [PDF]  [JSON]  [API]
```

### Where Blueprint Applies

```
Process                          What AI automates
─────────────────────────────────────────────────────────
Client onboarding               → Document verification, risk scoring
Procurement                     → Vendor check, compliance validation
HR approvals (leave, etc.)      → Policy rules, conflict detection
IT access requests              → Security policy validation
Investment committee            → Due diligence pre-check
Regulatory reporting            → Data collection + validation before filing
Vendor evaluation               → Comparative scoring against criteria
```

### Igniter Under the Hood — Why This Matters for Enterprise

| Enterprise requirement | Igniter solution |
|---|---|
| Compile-time validation | Process graph validated before deployment — schema errors cannot reach production |
| Audit trail | Receipt chain — every decision, every action is an immutable, verifiable record |
| AI in the process | Agents as first-class participants — not an integration layer, native to the model |
| Compliance | Refusal-first design — the process physically cannot skip a mandatory step |
| Delivery | Capsule transfer — a process definition ships as a verifiable artifact |
| Scale | Cluster mesh — processes run across multiple nodes |

### Build Further

```
MVP (delivered to client)               Next iterations
─────────────────────────────────────── ────────────────────────────────────
2–3 processes in one system          → Unlimited process catalog
Manual trigger (document upload)     → API trigger / webhook (from CRM/ERP)
Email notifications                  → Slack / Teams / SMS
Basic AI review                      → Fine-tuned model for the client's domain
Single node                          → Cluster deployment
Snapshot reports                     → Real-time BI dashboard
                                     → SAP / Oracle / Salesforce integration
                                     → Regulatory submission API (FDA, SEC)
```

---

## App 3.2: Accord — Agreement Lifecycle Management

### Tagline

> "Every agreement: from initiation to archive. Under control. With AI. Auditable."

### Pain

B2B business runs on agreements: SLAs, NDAs, partnership agreements, vendor
contracts, employment contracts. A typical enterprise manages hundreds of active
contracts — and most of them are "managed" through a folder on SharePoint and an
Excel spreadsheet of renewal dates.

The consequences are predictable. A contract expires unnoticed — and with it, IP
protection. An auto-renewal triggers without review — at terms that have shifted.
Nobody can say who actually signed. In an M&A due diligence, chaos.

Accord is lifecycle management that understands the meaning of a document, not
just its metadata. It knows what your obligations are, monitors whether they are
being met, and speaks up when something requires attention.

### How It Looks to the User

**Portfolio view**

```
ACCORD — Active agreements  (847)
────────────────────────────────────────────────────────────────────────
Requiring attention today:

  ● CRITICAL (3):
     NDA with DataVendor Inc — expires in 12 days  (no one initiated renewal)
     SLA with CloudPlatform — violation detected by AI  (uptime 98.1% vs. SLA 99.5%)
     Employment agreement — senior engineer — non-compete clause expired, not renewed

  ● REVIEW (7):
     5 vendor contracts — auto-renewal in 30 days, AI recommends review
     2 partnership agreements — terms not revisited in more than 18 months

[Handle critical items]  [View all]  [Batch actions]
```

**AI document analysis**

On upload of a new contract, or during a scheduled re-review:

```
AGREEMENT ANALYSIS
─────────────────────────────────────────────────────────
Document: Vendor Agreement — TechSupplier Ltd
Uploaded: 26 Apr 2026, 14:23

AI analysis  (3 minutes):

KEY TERMS:
  Term: 2 years  (until 26 Apr 2028) | Auto-renewal: YES  (60 days notice)
  Value: $84,000/year + 5% annual escalation
  SLA: 99.9% uptime, response <4h for P1
  Liability cap: $250,000  (2.97× annual fee — ABOVE STANDARD: typical is 1–2×)
  Governing law: Delaware, USA

RISKS:
  ● Liability cap 2.97× — above your standard  (1.5×)
  ● Auto-renewal with escalation — cumulative cost increase $8,400/year by year 2
  ● No SLA for P2/P3 incidents  (only P1 covered)
  ● IP and confidentiality — standard

RECOMMENDATIONS:
  1. Request liability cap reduced to 1.5×
  2. Add SLA coverage for P2 incidents
  3. Set a reminder for 26 Feb 2028  (60 days before auto-renewal)

[Accept recommendations]  [Start negotiations]  [Decline and archive]
```

**Obligation tracking**

```
OBLIGATIONS TRACKER — TechSupplier Ltd
─────────────────────────────────────────────────────
Active obligations: 8

  Ours to them:
    ✓ Monthly payment — paid through 26 April
    ○ Quarterly business review — next: 15 May  [Schedule]
    ✓ Security audit access — provided

  Theirs to us:
    ⚠ SLA uptime — current: 99.1%  (required: 99.9%) — 3 days in violation
      [Initiate SLA dispute]  [Document]  [Acknowledge and monitor]
    ✓ Support response time — within SLA
    ○ Quarterly roadmap briefing — pending

AI monitoring: on | Last check: today 06:00
```

**Due diligence package**

```
GENERATING DUE DILIGENCE PACKAGE
─────────────────────────────────────────────────────────
Requested by: M&A team
Type: Full contract audit

Accord collected:
  ✓ 847 active agreements — indexed
  ✓ 1,243 archived — indexed
  ✓ Liability exposure summary — $14.2M total cap
  ✓ Top 20 by value — full AI analysis
  ✓ Expired without formal closure — 3 found  (attention required)
  ✓ Auto-renewal risks next 12 months — 47 contracts
  ✓ Non-standard terms — 23 flagged

Package ready:  [Export ZIP]  [Secure link for auditor]  [API]
Generation time: 4 minutes  (typical manual effort: 2–3 weeks)
```

### Build Further

```
MVP Accord                              Next iterations
─────────────────────────────────────── ────────────────────────────────────
Upload + AI analysis                 → Email / DocuSign automatic intake
Basic obligation reminders           → ERP integration (payments from SAP)
Manual SLA monitoring                → API monitoring (automatic)
Single contract type                 → Specialized modules (M&A, HR, IP)
Snapshot reports                     → Regulatory reporting (GDPR, SOX)
Single tenant                        → Multi-entity (holding structures)
                                     → eSignature integration (DocuSign, HelloSign)
                                     → Salesforce / HubSpot sync (client contracts)
                                     → Law firm portal (external counsel)
```

---

# The Full Picture: Three Audiences — One Platform

```
                 End User              Creator               Enterprise
                 (Forma / Meridian)    (Studio / Signal)     (Blueprint / Accord)
──────────────────────────────────────────────────────────────────────────────
Knows Igniter?   NO                    SOMETIMES             NO (the dev does)
Who installs?    Developer             Creator or dev        Enterprise dev team
Value?           Personal outcomes     Audience growth       Compliance & scale
Entry point?     App / SaaS            Self-hosted SaaS      On-premise / private cloud
Extensibility?   Call a developer      DIY or hire a dev     Internal dev team
──────────────────────────────────────────────────────────────────────────────
Igniter role     Under the hood        Config + extend       Core architecture
Capsule?         Install extensions    Ship new features     Certified deployment
Audit?           Personal history      Campaign records      Regulatory compliance
Agents?          Coach / tutor         AI writer / scout     Compliance checker
```

## The Thread Between Audiences

A developer learns Igniter at the technical level — through `application-proposals.md`
and the platform itself.

With that expertise in hand, they build Forma for end users. Forma gains
traction, and the developer builds a reputation. A creator team notices the
pattern and hires them for Studio. Studio grows into Signal. A year later an
enterprise organization sees Studio, wants something similar for internal
processes, and Blueprint is born.

Igniter is the platform. The applications are what users see. Reputation builds
from the ground up: end users → creators → enterprise. Every layer depends on the
one below it, and each successful application is a reference case for the next.

## Priority Recommendation

Of the six applications proposed, the recommended build sequence:

| # | App | Why first |
|---|---|---|
| 1 | **Studio** | Creator audience = early adopters; high share potential; showcases the platform publicly |
| 2 | **Forma** | Mass market; clear, felt pain; fast "wow" moment for the user |
| 3 | **Blueprint** | High deal size; demonstrates enterprise Igniter; one sale becomes a reference case |
| 4 | **Signal** | Works best as an upsell to Studio; not the right entry point standalone |
| 5 | **Meridian** | Good market; but competition is fierce (Duolingo, Babbel, Khanmigo) |
| 6 | **Accord** | Enterprise niche; benefits from a mature Igniter ecosystem around it |

Studio first because creator communities share. A creator using Studio and
talking about it publicly is worth more at this stage than a Fortune 500 pilot
running quietly inside a firewall.
