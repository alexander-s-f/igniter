# Expert Review — Igniter Interactive Agent Platform

Date: 2026-04-25.

Perspective: external expert in distributed interactive agent systems.

## Documents In This Directory

| Document | Contents |
|----------|----------|
| [expert-review.md](expert-review.md) | Assessment, architectural findings, friction analysis, application skeleton |
| [interactive-app-dsl.md](interactive-app-dsl.md) | Proposed DSL for interactive agent applications with full examples |
| [igniter-ui-kit.md](igniter-ui-kit.md) | UI component system — design language, component taxonomy, agent-specific primitives, live update architecture |
| [igniter-plane.md](igniter-plane.md) | Living Graph Canvas — floating interactive system graph, bird's eye view, spatial navigation, node interactions, agent annotations |
| [research-horizon-analysis.md](research-horizon-analysis.md) | Meta-analysis of all six Research Horizon proposals — what's solid, what's missing, strategic tensions, new insights |
| [plastic-runtime-cells.md](plastic-runtime-cells.md) | Missing synthesis for Proposal D — cell vocabulary, plasticity operations, graduation sequence |
| [compression-experiment.md](compression-experiment.md) | Grammar compression experiment — three real Igniter handoffs measured, economic formula evaluated, break-even analysis |
| [agent-cycle-optimization.md](agent-cycle-optimization.md) | Agent development cycle optimization — six proposals to reduce token cost and latency of the Handoff protocol |
| [agent-track-pattern.md](agent-track-pattern.md) | Agent Track Pattern formal specification — vocabulary, state machine, topology, memory architecture, scaling model, Igniter integration, graduation path |
| [documentation-compression.md](documentation-compression.md) | Documentation compression methodology — content taxonomy, compression algorithm, 7 accumulation rules, Line-Up format for docs, tooling path |
| [concept-emergence.md](concept-emergence.md) | Concept emergence research — statistical mining of 88-doc corpus, 499 frequent patterns found, 22 named, vocabulary lifecycle model, "митоз" analogy applied |
| [semantic-gateway.md](semantic-gateway.md) | Semantic Gateway design — Human↔Agent interaction pre-processing, SAE-inspired local intent extraction, three-stage adaptive pipeline, RPi 5 viable |
| [capsule-transfer-expert-report.md](capsule-transfer-expert-report.md) · [ru](capsule-transfer-expert-report.ru.md) | Capsule Transfer track expert report — visionary, model/amplification, perspective development, recommendations, insights; agent-supervised supply chain analysis |
| [igniter-strategic-report.md](igniter-strategic-report.md) · [ru](igniter-strategic-report.ru.md) | Igniter whole-project strategic report — unique positioning, three value levels, critical gaps, growth path to significant enterprise platform |
| [application-proposals.md](application-proposals.md) · [ru](application-proposals.ru.md) | Five POC-ready application proposals (IT/developer audience) — Lense, Scout, Dispatch, Chronicle, Aria — each with pain, Igniter fit, MVP scope, DSL sketch, build-further threads |
| [application-proposals-non-tech.md](application-proposals-non-tech.md) · [ru](application-proposals-non-tech.ru.md) | Non-technical audience proposals — end users (Forma/Meridian), creators/media (Studio/Signal), enterprise (Blueprint/Accord) — six apps across three markets |
| [application-proposals-logistics-hvac.md](application-proposals-logistics-hvac.md) | Logistics & Field Service vertical proposals — Convoy (last-mile delivery), Freight (3PL/broker), Field (HVAC/appliance company), Nexus (multi-tenant SaaS for call centers serving field service) |
| [igniter-implementation-delta.md](igniter-implementation-delta.md) | Delta report across all 15 proposals — 24 missing platform items in P1–P5 tiers, per-app gap maps, ranked summary table by required delta, strategic shipping sequence |
| [igniter-lang/igniter-lang.md](igniter-lang/igniter-lang.md) · [ru](igniter-lang/igniter-lang.ru.md) | Contract model as language foundation — feasibility analysis, grammar sketch (EBNF + examples), Turing completeness paths, information-density hypothesis (SIR metric), formal placement against KPN/FRP/Lustre, prototype roadmap |

## Expert Documentation Rules

This directory can contain external expert drafts and reports. The canonical
index language is English, even when a source report is originally written in
Russian.

For future expert documents:

- keep this README entry in English
- prefer an English canonical version for documents that affect active tracks
- Russian originals may be kept as source material or companion notes
- active implementation decisions still require supervisor acceptance in
  `docs/dev`

## One-Line Summary

Igniter has all the right primitives — contracts, agents, web surfaces, cluster
mesh — but the authoring experience for interactive agent applications is still
too spread across packages, files, and wiring layers. The opportunity is a
compact, ActiveAdmin-style facade that declares an interactive agent app in one
place and expands to clean, inspectable Ruby.

Later documents analyze the Research Horizon and propose: a grammar compression
experiment measuring the economic formula on real Igniter handoff messages (break-
even at ~8 messages/session); a cell vocabulary synthesis for Proposal D (the
missing piece); and a meta-analysis identifying strategic tensions and new
directions across all six proposals.
