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

- `POST /tasks/create` creates an open task from a `title` field.
- `POST /tasks` resolves an existing task from an `id` field.
- `GET /events` returns a compact text read model with the open-task count.

Run the smoke launcher from the repository root:

```bash
ruby examples/application/interactive_web_poc.rb
```

Run the local browser server:

```bash
ruby examples/application/interactive_web_poc.rb server
```
