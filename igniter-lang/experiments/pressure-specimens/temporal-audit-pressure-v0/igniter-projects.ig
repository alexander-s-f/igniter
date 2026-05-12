
# 1. TaskCreate – creating a task
contract TaskCreate for project: Project, creator: User, data: TaskInput {

  given project_state: History[ProjectState] from "projects/{project.id}"

  phase validation {
    let current = project_state.at(data.valid_time)
    valid := current.status != "archived"
  }

  phase creation {
    task_id := generate_task_id(project.id)
    initial_state := {
      id: task_id,
      title: data.title,
      status: "todo",
      assignee: data.assignee,
      priority: data.priority || "medium",
      created_at: data.valid_time,
      created_by: creator.id
    }
    observe task_created(task_id, initial_state)
  }

  validate {
    valid == true                     severity: error   label: "TASK-001"
    data.title.length > 0
  }

  emit task_created(task_id, initial_state)

  output task_id: String
  output receipt: FactReceipt   # Link to the immutable fact on the ledger
}

# 2. TaskUpdateStatus – status transition (the most common case)
contract TaskUpdateStatus for task_id: String, new_status: String, actor: User, valid_time: DateTime {

  given task_history: BiHistory[TaskState] from "tasks/{task_id}"
  given project_history: History[ProjectState] from "projects/{task.project_id}"

  phase current_state {
    current := task_history.at(vt: valid_time, tt: now)
    allowed := workflow_allows_transition(current.status, new_status)
  }

  phase transition {
    new_state := current.merge({
      status: new_status,
      updated_at: valid_time,
      updated_by: actor.id
    })
    observe status_changed(task_id, current.status, new_status)
  }

  validate {
    allowed == true                   severity: error   label: "WF-TRANSITION"
    current != nil
  }

  when status_changed {
    emit task_status_updated(task_id, new_status, actor.id)
  }

  output new_state: TaskState
  output receipt: FactReceipt
}

# 3. SprintPlan - sprint planning

contract SprintPlan for sprint: SprintInput, project: Project {

  given backlog: History[Backlog] from "projects/{project.id}/backlog"
  given team_capacity: History[TeamCapacity] from "teams/{project.team_id}"

  phase capacity_check {
    available_points := team_capacity.at(sprint.start_date).remaining_points
    planned_points   := calculate_total_points(sprint.tasks)
  }

  phase planning {
    sprint_id := generate_sprint_id()
    for each task in sprint.tasks {
      assign_to_sprint(task.id, sprint_id)
      observe task_planned(task.id, sprint_id)
    }
  }

  validate {
    planned_points <= available_points   severity: warn   label: "CAPACITY-OVER"
  }

  emit sprint_planned(sprint_id, planned_points)

  output sprint_id: String
  output assigned_tasks: Integer
}

# 4. ProjectDashboardQuery — a purely read-only contract (for UI and AI)

contract ProjectDashboard for project_id: String, as_of: DateTime {

  given tasks: History[TaskState] from "projects/{project_id}/tasks"
  given sprints: History[SprintState] from "projects/{project_id}/sprints"

  phase snapshot {
    current_tasks   := tasks.as_of(as_of).filter(status != "done")
    burndown        := calculate_burndown(current_tasks, sprints)
    blockers_count  := count_blockers(current_tasks)
  }

  output burndown: BurndownChart
  output blockers: Integer
  output velocity: Integer
  output active_sprint: SprintState?
}

# TBackendAdapter:
# Igniter::Ledger::ContractableReceiptSink.new(
#   store: Igniter::Ledger::LedgerStore.new,
#   observations_store: :project_observations,
#   events_store: :project_events
# )