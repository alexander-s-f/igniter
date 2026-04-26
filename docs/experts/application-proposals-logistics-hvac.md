# Igniter Application Proposals — Logistics & Field Service

Date: 2026-04-26.
Perspective: product designer / vertical software strategist.
Purpose: application proposals for two specific business verticals —
logistics/delivery operations and field service (Appliance Repair & HVAC),
including both operator-facing tools and the SaaS layer sold to operators.

---

## Industry Context

These verticals share a structural pattern that maps directly onto Igniter's
strengths:

- **A job has a lifecycle** that spans hours or days, involves multiple
  participants, and changes state based on real-world events
- **Exceptions are the rule** — the plan that exists at 8am rarely survives
  until noon; the system must handle deviation, not just the happy path
- **Human-AI handoff is critical** — automation handles routine, humans handle
  judgment; the boundary must be explicit and auditable
- **Receipt is the business artifact** — proof of delivery, signed work order,
  dispatch log — these are legally and commercially significant

None of the major incumbents (ServiceTitan, Housecall Pro, McLeod, Samsara)
were designed with AI as a native participant. They bolt it on. An Igniter-built
application can make AI participation structural from day one.

---

# Part 1: Logistics

---

## App L1: Convoy — Regional Delivery Operations Platform

### Tagline

> "Every driver knows the plan. Every exception gets a decision, not a phone call."

### Who This Is For

A regional logistics operator: 15–200 delivery vehicles, mixed residential and
commercial stops, same-day and next-day windows. Currently managed through a
legacy TMS, spreadsheets, and a dispatcher who spends 60% of their day on the
phone reacting to problems that a system should have caught first.

This is NOT for FedEx or Amazon. This is for the regional carrier, the last-mile
delivery service, the wholesale distributor with its own fleet.

### Pain

Last-mile delivery has a dirty secret: 20–25% of deliveries do not complete on
the first attempt. Each failed attempt costs $15–25. The dispatcher finds out
about the failure when the driver calls, not before. By then, the optimal
reroute window has passed.

Meanwhile, customers are calling the office — "where is my delivery?" — because
nobody sent them a tracking update. The office staff is on the phone relaying
information between drivers and customers manually.

And when a driver calls in sick at 6am: total reconstruction of 40 stops across
3 zones, by a human, under time pressure, with coffee.

### Why Igniter Specifically

| Igniter feature | Application |
|---|---|
| Contracts graph | Route as a validated dependency graph: time windows, vehicle capacity, driver hours, zone constraints — validated at plan time, not dispatch time |
| Proactive agent | Monitors active routes; detects at-risk deliveries before they fail |
| Long-lived session | A route lives for a full working day; the session survives driver app restarts |
| Wizard flow | Exception handling: failed delivery → reroute options → driver decision → customer notification |
| `await` | System pauses route execution waiting for driver confirmation at checkpoints |
| Receipt chain | End-of-day delivery manifest: what was delivered, when, by whom, with what exceptions |

### Scenarios

**Scenario 1: Morning Dispatch**

```
CONVOY DISPATCH — Tuesday Apr 26
──────────────────────────────────────────────────────────────
Vehicles ready: 23 / 24   (Driver Davis: called sick — 41 stops unassigned)

Convoy has proposed a redistribution:
  ● Absorbed by Rodriguez (+14 stops, extends route by 38 min — within HOS)
  ● Absorbed by Okonkwo   (+12 stops, extends route by 22 min — within HOS)
  ● 15 stops flagged for reassignment to afternoon shift (3 vehicles available)

2 stops CANNOT be absorbed today:
  → Commercial window 08:00–09:00, Warehouse B — no available vehicle in zone
  → Requires customer call to reschedule

[Approve redistribution] [Adjust manually] [Call customer re: Warehouse B]
```

**Scenario 2: Proactive Exception Alert**

This runs silently in the background throughout the day:

