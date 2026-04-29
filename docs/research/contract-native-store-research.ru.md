# Contract-Native Store: Итерации исследования

Дата: 2026-04-29.
Формат: живой исследовательский документ — каждая итерация добавляется снизу.
Область: распределённые кластеры проактивных агентов; опциональный отдельный пакет.
Канонический: `contract-native-store-research.md`. Этот файл — русская версия.

---

## Итерация 0 — Ограничения и решения

*Зафиксировано в ходе дизайн-сессии, 2026-04-29.*

Эти ограничения определяют рамки исследования и не пересматриваются без причины.

### Целевой контекст

Уровень Igniter Application / Cluster. Основной потребитель — приложение с
децентрализованными, распределёнными, проактивными агентами. Хранилище должно
обслуживать агентов, которые:

- реагируют на изменения данных проактивно (без опроса снаружи)
- распределены по кластеру
- нуждаются в согласованном общем состоянии без накладных расходов на координацию
- должны рассуждать об историческом состоянии (что произошло до события Y?)

### Граница с внешними базами данных

Мы не запрещаем разработчику использовать его любимую БД. Предоставляем
минимальный API сопряжения; всё остальное — ответственность разработчика в
реализации промежуточного слоя. Если нативное хранилище окажется лучше на
практике — оно продаст себя само. Без принуждения.

### Приоритетные возможности

Из всех возможных направлений выбраны два:

1. **Compile-time query optimization** — пути доступа выводятся из графа
   контрактов до появления каких-либо данных, а не в runtime.
2. **Time-travel** — любое прошлое состояние доступно для запроса как
   структурное следствие иммутабельности, а не добавленная сверху фича.

### Область пакета

Опциональный, отдельный пакет (кандидат на имя: `igniter-store`).
Рекомендован, но не навязан. Продукт должен оправдать себя на практике.

---

## Итерация 1 — Где существующие системы не справляются

*Зафиксировано в ходе дизайн-сессии, 2026-04-29.*

Все существующие системы хранения — storage-first. Бизнес-логика живёт снаружи:

```
Relational (PG, SQLite)  → таблицы  → ORM      → бизнес-логика (снаружи)
Document (Mongo)         → документы → ODM      → бизнес-логика (снаружи)
Event stores (Kafka, ES) → события  → вручную  → бизнес-логика (снаружи)
Datomic                  → факты    → Datalog  → бизнес-логика (снаружи)
Graph DB (Neo4j)         → узлы     → Cypher   → бизнес-логика (снаружи)
```

В каждом случае движок хранения слеп к намерению. Он не знает зачем читаются
данные и что они означают в домене.

Igniter — первая система, где **полный граф зависимостей бизнес-логики известен
на compile-time**. Это открывает двери, структурно закрытые для всех систем выше.

### Три пробела, важных для распределённых агентов

**Пробел 1 — Планирование запросов в runtime.**
SQL и любой ORM строят план запроса в runtime. Движок видит запрос впервые при
его выполнении. В контракте каждый `store_read` — типизированная compile-time
зависимость. Хранилище может знать полный access pattern до появления каких-либо
данных или запросов.

**Пробел 2 — Поддержка проекций вручную.**
В CQRS/ES проекции — это написанные вручную потребители, перестраивающие read
model из событий. В Igniter проекции — это контракты. Если хранилище понимает
контракты, оно может поддерживать проекции автоматически — инкрементально,
с инвалидацией кэша из графа.

**Пробел 3 — История как второстепенная мысль.**
У Datomic есть time-travel, но это отдельный режим запросов (`as-of`,
`history`). В Igniter `History[T]` — хранилищная форма первого класса.
Append-only лог фактов — это не аудит-надстройка; это модель записи. Текущее
состояние — всегда проекция истории.

---

## Итерация 2 — Эскиз архитектуры

*Зафиксировано в ходе дизайн-сессии, 2026-04-29.*

### Синтез: контракты + time-travel + распределённые агенты

Три приоритета усиливают друг друга:

