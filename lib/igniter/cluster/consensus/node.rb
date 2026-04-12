# frozen_string_literal: true

module Igniter
  module Cluster
    module Consensus
    # Value objects for sync-reply handlers.
    # Must be non-Hash so the Agent runner sends them as replies rather than
    # treating them as new state.
    NodeStatus = Struct.new(:node_id, :role, :term, :commit_index,
                            :log_size, :state_machine, :leader, keyword_init: true)
    NodeReadResult = Struct.new(:data, keyword_init: true)

    # Timing constants — 1:20 heartbeat-to-election ratio for Ruby scheduling jitter.
    ELECTION_CHECK_INTERVAL = 0.05   # how often to poll for timeout (s)
    ELECTION_TIMEOUT_BASE   = 1.0    # minimum idle time before election (s)
    ELECTION_TIMEOUT_JITTER = 0.5    # random addition to prevent split votes (s)
    HEARTBEAT_INTERVAL      = 0.05   # leader heartbeat cadence (s)

    # Raft consensus agent — internal implementation.
    # Users should interact with +Cluster+ rather than +Node+ directly.
    #
    # The full Raft protocol (leader election, log replication, quorum-based
    # commit) is encapsulated here. The user-defined state machine is stored in
    # the agent state as +:state_machine_class+ and invoked on every commit.
    class Node < Igniter::Agent
      mailbox_size 2000
      mailbox_overflow :drop_oldest

      # Convenience factory — builds the correct initial_state automatically.
      #
      # @param name          [Symbol]       Registry key for this node
      # @param peers         [Array<Symbol>] Registry keys of all other nodes
      # @param state_machine [Class]        StateMachine subclass (default: StateMachine)
      # @param verbose       [Boolean]      print protocol events to stdout
      def self.start(name:, peers:, state_machine: StateMachine, verbose: false)
        super(
          name: name,
          initial_state: {
            node_id:             name,
            peers:               peers,
            state_machine_class: state_machine,
            verbose:             verbose,
            role:                :follower,
            term:                0,
            voted_for:           nil,
            log:                 [],
            commit_index:        -1,
            last_applied:        -1,
            votes_received:      [],
            state_machine:       {},
            next_index:          {},
            match_index:         {},
            current_leader:      nil,
            last_heartbeat_at:   Process.clock_gettime(Process::CLOCK_MONOTONIC),
            election_timeout:    ELECTION_TIMEOUT_BASE + rand * ELECTION_TIMEOUT_JITTER,
          }
        )
      end

      # Minimum votes required for a decision in a cluster of +size+ nodes.
      def self.quorum(size) = (size / 2) + 1

      # ── Internal helpers (called from schedule/on blocks) ────────────────────

      def self.find_peer(id) = Igniter::Registry.find(id)

      def self.log_msg(state, msg)
        $stdout.puts "  [#{state[:node_id]}] #{msg}" if state[:verbose]
      end

      # Apply committed log entries to the state machine and return the updated
      # state_machine hash + last_applied index.
      def self.apply_entries(sm, last_applied, log, commit_index, sm_class)
        sm = sm.dup
        while last_applied < commit_index
          last_applied += 1
          cmd = log[last_applied]&.dig(:command)
          sm = sm_class.call(sm, cmd) if cmd
        end
        [sm, last_applied]
      end

      # ── Timer: election check ──────────────────────────────────────────────
      schedule :election_check, every: ELECTION_CHECK_INTERVAL do |state:|
        next state if state[:role] == :leader

        elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - state[:last_heartbeat_at]
        next state if elapsed < state[:election_timeout]

        new_term = state[:term] + 1
        nid      = state[:node_id]
        lli      = state[:log].size - 1
        llt      = state[:log].empty? ? -1 : state[:log].last[:term]

        Node.log_msg(state, "timeout #{elapsed.round(2)}s → Candidate term=#{new_term}")

        state[:peers].each do |pid|
          Node.find_peer(pid)&.send(:request_vote, {
            term: new_term, candidate_id: nid,
            last_log_index: lli, last_log_term: llt,
          })
        end

        state.merge(
          role: :candidate, term: new_term,
          voted_for: nid, votes_received: [nid],
          last_heartbeat_at: Process.clock_gettime(Process::CLOCK_MONOTONIC),
          election_timeout: ELECTION_TIMEOUT_BASE + rand * ELECTION_TIMEOUT_JITTER,
        )
      end

      # ── Timer: heartbeat (leader only) ────────────────────────────────────
      schedule :heartbeat, every: HEARTBEAT_INTERVAL do |state:|
        next state unless state[:role] == :leader

        state[:peers].each do |pid|
          peer = Node.find_peer(pid)
          next unless peer

          mi        = state[:match_index][pid] || -1
          next_idx  = mi + 1
          prev_idx  = next_idx - 1
          prev_term = state[:log][prev_idx]&.dig(:term) || -1
          entries   = state[:log][next_idx..] || []

          peer.send(:append_entries, {
            term: state[:term], leader_id: state[:node_id],
            prev_log_index: prev_idx, prev_log_term: prev_term,
            entries: entries, leader_commit: state[:commit_index],
          })
        end

        state
      end

      # ── RequestVote ──────────────────────────────────────────────────────
      on :request_vote do |state:, payload:|
        msg  = payload
        base = msg[:term] > state[:term] ?
          state.merge(term: msg[:term], role: :follower, voted_for: nil) : state

        our_lt = base[:log].empty? ? -1 : base[:log].last[:term]
        our_li = base[:log].size - 1
        log_ok = msg[:last_log_term] > our_lt ||
                 (msg[:last_log_term] == our_lt && msg[:last_log_index] >= our_li)

        can_vote = msg[:term] >= base[:term] && log_ok &&
                   (base[:voted_for].nil? || base[:voted_for] == msg[:candidate_id])

        sender = Node.find_peer(msg[:candidate_id])

        if can_vote
          Node.log_msg(state, "votes for #{msg[:candidate_id]} (term #{msg[:term]})")
          sender&.send(:vote_response, {
            term: msg[:term], vote_granted: true, voter_id: state[:node_id],
          })
          base.merge(
            voted_for: msg[:candidate_id],
            last_heartbeat_at: Process.clock_gettime(Process::CLOCK_MONOTONIC),
          )
        else
          sender&.send(:vote_response, {
            term: base[:term], vote_granted: false, voter_id: state[:node_id],
          })
          base
        end
      end

      # ── VoteResponse ────────────────────────────────────────────────────
      on :vote_response do |state:, payload:|
        msg = payload
        next state unless state[:role] == :candidate && msg[:term] == state[:term]

        if msg[:term] > state[:term]
          next state.merge(role: :follower, term: msg[:term], voted_for: nil)
        end
        next state unless msg[:vote_granted]

        votes  = (state[:votes_received] + [msg[:voter_id]]).uniq
        quorum = Node.quorum(state[:peers].size + 1)  # full cluster = peers + self

        if votes.size >= quorum
          ni = state[:peers].each_with_object({}) { |p, h| h[p] = state[:log].size }
          mi = state[:peers].each_with_object({}) { |p, h| h[p] = -1 }
          Node.log_msg(state, "*** LEADER (term=#{state[:term]}, votes=#{votes.size}/#{state[:peers].size + 1}) ***")
          state.merge(role: :leader, votes_received: votes,
                      next_index: ni, match_index: mi)
        else
          state.merge(votes_received: votes)
        end
      end

      # ── AppendEntries ───────────────────────────────────────────────────
      on :append_entries do |state:, payload:|
        msg    = payload
        sender = Node.find_peer(msg[:leader_id])

        if msg[:term] < state[:term]
          sender&.send(:append_entries_response, {
            term: state[:term], success: false,
            follower_id: state[:node_id], match_index: -1,
          })
          next state
        end

        s = state.merge(
          term:              [state[:term], msg[:term]].max,
          role:              :follower,
          voted_for:         state[:term] == msg[:term] ? state[:voted_for] : nil,
          current_leader:    msg[:leader_id],
          last_heartbeat_at: Process.clock_gettime(Process::CLOCK_MONOTONIC),
        )

        if msg[:prev_log_index] >= 0
          ok = s[:log].size > msg[:prev_log_index] &&
               s[:log][msg[:prev_log_index]]&.dig(:term) == msg[:prev_log_term]
          unless ok
            sender&.send(:append_entries_response, {
              term: s[:term], success: false,
              follower_id: state[:node_id], match_index: s[:log].size - 1,
            })
            next s
          end
        end

        new_log    = s[:log].take(msg[:prev_log_index] + 1).concat(msg[:entries])
        new_commit = [[msg[:leader_commit], new_log.size - 1].min, s[:commit_index]].max

        sm, la = Node.apply_entries(s[:state_machine], s[:last_applied],
                                    new_log, new_commit, s[:state_machine_class])

        sender&.send(:append_entries_response, {
          term: s[:term], success: true,
          follower_id: state[:node_id], match_index: new_log.size - 1,
        })

        s.merge(log: new_log, commit_index: new_commit,
                last_applied: la, state_machine: sm)
      end

      # ── AppendEntriesResponse (leader) ──────────────────────────────────
      on :append_entries_response do |state:, payload:|
        msg = payload
        next state unless state[:role] == :leader

        if msg[:term] > state[:term]
          next state.merge(role: :follower, term: msg[:term], voted_for: nil)
        end

        pid    = msg[:follower_id]
        new_mi = state[:match_index].dup
        new_ni = state[:next_index].dup

        if msg[:success]
          new_mi[pid] = [new_mi[pid] || -1, msg[:match_index]].max
          new_ni[pid] = new_mi[pid] + 1
        else
          new_ni[pid] = [(new_ni[pid] || 1) - 1, 0].max
        end

        new_log    = state[:log]
        new_commit = state[:commit_index]
        quorum     = Node.quorum(state[:peers].size + 1)

        ((new_commit + 1)...new_log.size).each do |n|
          next unless new_log[n][:term] == state[:term]
          replicated = new_mi.values.count { |m| m >= n } + 1  # +1 for leader
          new_commit = n if replicated >= quorum
        end

        sm, la = Node.apply_entries(state[:state_machine], state[:last_applied],
                                    new_log, new_commit, state[:state_machine_class])

        if new_commit > state[:commit_index]
          Node.log_msg(state, "committed idx=#{new_commit} → #{sm.inspect}")
        end

        state.merge(match_index: new_mi, next_index: new_ni,
                    commit_index: new_commit, last_applied: la, state_machine: sm)
      end

      # ── client_write — appends to log (leader) or forwards ──────────────
      on :client_write do |state:, payload:|
        unless state[:role] == :leader
          ref = state[:current_leader] && Node.find_peer(state[:current_leader])
          if ref
            ref.send(:client_write, payload)
          else
            Node.log_msg(state, "no leader known — write dropped")
          end
          next state
        end

        entry   = { term: state[:term], command: payload[:command] }
        new_log = state[:log] + [entry]
        Node.log_msg(state, "Leader appends log[#{new_log.size - 1}]: #{payload[:command].inspect}")
        state.merge(log: new_log)
      end

      # ── Sync query: status ───────────────────────────────────────────────
      # Returns NodeStatus (non-Hash) → runner sends as sync reply, NOT new state.
      on :status do |state:, payload:|
        NodeStatus.new(
          node_id:       state[:node_id],
          role:          state[:role],
          term:          state[:term],
          commit_index:  state[:commit_index],
          log_size:      state[:log].size,
          state_machine: state[:state_machine],
          leader:        state[:current_leader],
        )
      end

      # ── Sync query: read full state machine snapshot ─────────────────────
      # Returns NodeReadResult (non-Hash) so the runner sends it as sync reply.
      on :read do |state:, payload:|
        NodeReadResult.new(data: state[:state_machine].dup)
      end
    end
    end
  end
end
