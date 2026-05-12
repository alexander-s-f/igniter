
# a decentralized and distributed agent messenger + coordination channel** called LedgerMesh** (or **AgentMesh** - whatever you prefer).

# This isn't just a chat. It's an **epistemic communication layer** for agents, where:
# - All communication is immutable facts in the igniter-ledger.
# - Each agent stores its context and domains as History[T] / BiHistory[T].
# - The conversation history is also BiHistory[Message].
# - Coordination is via Igniter-Lang contracts, which agents invoke on each other.
# - Full auditability, time-travel, receipts, and evidence links.
--
# `igniter-ledger` fits perfectly as a backend (I just checked the current state of the package
# it already has everything you need: `LedgerStore`, `ContractableReceiptSink`, `NetworkBackend` + `LedgerServer`, causation chains, partitions, changefeeds, snapshots and `as_of` / `history_partition`).

# LedgerMesh Architecture (Igniter Lang Way)


#  Agent A (Node 1) Agent B (Node 2) Agent C (Node 3)
#  ├── RuntimeMachine ├── RuntimeMachine ├── RuntimeMachine
#  ├── Igniter-Lang contracts ├── Igniter-Lang contracts ├── Igniter-Lang contracts
#  └── Local LedgerStore └─► NetworkBackend ──► LedgerServer (shared / distributed)
#  │ ▲
#  └─────────────► ContractableReceiptSink + Changefeed SSE


# Key principles:
# - Decentralization — each agent can work completely offline with its own local FileBackend. Synchronization occurs via the NetworkBackend.
# - Immutability — no message, no context change can be modified or deleted.
# - Time model — BiHistory[Message] + valid_time / transaction_time.
# - Coordination — not "send JSON," but "call another agent's contract."
# - Discovery — via a shared directory/agents partition (each agent publishes its public profile as a fact).
--
#  How Ledger is 100% utilized
--
# | What we store | Type in Igniter-Lang | Store / Partition in Ledger | Access |
# |----------------------------|-----------------------------|---------------------------------------------|--------|
# | Agent Context | `History[AgentContext]` | `agent_context/{agent_id}` | Private + as_of |
# | Agent Domain / Knowledge | `BiHistory[DomainRecord]` | `domains/{agent_id}/{domain}` | Private |
# | Chat / Correspondence | `BiHistory[Message]` | `chats/{chat_id}` (partition by chat_id) | Shared between participants |
# | System Events | `History[CoordinationEvent]`| `coordination/{agent_id}` | Public Changefeed |
# | Agent Public Profile | Fact | `directory/agents/{agent_id}` | Global directory |
--
# `ContractableReceiptSink` automatically writes all `observe` / `emit` from contracts as receipts.

#  Examples of contracts (Narrative Contracts v2)
#  1. Send Direct Message – sending a message (basic primitive)


contract SendDirectMessage for from_agent: AgentId, to_agent: AgentId, content: MessageContent, chat_id: String? {

  given my_context: History[AgentContext] from "agent_context/{from_agent}"
  given chat_history: BiHistory[Message] from "chats/{chat_id || generate_chat_id(from_agent, to_agent)}"

  phase validation {
    current_chat := chat_history.at(vt: now, tt: now)
    allowed     := current_chat.participants.includes?(to_agent)
  }

  phase append {
    message_id := generate_message_id()
    message    := {
      id: message_id,
      from: from_agent,
      to: to_agent,
      content: content,
      timestamp: now,
      reply_to: content.reply_to?
    }
    observe message_sent(message_id, to_agent)
  }

  validate {
    allowed == true                  severity: error   label: "CHAT-ACCESS"
  }

  emit message_delivered(message_id, to_agent)   # through changefeed

  output message_id: String
  output receipt: FactReceipt
}

# 2. UpdateAgentContext — the agent updates its context

contract UpdateAgentContext for agent_id: AgentId, delta: ContextDelta {

  given my_history: History[AgentContext] from "agent_context/{agent_id}"

  phase merge {
    current := my_history.at(now)
    new_context := current.apply_delta(delta)   # controlled merge
    observe context_updated(agent_id, delta.keys)
  }

  emit context_changed(agent_id)   # other agents may sign up

  output new_context_snapshot: AgentContext
  output receipt: FactReceipt
}

# 3. CreateMultiAgentChat – creating a group chat

contract CreateMultiAgentChat for initiator: AgentId, participants: Array[AgentId], topic: String {

  phase setup {
    chat_id := generate_chat_id(participants)
    initial_history := BiHistory[Message].new(
      participants: [initiator, *participants],
      topic: topic
    )
  }

  validate {
    participants.count >= 2
  }

  emit chat_created(chat_id, participants)

  output chat_id: String
  output initial_receipt: FactReceipt
}

# 4. CoordinateTask — coordination (an agent asks another agent to complete a contract)

contract CoordinateTask for requester: AgentId, target_agent: AgentId, task_contract: ContractRef, input: Any {

  given target_profile: History[AgentProfile] from "directory/agents/{target_agent}"

  phase delegation {
    capability_check := target_profile.at(now).supports_contract(task_contract)
    task_id := generate_task_id()
    observe task_delegated(task_id, target_agent, task_contract.name)
  }

  validate {
    capability_check == true         severity: error   label: "DELEGATION-ACCESS"
  }

  emit task_invocation_request(task_id, target_agent, task_contract, input)

  output task_id: String
  output receipt: FactReceipt
}

#  ### Decentralization and Distribution
--
# - **Local Mode** — each agent launches its own `LedgerStore.new(backend: :file)`.
# - **Network Mode** — `NetworkBackend` + `LedgerServer` (already included in the package). Agents connect via TCP/Unix.
# - **Changefeed** — SSE or WebSocket on `ContractableReceiptSink` → real-time notifications.
# - **Discovery** — the agent writes a fact to `directory/agents/{id}` with public capabilities upon startup.
# - **Offline-first** — the agent runs locally; when connected, replay and merge are performed via the causation chain.
# - **Security** — each fact is signed by the producer (agent_id); the causation chain protects against spoofing.