```
Compile-time граф   →  пути доступа известны на deploy
                    →  хранилище индексирует по контракту, а не по запросу
                    →  агенты объявляют reads; хранилище маршрутизирует writes

Append-only факты   →  каждая запись — новый факт, ничего не мутируется
                    →  time-travel структурен (факты где t <= T)
                    →  Raft consensus log И ЕСТЬ ось времени

Content addressing  →  факты хранятся по хешу содержимого (как Git objects)
                    →  структурное разделение между версиями бесплатно
                    →  дедупликация автоматична
                    →  цепочка причинности связывает факты (поле previous_hash)
```

### Модель факта

Каждый `store_write` производит иммутабельный факт:

```
Fact {
  contract:      ReminderContract,        # какой контракт произвёл
  store:         :reminders,              # какой Store[T]
  key:           "uuid-123",              # идентичность внутри хранилища
  value_hash:    "sha256:abc...",         # content address значения
  value:         { id: "...", ... },      # реальный payload
  causation:     "sha256:prev...",        # ссылка на предыдущий факт для этого ключа
  timestamp:     1714000000,              # wall-clock (для time-travel запросов)
  term:          42,                      # Raft term (для распределённого упорядочения)
  schema_hash:   "sha256:schema...",      # content address версии схемы
}
```

Одна структура даёт:

- **Time-travel**: `facts.select { |f| f.timestamp <= t && f.store == :reminders }`
- **Audit trail**: следовать цепочке `causation` назад
- **Версионирование схемы**: `schema_hash` связывает каждый факт с точной версией схемы
- **Распределённое упорядочение**: `term` из Raft consensus разрешает конфликты
- **Дедупликация**: одинаковое содержимое ⟹ одинаковый `value_hash`

### Генерация пути доступа на compile-time

Когда контракт объявляет:

```ruby
store_read :reminder, from: :reminders, by: :id, using: :reminder_id,
           cache_ttl: 60, coalesce: true
```

Компилятор эмитирует:

```
AccessPath {
  store:          :reminders,
  lookup:         :primary_key,
  key_binding:    :reminder_id,
  cache_strategy: :ttl,
  cache_ttl:      60,
  coalesce:       true,
  consumers:      [ReminderContract, ReminderDetailProjection, ...]
}
```

Хранилище читает это при deploy и строит индекс заранее. В runtime нет шага
"запланировать этот запрос" — путь был материализован при компиляции контракта.

### Локальность данных для распределённых агентов

Когда `ProactiveAgent` объявляет:

```ruby
store_read :pending_tasks, from: :tasks, scope: :pending, cache_ttl: 30
```

Хранилище знает на deploy:

- `ProactiveAgent` читает `:tasks` со scope `:pending`
- кэш 30 сек
- при изменении `:tasks` — цель инвалидации кэша `ProactiveAgent`
- если `ProactiveAgent` работает на Node A — реплицировать релевантные
  изменения `:tasks` на Node A с приоритетом

Это **оптимизация локальности данных, выведенная из графа контрактов** — невозможна
ни в каком ORM или планировщике запросов сегодня.

### Внутренняя структура хранилища (кандидат)

```
igniter-store/
  WriteStore     ← append-only лог фактов; WAL-backed; content-addressed values
  ReadStore      ← проекции, поддерживаемые графом контрактов; живые materialized views
  TimeIndex      ← индекс timestamp + term над логом фактов (O(log n) time-travel)
  SchemaGraph    ← compile-time сгенерированные пути доступа из контрактов
  ClusterSync    ← consensus репликация через существующий Igniter::Consensus (Raft)
  Adapter API    ← минимальная поверхность сопряжения для внешних БД (escape hatch)
```

### Связь с существующими компонентами Igniter

```
Igniter::Consensus  →  ClusterSync использует Raft log; записи лога = факты
Igniter::NodeCache  →  ReadStore соблюдает существующую семантику TTL + coalescing
Igniter::AI::Agent  →  ProactiveAgent может подписываться на проекции ReadStore
incremental dataflow →  поддержка проекций — это модель инкрементальных вычислений
Saga / Effect       →  сбой store_write инициирует Saga компенсацию; факт не коммитится
```

---

## Итерация 3 — Открытые треды

*Зафиксировано в ходе дизайн-сессии, 2026-04-29. Для расширения в будущих итерациях.*

### Тред A — Минимальная поверхность Adapter API

Какой минимальный интерфейс нужен разработчику для подключения внешней БД?

