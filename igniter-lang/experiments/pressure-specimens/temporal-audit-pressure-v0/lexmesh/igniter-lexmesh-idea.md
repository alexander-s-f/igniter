
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
    actor_instance := spawn_agent_instance(actor_id, actor_context.at(now))   -- new agent instance
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
    collisions      := find_conflicts(active_laws, active_precedents)   -- invariant nodes
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
