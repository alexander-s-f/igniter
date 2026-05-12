
### We're building JurisLedger (or LexMesh)—a fully agent-based, decentralized system for storing legislation, precedents, and court cases based on Igniter-Lang + igniter-ledger.

igniter-ledger is ideal as a single source of truth:
- All legislation, amendments, precedents, and cases are immutable BiHistory[T] / History[T].
- Time travel (as_of) is built in natively.
- Each legal change is a separate fact with a causation chain.
- Simulations are isolated partitions (simulations/{sim_id}/...).
- Agents communicate and coordinate via LedgerMesh (as we did in the previous use case).
- Collision detection, case replay, and strategy—all through declarative contracts.

### JurisLedger Architecture (Igniter Langway)

```
Central Ledger (or distributed LedgerServer)
├── laws/                  → BiHistory[LawArticle]
├── amendments/            → History[Amendment]
├── precedents/            → BiHistory[Precedent]
├── court_cases/           → BiHistory[CourtCase]
├── simulations/{sim_id}/
│   ├── actors/{actor_id}/ → isolated AgentContext + Env
│   └── env/{env_id}/      → SimulationEnvironment
└── collisions/            → History[CollisionReport] (automatically)

Agents (multiple instances)
├── RuntimeMachine + Igniter-Lang
├── Local / Network LedgerStore
└── ContractableReceiptSink → все observations = immutable facts
```

Key Features:
- Any agent can request "law as of March 15, 2025" → `law.at(vt: ..., tt: ...)`.
- A temporary **Agent instance** with an isolated partition is created for simulation.
- Collision detection is a separate contract that runs cross-history invariants.
- Full reproducibility: any case can be replayed at any time.

### How the Ledger is used 100%
| Entity | Type in Igniter-Lang | Partition in ledger | Access |
|---------------------------|---------------------------------|---------------------------------------------|--------|
| Law / Article | `BiHistory[LawArticle]` | `laws/{jurisdiction}/{article_id}` | Public + as_of |
| Amendment | `History[Amendment]` | `amendments/{law_id}` | Public |
| Precedent | `BiHistory[Precedent]` | `precedents/{court}/{case_number}` | Public |
| Court Case | `BiHistory[CourtCase]` | `court_cases/{id}` | Public |
| Simulation | `History[SimulationRun]` | `simulations/{sim_id}` | Private per sim |
| Actor context in the simulation | `History[ActorState]` | `simulations/{sim_id}/actors/{actor_id}` | Isolated |
| Environment (Env) | `History[SimulationEnv]` | `simulations/{sim_id}/env/{env_id}` | Isolated |
| Collisions / Conflicts | `History[Collision]` | `collisions/{jurisdiction}` | Public changefeed |

### Contract Examples (Narrative Contracts v2)

#### 1. LawAtDate — query for the current version of the law

```ig
contract LawAtDate for jurisdiction: String, article_id: String, valid_time: DateTime {

  given law_history: BiHistory[LawArticle] from "laws/{jurisdiction}/{article_id}"

  phase retrieval {
    current_version := law_history.at(
      vt: valid_time,
      tt: now
    )
  }

  validate {
    current_version != nil   severity: error   label: "LAW-NOT-FOUND"
  }

  emit law_retrieved(article_id, valid_time, current_version.version)

  output version: LawArticle
  output receipt: FactReceipt
}
```

#### 2. PrecedentSearch — search for relevant precedents

```ig
contract PrecedentSearch for query: LegalQuery, as_of: DateTime {

  given precedents: History[Precedent] from "precedents/{query.jurisdiction}"

  phase search {
    relevant := precedents.as_of(as_of)
      .filter( topic matches query.topic && similarity_score > 0.75 )
      .sort_by( relevance )
      .take(10)
  }

  emit precedents_found(query, relevant.count)

  output results: Array[PrecedentSummary]
  output receipt: FactReceipt
}
```

#### 3. ReproduceCase — full reproduction of the court case

```ig
contract ReproduceCase for case_id: String, simulation_time: DateTime {

  given case_history: BiHistory[CourtCase] from "court_cases/{case_id}"

  phase replay {
    historical_state := case_history.at(
      vt: simulation_time,
      tt: now
    )
    outcome := apply_law_to_facts(historical_state.facts, historical_state.applicable_laws)
  }

  validate {
    historical_state != nil
  }

  emit case_reproduced(case_id, simulation_time, outcome.verdict)

  output reproduced_outcome: CaseOutcome
  output receipt: FactReceipt
}
```

#### 4. RunSimulation — run a simulation for a specific Actor + Env

```ig
contract RunSimulation for sim_id: String, actor_id: String, env_id: String, scenario: ScenarioInput {

  given actor_context: History[ActorState] from "simulations/{sim_id}/actors/{actor_id}"
  given env_state: History[SimulationEnv] from "simulations/{sim_id}/env/{env_id}"

  phase setup {
    actor_instance := spawn_agent_instance(actor_id, actor_context.at(now))   # new agent instance
    env_snapshot   := env_state.at(now)
  }

  phase execution {
    result := actor_instance.execute_contract(
      "ApplyLegalStrategy",
      input: { scenario: scenario, env: env_snapshot }
    )
    observe simulation_step(sim_id, actor_id, result.decision)
  }

  validate {
    result.valid == true
  }

  emit simulation_completed(sim_id, actor_id, result.strategy_score)

  output simulation_result: SimulationResult
  output receipt: FactReceipt
}
```