Кандидат:

```ruby
module Igniter::Store::Adapter
  # Вызывается store_read узлами в runtime (после резолвинга compile-time пути)
  def read(store_key, lookup)     # → Fact или nil

  # Вызывается store_write узлами на app boundary
  def write(store_key, fact)      # → committed Fact

  # Вызывается store_append узлами (History[T])
  def append(history_key, fact)   # → appended Fact

  # Вызывается compile-time path builder при deploy
  def build_access_path(path_descriptor)  # → void; реализация сохраняет индекс
end
```

Открыто: должен ли `build_access_path` быть опциональным (пропускаться для
простых адаптеров)?

### Тред B — API time-travel запросов

Как выглядит time-travel запрос из контракта?

Кандидат DSL:

```ruby
store_read :reminder_at_t, from: :reminders, by: :id, using: :reminder_id,
           as_of: :query_time   # :query_time — input узел

# Или как проекция:
project :reminder_history, from: :reminders, key: :reminder_id,
        over: :all_time         # возвращает Array<Fact>, упорядоченный по timestamp
```

Открыто: должен ли time-travel быть keyword первого класса или опцией на
`store_read`? Должен ли `as_of` принимать Raft term (для распределённой
консистентности) в дополнение к wall-clock timestamp?

### Тред C — Контракт как язык запросов

Радикальное направление: язык контрактов IS язык запросов. Никакого SQL,
GraphQL, Cypher. Контракт-запрос (read-only) объявляет зависимости `store_read`;
хранилище исполняет их как скомпилированный query plan.

```ruby
class FindPendingTasksQuery < Igniter::Contract
  define do
    input  :agent_id
    store_read :tasks, from: :tasks, scope: :pending,
               filter: { assigned_to: :agent_id }
    compute :prioritized, depends_on: [:tasks], call: PrioritySort
    output :prioritized
  end
end
```

Открыто: стоит ли развивать это в нативном хранилище или это слой над API
хранилища?

### Тред D — Эволюция схемы без миграций

Когда тип поля контракта меняется с `:string` на `:integer`, хранилище держит
факты, произведённые под обеими версиями схемы (отслеживается через
`schema_hash`). Coercion контракт может их связать:

```ruby
class ReminderContract::Coercion::V1toV2 < Igniter::Contract
  define do
    input  :fact_v1
    compute :coerced, depends_on: [:fact_v1], call: CoerceStatusField
    output :fact_v2
  end
end
```

Старые факты никогда не перезаписываются. Read path прозрачно запускает
coercion контракт когда `schema_hash` не совпадает с текущей версией.

Открыто: должны ли coercion контракты автогенерироваться из field diff
(migration plan) или всегда создаваться вручную?

### Тред E — Реактивное хранилище для проактивных агентов

Когда агент проактивный — он не должен опрашивать хранилище. Хранилище должно
push-инвалидировать агентов, чьи access paths покрывают изменившиеся факты.

```
Факт записан в :tasks (scope :pending затронут)
→ хранилище проверяет SchemaGraph: у кого AccessPath на :tasks/:pending?
→ ProactiveAgent на Node A и Node B подписаны
→ хранилище push-ит инвалидацию в mailbox обоих агентов
→ агенты ре-резолвят зависимость :tasks без опроса
```

Это сливает существующую модель mailbox `Igniter::AI::Agent` с реестром access
paths хранилища.

Открыто: push инвалидации или push нового факта? Push сначала в локальный node
cache, затем к удалённым агентам?

---

## Кандидаты следующих итераций

Порядок приоритета (открыт для пересмотра):

1. **Тред A** — закрепить минимальный adapter API; это определяет escape hatch
   и ограничивает область нативного хранилища
2. **Тред B** — определить time-travel query API; это главный дифференциатор
3. **Тред E** — реактивное хранилище + проактивные агенты; это первичный use
   case, должен определять дизайн write path
4. **Тред D** — coercion контракты / zero-migration evolution; строится на B
5. **Тред C** — контракт как язык запросов; самое радикальное, наименее срочно

---

## Итерация 4 — Тред E: дизайн Query API на контракте

*Зафиксировано в ходе дизайн-сессии, 2026-04-29.*