```
CONVOY ALERT — 10:47 am
──────────────────────────────────────────────────────────────
Driver Rodriguez — stop #8 of 22 (ETA was 10:30)
  Current position: 4.2 miles from stop, in traffic
  Revised ETA: 11:12  (stop has window: 10:00–11:00)

Risk: PROBABLE LATE DELIVERY

Options:
  A. Notify customer now — offer ETA 11:12 or reschedule  [Recommended]
  B. Swap stop #8 with stop #9 (same zone, flexible window) — saves 11 min
  C. No action — accept lateness

[Notify customer] [Swap stops] [No action]
```

Customer gets notified automatically if dispatcher approves. No phone call to
Rodriguez. No manual lookup.

**Scenario 3: Failed Delivery Wizard**

```
FAILED DELIVERY — Rodriguez / Stop #11
──────────────────────────────────────────────────────────────
Reported by driver: "Nobody home. No safe drop location."
Time: 12:34

Package: 2 boxes, residential, requires signature
Customer phone: on file

Convoy suggests:
  Step 1: Attempt customer contact (auto-call in 60 seconds)
  Step 2: If no answer → hold at depot or neighbor drop (if flagged)
  Step 3: Schedule re-delivery for tomorrow, same window

Customer picked up. Outcome:
  → Requested redelivery tomorrow 10am–12pm
  → Convoy added to tomorrow's route automatically

[Confirm] [Different outcome] [Manual handling]
```

**Scenario 4: End-of-Day Manifest and Receipt**

```
ROUTE COMPLETE — Rodriguez — Tuesday Apr 26
──────────────────────────────────────────────────────────────
Stops planned: 22
Stops completed: 20
Failed (rescheduled): 1  (stop #11 — customer rescheduled)
Exception handled: 1  (stop #8 — 12 min late, customer notified)

Drive time: 6h 14m  |  Miles: 187  |  HOS compliant: YES
Signatures collected: 18/20 (2 contactless)
Customer notifications sent: 4 (3 ETA updates, 1 reschedule)

[Export manifest] [Submit to client] [Flag for billing review]
```

### DSL Sketch

```ruby
App = Igniter.interactive_app :convoy do
  service :routes,    Services::RouteStore
  service :drivers,   Services::DriverRegistry
  service :stops,     Services::StopManifest
  service :customers, Services::CustomerContacts

  agent :monitor, Agents::RouteMonitorAgent do
    wakeup every: 90   # seconds
    tools  CheckTrafficTool, PredictETATool, DetectAtRiskTool
  end

  agent :dispatcher, Agents::DispatchAgent do
    tools  RedistributeStopsTool, ProposeRerouteTool,
           NotifyCustomerTool, LogExceptionTool
  end

  surface :dispatch_center, at: "/" do
    zone :active_routes,     label: "Routes"
    zone :alerts,            label: "Alerts"
    zone :unassigned,        label: "Unassigned"
    stream :exception_feed
    chat :dispatcher_chat, with: :dispatcher
  end

  surface :route, at: "/route/:id" do
    zone :stop_list
    zone :driver_position
    zone :exceptions
    stream :live_updates
  end

  flow :exception_handling do
    step :detect,          agent: :monitor
    step :assess,          agent: :dispatcher
    step :decide,          requires_approval: true
    step :notify_customer, agent: :dispatcher
    step :resolve
    step :log,             produces: :exception_record
  end

  flow :end_of_day do
    step :collect_outcomes
    step :reconcile
    step :generate_manifest, produces: :delivery_receipt
  end

  endpoint :stream,   at: "/events",  format: :sse
  endpoint :driver,   at: "/driver",  format: :json   # driver mobile app API
end
```

### POC Scope

In scope:
- Manual stop list import (CSV) + driver assignment
- Proactive ETA monitoring (geocoding + traffic estimate)
- Exception alert with 3 resolution options
- Customer notification (SMS via Twilio or similar)
- End-of-day delivery manifest (PDF/JSON)
- SSE live dispatch board

Out of scope for POC: real-time GPS integration, native mobile driver app
(driver uses web view), automated billing, fleet maintenance.

### Build Further

