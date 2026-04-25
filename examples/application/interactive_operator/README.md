# Interactive Operator

This is the app-local skeleton behind `examples/application/interactive_web_poc.rb`.
The launcher remains stable for the examples catalog, while the runnable app is
split into small copyable seams:

- `services/task_board.rb` owns application state.
- `web/operator_board.rb` owns the rendered `igniter-web` surface.
- `server/rack_app.rb` owns the Rack request boundary.
- `app.rb` assembles the `Igniter::Application` environment and web mount.
- `config.ru` exposes the same app to Rack-compatible runners.

Run the smoke launcher from the repository root:

```bash
ruby examples/application/interactive_web_poc.rb
```

Run the local browser server:

```bash
ruby examples/application/interactive_web_poc.rb server
```
