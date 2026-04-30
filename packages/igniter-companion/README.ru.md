# igniter-companion

DSL уровня приложения для Record/History, backed by `igniter-store`.

> Канонический оригинал — [README.md](README.md) (English).

## Цель

Этот пакет — **потребитель `igniter-store` с точки зрения прикладного кода**.

Он существует по двум причинам:

1. **Пользовательская поверхность** — показывает, как должна выглядеть работа с фактами из кода контрактов/приложений: типизированные `Record`, append-only `History`, scope-запросы, реактивные подписки.

2. **Давление на ядро** — каждая новая возможность на этом уровне выявляет пробелы, неудобства или баги в `igniter-store`. Это намеренно. Инсайты фиксируются в секции [Давление и инсайты](#давление-и-инсайты) ниже.

### Метафора туннеля

```
examples/application/companion   ←── app-level contracts, manifests, materializer
                   │
                   │  копают навстречу друг другу
                   ▼
  packages/igniter-companion      ←── типизированный DSL поверх igniter-store
                   │
                   ▼
  packages/igniter-store          ←── факты, WAL, scope, reactive (Rust/Ruby FFI)
```

**Точка сближения**: когда `PersistenceSketchPack` в `examples/application/companion`
начнёт работать через `Igniter::Companion::Store` вместо blob-JSON в SQLite.

---

## Архитектура

```
lib/igniter/companion/
  record.rb    — Record mixin: store_name, field, scope DSL → типизированные объекты
  history.rb   — History mixin: history_name, field → append-only события
  store.rb     — Store: register, write, read, scope, append, replay, on_scope
```

### `Record`

Оборачивает `Store[T]` из igniter-store. Последнее записанное значение — текущее состояние.

```ruby
class Reminder
  include Igniter::Companion::Record
  store_name :reminders

  field :title
  field :status, default: :open
  field :due,    default: nil

  scope :open, filters: { status: :open }
  scope :done, filters: { status: :done }, cache_ttl: 30
end
```

### `History`

Оборачивает `History[T]` из igniter-store. Append-only, ключи генерируются автоматически.

```ruby
class TrackerLog
  include Igniter::Companion::History
  history_name :tracker_logs
  partition_key :tracker_id   # включает partition replay

  field :tracker_id
  field :value
  field :notes, default: nil
end
```

### `Store`

Оркестратор — хранит инстанс `IgniterStore`, знает о зарегистрированных схемах.

```ruby
store = Igniter::Companion::Store.new            # in-memory (по умолчанию)
store = Igniter::Companion::Store.new(           # file-backed WAL
  backend: :file,
  path:    "/tmp/companion.wal"
)

store.register(Reminder)   # регистрирует AccessPath для каждого scope

store.write(Reminder, key: "r1", title: "Buy milk", status: :open)
store.read(Reminder,  key: "r1")                 # => #<Reminder key="r1" ...>
store.scope(Reminder, :open)                     # => [#<Reminder ...>, ...]
store.scope(Reminder, :open, as_of: checkpoint)  # time-travel

store.append(TrackerLog, tracker_id: "t1", value: 8.5)
store.replay(TrackerLog)                         # => [#<TrackerLog ...>, ...]
store.replay(TrackerLog, since: cutoff)          # с фильтром по времени
store.replay(TrackerLog, partition: "sleep")     # фильтр по partition_key

store.causation_chain(Reminder, key: "r1")       # цепочка мутаций для отладки
```

### Нормализованные receipts

`write` и `append` возвращают объекты-receipts с метаданными мутации.
Неизвестные методы делегируются на вложенный record/event:

```ruby
receipt = store.write(Reminder, key: "r1", title: "Buy milk")
receipt.mutation_intent          # => :record_write
receipt.fact_id                  # => "550e8400-..."
receipt.value_hash               # => "a3b1c2..."
receipt.causation                # => nil (первая запись) или предыдущий value_hash
receipt.title                    # => "Buy milk"  (делегировано на Reminder)
receipt.record                   # => #<Reminder ...>

receipt = store.append(TrackerLog, tracker_id: "sleep", value: 8.5)
receipt.mutation_intent          # => :history_append
receipt.timestamp                # => 1714483200.123
receipt.value                    # => 8.5  (делегировано на TrackerLog)
receipt.event                    # => #<TrackerLog ...>
```

### Реактивные подписки

```ruby
store.on_scope(Reminder, :open) do |store_name, scope|
  # вызывается при инвалидации scope-кэша
  puts "#{store_name}/#{scope} changed — refresh your view"
end
```

Подписчик **не** вызывается на каждый write — только когда scope-кэш был прогрет
запросом до этого, а следующий write его инвалидировал. Lazy-семантика из igniter-store
(см. [Инсайты](#давление-и-инсайты)).

---

## Запуск тестов

```bash
# Скомпилировать igniter-store (один раз):
cd ../igniter-store
PATH="$HOME/.cargo/bin:$PATH" bundle exec rake compile

# Запустить суиту companion:
cd ../igniter-companion
bundle exec rake spec
```

---

## Давление и инсайты

Живой журнал. Каждый раз, когда companion-слой выявляет несоответствие или баг
в нижележащем слое, это фиксируется здесь с датой, симптомом, причиной,
исправлением и уроком.

---

### [2026-04-30] Float-coercion в `ruby_to_json_inner`

**Симптом**: тест с `TrackerLog#value = 7.0` получал обратно Integer `7`.

**Причина**: в `fact.rs` использовался `i64::try_convert(val)` для определения
числового типа. Magnus вызывает Ruby-метод `to_i` при конвертации, поэтому
`Float(7.0).to_i` → `7`, `Float(8.5).to_i` → `8`.

**Исправление** (в `igniter-store/ext/igniter_store_native/src/fact.rs`):
```rust
// Было (неточно — coerce-ит Float через to_i):
if let Ok(i) = i64::try_convert(val) { return serde_json::json!(i); }
if let Ok(f) = f64::try_convert(val) { return serde_json::json!(f); }

// Стало (точная проверка Ruby-типа):
if let Some(int) = RbInteger::from_value(val) {
    if let Ok(n) = int.to_i64() { return serde_json::json!(n); }
}
if let Some(flt) = RbFloat::from_value(val) {
    return serde_json::json!(flt.to_f64());
}
```

**Урок**: Magnus's `T::try_convert` проходит через Ruby coercion-протокол.
Для точного type-dispatch нужны `RbInteger::from_value` / `RbFloat::from_value`.

---

### [2026-04-30] Lazy-инвалидация scope-кэша

**Наблюдение**: scope-consumer не вызывается на первый write — только если
scope-кэш был прогрет запросом до этого.

**Это намеренное поведение**: `ReadCache` удаляет scope-записи при инвалидации,
но нечего удалять если кэш пустой → нет записей → нет уведомлений.

**Последствие для companion**: `on_scope` документируется как
"уведомление об изменении прогретого кэша", не "уведомление о каждой мутации".
Для реакции на каждую мутацию нужен другой механизм (event bus / WAL tail).

**Открытый вопрос для igniter-store**: стоит ли добавить `eager: true` опцию
в `AccessPath`, которая регистрирует consumer как point-write listener
независимо от состояния кэша?

---

### [2026-04-30] Partition queries для History

**Добавлена возможность**: `partition_key :field_name` на `History`-классе; `Store#replay(partition: "value")` фильтрует события по этому полю.

**Реализация**: partition key хранится в value payload (не в ключе факта), поэтому фильтрация происходит на Ruby-слое после того, как `@inner.history(...)` возвращает все события для данного store. Регистрация нового `AccessPath` не нужна.

**Проверка сходимости**: check `history_partition_query` в `StoreConvergenceSidecarContract` проходит с `partition_replay_count == 2` и `partition_replay_values == [7.0, 8.5]`.

---

### [2026-04-30] Нормализованные receipts (`WriteReceipt` / `AppendReceipt`)

**Добавлена возможность**: `Store#write` возвращает `WriteReceipt`; `Store#append` — `AppendReceipt`. Оба несут `mutation_intent`, `fact_id`, `value_hash` и делегируют неизвестные методы на вложенный record/event.

**Давление**: raw `IgniterStore` возвращает `FactData`-подобный объект с `id`/`value_hash`/`causation`/`timestamp`. Обёртка в типизированные receipts на companion-слое не позволяет утечь деталям store во внешний код.

**Следующий открытый вопрос** (`pressure.next_question`): `:manifest_generated_record_history_classes` — автогенерация `Record`/`History`-классов из декларации `persistence_manifest` без фиксации финального DSL.

---

### [предстоящее] `nil` vs absent поля на чтении

**Гипотеза** (не проверена): если поле не было записано в value (например,
опциональное поле, добавленное после первых записей), `Record#initialize`
применит `default:` из декларации. Но если `nil` был явно записан — вернётся
`nil`, а не default. Разница между *отсутствующим* и *явно nil* не моделируется.
Стоит протестировать и, возможно, ввести отдельное понятие.

---

### [предстоящее] Вложенные Hash-значения

Текущий DSL не имеет вложенных типов:

```ruby
field :address  # { city: "Moscow", zip: "101000" }
```

После round-trip через igniter-store ключи становятся Symbols (`:city`, `:zip`).
Это правильно. Но нет способа объявить структуру вложенного объекта.
Кандидат для будущего расширения: `embedded :address do ... end`.

---

### [предстоящее] Сходимость с `examples/application/companion`

Текущий `CompanionStore` в `examples/application/companion/services/companion_store.rb`
использует blob-JSON через SQLite. Целевой путь:

```
PersistenceSketchPack (DSL: persist/history/field/scope)
  → генерирует Record/History классы
  → хранит через Igniter::Companion::Store
  → backed by Igniter::Store::IgniterStore (facts + WAL)
```

Когда первый реальный `persist :reminders` пройдёт через этот стек end-to-end,
туннели сойдутся.