| Thread | What it unlocks |
|---|---|
| Driver mobile app | Native iOS/Android with real-time stop navigation |
| GPS fleet integration | Live vehicle tracking via Samsara / Verizon Connect API |
| Customer tracking portal | Self-serve "where is my delivery?" link per shipment |
| Proof of delivery photos | Driver captures photo + signature, attached to receipt |
| Automated billing | Delivery manifest → invoice in QuickBooks / NetSuite |
| Multi-depot | Routes and drivers across multiple warehouse locations |
| Analytics | On-time rate, failed delivery cost, driver performance trends |
| White-label | Courier builds its own branded platform on top of Convoy |

---

## App L2: Freight — 3PL & Broker Operations Hub

### Tagline

> "Every load has a home. Every exception has an owner. Every move leaves a paper trail."

### Who This Is For

A freight broker or third-party logistics provider (3PL): matching shipper loads
to carrier capacity, managing documentation, tracking in-transit freight, and
handling the inevitable exceptions (damaged goods, late pickups, carrier no-shows,
claims). Team of 5–50 operations staff.

### Pain

Freight brokerage is fundamentally an information coordination problem. A broker
juggles 50–200 active loads, each with a shipper, a carrier, a route, and a set
of documents. The status of any given load exists in: email, phone call notes, a
TMS with a 10-second login time, a spreadsheet the new coordinator made, and the
broker's memory.

When a carrier goes dark at mile 400 with a $200k load of electronics — the
broker finds out from the shipper, not the carrier. The exception workflow is
email, phone, more email. The claims process is paper-based and takes months.

### Igniter Fit

| Igniter feature | Application |
|---|---|
| Contracts graph | Load lifecycle: tender → carrier accept → pickup confirm → in-transit → delivery → POD → invoice — validated dependency chain |
| Long-lived session | A load lives for 1–5 days; all events, communications, and documents attach to the session |
| Proactive agent | Monitors carrier check-in cadence; escalates when a carrier goes dark |
| `await` | Load cannot advance to invoice step without confirmed POD document |
| Wizard flow | Claims initiation: incident → carrier response → documentation → resolution |
| Receipt chain | POD receipt + delivery confirmation + claims history — all immutable |

### Scenarios

**Scenario 1: Load Board + Carrier Matching**

```
OPEN LOAD — LTL Springfield → Memphis
──────────────────────────────────────────────────────────────
Pickup: Apr 27, 08:00–12:00
Delivery: Apr 28, before 17:00
Weight: 8,400 lbs  |  Pallets: 6  |  Hazmat: No
Target rate: $1,240

Freight found 4 carrier matches:
  ● Swift (preferred, 98.2% on-time, $1,180)          [Tender]
  ● Werner  (96.1% on-time, $1,150)                   [Tender]
  ○ Knight (lane history: 1 no-show last quarter)     [Review first]
  ○ Broker pool — spot market (~$1,310 est.)          [Post to DAT]

[Tender to Swift] [Tender to Werner] [Review Knight history] [Post spot]
```

**Scenario 2: Proactive Dark Carrier Alert**

```
FREIGHT ALERT — Load #FL-2847
──────────────────────────────────────────────────────────────
Carrier: Horizon Transport
Last check-in: 6 hours ago (expected: every 2 hours)
Last known position: I-40, near Amarillo TX
ETA to delivery: was 14:00 tomorrow

Freight tried: 2 automated check-in pings — no response

Recommended actions:
  1. Call carrier dispatch (number on file)        [Call now — Freight dials]
  2. Notify shipper: possible delay                [Draft notification]
  3. Identify backup carrier in lane              [Find backup]

This load: electronics, $187,000 declared value.
Insurance: Active (Horizon, $100k; broker contingent, $87k)

[Call carrier] [Notify shipper] [Find backup] [Mark as monitored]
```

**Scenario 3: POD Receipt and Invoice Gate**

```
DELIVERY CONFIRMED — Load #FL-2847
──────────────────────────────────────────────────────────────
Delivered: Apr 28, 13:47 (deadline: 17:00) ✓
Driver: M. Reyes  |  Signed by: J. Smith (Receiving, Memphis DC)

POD uploaded: [signed-pod-fl2847.pdf]
AI review of POD:
  ✓ Consignee signature present
  ✓ Date/time match delivery record
  ✓ All 6 pallets counted
  ✗ Pallet #4 noted as "corner damage" by receiver

Action required before invoice:
  → Shipper must acknowledge damage note
  → Carrier must submit damage report within 24h

[Notify shipper of damage note] [Hold invoice] [Proceed despite note]
```

