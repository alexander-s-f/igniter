# Credentials

Use credentials when an Igniter application needs secrets such as API keys but
must still boot cleanly without them.

## Current Shape

Credentials live in `igniter-application` as app runtime configuration. The
first supported source is an environment variable:

```ruby
environment = Igniter::Application.build_kernel
                                  .credential(
                                    :openai_api_key,
                                    env: "OPENAI_API_KEY",
                                    required: false
                                  )
                                  .then { |kernel| Igniter::Application::Environment.new(profile: kernel.finalize) }
```

Application code can ask whether live mode is available:

```ruby
if environment.credentials.configured?(:openai_api_key)
  api_key = environment.credentials.fetch(:openai_api_key)
else
  # show setup state or run offline mode
end
```

## Rules

- Missing optional credentials should produce setup state, not a crash.
- Missing required credentials raise `MissingCredentialError` when fetched.
- `profile.to_h`, manifests, snapshots, reports, and logs must not include
  secret values.
- Smoke tests should stay offline and deterministic by default.
- Live provider calls should be opt-in through configured credentials.

## Ready-To-Go App Pattern

For live LLM applications:

- declare `:openai_api_key` against `OPENAI_API_KEY`
- boot without the key
- show a visible setup message when the key is missing
- switch to live mode when the key exists
- keep offline smoke paths independent from the live provider

This keeps examples runnable for everyone while making real API usage one
configuration step away.