### Вопрос

Должен ли `ArticleContract.find(title: "hello igniter")` существовать на
классе? Рассмотрены три пути:

- **A** — Arel-style class method (`ArticleContract.find(...)`)
- **B** — `Persistable` mixin/враппер (отдельный класс как `Contractable`)
- **C** — запросы объявляются в теле контракта; никакого runtime query building

### Почему Arel-style неправильный ответ для Igniter

`ArticleContract.find(title: "hello igniter")` нарушает три инварианта Igniter:

1. **Нет compile-time валидации** — запрос строится в runtime; компилятор
   ничего о нём не знает.
2. **Store должен инжектироваться per-execution**, а не храниться как
   class-level синглтон. Глобальный `ArticleContract.store = my_store`
   нетестируем и неправильен в кластере.
3. **Контракт становится гибридом** — schema + validator + query object
   одновременно. Эти concerns не должны смешиваться.

### Почему `Persistable` — неправильный уровень абстракции

`Persistable` решает правильную проблему ("не все контракты — persistence"),
но на неправильном уровне. Opt-in — это объявление `persist` внутри тела
контракта. Контракт с `persist` получает store surface; без него — ничего.
Отдельный модуль-враппер добавляет косвенность без прибавки в ясности.

### Правильная модель: запросы — это контракты

Запрос в Igniter — это контракт с `input` узлами и `store_read`
зависимостями. Макрос `query` объявляет именованный мини-контракт,
привязанный к родительскому классу. Компилятор валидирует его при загрузке
точно так же как основной `define` блок.

```ruby
class ArticleContract < Igniter::Contract
  # Opt-in: только у этого контракта есть store surface
  persist :articles, key: :id do
    field :id,     type: Types::UUID,   default: -> { SecureRandom.uuid }
    field :title,  type: Types::String
    field :status, type: Types::Symbol, default: :draft
    index :title
    scope :by_title,  where: { title: :title }
    scope :published, where: { status: :published }
  end

  # query = объявленный store_read контракт; генерирует sugar на классе
  query :find_by_title do
    input  :title
    store_read :article, from: :articles, scope: :by_title
    output :article
  end

  query :published_articles do
    store_read :articles, from: :articles, scope: :published
    output :articles
  end

  # Time-travel — просто ещё один input, не специальный режим
  query :article_at do
    input  :id
    input  :as_of
    store_read :article, from: :articles, by: :id, using: :id, as_of: :as_of
    output :article
  end

  # Бизнес-логика — отдельно
  define do
    input :title
    input :status
    compute :validated, depends_on: %i[title status], call: ValidateArticle
    store_write :saved, from: :validated, target: :articles
    output :saved
  end
end
```

Использование — store всегда инжектируется per-call, никогда не глобальный:

```ruby
# Sugar, сгенерированный из query деклараций:
ArticleContract.find_by_title(title: "hello igniter", store: my_store)
ArticleContract.published_articles(store: my_store)
ArticleContract.article_at(id: "uuid-123", as_of: 3.days.ago.to_f, store: my_store)

# Под капотом — каждый вызов является просто выполнением контракта:
ArticleContract::Queries::FindByTitle.execute({ title: "hello igniter" }, store: my_store)
```

### Сравнение

| | Arel / ActiveRecord | Igniter `query` |
|--|-----|------|
| Валидация запроса | runtime | compile-time |
| Store scope | глобальный синглтон | per-call injection |
| Time-travel | отдельный API | `input :as_of` — обычный input |
| Реактивная инвалидация | нет | `store_read` → cache miss → agent push |
| Cache | отдельная настройка | `cache_ttl:` на `store_read` |
| Тестирование | мок ORM | `adapter: :memory` |
| "Не все контракты" | `include Persistable` | просто нет `persist` блока |

### Решение: A + B (отложено)

- **Основной путь (A)**: только объявленные `query` блоки генерируют
  class-level методы. Любое чтение должно быть задекларировано.
  Валидируется компилятором. Это целевая модель.

- **Сложные случаи (B)**: отдельный query contract без sugar, для запросов
  которые не принадлежат одному контракту:

  ```ruby
  class FindDraftsByAuthor < Igniter::Contract
    define do
      input :author_id
      store_read :drafts, from: :articles,
                 filter: { author_id: :author_id, status: :draft }
      output :drafts
    end
  end
  ```