**Scenario 4: Claims Wizard**

```
CLAIM INITIATED — Load #FL-2847
──────────────────────────────────────────────────────────────
Shipper has filed a damage claim: $4,200 (pallet #4)

Step 1/4: Documentation Collection
  Required:
    ✓ POD with damage notation
    ✓ Shipper's invoice for damaged goods
    ✓ Photos from delivery (requested from driver)
    ○ Carrier damage report (due in 18h)

  Freight has drafted carrier demand letter.
  [Review letter] [Send now] [Edit first]

Step 2/4 will open after carrier response or 24h timeout.
```

### Build Further

| Thread | What it unlocks |
|---|---|
| EDI integration | Automated load tender/accept via 204/990 EDI |
| Rate engine | Historical lane rates + market feed for pricing |
| Carrier onboarding | Insurance verification, compliance, credit check wizard |
| Shipper portal | Shipper tracks own loads, downloads PODs |
| Automated invoicing | POD confirmed → invoice generated → submitted to shipper TMS |
| Claims automation | Damage report → carrier demand → settlement tracking |
| Analytics | Lane profitability, carrier performance, exception cost |

---

# Part 2: Appliance Repair & HVAC

---

## App H1: Field — Service Company Operations Platform

### Tagline

> "From the first call to the five-star review — one system that runs itself."

### Who This Is For

An independent HVAC or appliance repair company: 3–30 technicians, residential
and light commercial, scheduling calls, dispatching techs, writing estimates,
invoicing, and chasing reviews. Currently using a combination of Google Calendar,
QuickBooks, and phone calls. Or paying $200–600/month for ServiceTitan or
Housecall Pro and using 20% of its features.

### Pain

A typical service call lifecycle has twelve touchpoints, and most of them are
manual:

```
Customer calls → schedule appointment → send confirmation → remind customer
→ dispatch tech → tech calls for parts → wait for parts → tech completes job
→ write estimate → customer approves → collect payment → send invoice
→ enter into QuickBooks → request Google review → follow up for maintenance
```

Every one of these is either a phone call, a manual entry, or a reminder someone
forgot to set. On a busy day with 8 techs, this is 96 touchpoints — most of
them missed.

The business consequence: no-shows because the customer forgot (15–20% of
appointments), invoices that go out late or wrong, reviews that never get
requested, and a maintenance pipeline that exists in the owner's head.

### Igniter Fit

| Igniter feature | Application |
|---|---|
| Contracts graph | Job lifecycle as validated dependency graph: you cannot invoice a job that has no signed estimate |
| Proactive agent | Sends reminders, tracks tech ETAs, triggers review requests — autonomously |
| Long-lived session | A job lives for 1–14 days (diagnosis → parts order → completion) |
| Wizard flow | Tech-facing job flow: arrive → diagnose → estimate → approval → complete |
| `await` | Job pauses waiting for customer signature before proceeding to parts order |
| Receipt chain | Job receipt: signed estimate + parts used + payment + photos |

### Scenarios

**Scenario 1: Inbound Call → Booked Appointment**

Office staff (or AI phone agent) is on the call:

```
NEW SERVICE REQUEST
──────────────────────────────────────────────────────────────
Customer: Sarah Chen  (returning customer — 2 previous jobs)
Equipment: Carrier AC unit, installed 2019 (from prior job record)
Problem: "Not cooling, making a noise"
Address: 421 Oak St  (in Zone B)

Field suggests:
  Tech availability in Zone B:
    ● Martinez — today 2pm–4pm (AC certified, familiar with Carrier)
    ● Johnson  — tomorrow 10am–12pm

Customer requests: tomorrow morning

Appointment set: Thu Apr 27, 10am–12pm / Tech: Johnson
  → Confirmation SMS sent to Sarah ✓
  → Reminder queued for tomorrow 8am ✓
  → Job created: #JB-4821

[View job] [Notes] [Adjust window]
```

