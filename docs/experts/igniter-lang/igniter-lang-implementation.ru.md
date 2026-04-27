# Igniter-Lang: Стратегия Реализации

*Серия исследований — Документ 12*
*Трек: Реализация*

---

## §0 Стратегия

**Ключевое решение**: Ruby DSL является референсной реализацией Igniter-Lang.
Грамматика — позже, когда семантика доказана.

Это не компромисс — это проверенный путь. TypeScript начинался как "JavaScript
с типами". Kotlin — как "Java с лучшим синтаксисом". В обоих случаях хост-язык
предоставлял рантайм, пока семантика валидировалась на реальном коде. Грамматика
была зафиксирована только когда дизайн стабилизировался.

Для Igniter-Lang:

```
Фаза 1 — DSL как язык (сейчас)
  Расширить Ruby DSL для выражения полной спецификации Igniter-Lang.
  ContractBuilder получает новые ключевые слова. Существующие контракты неизменны.
  Семантика доказывается на реальных приложениях.

Фаза 2 — Сменяемые бекенды (параллельно с Фазой 1)
  Backend-интерфейс становится явным.
  Ruby backend = текущий рантайм, извлечённый и формализованный.
  Rust backend = будущее, для WCET / реального времени / сертифицированного экспорта.

Фаза 3 — Грамматика (когда дизайн стабилен)
  .il синтаксис → парсер → тот же AST, который строит DSL.
  Все бекенды неизменны. Грамматика — это фронтенд, а не редизайн.
```

**Сигналы готовности к Фазе 3:**
- DSL стабилен ≥ 3–6 месяцев без breaking changes
- 2–3 реальных приложения написаны на DSL
- Список трений Ruby-синтаксиса конкретен и стабилен (см. §4)

До появления этих сигналов работа над грамматикой — преждевременная оптимизация.

---

## §1 Backend-Интерфейс

Backend — единственный шов между языком и выполнением. Явный интерфейс позволяет:
Ruby сегодня, Rust для реального времени завтра, экспорт для формальной верификации
космоса/медицины послезавтра.

```ruby
module Igniter
  module Lang
    # Абстрактный backend. Все бекенды включают этот модуль и реализуют четыре метода.
    module Backend
      # Скомпилировать AST-узел Igniter::Lang в артефакт бекенда.
      # Для Ruby backend создаёт frozen CompiledGraph.
      # Для Rust backend создаёт нативный байткод.
      # @param  ast  [Igniter::Lang::AST::Contract]
      # @return [CompiledArtifact]
      def compile(ast) = raise NotImplementedError

      # Выполнить скомпилированный артефакт с заданными входами.
      # @param  artifact [CompiledArtifact]
      # @param  inputs   [Hash]
      # @return [ExecutionResult]
      def execute(artifact, inputs) = raise NotImplementedError

      # Статическая верификация: проверка типов, анализ инвариантов, манифест
      # хранилища, WCET-анализ (если объявлен deadline:), проверка размерности единиц.
      # Возвращает VerificationReport независимо от результата; вызывающий решает.
      # @param  ast [Igniter::Lang::AST::Contract]
      # @return [Igniter::Lang::VerificationReport]
      def verify(ast) = raise NotImplementedError

      # Экспортировать AST как формальный артефакт для внешнего инструментария.
      # @param  ast    [Igniter::Lang::AST::Contract]
      # @param  format [Symbol]  :aadl | :sysml | :tla_plus | :coq | :sbom | :json_schema
      # @return [String]
      def export(ast, format:) = raise NotImplementedError
    end

    module Backends
      # Бекенд по умолчанию. Оборачивает существующий пайплайн компиляции и рантайм.
      class Ruby
        include Backend
        # compile  → Igniter::CompiledGraph  (существующий компилятор, без изменений)
        # execute  → Igniter::Runtime::Execution  (существующий рантайм, без изменений)
        # verify   → расширяет CompiledGraph проверками Lang-уровня
        # export   → raises NotImplementedError для не-Ruby форматов (пока)
      end

      # Будущее. Расширение Rust через Magnus FFI.
      # compile  → нативный байткод
      # verify   → WCET-анализ, проверка размерности физических единиц
      # export   → AADL, TLA+, Coq
      # class Rust; include Backend; end
    end
  end
end
```