- **Никакого Arel-style runtime query building.** Никогда.

- **Реализация макроса `query` отложена** до давления реальных приложений.
  Модель принята; sugar появится когда будет нужен.

### Ключевые инварианты, которые сохраняются

- Контракт без `persist` имеет нулевую store surface.
- Store всегда инжектируется per execution (keyword аргумент `store:`).
- Каждый запрос — скомпилированный граф; компилятор валидирует inputs,
  типы и `store_read` привязки при загрузке.
- Time-travel не требует специального режима запроса — `as_of:` —
  обычный типизированный input.

---

## Итерация 5 — Тред B: Time-Travel DSL API

*Зафиксировано в ходе дизайн-сессии, 2026-04-29.*

### Три измерения time-travel

Time-travel — это не одна семантика, а три различных формы запроса:

```
as_of:        Float | Integer  → «что было на момент T?»            — single value
since/until:                   → «все версии между T1 и T2»          — Array
after_fact:   String           → «состояние после конкретного факта» — causal
```

Форма возврата ортогональна:

```
returns: :value           → payload Hash (default)
returns: :history         → Array<Hash>, упорядоченный по timestamp
returns: :fact            → сырой Fact struct (полные метаданные, для audit)
returns: :causation_chain → [{value_hash, causation, timestamp}, ...]
```

### Решение: `as_of` — опция на `store_read`, не отдельный keyword

```ruby
# НЕ это (лишний keyword засоряет DSL):
store_read_at :article, from: :articles, at: :query_time

# А это — as_of как параметр store_read:
store_read :article, from: :articles, by: :id, using: :id, as_of: :query_time
```

`as_of:` принимает два типа из существующей type system:

- **Float** → сравнивается с `fact.timestamp` (wall-clock, standalone)
- **Integer** → сравнивается с `fact.term` (Raft term, cluster)

Store определяет режим по типу значения. Новый тип `TimePoint` не нужен
в первой итерации.

`after_fact:` принимает **String** (value\_hash) для точного каузального
упорядочивания в distributed деплоях, где wall-clock ненадёжен при clock skew.

### Полная сигнатура `store_read` с time-travel

```ruby
store_read :node_name,
  from:        :store_name,         # какой Store[T]
  by:          :primary_key,        # :primary_key | :scope | :filter
  using:       :input_node,         # input узел с ключом
  scope:       :scope_name,         # для :scope lookup
  filter:      { field: :input },   # для :filter lookup

  # time-travel
  as_of:       :time_input,         # Float (wall-clock) | Integer (Raft term)
  since:       :from_input,         # начало диапазона (auto → returns: :history)
  until:       :to_input,           # конец диапазона
  after_fact:  :hash_input,         # String — value_hash точки причинности

  # форма возврата
  returns:     :value,              # :value | :history | :fact | :causation_chain
  schema:      :current,            # :current (coerce) | :as_stored (raw, audit)

  # кэш
  cache_ttl:   60,                  # игнорируется для time-travel (прошлое иммутабельно)
  coalesce:    true
```

Правила совместимости:

| Комбинация | Результат |
|---|---|
| `as_of:` | single value на T; иммутабельно кэшируется |
| `since:` + `until:` | auto `returns: :history` |
| `after_fact:` | single value после точки причинности; иммутабельно кэшируется |
| `returns: :causation_chain` | временные ограничения игнорируются; полная цепочка |
| `as_of:` + `cache_ttl:` | `cache_ttl:` игнорируется; прошлое не меняется |

### Полный пример на ArticleContract