**Scenario 2: Day-of Dispatch Surface**

```
FIELD DISPATCH — Thursday Apr 27
──────────────────────────────────────────────────────────────
8 technicians active  |  23 jobs today

09:47  Martinez — Job #JB-4819 (AC repair)
        Status: En route  ETA: 14 min  [Track]
        Customer notified: "Your tech is 14 minutes away"  ✓

09:52  Johnson — Job #JB-4821 (Sarah Chen / AC)
        Status: Scheduled 10am  No action needed

10:18  Kim — Job #JB-4817 (Refrigerator — GE Profile)
        WAITING PARTS:  compressor ordered Mon, expected Fri
        Customer last updated: Tuesday  [Send update]

11:03  ALERT: Torres — Job #JB-4820 running 40 min over estimate
        Customer window closing at noon
        [Call Torres] [Notify customer] [Reschedule remainder]
```

**Scenario 3: Tech-Side Job Flow (Mobile)**

Johnson is on site with Sarah Chen. Uses Field on his phone:

```
JOB #JB-4821 — Sarah Chen / AC — Carrier 3-ton
──────────────────────────────────────────────────────────────
Step 1: Arrived  [Mark arrived — 10:08am]

Step 2: Diagnosis
  Johnson enters findings:
    Refrigerant low — leak suspected at Schrader valve
    Capacitor reading: 12µF (spec: 35µF) — replace needed

  Field auto-builds estimate:
    Refrigerant recharge (2 lbs R-410A): $160
    Schrader valve replacement:           $85
    Capacitor replacement:               $95
    Labor (est. 1.5h):                  $180
    ─────────────────────────────────────
    Total:                              $520

  [Send estimate to customer for approval]

Step 3: Awaiting approval — Sarah reviewing on her phone
  [Approved at 10:41] ✓

Step 4: Parts — capacitor on truck / refrigerant on truck
  Proceeding with repair.

Step 5: Complete
  [Mark complete] [Upload photos] [Collect payment]
  Payment: $520 via card  ✓
  Receipt sent to sarah@email.com ✓

Step 6: Review request
  Field: "Send review request now or in 2 hours?"
  [Now] [In 2h] [Skip]
```

**Scenario 4: Proactive Maintenance Pipeline**

```
FIELD MAINTENANCE AGENT — Weekly Report
──────────────────────────────────────────────────────────────
Equipment due for maintenance this month: 14 units

  ● 6 customers have existing maintenance agreements — auto-schedule ✓
  ● 8 customers are overdue — no agreement

  Field drafted outreach for the 8:
    "Hi Sarah, it's been 11 months since we serviced your Carrier AC.
     Summer is coming — want to book a tune-up? We have openings
     next week at $89 (free if you join our maintenance plan)."

  Preview outreach: [Review all 8] [Send now] [Edit template]

  Historical response rate for this template: 34%
  Projected bookings: 2–3 jobs
```

### DSL Sketch

```ruby
App = Igniter.interactive_app :field do
  service :jobs,        Services::JobStore
  service :techs,       Services::TechRegistry
  service :customers,   Services::CustomerStore
  service :parts,       Services::PartsInventory
  service :equipment,   Services::EquipmentHistory

  agent :dispatcher, Agents::DispatchAgent do
    wakeup every: 300
    tools  CheckTechETATool, DetectDelayTool,
           NotifyCustomerTool, SuggestRerouteTool
  end

  agent :office, Agents::OfficeAgent do
    tools  BuildEstimateTool, SendConfirmationTool,
           RequestReviewTool, DraftMaintenanceOutreachTool
  end

  surface :dispatch, at: "/" do
    zone :todays_schedule
    zone :alerts
    zone :parts_waiting
    stream :live_updates
  end

  surface :job, at: "/job/:id" do
    zone :job_details
    zone :tech_location
    zone :estimate
    zone :timeline
    stream :job_events
  end

  flow :service_job do
    step :intake
    step :schedule,      produces: :appointment_confirmation
    step :dispatch
    step :diagnose,      agent: :office
    step :estimate,      requires_approval: true   # customer approves
    step :complete
    step :invoice,       produces: :job_receipt
    step :review_request, agent: :office
  end

  endpoint :stream,  at: "/events",  format: :sse
  endpoint :mobile,  at: "/tech",    format: :json   # tech mobile API
end
```

