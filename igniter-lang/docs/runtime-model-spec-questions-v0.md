# Igniter-Lang: Runtime Model Specification Questions v0

Status: research / forward spec
Date: 2026-05-05
Author: `[Igniter-Lang Compiler/Grammar Expert]`
Supervisor: `[Architect Supervisor / Codex]`
Context: Ahead of a real compiler. Ruby simulation is a proof harness only.

---

## Preface

The six questions below are not implementation details. They are
**language identity questions**. The answers commit Igniter-Lang to a
specific semantics that must be consistent with the core thesis:

```text
Epistemic Contract Language:
  typed contract + explicit time + observable evidence
  + lifecycle constraints + capability gates
  = justified, auditable, reproducible computation
```

Every answer to these questions must reinforce, not contradict, that thesis.

---

## I. Переменные / Binding Model

### Вопрос

Есть ли в Igniter-Lang переменные? Можно ли изменить значение после привязки?

### Ответ: Bindings, not variables

В Igniter-Lang нет переменных в традиционном смысле — **только именованные
привязки** (bindings). Привязка создаётся однажды и не изменяется.

```text
let sum = a + b        -- создаёт привязку sum: нельзя sum = sum + 1
let x = f(y)          -- привязка результата функции
```

**[D] Однозначное присваивание (Single Assignment)**

Каждое имя в каждом лексическом контексте привязывается ровно один раз.
Переприсваивание — ошибка компиляции.

```text
let x = 1
let x = 2    -- ОШИБКА: x уже привязана в этом контексте
```

### Почему это правильный выбор

**Аргумент из ECL-тезиса**: каждый `value_observation` должен быть
воспроизводим при тех же входных данных и `as_of`. Если значение может
измениться между двумя обращениями к одному имени — воспроизводимость
нарушается. Мутабельные переменные несовместимы с CORE-фрагментом.

**Аргумент из observation model**: наблюдение производится ровно один раз
для конкретного состояния вычисления. Мутабельное состояние потребовало бы
либо отдельного наблюдения на каждое изменение (накладно), либо молчаливого
скрытия изменений (нарушает epistemic инвариант).

**Следствие для ESCAPE**: ESCAPE-операции могут возвращать новые значения
после вызова, но эти значения тоже привязываются однажды. Нет `x += 1`
внутри FFI-обёртки. Изменяемое внешнее состояние отражается как новое
значение при следующем `read` с новым `as_of`.

### Изменяемые данные в модели

Изменяемое состояние существует — но **за границей языка**, в TBackend.
Язык читает его через `read` с явным `as_of`. Каждое чтение — новая привязка.

```text
-- Два чтения в разные моменты времени:
read geo_t1: Collection[GeoSignal] from "geo_signal/..." as_of t1
read geo_t2: Collection[GeoSignal] from "geo_signal/..." as_of t2

-- geo_t1 и geo_t2 — разные привязки, разные наблюдения.
-- Нет мутации: есть временны́е срезы.
```

---

## II. Область видимости / Scoping

### Вопрос

Где имена видны? Что закрывается в замыканиях? Как модули изолируют имена?

### Ответ: три уровня лексической области видимости

```text
Уровень 1: Module scope
  Имена TypeDecl, FunctionDecl, ContractDecl видны внутри модуля.
  Другой модуль видит их только через явный import.

Уровень 2: Contract scope
  InputDecl, ReadDecl, ComputeDecl, SnapshotDecl видны внутри ContractDecl.
  Порядок не важен — компилятор строит DependencyGraph до оценки имён.

Уровень 3: Expression scope (def body / lambda)
  let-привязки и параметры функции видны от точки определения до конца body.
  Нет hoisting. Нет теневых имён (shadowing запрещён в strict mode).
```

**[D] Нет динамической области видимости**

Igniter-Lang — строго лексически видимый язык. Нет `Thread.current`, нет
`*global`, нет implicit context propagation. Контекст передаётся явно через
параметры (включая `TemporalCtx`).

**[D] Замыкания — ограниченные**

Lambda-выражения в `fold`/`map`/`filter` могут захватывать привязки из
внешней области видимости, но только CORE-значения (не TBackend-читаемые
и не ESCAPE). Замыкание не может захватить TemporalCtx из внешнего контекста
(это означало бы неявную передачу времени — нарушение PROP-014 C-2).