**Выбор бекенда**: настраивается глобально или для конкретного контракта:

```ruby
Igniter::Lang.configure do |c|
  c.backend = Igniter::Lang::Backends::Ruby.new   # по умолчанию
end

# Переопределение для конкретного контракта (полезно для сертифицированного экспорта):
contract :thermal_control, backend: :rust do
  ...
end
```

---

## §2 Каталог Расширений DSL

Восемь групп расширений. Каждая группа независима; могут поставляться инкрементально.
Приоритет соответствует дорожной карте в §5.

---

### Группа 1 — Объекты Временны́х Типов

Новые Ruby-объекты, представляющие `History[T]`, `BiHistory[T]` и иерархию типов
`T ⊑ History[T] ⊑ BiHistory[T]`.

```ruby
# Конструкторы типов — используются как аннотации типов в DSL контрактов
History   = Igniter::Lang::Types::History    # History[T] через History[Money]
BiHistory = Igniter::Lang::Types::BiHistory  # BiHistory[T]
OLAPPoint = Igniter::Lang::Types::OLAPPoint  # OLAPPoint[T, dims]
Forecast  = Igniter::Lang::Types::Forecast   # Forecast[T] для time-travel вперёд

# Обобщённый синтаксис — History[Money] вызывает History.[] (стандартный Ruby-идиом)
# Новый синтаксис не нужен; чистый Ruby.

# Примеры:
input :price_history, History[Money]
input :telemetry,     BiHistory[Kelvin]
```

`History[T]` — не просто маркер: он несёт контракт паттерна доступа, который
информирует манифест требований к хранению бекенда.

---

### Группа 2 — Декларация `store`

Новое ключевое слово DSL верхнего уровня, используемое вне или внутри блока контракта.

```ruby
# Хранилище верхнего уровня (разделяется между контрактами в пространстве имён):
store :price_history, History[Money],
  backend:        :timeseries,
  partition:      :by_product,
  consistency:    :causal,
  replicas:       3,
  seal_after:     { size: 10_000, time: 1.hour },
  write:          :single_writer,
  write_conflict: :last_wins

store :revenue_cube,
      OLAPPoint[Money, { product: String, region: String, month: Date }],
  backend:         :columnar,
  partition:       :by_month,
  source:          :orders,
  materialization: :incremental,
  lag:             30.seconds

store :workflow_log, ExecutionState,
  backend:     :log,
  retention:   90.days,
  idempotency: :content_addressed
```

Декларация `store` питает манифест требований к хранению компилятора.
Ruby backend передаёт манифест рантайму для инстанцирования адаптеров.

---

### Группа 3 — Расширения `invariant`

Расширить существующий DSL `invariant` параметрами `label:`, `severity:` и
`overridable_with:`.

```ruby
# Текущее состояние (уже работает):
invariant "price > 0", on: :price

# Расширенное:
invariant "price > 0",
  on:       :price,
  label:    "PRICE-FLOOR-01",          # трассируемость к документу требований
  severity: :error,                    # :error (вызывает) | :warn (логирует) | :log (метрика)
  message:  "Цена должна быть положительной"

# Переопределяемый инвариант (медицина / авиация — человеческое переопределение с аудитом):
invariant "interactions.none? { |i| i.severity == :contraindicated }",
  on:               :interactions,
  label:            "CG-INTERACTION-01",
  severity:         :error,
  overridable_with: :documented_justification   # переопределение хранится в аудит-трейле BiHistory
```

`severity: :warn` не вызывает исключение — присоединяет объект `Warning` к
`ExecutionResult`. Вызывающий решает: показать, заблокировать или записать.

---

### Группа 4 — Тип Узла `olap`

