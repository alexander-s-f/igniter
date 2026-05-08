-- Syntax pressure specimen: primitive surface over contract substrate.
-- This file is not current Igniter-Lang canon and is not expected to parse.
-- Non-canon pressure constructs in this file include:
-- section, entrypoint, entity, map literal with =>, set literal #{...},
-- method-chain collection calls, fixture data blocks, and assert blocks.

module Lab.Fixtures.PrimitiveSurface

section Domain {
  type Employee {
    id: String
    name: String
    role: Symbol
    region: String
    skills: Set[Symbol]
  }

  type DispatchTask {
    id: String
    region: String
    required_skill: Symbol
    effort_hours: Integer
    priority: Integer
  }

  type Assignment {
    task: DispatchTask
    employee: Employee
    score: Integer
    tags: Set[Symbol]
  }
}

section Fixtures {
  entity alice: Employee {
    id: "emp-1"
    name: "Alice"
    role: :engineer
    region: "UA-KV"
    skills: #{ :network, :storage, :triage }
  }

  entity bob: Employee {
    id: "emp-2"
    name: "Bob"
    role: :operator
    region: "UA-LV"
    skills: #{ :dispatch, :triage }
  }

  entity cara: Employee {
    id: "emp-3"
    name: "Cara"
    role: :engineer
    region: "UA-KV"
    skills: #{ :network, :dispatch }
  }

  let team: Array[Employee] = [alice, bob, cara]

  let region_labels: HashMap[String, Symbol] = {
    "UA-KV" => :kyiv,
    "UA-LV" => :lviv
  }

  let open_tasks: Array[DispatchTask] = [
    DispatchTask {
      id: "task-1",
      region: "UA-KV",
      required_skill: :network,
      effort_hours: 4,
      priority: 9
    },
    DispatchTask {
      id: "task-2",
      region: "UA-LV",
      required_skill: :dispatch,
      effort_hours: 2,
      priority: 6
    },
    DispatchTask {
      id: "task-3",
      region: "UA-KV",
      required_skill: :storage,
      effort_hours: 7,
      priority: 8
    }
  ]
}

section Contracts {
  contract SkillMatch(employee: Employee, task: DispatchTask) -> result: Bool {
    let same_region = employee.region == task.region
    let has_skill = task.required_skill in employee.skills
    let result = same_region && has_skill

    output result: Bool = result
  }

  contract ScoreAssignment(employee: Employee, task: DispatchTask) -> assignment: Option[Assignment] {
    let matched = SkillMatch(employee, task).result

    let score = if matched {
      (task.priority * 10) - task.effort_hours
    } else {
      0
    }

    let tags = if task.priority >= 8 {
      #{ :urgent, task.required_skill }
    } else {
      #{ task.required_skill }
    }

    let assignment = if matched {
      some(Assignment {
        task: task,
        employee: employee,
        score: score,
        tags: tags
      })
    } else {
      none
    }

    output assignment: Option[Assignment] = assignment
  }

  contract PlanDay(team: Array[Employee], tasks: Array[DispatchTask]) -> assignments: Array[Assignment], summary: HashMap[Symbol, Integer] {
    let candidates = tasks.flat_map(task ->
      team.map(employee -> ScoreAssignment(employee, task).assignment)
    )

    let assignments = candidates
      .filter(candidate -> candidate.is_some)
      .map(candidate -> candidate.unwrap)
      .sort_by(assignment -> 0 - assignment.score)

    let total_hours = assignments.reduce(0, (sum, assignment) ->
      sum + assignment.task.effort_hours
    )

    let urgent_count = assignments.filter(assignment ->
      :urgent in assignment.tags
    ).count

    let summary = {
      :assignments => assignments.count,
      :urgent => urgent_count,
      :hours => total_hours
    }

    invariant all_assignments_have_positive_score: assignments.all(a -> a.score > 0)
      severity :error

    output assignments: Array[Assignment] = assignments

    output summary: HashMap[Symbol, Integer] = summary
  }
}

section Entry {
  entrypoint plan_today {
    contract: PlanDay
    args {
      team: team
      tasks: open_tasks
    }
  }
}

section Expectations {
  assert plan_today.summary[:assignments] == 3
  assert plan_today.summary[:urgent] == 2
  assert plan_today.summary[:hours] == 13
}