```text
-- РАЗРЕШЕНО: замыкание захватывает константу из внешней области
let threshold = 10
filter(slots, slot -> slot.hour > threshold)   -- OK: threshold это CORE-значение

-- ЗАПРЕЩЕНО: замыкание захватывает ctx из внешней области
let ctx = temporal_ctx
fold(items, [], (acc, x) -> acc ++ [now(ctx)])  -- OOF: ctx должен быть явным параметром
```

**Следствие**: замыкания в Igniter-Lang — это чистые функции с захватом
только иммутабельных CORE-значений. Это делает их безопасными для параллельного
выполнения (см. раздел V).

---

## III. Управление памятью / Memory Ownership

### Вопрос

Кто владеет памятью? Нужен ли stack/heap разделитель? Есть ли явная
аллокация/деаллокация?

### Ответ: Наблюдение как единица памяти

Igniter-Lang не имеет явного управления памятью на уровне языка. Нет
`malloc`/`free`, нет `new`/`delete`, нет `Box<T>`. Причина: языковая
единица — **наблюдение** (`ObsPacket`), а не объект в куче.

```text
Время жизни значения = время жизни наблюдения = lifecycle класс:
  :local    -> flush after expression evaluation
  :session  -> survive until SemanticImage
  :window   -> survive until BoundaryReceipt
  :durable  -> explicit compaction policy
  :audit    -> preserve always
```

### Два уровня: evaluation stack и observation store

```text
Evaluation stack (compiler-managed):
  Временные вычисления внутри def/compute node.
  Живут ровно столько, сколько нужно для вычисления.
  Компилятор управляет ими без участия языка.

Observation store (TBackend-managed):
  ObsPacket с lifecycle. Явного owner нет — TBackend реализует политику.
  Язык декларирует lifecycle; TBackend выполняет retention/compaction.
```

**[D] Value semantics, not reference semantics**

Все значения в Igniter-Lang — это значения (value semantics), не ссылки
(reference semantics). Передача `Collection[T]` в функцию — семантически
полная копия. Компилятор может оптимизировать это до zero-copy sharing,
но язык не различает копирование и sharing.

Следствие: нет aliasing, нет dangling references, нет use-after-free.

### Контракт на память с native backend (LLVM)

Для native backend (PROP-012) правила:

```text
CORE compute nodes:
  Stack-allocatable если размер известен statically.
  Heap-allocatable для Collection[T] с динамическим размером.

ESCAPE FFI calls:
  Входные данные: языковые значения, передаются в native buffer.
  Выходные данные: receipt payload аллоцируется языком, не хостом.
  Host memory не может утечь в языковую область (typed boundary).
```

---

## IV. Сборщик мусора / GC Model

### Вопрос

Нужен ли GC? Если да — какая модель? Как сочетается с lifecycle-семантикой?

### Ответ: Двухуровневый GC — evaluation GC + semantic GC

Igniter-Lang требует **двух разных механизмов** утилизации памяти.
Их нельзя объединить в один.

---

#### Уровень 1: Evaluation GC (runtime / RAII-подобный)

Внутри вычисления (def body, compute node) временные значения освобождаются
детерминированно после завершения вычисления. Это не сборка мусора в
традиционном смысле — это **детерминированное освобождение**.

```text
Модель: region-based memory (или RAII-подобная).
  Каждый compute node открывает region.
  После производства output observation — region освобождается.
  Нет циклических ссылок (DAG-граф), нет нужды в mark-and-sweep.
```

**[D] Детерминированный evaluation GC — возможен**

Потому что:
- Граф вычислений — DAG (нет циклов)
- Нет мутабельных ссылок (нет aliasing)
- Время жизни каждого значения ограничено его compute node

→ Компилятор может доказать время жизни статически. GC не нужен
для evaluation — достаточно region-based allocation.

---

#### Уровень 2: Semantic GC (TBackend / lifecycle-based)

Это **не** runtime GC. Это политика удержания наблюдений, управляемая
TBackend согласно lifecycle-классу (PROP-010).