Новый тип узла в `ContractBuilder`. Декларирует что узел читает из хранилища
`OLAPPoint` и производит `OLAPSlice`.

```ruby
contract :monthly_revenue do
  input :year, Integer

  olap :revenue, OLAPPoint[Money, { product: String, region: String, month: Date }],
    slice:     { year: :year },          # фильтр измерения
    rollup:    :sum,                     # агрегация
    partition: :by_region                # подсказка fanout для cluster scatter-gather

  compute :top_products, with: [:revenue], call: TopProductsAnalyzer

  output :by_region, from: :revenue
  output :leaders,   from: :top_products
end
```

Бекенд получает узел `olap` и знает:
- Для Ruby backend: выполнить против настроенного колонарного хранилища
- Для Rust backend: сгенерировать план параллельного scatter-gather выполнения

---

### Группа 5 — Стабилизация DSL `rule`

Система временны́х правил существует; это стабилизация и прояснение API.
Breaking changes отсутствуют — только аддитивные изменения.

```ruby
# Полная декларация правила (стабилизированный API):
rule :weekend_manager_price do
  applies_to :price                     # какой узел контракта изменяет это правило
  applies:   -> { as_of.saturday? || as_of.sunday? }
  compute:   -> (price) { price * 1.15 }
  priority:  10
  combines:  :override                  # :override | :additive | :clamp_min | :clamp_max
end

# Вероятностное правило (из спецификации temporal-deep):
rule :demand_surge_price do
  applies_to :price
  ~applies:  -> { demand_model.surge_probability(as_of) }   # префикс ~ = вероятностное
  compute:   -> (price) { price * 1.30 }
  priority:  20
end

# Синтезированное правило (компилятор генерирует из цели):
synthesize rule :optimal_discount do
  goal:     "revenue.maximise subject_to: margin >= 0.20"
  template: -> (price) { price * (1 - discount_rate) }
end
```

---

### Группа 6 — Типы Физических Единиц

Value-объекты представляющие физические единицы. Алгебра единиц на уровне Ruby-объектов;
проверка размерности при компиляции в верификаторе бекенда.

```ruby
module Igniter::Lang::Units
  # Базовые типы единиц — иммутабельные value-объекты, оборачивающие Numeric
  Kelvin   = Data.define(:value) { def +(other) = Kelvin.new(value + other.value) }
  Meter    = Data.define(:value)
  Second   = Data.define(:value)
  Kilogram = Data.define(:value)
  Newton   = Data.define(:value)   # kg⋅m/s²

  # Удобные конструкторы на Numeric:
  #   250.kelvin  →  Kelvin.new(250)
  refine Numeric do
    def kelvin   = Kelvin.new(self)
    def meter    = Meter.new(self)
    def kilogram = Kilogram.new(self)
    def newton   = Newton.new(self)
  end
end

# В контракте:
input  :temperature, Kelvin
input  :mass,        Kilogram

invariant "temperature.value >= 0.0",
  on: :temperature, label: "THERMO-01"

compute :force, with: [:mass, :acceleration],
  call:        ForceCalc,
  return_type: Newton    # верификатор бекенда проверяет размерную согласованность F = ma
```

---

### Группа 7 — Контракты с `deadline:`

Контракты выполнения реального времени. WCET-анализ при компиляции в Rust-бекенде;
мониторинг дедлайнов в рантайме Ruby-бекенда.

```ruby
# Дедлайн уровня контракта:
contract :navigation_step, deadline: 10.milliseconds do
  # Compute-узлы декларируют WCET (наихудшее время выполнения) как документацию —
  # обеспечивается Rust-бекендом когда доступен:
  compute :obstacle_map,     with: [:sensor_fusion], call: ObstacleMapper,    wcet: 2.milliseconds
  compute :path_candidate,   with: [:obstacle_map],  call: PathPlanner,        wcet: 5.milliseconds
  compute :velocity_command, with: [:path_candidate], call: VelocityController, wcet: 1.millisecond

  # Ruby backend: измеряет реальное wall time, добавляет предупреждение :deadline_exceeded
  # Rust backend: статический WCET-анализ при компиляции — отклоняет если критический путь > дедлайна
  ...
end
```