### POC Scope

In scope:
- Job creation from inbound request
- Tech calendar and zone-based assignment
- Customer confirmation and reminder SMS
- Tech mobile job flow (web-responsive, no native app needed)
- Digital estimate with customer SMS approval link
- Payment capture (Stripe integration)
- Review request trigger after job close
- Parts-waiting status with customer update

Out of scope for POC: native mobile app, QuickBooks sync, online booking widget,
inventory management, multi-location.

### Build Further

| Thread | What it unlocks |
|---|---|
| Online booking widget | Customer self-books from website (embed on existing site) |
| QuickBooks / Xero sync | Invoice auto-posted to accounting |
| Parts ordering | Tech requests parts → auto-PO to supplier |
| Maintenance plans | Recurring billing + auto-scheduling for plan members |
| Equipment history | Full service history per unit, visible to tech on job |
| Photo documentation | Before/after photos attached to job receipt |
| Technician performance | Jobs/day, customer ratings, first-call resolution rate |
| Franchise mode | Multiple locations, centralized scheduling and billing |

---

## App H2: Nexus — Field Service SaaS Platform

### Tagline

> "You run the calls. AI books the jobs. Technicians show up. Companies pay you."

### Who This Is For

A **marketing or call center company** that sells lead generation, appointment
booking, and customer communication services to HVAC and appliance repair
companies. They handle inbound calls for 20–80 service companies, book jobs,
send reminders, and follow up for reviews — charging the service companies
$200–800/month per market.

This is a B2B SaaS model. The call center company is the customer building on
Nexus. The HVAC companies are their clients (tenants). The homeowners are the
end users.

This is the most commercially ambitious proposal in this document. It is also
the most direct challenge to ServiceTitan ($9.5B valuation) and Housecall Pro —
built natively in Igniter, AI-first, developer-extensible, and capsule-delivered
to each client.

### The Business Model Being Served

```
Homeowner calls → Call center answers for "ABC Heating & Cooling"
               → Books appointment in ABC's calendar
               → Sends confirmation from ABC's number
               → Dispatches ABC's tech
               → Collects review for ABC's Google profile

ABC Heating pays: $350/month for this service
Call center has: 40 clients × $350 = $14,000/month

The call center's margin depends on how much is automated vs. human-handled.
Nexus makes the automated portion as large as possible.
```

### Pain

The call center company currently uses a patchwork of tools:
- One CRM for their own operations
- Individual logins to each client's calendar (20–80 logins)
- Copy-paste to update each client's system
- Manual reminder calls because automated SMS isn't set up
- No unified view of all clients' job pipelines

When a call comes in for "Miller Appliance Repair," the agent has 90 seconds
to look up Miller's availability, book the job in Miller's system, and confirm
with the homeowner — while managing 3 other calls. Mistakes happen. Clients
churn when they happen too often.

### Igniter Fit

| Igniter feature | Application |
|---|---|
| Capsule model | Each service company (tenant) is a capsule: their schedule, techs, zones, pricing, branding |
| Contracts graph | Lead qualification → client match → tech availability → appointment booking — validated at each step |
| Proactive agent | Handles routine outreach autonomously: reminders, ETAs, follow-ups, review requests |
| Long-lived session | A job lifecycle attaches to the tenant capsule and persists through all touchpoints |
| Receipt chain | Full audit trail per job per tenant — for dispute resolution and client reporting |
| `await` | Homeowner must confirm the appointment window before tech is dispatched |
| Capsule transfer | New client onboarding = capsule deployment; client offboarding = capsule revocation |

### Scenarios

**Scenario 1: Inbound Call Handling (AI-Assisted)**

The call center agent (or AI voice agent) takes an inbound call:

```
INBOUND CALL — Line 4
──────────────────────────────────────────────────────────────
Caller ID matched: returning homeowner (Sarah Chen, 3 prior jobs)
Routing to: Miller Appliance Repair  (DID match)

Nexus surface shows:
  Sarah Chen | 421 Oak St | Account active
  Prior jobs: refrigerator repair (2024), dishwasher (2023)
  Current equipment on file: LG fridge (2020), Whirlpool dishwasher (2018)

Caller says: "My fridge stopped cooling"

Nexus suggests:
  Likely equipment: LG fridge (2020) — on file
  Miller availability in Sarah's zone (B):
    ● Tomorrow Thu 10am–12pm  (tech: Rodriguez, appliance certified)
    ● Fri 2pm–4pm

Agent offers Thursday → Sarah confirms.

Nexus books:
  Job #ML-4821 in Miller's schedule ✓
  Confirmation SMS to Sarah (from Miller's number) ✓
  Calendar hold for Rodriguez ✓
  Reminder queued: tomorrow 8am ✓
```

**Scenario 2: Multi-Client Dispatch Surface**

This is the call center's internal view:

```
NEXUS OPERATIONS — Thu Apr 27
──────────────────────────────────────────────────────────────
Active clients: 38  |  Jobs today: 214  |  Alerts: 3

CLIENT SUMMARY (sorted by alerts):

  Miller Appliance     11 jobs  ●● 2 alerts
    → Rodriguez: 40 min over estimate on job #ML-4819
    → Parts delay: job #ML-4822, customer not yet notified

  ABC HVAC             18 jobs  ● 1 alert
    → Seasonal spike: 3 jobs unassigned (no tech in zone C today)

  Precision Repair      9 jobs  ✓ no alerts

  [+ 35 more clients]

[Handle Miller alerts] [Handle ABC alert] [View all]
```

**Scenario 3: New Client Onboarding — Capsule Deployment**

A new service company signs up with the call center:

```
NEW CLIENT ONBOARDING — Sunrise HVAC (Chicago North)
──────────────────────────────────────────────────────────────
Onboarding wizard:
  Step 1: Company profile
    Name, DID phone number, service area (zip codes), branding

  Step 2: Services & pricing
    Services offered: HVAC install, AC repair, furnace repair, maintenance
    Labor rates: standard / overtime / emergency
    Parts markup: 30%

  Step 3: Technicians
    4 techs imported from CSV
    Skills tagged: Tom (HVAC certified), Maria (both), ...

  Step 4: Zones & routing rules
    Zip code zones drawn on map
    Zone assignments per tech

  Step 5: Communication templates
    Confirmation SMS ← pre-filled, editable
    Reminder SMS    ← pre-filled, editable
    Review request  ← pre-filled, editable

  Step 6: Verification & launch
    Test booking flow ← Nexus creates a test job and verifies full chain

Sunrise HVAC is live. [View client dashboard]
```

Igniter capsule model: each client is a deployed capsule instance with its own
configuration, data isolation, and activation receipt.

**Scenario 4: Client Monthly Report (Delivered to Service Company)**

```
MONTHLY REPORT — Miller Appliance Repair — April 2026
──────────────────────────────────────────────────────────────
(Generated by Nexus, sent to Miller owner automatically)

Jobs completed:    94     Revenue recovered: $38,200
Avg response time: 23 min (industry benchmark: 45 min)
Reminders sent:   182     No-show rate: 8%  (down from 14% in March)
Review requests:   89     New reviews: 31 (avg rating: 4.8)

Top performing tech: Rodriguez (28 jobs, 4.9 rating)
Busiest day: Wednesday

Cost this month: $350
Estimated value: ~$4,200 in jobs that would have been lost without reminders
               + 31 reviews driving ~$800/month in new leads (est.)

[View detailed breakdown] [Download PDF] [Contact Nexus support]
```

### DSL Sketch