```text
Semantic GC roots (из PROP-010):
  - Все :durable наблюдения — GC root до явного compaction
  - Все :audit наблюдения — permanent GC root
  - SemanticImage — GC root для текущего сеанса
  - BoundaryReceipt — GC root для window boundary

Semantic GC sweep:
  - :local наблюдения → flush после evaluation завершения
  - :session наблюдения → flush после SemanticImage checkpoint
  - :window наблюдения → compact после BoundaryReceipt

DR-1..DR-5 (PROP-010) — это правила downgrade для semantic GC.
```

**[D] Semantic GC — это язык, не runtime**

Жизненный цикл наблюдений декларируется в языке (lifecycle annotation).
TBackend исполняет политику. Это значит:

- Нет stop-the-world GC паузы в language runtime
- GC наблюдений — асинхронный TBackend-процесс
- Language runtime никогда не блокируется на compaction

→ Для language runtime: RAII/region для evaluation. Zero GC pauses.

---

#### Сравнение с известными моделями

| Модель | Подходит? | Причина |
|--------|-----------|---------|
| Stop-the-world GC (JVM) | Нет | Нарушает temporal determinism (GC pause меняет `as_of` чувствительность) |
| Reference counting (Swift/Rust) | Частично | Нет циклов в DAG → работает, но избыточно |
| Region-based (Cyclone) | Да | Точно соответствует compute node lifetime |
| Ownership (Rust) | Да | Value semantics + DAG → статические lifetime доказательства |
| Semantic GC (язык-специфичный) | Да | Для ObsPacket lifecycle |

**[R] Цель**: region-based evaluation (RAII-подобный) + ownership для
native backend (статически доказуемый). Традиционный GC не нужен.

---

## V. Параллелизм / Concurrency Model

### Вопрос

Могут ли контракты выполняться параллельно? Как CORE/ESCAPE влияет
на параллельное выполнение? Есть ли разделяемое состояние?

### Ответ: Structural parallelism из DAG + ESCAPE boundary

Это самый интересный ответ из шести.

---

#### CORE — структурный параллелизм по умолчанию

Граф CORE-вычислений — DAG. Узлы без зависимостей друг от друга могут
выполняться параллельно без координации.

```text
contract DispatchRanking {
  input technician_list: Collection[TechnicianId]

  compute scores = map(technician_list, t -> score(t))
    -- score(t) для каждого t независимы -> параллельно

  compute ranked = sort_by(scores, s -> s.score)
    -- зависит от scores -> последовательно после scores

  output ranked: Collection[RankedTechnician]
}
```

Компилятор видит зависимости в DependencyGraph и может автоматически
параллелизовать независимые ветки.

**[D] CORE параллелизм безопасен по конструкции**

Потому что:
- Нет мутабельного состояния (нет data races)
- Нет shared memory (value semantics)
- DAG → нет deadlocks (нет циклических зависимостей)
- Детерминированные функции → результат не зависит от порядка

→ Компилятор может параллелизировать CORE без явных аннотаций.

---

#### map/fold — явный параллелизм над коллекциями

```text
-- Неформальная семантика (компилятор решает реализацию):

map(collection, f)
  -- если collection.count > threshold -> parallel map
  -- если f является CORE и stateless -> всегда safe to parallelize

fold(collection, init, f)
  -- fold НЕ параллелизуем по умолчанию (зависимость acc от предыдущего шага)
  -- parallel fold возможен если f коммутативна и ассоциативна
  -- явная аннотация: fold_commutative(c, init, f) -> parallel safe
```

**[Q] Нужна ли явная аннотация `@parallel` или компилятор решает автоматически?**
Recommendation: автоматически для CORE, явная аннотация для ESCAPE.

---

#### ESCAPE — параллелизм с coordination

ESCAPE-вызовы к внешним системам не могут параллелизоваться молча:

```text
-- Два независимых ESCAPE вызова к одной системе:
read orders_a from "orders/A" lifecycle :window
read orders_b from "orders/B" lifecycle :window

-- Можно ли их выполнять параллельно? Да — они независимы.
-- Но capability check и intent_observation должны быть per-call.
-- Нет shared state между ними -> safe.

-- НЕЛЬЗЯ параллелизировать:
call assign_technician(order: A, tech: t1)
call assign_technician(order: A, tech: t2)
-- Оба пишут в одну запись -> capability gate должен сериализовать.
```