---

### Группа 8 — `time_machine` и `Forecast[T]`

Из документа OLAP. Декларативный time-travel и проецирование вперёд.

```ruby
# Назад (уже выразимо через as_of; здесь делаем явным):
time_machine :price_rewind, on: :price do
  backward { |t| price_history[:as_of t] }
end

# Вперёд — три режима:
time_machine :price_forecast, on: :price do
  forward :deterministic do
    apply_rules_scheduled_after: as_of
  end

  forward :counterfactual do |scenario|
    with_inputs: scenario.overrides
  end

  forward :approximate do
    extrapolate: :linear, horizon: 90.days
  end
end
```

`Forecast[T]` — обёртка: `{ value: ~T, horizon: DateTime, method: Symbol }`.

---

## §3 Существующая Инфраструктура — Что Не Меняется

Ключевое преимущество DSL-first: подавляющее большинство Igniter остаётся нетронутым.

| Компонент | Статус | Примечания |
|-----------|--------|-----------|
| `Igniter::Contract` | Без изменений | Работает как сегодня |
| `ContractBuilder` DSL | Только расширяется | Новые ключевые слова аддитивны |
| `Compiler::GraphCompiler` | Без изменений | Новые типы узлов регистрируются через существующие точки расширения |
| `Runtime::Execution` | Без изменений | Новым типам узлов нужны резолверы |
| `Runtime::Resolver` | Расширяется | Новые резолверы для `:olap`, `:store`, `:time_machine` |
| Actor system | Без изменений | |
| Server / Mesh | Без изменений | |
| Все расширения | Без изменений | |

Существующие контракты, не использующие новые ключевые слова, компилируются и
выполняются идентично. Миграция не требуется.

---

## §4 Лог Трений Ruby DSL — Мотивация для Грамматики

Отслеживать по мере развития DSL. Когда список стабилизируется — он определяет грамматику.

| Трение | Обходной путь в DSL | Решение в грамматике |
|--------|--------------------|--------------------|
| `History[Money]` — не идиоматический Ruby | `History.of(Money)` | `History<Money>` или нативный `History[Money]` |
| Строки инвариантов без IDE-поддержки | Просто строки | `invariant expr` (не строка) с подсветкой синтаксиса |
| `~applies:` с proc-синтаксисом | `~applies: -> { ... }` | `~applies { ... }` блочный синтаксис |
| Арифметика физических единиц в proc'ах | `Newton.new(m * a)` | Инфиксный: `mass * acceleration : Newton` |
| Аннотация типа возврата `compute` | `return_type: Newton` kwarg | `compute :force → Newton { ... }` |
| Блок `rule` внутри тела контракта | Отдельная декларация верхнего уровня | `within contract :x rule :y { ... }` |
| Нет системы import / namespace | Ruby `require` + модули | `import Igniter::Lang::Units::*` |

**Правило**: добавлять в лог только когда реальный use case порождает неудобный DSL.
Не добавлять теоретические записи. Дизайн грамматики определяется реальными трениями,
а не эстетическими предпочтениями.

---

## §5 Дорожная Карта Реализации

### Итерация 1 — Фундамент (~400 строк кода)

- Модуль `Igniter::Lang::Backend` + обёртка `Igniter::Lang::Backends::Ruby`
- Объекты типов `Igniter::Lang::Types::History`, `BiHistory`, `OLAPPoint`, `Forecast`
- Структура `Igniter::Lang::VerificationReport`
- Конфигурация `Igniter.lang_backend=`
- Тесты: контракт backend-интерфейса выполнен Ruby-бекендом

Результат: `require "igniter/lang"` загружает фундамент; все существующие спеки проходят.

### Итерация 2 — Ключевые Расширения DSL (~600 строк кода)

- Ключевое слово `store` в DSL (Группа 2)
- Расширения `invariant`: `label:`, `severity:`, `overridable_with:` (Группа 3)
- Тип узла `olap` + резолвер (Группа 4)
- Стабилизация DSL `rule` (Группа 5)
- Манифест требований к хранению, генерируемый компилятором