#### 5. DetectCollisions — search for conflicts between laws/precedents

```ig
contract DetectCollisions for jurisdiction: String, as_of: DateTime {

  given laws: BiHistory[LawArticle] from "laws/{jurisdiction}"
  given precedents: BiHistory[Precedent] from "precedents/{jurisdiction}"

  phase cross_check {
    active_laws     := laws.as_of(as_of)
    active_precedents := precedents.as_of(as_of)
    collisions      := find_conflicts(active_laws, active_precedents)   # invariant nodes
  }

  validate {
    collisions.count == 0   severity: warn   label: "COLLISION-DETECTED"
  }

  emit collisions_report(jurisdiction, as_of, collisions)

  output collisions: Array[Collision]
  output receipt: FactReceipt
}
```

#### 6. DevelopStrategy — strategy development (agent-based)

```ig
contract DevelopStrategy for actor_id: String, goal: LegalGoal, constraints: Array[Constraint] {

  given actor_knowledge: History[AgentContext] from "simulations/current/actors/{actor_id}"

  phase reasoning {
    possible_strategies := generate_strategies(goal, constraints, actor_knowledge.at(now))
    best_strategy      := score_and_rank(possible_strategies)
  }

  emit strategy_proposed(actor_id, best_strategy)

  output recommended_strategy: Strategy
  output confidence: Float
  output receipt: FactReceipt
}
```

### How Simulations Work

1. The user/main agent creates a simulation → `CreateSimulation` contract.
2. For each **Actor** (party in the case, regulator, company, etc.), a separate **Agent instance** is spawned with an isolated Ledger partition.
3. For each **Env** (economic situation, political context, etc.), its own snapshot.
4. `RunSimulation` contracts are launched → each agent thinks independently and interacts via LedgerMesh.
5. The results are written back to the Ledger → you can analyze, replay, and compare strategies.


### Round 2: Contracts in Igniter-Lang

All contracts are fully integrated with igniter-ledger:
- given … from BiHistory/History → native as_of / at(vt:, tt:) queries
- emit / observe → automatically written as immutable facts via ContractableReceiptSink
- output receipt: FactReceipt → proof of every action
- Simulations use isolated partitions `simulations/{sim_id}/…`
- Full compatibility with LedgerMesh (agents can call these contracts from each other)

### 1. LawAtDate - get the current version of the law

```ig
contract LawAtDate for jurisdiction: String, article_id: String, valid_time: DateTime {

  given law_history: BiHistory[LawArticle] from "laws/{jurisdiction}/{article_id}"

  phase retrieval {
    current_version := law_history.at(vt: valid_time, tt: now)
  }

  validate {
    current_version != nil   severity: error   label: "LAW-NOT-FOUND"
  }

  emit law_retrieved(article_id, valid_time, current_version.version_number)

  output version: LawArticle
  output receipt: FactReceipt
}
```

### 2. PrecedentSearch — search for relevant precedents

```ig
contract PrecedentSearch for query: LegalQuery, as_of: DateTime {

  given precedents: History[Precedent] from "precedents/{query.jurisdiction}"

  phase search {
    results := precedents.as_of(as_of)
      .filter(topic matches query.topic && similarity_score(query.facts) > 0.75)
      .sort_by(relevance)
      .take(12)
  }

  emit precedents_found(query.topic, results.count)

  output results: Array[PrecedentSummary]
  output receipt: FactReceipt
}
```

### 3. ReproduceCase — a complete replay of a past court case

```ig
contract ReproduceCase for case_id: String, simulation_time: DateTime {

  given case_history: BiHistory[CourtCase] from "court_cases/{case_id}"

  phase replay {
    historical_state := case_history.at(vt: simulation_time, tt: now)
    outcome := apply_law_to_facts(
      facts: historical_state.facts,
      applicable_laws: historical_state.applicable_laws
    )
  }

  validate { historical_state != nil }

  emit case_reproduced(case_id, simulation_time, outcome.verdict)

  output reproduced_outcome: CaseOutcome
  output receipt: FactReceipt
}
```

### 4. RunSimulation — running simulation for Actor + Env

```ig
contract RunSimulation for sim_id: String, actor_id: String, env_id: String, scenario: ScenarioInput {

  given actor_context: History[ActorState] from "simulations/{sim_id}/actors/{actor_id}"
  given env_state: History[SimulationEnv] from "simulations/{sim_id}/env/{env_id}"

  phase setup {
    actor_instance := spawn_agent_instance(actor_id, actor_context.at(now))
    env_snapshot   := env_state.at(now)
  }

  phase execution {
    result := actor_instance.execute_contract("ApplyLegalStrategy", {
      scenario: scenario,
      env: env_snapshot
    })
    observe simulation_step(sim_id, actor_id, result.decision)
  }

  emit simulation_completed(sim_id, actor_id, result.strategy_score)

  output simulation_result: SimulationResult
  output receipt: FactReceipt
}
```