**[D] ESCAPE параллелизм контролируется capability gate**

Если два ESCAPE вызова требуют одного ресурса (capability `dispatch_assign`
для одного `order_id`) — gate может реализовать mutex/lock.
Язык декларирует намерение; gate решает политику сериализации.

---

#### Нет shared mutable state в языке

Igniter-Lang не имеет механизмов для разделяемого изменяемого состояния:
нет `Mutex`, нет `Channel`, нет `Actor`. Всё разделяемое состояние — в
TBackend, доступ через `read` с явным `as_of`. TBackend отвечает за
consistency model (PROP-008: `min_consistency: strong/eventual`).

```text
Модель параллелизма: CSP-подобная, но без явных каналов.
  Контракты общаются через TBackend-факты, не через прямые сообщения.
  Нет горутин, нет akka-акторов. Параллелизм — структурный, из DAG.
```

---

#### Планировщик и RuntimeContract

RuntimeContract.scheduler (PROP-006) определяет:
- inline runner (последовательный, без потоков)
- thread_pool runner (параллельный CORE)
- distributed runner (ESCAPE через capability)

Выбор runner — не языковая конструкция. Это конфигурация RuntimeMachine.
Программа одинаково корректна при любом runner.

**[D] Корректность не зависит от выбора runner — только производительность**

Это фундаментальная гарантия: CORE-программа детерминирована независимо от
того, выполняется ли она в одном потоке или в пуле. Это возможно только
благодаря immutable bindings + value semantics + DAG.

---

## VI. Самокомпилируемость / Self-Hosting

### Вопрос

Может ли Igniter-Lang компилировать себя? Какой путь к self-hosting?

### Ответ: Self-hosting — цель, но не первый шаг

Самокомпилируемость — важный сигнал зрелости языка. Но она требует
нескольких условий, которых сейчас нет:

```text
Требования для self-hosting:
  1. Язык должен иметь достаточную выразительность для написания компилятора
  2. Существующая реализация (bootstrap compiler) способна скомпилировать сам язык
  3. Stdlib достаточна для строковой обработки, IO, парсинга
  4. FFI достаточен для взаимодействия с ОС (файловая система, STDIN/STDOUT)
```

---

### Этапы пути к self-hosting

**Stage 0 (сейчас): Ruby bootstrap harness**
```text
RuntimeMachine (Ruby) + CompiledProgram (Ruby) + hand-authored .igapp/
  -> proves semantics, not syntax
  -> not a compiler
```

**Stage 1: Ruby bootstrap compiler**
```text
Ruby parser -> ParsedProgram -> ClassifiedProgram -> TypedProgram -> SemanticIR
  -> outputs .igapp/ artifacts
  -> acceptance test: parser(add.ig) == fixtures/add.igapp/
```

**Stage 2: Igniter-Lang interpreter (в Igniter-Lang)**
```text
Написать интерпретатор для .igapp/ SemanticIR на Igniter-Lang.
  -> требует: stdlib string, Collection, Result, IO через FFI
  -> SemanticIR это JSON -> требует JSON parser (stdlib или FFI)
  -> это первая программа на Igniter-Lang, читающая Igniter-Lang артефакты
```

**Stage 3: Compiler frontend в Igniter-Lang**
```text
Написать parser (PROP-015 grammar) на Igniter-Lang.
  -> требует: String operations, Collection, recursive parsing
  -> Рекурсивный парсер -> fold_until для стека, не рекурсия (нет self-call в CORE)
  -> Парсер как набор контрактов: parse_expr, parse_decl, etc.
  -> Каждый контракт принимает (source: String, pos: Integer) -> Result[ParsedNode, ParseError]
```

**Stage 4: Full compiler pipeline в Igniter-Lang**
```text
ParsedProgram -> ClassifiedProgram -> TypedProgram -> SemanticIR
  -> выходные данные: .igapp/ JSON (stdlib IO FFI)
  -> bootstrapped: Ruby компилятор компилирует Igniter-Lang компилятор
  -> результат: компилятор на .igapp/ который запускается на RuntimeMachine
```

