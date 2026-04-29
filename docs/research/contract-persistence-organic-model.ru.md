# Contract Persistence: Органическая модель

Дата: 2026-04-29.
Область: Архитектурные рекомендации по органическому persistence, нативному для контрактов.
Не является публичным API, пакетным API или планом выполнения.

## Текущее состояние (честный срез)

Что доказано в Companion:

```
persist → Store[T]            ✓ manifest descriptor
history → History[T]           ✓ manifest descriptor
field/index/scope/command      ✓ DSL-метаданные
storage_plan (R1)              ✓ report-only lowering candidates
command → mutation intent      ✓ граф возвращает, store применяет
materializer lifecycle         ✓ review-only, без execution
```

Что **не** является частью графа сейчас:

- `field` — только метаданные манифеста, не узел графа
- Store reads — происходят **снаружи** контракта, в `CompanionStore`
- Store writes — intent hash, интерпретируемый store-ом
- Adapter — runtime injection, не compile-time конфигурация

Граф знает о намерении хранить — но не является участником хранения.
Это хорошая отправная точка, но ещё не "organic".

## Что значит "organic" в контексте Igniter

ORM-подход: **storage first**

```
Table → Model class → Query methods → Business logic
```

Igniter organic persistence: **semantics first**

```
Contract (rules + shapes) → Storage plan → Adapter lowering → Physical storage
```

Ключевые принципы:

1. **Контракт IS схема.** `persist :reminders do field :title end` — это и
   есть определение данных. Никакой отдельной миграционной схемы.
2. **Store[T] — узел графа**, а не DSL-метадата. Компилятор валидирует,
   runtime резолвит.
3. **Чтение — граф-зависимость.** `store_read :reminder, by: :id` резолвится
   runtime-ом с TTL cache и coalescing — так же как `compute`.
4. **Запись — типизированный output.** `store_write :reminder,
   target: :reminders` выполняется runtime-ом на app boundary, с Saga
   компенсацией.
5. **Adapter — runtime plugin.** Контракт объявляет что хранить; adapter
   говорит как.

## Модель: Store[T] и History[T] как узлы первого класса

### Новые типы узлов в модели графа

```ruby
# lib/igniter/model/ — новые NodeType:
# StoreNode       — аналог ComputeNode, но резолвится adapter-ом
# HistoryNode     — append-only вариант StoreNode
# StoreReadNode   — разрешение через adapter (как compute, с cache_ttl/coalesce)
# StoreWriteNode  — side effect на app boundary (как effect, с compensate)
```

### DSL (целевая форма)

```ruby
class ReminderContract < Igniter::Contract
  define do
    # Объявление Store[T] — это и схема, и узел графа
    persist :reminders, key: :id, adapter: :sqlite do
      field :id,     type: Types::UUID,  default: -> { SecureRandom.uuid }
      field :title,  type: Types::String
      field :status, type: Types::Enum[:open, :closed], default: :open
      index :status
      scope :open, where: { status: :open }
    end

    # История — append-only, без update/delete семантики
    history :reminder_logs, partition_key: :reminder_id do
      field :reminder_id, type: Types::UUID
      field :action,      type: Types::Symbol
      field :occurred_at, type: Types::DateTime, default: -> { Time.now }
    end

    # --- Входы ---
    input :reminder_id

    # store_read резолвится runtime-ом — lazy node как compute
    store_read :reminder, from: :reminders, by: :id, using: :reminder_id,
               cache_ttl: 60, coalesce: true

    # Бизнес-логика остаётся в compute — без зависимости от хранилища
    compute :updated_reminder, depends_on: [:reminder], call: CompleteReminderTransition

    # store_write — типизированный side effect на app boundary
    store_write :saved_reminder, from: :updated_reminder, target: :reminders

    # store_append — для историй
    store_append :log_entry, from: :updated_reminder, target: :reminder_logs

    output :saved_reminder
  end
end
```

### Что это даёт

| Аспект | ORM | Igniter Organic |
|--------|-----|-----------------|
| Схема | Отдельный migration file | `persist do field ... end` IS схема |
| Чтение | `Model.where(...)` вне бизнес-логики | `store_read` — граф-зависимость с cache/coalesce |
| Запись | `model.save!` императивно | `store_write` — типизированный output с Saga |
| Валидация | callbacks/validations в модели | type system на field + граф-компилятор |
| Отношения | belongs_to/has_many | `relation` — граф-ребро, валидируемое компилятором |
| Адаптер | ActiveRecord + database.yml | runtime plugin, объявлен в контракте |
| Миграция | `rails generate migration` | diff между `Store[T].version(n)` и `Store[T].version(n+1)` |

## Relations как граф-рёбра

Сейчас relations — manifest metadata с `enforcement: :report_only`. В
органической модели — это типизированные рёбра, которые **компилятор
валидирует**:

```ruby
relation :logs_by_reminder,
  from: Store[:reminders],
  to:   History[:reminder_logs],
  join: { id: :reminder_id },
  cardinality: :one_to_many

# В проекции — relation становится граф-входом
project :reminder_detail,
  using: :logs_by_reminder,
  depends_on: [:reminder]
```