### 5. DetectCollisions — search for conflicts between laws and precedents

```ig
contract DetectCollisions for jurisdiction: String, as_of: DateTime {

  given laws: BiHistory[LawArticle] from "laws/{jurisdiction}"
  given precedents: BiHistory[Precedent] from "precedents/{jurisdiction}"

  phase cross_check {
    active_laws      := laws.as_of(as_of)
    active_precedents := precedents.as_of(as_of)
    collisions       := find_legal_conflicts(active_laws, active_precedents)
  }

  validate { collisions.count == 0   severity: warn   label: "COLLISION-DETECTED" }

  emit collisions_report(jurisdiction, as_of, collisions.count)

  output collisions: Array[Collision]
  output receipt: FactReceipt
}
```

### 6. DevelopStrategy — development of a legal strategy by an agent

```ig
contract DevelopStrategy for actor_id: String, goal: LegalGoal, constraints: Array[Constraint] {

  given actor_knowledge: History[AgentContext] from "simulations/current/actors/{actor_id}"

  phase reasoning {
    possible_strategies := generate_strategies(goal, constraints, actor_knowledge.at(now))
    best_strategy       := score_and_rank(possible_strategies, actor_knowledge)
  }

  emit strategy_proposed(actor_id, best_strategy.name)

  output recommended_strategy: Strategy
  output confidence: Float
  output receipt: FactReceipt
}
```

### 7. AmendLaw — make an amendment (new version in BiHistory)

```ig
contract AmendLaw for jurisdiction: String, article_id: String, amendment: AmendmentInput {

  given law_history: BiHistory[LawArticle] from "laws/{jurisdiction}/{article_id}"

  phase apply {
    new_version := law_history.create_new_version(amendment.changes, amendment.valid_from)
    observe law_amended(article_id, amendment.number)
  }

  validate { amendment.valid_from > now   severity: error }

  emit law_amendment_applied(article_id, amendment.number)

  output new_version_number: Integer
  output receipt: FactReceipt
}
```

### 8. RegisterCourtCase — register a new court case

```ig
contract RegisterCourtCase for case_input: CourtCaseInput {

  phase registration {
    case_id := generate_case_id(case_input.court, case_input.number)
    initial_state := create_initial_case_state(case_input)
    observe court_case_registered(case_id)
  }

  emit case_registered(case_id, case_input.plaintiff, case_input.defendant)

  output case_id: String
  output receipt: FactReceipt
}
```

### 9. QueryApplicableLawsForFacts — find all applicable rules based on the facts

```ig
contract QueryApplicableLawsForFacts for facts: FactPattern, as_of: DateTime {

  given all_laws: History[LawArticle] from "laws/{facts.jurisdiction}"

  phase analysis {
    applicable := all_laws.as_of(as_of)
      .filter(law -> law.applies_to(facts))
      .sort_by(precedence)
  }

  emit applicable_laws_found(facts.summary, applicable.count)

  output laws: Array[LawArticle]
  output receipt: FactReceipt
}
```

### 10. AuditActionCompliance — check the compliance of the action with the law

```ig
contract AuditActionCompliance for action: ActionDescription, as_of: DateTime {

  given laws: BiHistory[LawArticle] from "laws/{action.jurisdiction}"

  phase audit {
    applicable_laws := laws.as_of(as_of).filter(applies_to: action)
    violations      := check_violations(action, applicable_laws)
  }

  emit compliance_audited(action.id, violations.count)

  output is_compliant: Bool
  output violations: Array[Violation]
  output receipt: FactReceipt
}
```

### 11. SimulateLegalScenario — simulation of possible outcomes of the case

```ig
contract SimulateLegalScenario for case_id: String, scenarios: Array[ScenarioVariant] {

  phase monte_carlo {
    for each variant in scenarios {
      result := RunSimulation(sim_id: generate_sim_id(), actor_id: "court", env_id: "default", scenario: variant)
      observe scenario_outcome(variant.id, result.verdict)
    }
  }

  emit legal_scenarios_simulated(case_id, scenarios.count)

  output outcomes: Array[SimulatedOutcome]
  output receipt: FactReceipt
}
```

### 12. GenerateLegalBrief — generate a legal opinion / brief

```ig
contract GenerateLegalBrief for query: LegalQuery, as_of: DateTime {

  given knowledge: History[AgentContext] from "legal_knowledge_base"

  phase research {
    laws       := LawAtDate(...)
    precedents := PrecedentSearch(...)
    analysis   := synthesize_brief(laws, precedents, query)
  }

  emit legal_brief_generated(query.topic)

  output brief: LegalBrief
  output confidence: Float
  output sources: Array[FactReceipt]   # доказательная база
}
```
