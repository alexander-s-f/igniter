# Interactive Operator

This is the app-local skeleton behind `examples/application/interactive_web_poc.rb`.
The launcher remains stable for the examples catalog, while the runnable app is
split into small copyable seams:

- `services/task_board.rb` owns application state.
- `web/operator_board.rb` owns the rendered `igniter-web` surface.
- `app.rb` declares the `Igniter::Application.rack_app` services, web mount,
  and tiny Rack endpoints.
- `config.ru` exposes the same app to Rack-compatible runners.

The current application commands are intentionally plain Rack form targets:

- `POST /tasks/create` creates an open task from a `title` field and redirects
  with `notice=task_created`.
- `POST /tasks/create` refuses blank titles without mutation and redirects with
  `error=blank_title`.
- `POST /tasks` resolves an existing task from an `id` field and redirects
  with `notice=task_resolved` or `error=task_not_found`.
- `GET /events` returns a compact text read model with the open-task count,
  action count, and recent typed action facts.

The web surface renders `notice` and `error` query params as compact feedback
messages on the next board render. This stays app-local and intentionally does
not introduce session storage, a validation framework, or a UI component kit.

Run the smoke launcher from the repository root:

```bash
ruby examples/application/interactive_web_poc.rb
```

Run the local browser server:

```bash
ruby examples/application/interactive_web_poc.rb server
```