**Stage 5: Native self-hosting**
```text
LLVM backend (PROP-012) компилирует .igapp/ компилятора в native binary.
  -> результат: native igniterc бинарник
  -> self-hosting: igniterc может скомпилировать сам себя
```

---

### Ключевой вызов: рекурсивный парсер без рекурсии

Парсер — классически рекурсивная программа. В Igniter-Lang нет рекурсии
(OOF-G1). Как написать парсер без рекурсии?

```text
Решение: итеративный парсер с явным стеком.

parse_program(source: String) -> Result[ParsedProgram, ParseError] {
  let state = { tokens: tokenize(source), stack: [], output: [] }

  -- Итеративный Pratt parser или LR parser с явным стеком:
  fold_until(state.tokens, state, (state, token) -> {
    let new_state = apply_parser_rule(state, token)
    if new_state.done { Err(new_state) }  -- fold_until early exit
    else { Ok(new_state) }
  })
}
```

`fold_until` с явным стеком реализует продвинутый парсер без рекурсии.
Это нетривиально, но доказуемо возможно (LR/LALR парсеры уже итеративны
по конструкции). Это не ограничение, а дисциплина.

---

### Сигнал: ECL как язык для систем с доказуемыми свойствами

Self-hosting самый интересен не технически, а семантически:

```text
Компилятор Igniter-Lang написан в Igniter-Lang:
  - Каждый шаг компиляции является контрактом с typed inputs/outputs
  - Каждая ошибка компиляции — failure_observation с reason_code
  - Каждый проход (Pass 0/1/2) — отдельный contract с observable доказательством
  - Вся цепочка компиляции — auditable observation chain

Что это означает: компилятор, который компилирует сам себя,
оставляет доказуемый аудит-след от исходника до артефакта.
```

**[D] Self-hosting Igniter-Lang — это первый компилятор с полным
epistemic evidence chain от источника до артефакта.**

Никакой другой язык не может утверждать то же самое, потому что ни один
другой язык не делает observation первоклассным типом.

---

## Итоговая таблица

| Вопрос | Решение | Принцип |
|--------|---------|---------|
| Переменные | Immutable bindings (let) | Single assignment; воспроизводимость |
| Область видимости | Лексическая, 3 уровня; нет динамики | Явная передача контекста |
| Управление памятью | Value semantics; region-based evaluation | Нет aliasing; DAG lifetime |
| Сборщик мусора | Region GC (evaluation) + Semantic GC (TBackend) | Нет stop-the-world |
| Параллелизм | Structural (DAG) + capability-gated ESCAPE | Нет shared mutable state |
| Self-hosting | Stage 1→5; итеративный парсер через fold_until | ECL audit trail от источника |

---

## Open Questions

[Q-1] Должен ли компилятор автоматически параллелизировать независимые
CORE-ветки, или нужна явная `@parallel` аннотация?

[Q-2] Нужен ли `fold_commutative` как отдельный примитив для параллельного
fold (map-reduce), или это должно быть аннотацией на обычном fold?

[Q-3] Ownership (Rust-подобный) vs region-based (Cyclone-подобный) для
native backend — какая модель лучше подходит к DAG-структуре?

[Q-4] IO в stdlib: для Stage 2 self-hosting нужен JSON parser и file IO.
Это ESCAPE FFI с `host_lang: :native`? Или отдельная stdlib категория?

[Q-5] Bootstrapping split: будет ли Ruby компилятор (Stage 1) частью
официального toolchain навсегда, или он отбрасывается после Stage 4?

---

## Ссылки

- PROP-001: Semantic Domain (V, T, Tt, C, Expr, O, F)
- PROP-003: Fragment Classification (CORE/ESCAPE/OOF)
- PROP-004: Type System (structural types, Projection[T,horizon])
- PROP-004b: Axiom Layer (Tier 1 stdlib, value semantics)
- PROP-008: TBackend Contract (consistency model, reproducible resume)
- PROP-010: Temporal Lifecycle (DR-1..DR-5, semantic GC roots)
- PROP-012: CompiledProgram, native backend, FFI discipline
- PROP-013: fold/fold_until, TR-1 termination rule
- PROP-015: Grammar (def non-recursive, let single-assignment)