Компилятор проверяет, что `id` в `reminders` и `reminder_id` в
`reminder_logs` имеют совместимые типы. Это compile-time type-checking
отношений — чего нет ни в каком ORM.

## Migration как первоклассный контракт

Текущий `WizardTypeSpecMigrationPlanContract` уже близок к этому. Целевая
модель:

```ruby
class ReminderContract::Migration < Igniter::Contract
  define do
    # Store[T] сам является версионированным — хранит историю spec-изменений
    input :previous_schema, from: Store[ReminderContract].version(:previous)
    input :current_schema,  from: Store[ReminderContract].version(:current)

    compute :schema_diff,    depends_on: %i[previous_schema current_schema], call: StoreSchemaDiff
    compute :migration_plan, depends_on: [:schema_diff], call: MigrationPlanBuilder

    output :migration_plan  # report-only, не выполняется
  end
end
```

Ключевая идея: **версионирование схемы — это History[ContractSpecChange]**,
что уже есть в Companion (`WizardTypeSpecChange`). История изменений схемы
хранится теми же механизмами, что и история бизнес-событий. Это и есть
органичная форма.

## Adapter как runtime plugin

```ruby
# Адаптер объявлен в контракте — compile-time decision
class ReminderContract < Igniter::Contract
  adapter :sqlite, database: "companion.db"    # для development
  # adapter :postgres, url: ENV["DATABASE_URL"] # для production
  # adapter :memory                              # для тестов

  define do
    persist :reminders do ... end
  end
end

# В тестах:
ReminderContract.execute(
  { reminder_id: "123" },
  adapter: :memory  # override per execution
)
```

Минимальный интерфейс адаптера:

```ruby
module Igniter::Persistence::Adapter
  def read(store_key, query)           # → Record или nil
  def write(store_key, record)         # → persisted Record
  def append(history_key, event)       # → appended Event
  def query(store_key, scope, params)  # → Array<Record>
end
```

## Ключевое отличие от ORM: граф как единица хранения

В ORM **единица хранения — объект** (User, Post, Comment). Бизнес-логика
разбросана по callbacks, concerns, service objects.

В Igniter organic persistence **единица хранения — контракт**. Контракт
объявляет:

- что он хранит (`persist`, `history`)
- как получить (`store_read`)
- как изменить (`store_write`, `store_append`)
- как данные связаны (`relation`)
- как выглядит схема для адаптера (`field`, `index`, `scope`)

Runtime делает всё остальное: lazy resolution, cache, invalidation, Saga
компенсация, audit trail. Бизнес-логика остаётся в `compute` — изолированная,
тестируемая, без зависимости от хранилища.

## Что сохранить из текущего дизайна

| Текущее | Статус |
|---------|--------|
| `persist → Store[T]` / `history → History[T]` | Сохранить — правильная семантика |
| Command intent → app boundary | Сохранить — правильный паттерн |
| Storage plan sketch (R1) | Сохранить как compile-time artifact |
| Report-only materializer lifecycle | Сохранить — execution должен быть явным |
| Manifest + glossary health | Сохранить как guardrail |
| `WizardTypeSpec + History[ContractSpecChange]` | Сохранить — это и есть версионирование схемы |

## Фазированный путь (поверх текущего roadmap)

```
R1 (done)  Storage plan sketch — report-only
R2a        field → type system — поля участвуют в Type validation
R2b        store_read как compute-like граф-узел (lazy, cache_ttl, coalesce)
R3         store_write / store_append как typed effect output с Saga
R4         Adapter interface + memory adapter для тестов
R5         Migration как diff Store[T].v(n) → Store[T].v(n+1)
R6         Materializer dry run → executable materializer
R7         Extraction: descriptors → igniter-extensions,
           adapters/materializer → igniter-application,
           reserve igniter-persistence
```

## Вывод

Companion — правильное доказательство модели. Граница "граф вычисляет
намерение, store применяет" — **правильная**. Манифест, storage plan и
glossary health — правильная инфраструктура.

Шаг к "organic" — сделать `Store[T]` и `History[T]` **первоклассными узлами
графа**, а не просто DSL-метаданными. Тогда `store_read` резолвится
runtime-ом с тем же cache/coalesce что и вычисления, `store_write`
выполняется как typed effect с Saga, а relations валидируются компилятором.
Это и есть persistence как часть контракта, а не ORM поверх него.

## Handoff

```text
[Architect Supervisor / Codex]
Track: docs/research/contract-persistence-organic-model.ru.md
Canonical: docs/research/contract-persistence-organic-model.md
Status: архитектурные рекомендации по органическому persistence.
[D] Store[T] и History[T] должны стать первоклассными типами узлов графа.
[D] store_read — lazy граф-узел, резолвируемый runtime adapter-ом.
[D] store_write/store_append — typed effect outputs с поддержкой Saga.
[D] Relations — типизированные граф-рёбра, валидируемые компилятором.
[D] Fields должны участвовать в type system Igniter.
[D] Adapter объявлен в контракте, переопределяется per-execution.
[D] Версионирование схемы IS History[ContractSpecChange] — уже есть в Companion.
[R] Не добавлять ORM-style query methods или model callbacks.
[R] Сохранять границу "граф вычисляет намерение, store применяет".
[S] Следующий лучший срез: R2a — подключение field к type system.
```