Результат: `store`, `invariant label:` и `olap` доступны в контрактах.
`VerificationReport` включает манифест хранилища и карту покрытия инвариантов.

### Итерация 3 — Доменные Расширения (~500 строк кода)

- Типы физических единиц: `Kelvin`, `Meter`, `Kilogram`, `Newton` + рефайнменты `Numeric` (Группа 6)
- `deadline:` на контрактах + `wcet:` на compute-узлах (Группа 7)
- Ruby backend: мониторинг дедлайнов в рантайме → предупреждение `DeadlineMissed`
- DSL `time_machine` + тип `Forecast[T]` (Группа 8)

Результат: DSL-наброски из отчёта валидации (наука/робот./космос/медицина) полностью
запускаемы на Ruby-бекенде.

### Итерация 4 — Грамматический Фронтенд (когда лог трений стабилизируется)

- Выбор парсер-инструмента: `Racc` (stdlib, нет зависимостей) vs `Parslet` (чистый PEG, одна зависимость)
- Парсер создаёт узлы `Igniter::Lang::AST::*` — те же структуры, что строит DSL
- Компилятор принимает и AST (от парсера), и вывод DSL-builder
- Файлы `.il` используются наряду с `.rb` контрактами
- Все бекенды неизменны

**Racc** — выбор по умолчанию: нет новых зависимостей, проверен в Ruby stdlib и MRI.
`Parslet` приемлем если грамматика требует PEG-семантики (значимые пробелы, сложные lookaheads).

### Итерация 5 — Rust Backend (когда нужно реальное время или сертификация)

- Rust crate: `igniter-lang-compiler` (публикуется отдельно)
- Ruby gem: `igniter-lang-rust` — обёртка Magnus FFI
- Реализует интерфейс `Backend`: `compile`, `verify` (с WCET), `export` (AADL, TLA+)
- Проверка размерности физических единиц при компиляции
- Контракты `deadline:` верифицируются статически (WCET критического пути ≤ дедлайна)

---

## §6 Формальные Тождества из Реализации

Реализация подтверждает теоретические тождества из более ранних документов:

```
Вызов ContractBuilder   ≡  Построение AST-узла
                            (DSL и парсер создают идентичные AST)

Декларация store        ≡  Contract({}) → Store[T]
                            (store сам является контрактом без входов)

invariant label:        ≡  Именованное утверждение уточняющего типа
                            (label — имя типа в пространстве имён требований)

Backend.verify(ast)     ≡  Компилятор как верификатор
                            (PTIME для Horn-фрагмента, согласно документу инвариантов)

Backend.export(ast, :aadl) ≡  Сертифицированный экспорт
                            (артефакт компиляции И ЕСТЬ формальная спецификация)

Ruby backend            ≡  Референсная семантика
Rust backend            ≡  Оптимизированная семантика с тем же наблюдаемым поведением
```

---

## §7 Не-Цели

- **Без monkey-patching пользовательских классов.** Все расширения opt-in через
  `include` или явные вызовы DSL. Рефайнменты `Numeric` для единиц используют
  `refine` (scoped), а не `class Numeric`.

- **Без новых runtime-объектов в горячем пути.** Объекты типов `History[T]` и
  `BiHistory[T]` существуют только в фазе определения (компиляция). В рантайме
  значения — обычные Ruby-объекты; тип находится в скомпилированном графе,
  а не в каждом значении.

- **Без грамматики до сигналов.** Итерация 4 не начинается пока лог трений не был
  стабильным хотя бы для одного реального приложения. Написание грамматики для
  ещё изменяющейся спецификации — это расточительство.

- **Без Rust-бекенда без реального use case реального времени или сертификации.**
  Итерация 5 требует конкретного use case (реальный проект робототехники, реальная
  наземная система для космоса, реальная сертификация медицинского устройства)
  для обоснования стоимости поддержки.
