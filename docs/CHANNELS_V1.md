# Igniter Channels — V1

`Igniter::Channels` is the transport-neutral outbound communication layer for
Igniter. It is intended for adapters such as Telegram, WhatsApp, email, SMS,
webhook delivery, and CRM/call-center notification transports.

Load it with:

```ruby
require "igniter/channels"
```

## Core objects

- `Igniter::Channels::Message` — immutable transport-agnostic message envelope
- `Igniter::Channels::DeliveryResult` — normalized delivery result
- `Igniter::Channels::Base` — adapter base class built on `Igniter::Effect`

## Message envelope

```ruby
message = Igniter::Channels::Message.new(
  to: "telegram:123456",
  body: "Call summary is ready",
  metadata: { crm_id: "lead-42" },
  correlation_id: "call-2026-04-12-001"
)
```

The envelope is intentionally generic:

- `to` — destination identifier
- `body` — main content
- `subject` — optional title/subject
- `metadata` — provider-neutral extra fields
- `template` / `template_vars` — optional templated delivery
- `idempotency_key` / `correlation_id` — delivery coordination hooks

## Writing a channel adapter

```ruby
require "igniter/channels"

class TelegramChannel < Igniter::Channels::Base
  channel_name :telegram

  private

  def deliver_message(message)
    response = telegram_api.send_message(
      chat_id: message.to,
      text: message.body
    )

    {
      status: :sent,
      external_id: response.fetch("message_id"),
      payload: response
    }
  end
end
```

`deliver_message` may return:

- `Igniter::Channels::DeliveryResult`
- `Hash`
- `String` — treated as `external_id`
- `nil` — treated as a successful send

Any other exception is wrapped into `Igniter::Channels::DeliveryError`.

## Built-in webhook adapter

The first built-in transport is `Igniter::Channels::Webhook`.

```ruby
require "igniter/channels"

webhook = Igniter::Channels::Webhook.new(
  url: "https://hooks.example.com/events",
  headers: { "X-App" => "igniter" },
  params: { source: "crm" }
)

result = webhook.deliver(
  body: { event: "call.completed", score: 0.97 },
  metadata: { headers: { "X-Trace" => "abc-123" } }
)

result.status                 # => :delivered or :queued
result.payload[:status_code]  # => 200 / 202 / ...
```

Supported webhook features:

- configurable default `url`, `method`, `headers`, query `params`
- per-message header and param overrides/merges
- JSON, form, and plain text bodies
- basic auth
- normalized `DeliveryResult`

`Webhook` is an outbound transport. Incoming webhooks remain the job of Rails or
other application adapters that convert external HTTP requests into contract
events.

## Built-in Telegram adapter

`Igniter::Channels::Telegram` is the first built-in user-facing messaging adapter.

```ruby
require "igniter/channels"

telegram = Igniter::Channels::Telegram.new(
  bot_token: ENV["TELEGRAM_BOT_TOKEN"],
  default_chat_id: ENV["TELEGRAM_CHAT_ID"]
)

result = telegram.deliver(
  subject: "Call Summary",
  body: "Lead is interested in a follow-up next Tuesday."
)

result.status      # => :delivered
result.message_id  # => Telegram message id
```

Supported Telegram features in the MVP adapter:

- `sendMessage` delivery
- default `bot_token` and `chat_id` from initializer or environment
- `telegram:<chat_id>` or raw `chat_id` destinations
- optional `subject + body` rendering into one message
- `parse_mode`, `message_thread_id`, `reply_markup`
- optional preview suppression and silent delivery

Current limitation:

- attachments/media are not supported yet in the built-in adapter

## Using channels directly

```ruby
channel = TelegramChannel.new

result = channel.deliver(
  to: "telegram:123456",
  body: "Your transcript is ready"
)

result.success?   # => true
result.external_id
```

## Using channels in contracts

Because `Igniter::Channels::Base` inherits from `Igniter::Effect`, adapters can
also participate in contracts as first-class side effects.

```ruby
class NotifyAgent < Igniter::Contract
  define do
    input :chat_id
    input :summary

    effect :telegram_notice,
           uses: TelegramChannel,
           depends_on: %i[chat_id summary]

    output :telegram_notice
  end
end
```

## Intended layering

- `Igniter::Tool` may call channels directly
- `Igniter::AI::Skill` may orchestrate channel usage
- Rails/webhook plugins adapt inbound traffic into contracts
- `Igniter::App` and upper layers wire credentials, routing, and policy

`Igniter::Channels` is not an AI layer. It is a delivery/transport layer that AI
and application code can use.