```ruby
# [Alex / Owner] -> "Nexus my favorite Igniter project idea *"
# Nexus is a multi-tenant platform.
# Each HVAC company is a capsule instantiated within the platform.

App = Igniter.interactive_app :nexus do
  service :clients,   Services::ClientRegistry       # HVAC companies
  service :jobs,      Services::MultiTenantJobStore  # scoped by client
  service :techs,     Services::MultiTenantTechStore
  service :calls,     Services::InboundCallLog

  agent :intake, Agents::IntakeAgent do
    tools  MatchCallerTool, CheckAvailabilityTool,
           BookJobTool, SendConfirmationTool
  end

  agent :operations, Agents::OperationsMonitorAgent do
    wakeup every: 300
    tools  ScanAllClientAlertsTool, DetectDelaysTool,
           NotifyCustomerTool, EscalateToStaffTool
  end

  agent :lifecycle, Agents::JobLifecycleAgent do
    tools  SendReminderTool, TrackCompletionTool,
           RequestReviewTool, GenerateClientReportTool
  end

  surface :operations_center, at: "/" do
    zone :client_summary     # all clients at a glance
    zone :active_alerts
    zone :todays_volume
    stream :real_time_feed
  end

  surface :client, at: "/client/:id" do
    zone :jobs
    zone :techs
    zone :performance
    stream :client_feed
  end

  flow :job_lifecycle do
    step :intake,     agent: :intake
    step :remind,     agent: :lifecycle
    step :dispatch
    step :complete
    step :review,     agent: :lifecycle
    step :report,     produces: :job_receipt
  end

  flow :client_onboarding do
    step :profile
    step :services_and_pricing
    step :techs_and_zones
    step :communication_templates
    step :verify_and_launch, produces: :client_activation_receipt
  end

  endpoint :stream,      at: "/events",       format: :sse
  endpoint :voice_hook,  at: "/call/inbound", format: :json  # Twilio webhook
  endpoint :client_api,  at: "/api/v1",       format: :json  # client portal
end
```

### POC Scope

In scope:
- 3–5 tenant clients (simulated, not live HVAC companies)
- Inbound call surface with caller lookup and booking
- Multi-client operations view with alert triage
- Automated SMS confirmation, reminder, review request (Twilio)
- New client onboarding wizard (5 steps)
- Monthly client report auto-generation

Out of scope for POC: AI voice agent (human agent handles calls), real payment
processing, native mobile for techs, multi-region, billing/invoicing for
the call center's own operations.

### Build Further

| Thread | What it unlocks |
|---|---|
| AI voice agent | Inbound call handled entirely by AI (no human agent) |
| Online booking widget | Homeowner self-books on service company's website |
| Multi-region scale | Platform serves call centers in 5–50 markets |
| Client billing | Call center invoices clients automatically from Nexus |
| Parts supplier integration | Tech requests parts → auto-PO to preferred supplier |
| Equipment financing | Suggest financing options for large-ticket replacements |
| Technician recruitment | Platform identifies high-performing techs, facilitates referrals |
| Franchise model | Nexus powers a national franchise of local HVAC companies |

---

# Common Pattern Across All Four Applications

All four applications map onto the same structural template — but with different
domain vocabulary:

```
Domain              "The Plan"          "The Session"     "The Receipt"
──────────────────────────────────────────────────────────────────────────
Convoy              Route manifest      Active route      Delivery manifest
Freight             Load tender         Active load       POD + claims record
Field               Job schedule        Active job        Signed job receipt
Nexus               Client capsule      Active job × N    Job receipt × tenant
```

In each case:
- The plan is validated at creation time (contracts graph)
- The session lives through real-world events and exceptions
- An agent monitors and acts on routine touchpoints autonomously
- Humans are engaged only for judgment calls and approvals
- The receipt closes the loop with an immutable, auditable artifact

This is Igniter's structural advantage in field-operations software: the pattern
that operators deal with every day — plan, execute, handle exceptions, close with
evidence — maps exactly onto the compile-time graph → long-lived session → receipt
model.

---

# Implementation Priority

| # | App | Rationale |
|---|---|---|
| 1 | **Nexus** | Highest commercial leverage — one Nexus installation serves 20–80 clients; capsule multi-tenancy is the defining showcase |
| 2 | **Field** | Direct prerequisite knowledge for Nexus; simpler single-tenant version first |
| 3 | **Convoy** | Strong developer-facing demo; proactive exception agent is compelling |
| 4 | **Freight** | More niche; valuable but narrower audience than the others |