```ruby
class ArticleContract < Igniter::Contract
  persist :articles, key: :id do
    field :id,         type: :string
    field :title,      type: :string
    field :status,     type: :symbol, default: :draft
    field :body,       type: :string
    field :updated_at, type: :float,  default: -> { Time.now.to_f }
    index :title
    index :status
    scope :published, where: { status: :published }
  end

  # «Каким был этот Article на момент T?»
  # as_of: Float → wall-clock (standalone)
  # as_of: Integer → Raft term (cluster)
  query :article_at do
    input :id
    input :as_of   # Float | Integer — store определяет режим по типу
    store_read :article, from: :articles, by: :id, using: :id, as_of: :as_of
    output :article
  end

  # «Состояние после конкретного факта» — каузальная точность
  # Нужно в distributed: wall-clock ненадёжен при clock skew
  query :article_after_fact do
    input :id
    input :fact_hash   # String — value_hash из Fact
    store_read :article, from: :articles, by: :id, using: :id,
               after_fact: :fact_hash
    output :article
  end

  # «Все версии между T1 и T2»
  query :article_versions do
    input :id
    input :from_time, type: :float, default: -> { (Time.now - 86_400 * 30).to_f }
    input :to_time,   type: :float, default: -> { Time.now.to_f }
    store_read :versions, from: :articles, by: :id, using: :id,
               since: :from_time, until: :to_time   # auto: returns :history
    output :versions   # Array<Hash>
  end

  # «Полная цепочка мутаций» — отладка и аудит
  query :article_lineage do
    input :id
    store_read :chain, from: :articles, by: :id, using: :id,
               returns: :causation_chain
    output :chain   # [{value_hash:, causation:, timestamp:}, ...]
  end

  # «Сырой факт как сохранён» — audit без coercion схемы
  query :article_audit_snapshot do
    input :id
    input :as_of
    store_read :fact, from: :articles, by: :id, using: :id,
               as_of: :as_of, returns: :fact, schema: :as_stored
    output :fact   # Fact struct: value_hash, causation, schema_version
  end

  define do
    input :title
    input :body
    input :status
    compute :validated, depends_on: %i[title body status], call: ValidateArticle
    store_write :saved, from: :validated, target: :articles
    output :saved
  end
end
```

Использование — store всегда per-call:

```ruby
store = Igniter::Store::IgniterStore.new

# Текущее состояние
ArticleContract.execute({ title: "hello", body: "...", status: :draft }, store: store)

# Точка во времени, wall-clock
ArticleContract.article_at(id: "uuid-1", as_of: 3.days.ago.to_f, store: store)

# Точка во времени, Raft term (cluster)
ArticleContract.article_at(id: "uuid-1", as_of: 42, store: store)

# После конкретного факта (causal — самое точное)
ArticleContract.article_after_fact(id: "uuid-1", fact_hash: "sha256:abc...", store: store)

# Срез истории
ArticleContract.article_versions(id: "uuid-1",
                                  from_time: 7.days.ago.to_f,
                                  to_time:   Time.now.to_f,
                                  store: store)

# Causation chain
ArticleContract.article_lineage(id: "uuid-1", store: store)

# Audit snapshot без coercion
ArticleContract.article_audit_snapshot(id: "uuid-1", as_of: 3.days.ago.to_f, store: store)
```

### Кэш-поведение time-travel

```
as_of: nil    → current read   → кэш [store, key, nil]    → инвалидируется при записи
as_of: Float  → time-travel    → кэш [store, key, as_of]  → НИКОГДА не инвалидируется
after_fact:   → causal read    → кэш [store, key, hash]   → НИКОГДА не инвалидируется
since/until   → history slice  → НЕ кэшируется (слишком большой → используй проекции)
```

Прошлое иммутабельно. `cache_ttl:` для time-travel игнорируется;
результат кэшируется навсегда после первого разрешения.

### Отложено (не в первой итерации)

| Вопрос | Статус |
|--------|--------|
| `Types::TimePoint` (unified clock type) | Отложено — Float/Integer достаточно |
| Pagination для `:history` (`limit:`, `offset:`) | Отложено — давление приложений |
| `schema: :as_stored` coercion contracts | Отложено — связано с Тредом D |
| `since/until` кэширование через проекции | Отложено — Тред E / incremental dataflow |
| Raft log index как третий ordering primitive | Отложено — term достаточно сейчас |

---

## Ссылки

- [Contract Persistence Organic Model](./contract-persistence-organic-model.md)
- [Contract Persistence Roadmap](./contract-persistence-roadmap.md)
- [Companion Current Status Summary](./companion-current-status-summary.md)
- [POC Спецификация](./contract-native-store-poc.md)
- [Канонический английский файл](./contract-native-store-research.md)
