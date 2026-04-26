# Igniter — Стратегический Экспертный Отчёт

Date: 2026-04-26.
Perspective: эксперт в распределённых агентных системах, enterprise-архитектуре, и AI-нативных платформах.
Subject: стратегический анализ Igniter — где он сейчас, чем может стать, и как туда попасть.

---

## 1. Визионерский Взгляд

### 1.1 Смена парадигмы, которую Igniter может захватить

Мы живём в переломный момент в программировании. Не потому что появились LLM —
а потому что **меняется форма самого приложения**.

Классическое enterprise-приложение — это request/response машина: пришёл запрос,
отработала бизнес-логика, вернулся ответ. Всё синхронно, всё атомарно, всё живёт
меньше секунды. Rails был идеален для этой формы.

Новое enterprise-приложение — это другое. Это:

> Долгоживущие, проактивные, интерактивные процессы, где люди и AI-агенты
> совместно работают над задачами, которые длятся минуты, часы, дни.

Это инцидент-менеджмент, где агент мониторит систему и инициирует диалог с
дежурным инженером. Это onboarding-платформа, где агент ведёт нового сотрудника
через 40-шаговый wizard, и может приостановиться на 3 дня пока кто-то подписывает
документ. Это compliance-сценарий, где агент и человек совместно проводят аудит,
каждый шаг которого логируется и верифицируется.

**Igniter — это единственный Ruby framework, который спроектирован для этой
новой формы приложения.**

Не Rails — там нет ни агентного рантайма, ни долгоживущих сессий, ни capsule
supply chain. Не просто LLM wrapper — там нет contracts, нет compile-time
validation, нет enterprise-grade доставки. Igniter стоит в уникальной позиции.

Вопрос не в том, нужен ли миру такой инструмент. Нужен — очевидно. Вопрос в том,
**станет ли Igniter тем, кто занимает эту позицию первым и убедительно.**

### 1.2 Что значит "значимый enterprise-проект"

Значимый — не значит популярный. Значимый означает:

1. **Уникальная ниша**: область, где нет достойной альтернативы
2. **Доверие**: enterprise покупает то, в что верит — audit trail, явные
   контракты, refusal-first design, receipt chain
3. **Производительность**: разработчики должны уметь строить то, что без Igniter
   строить мучительно
4. **Референсные клиенты**: один убедительный case study дороже ста звёздочек
   на GitHub

Igniter уже имеет архитектурную основу для #1. Capsule Transfer закладывает
основу для #2. Authoring experience пока не на уровне #3. #4 ещё не начато.

---

## 2. Идея, Модель, Усиление

### 2.1 Ядро Igniter — редкая вещь

Contracts как validated dependency graphs — это не просто техническая фича.
Это **другой способ думать о бизнес-логике**.

В большинстве фреймворков бизнес-логика живёт как процедурный код: делаем A,
потом B, потом C. Игнорируем зависимости, пока не приходит производственная
авария. Igniter говорит: сначала объяви граф зависимостей. Компилятор проверит
его до запуска. Рантайм выполнит только то, что нужно, с кешированием и
инвалидацией.

Это не "ещё один способ написать бизнес-логику". Это **compile-time safety для
бизнес-правил** — вещь, которой в Ruby-экосистеме раньше не было.

```
Contracts Kernel
├── Compile-time: граф валидирован до запуска
├── Runtime: ленивое выполнение, только нужные узлы
├── Cache: TTL + coalescing + fingerprinting
└── Zero production deps: встраивается куда угодно
```

### 2.2 Три уровня ценностного предложения

Igniter работает на трёх независимых уровнях, и это сила:

**Уровень 1: Contracts Kernel (embed mode)**
Встраивается в любой Ruby-проект. Никаких зависимостей. Validated dependency
graphs для бизнес-логики. Ценность: предсказуемость + debuggability. Покупатель:
разработчик, который устал от "почему это вычислилось неправильно".

**Уровень 2: Application Platform (agent-native apps)**
Полноценный рантайм для интерактивных агентных приложений. Capsule model,
Ignite lifecycle, web surfaces, proactive agents. Ценность: строй сложные
human-AI apps без бесконечного glue-кода. Покупатель: команда, которая строит
SaaS с AI-ассистентами.

**Уровень 3: Enterprise Supply Chain (capsule transfer)**
Verifiable, auditable, refusal-first доставка приложений между хостами. Receipt
chain, activation evidence, compliance gates. Ценность: enterprise-grade
deployment под надзором агентов. Покупатель: CTO / DevOps Lead в regulated
industry.

Три уровня — три независимые точки входа. Разработчик начинает с Level 1,
компания вырастает до Level 2, enterprise требует Level 3.

### 2.3 Усиление через Agent-as-First-Class-Citizen

Главная идея, которую нужно провести через весь Igniter:

> Агент — это не вызов API. Агент — это участник системы с тем же статусом,
> что и пользователь или сервис.

Это означает:
- Агент может инициировать диалог (proactive wakeup)
- Агент может запросить структурированный ввод (pending input)
- Агент может подождать (await в distributed contracts)
- Агент может быть проверен (activation evidence)
- Агент может быть доставлен (capsule transfer)

Ни один другой Ruby framework не думает об агентах в таких терминах. Это
уникальное конкурентное преимущество.

---

## 3. Развитие Перспективы

### 3.1 Где Igniter сейчас — честная карта

```
MATURE (production-ready, impressive):
├── Contracts kernel — DSL, compile, runtime, cache, coalescing
├── Diagnostics — text/markdown/structured formatters
├── Extensions — saga, differential, provenance, invariants
└── Transfer Chain — 14 шагов, end-to-end verified

SOLID (working, needs polish):
├── AI/LLM/Tool/Skill system — canonical Igniter::AI::* namespace
├── Actor system — Agent/Supervisor/Registry/StreamLoop
├── Server/Mesh — static/dynamic/gossip, Prometheus SD, K8s probes
└── Capsule Activation — dry-run + commit-readiness verified

EMERGING (POC-level, exciting but incomplete):
├── Interactive web surfaces — igniter-web, Arbre, POC board accepted
├── Ignite lifecycle — bootstrap/join/detach/re-ignite skeleton
├── Flow/Session model — FlowSessionSnapshot, PendingInput landed
└── Application::Kernel/Profile/Environment — prototype exists

DESIGN PHASE (docs-only, not yet implemented):
├── Activation Evidence & Receipt (current active track)
├── Activation Commit (Phase 3, blocked until evidence shapes defined)
└── Enterprise Orchestration (Phase 6, vision only)
```

### 3.2 Три критических разрыва

**Разрыв #1: Developer Experience**

Сегодня для hello-world интерактивного приложения нужно 5 файлов, понимание
4 пакетов и 30 минут чтения документации. Это неприемлемо для adoption.

Цель: один файл, один `Igniter.interactive_app` block, две строки в `config.ru`.
Это возможно — архитектура позволяет. Нет только authoring facade поверх
уже существующих правильных примитивов.

**Разрыв #2: Showcase / Reference App**

Igniter не имеет ни одного публичного впечатляющего примера, который можно
показать потенциальному пользователю и сказать "смотри, вот что это делает".

`examples/companion` — правильный кандидат. Но он должен быть не заглушкой,
а настоящим работающим приложением с проактивным агентом, wizard-flow,
live-обновлениями и LLM integration. Это не дополнительная фича — это
**маркетинговый артефакт**.

**Разрыв #3: Enterprise Story не дорассказана**

Capsule Transfer — готов. Activation review — готов. Но нет документа,
который говорит enterprise-buyer'у: "вот как Igniter решает твою проблему
с compliance, audit, и agent-supervised deployment". Phase 6 (Enterprise
Orchestration) остаётся 7 строками в roadmap.

### 3.3 Траектория к значимости

```
2026 Q2: Foundation Complete
├── Evidence & Receipt track closed
├── Activation commit (Phase 3) opened and scoped
└── interactive_app facade — POC shipped

2026 Q3: Showcase Moment
├── examples/companion — полноценное reference app
├── Igniter.interactive_app public API stable
├── SSE/WebSocket push (первый класс)
└── Enterprise Orchestration vision doc

2026 Q4: Enterprise Credibility
├── Capsule Transfer — Phase 4 (activation receipt)
├── First real adoption case — companion/home-lab → production
├── Compliance story documented
└── MCP Adapter package (AI tooling integration)

2027: Meaningful Position
├── Capsule marketplace concept
├── Multi-tenant capsule delivery
└── Agent-supervised compliance gates (regulatory)
```

---

## 4. Рекомендации

### 4.1 ПРИОРИТЕТ #1: Сделать `Igniter.interactive_app` реальностью

Это самое высокоприоритетное техническое решение. Не потому что это сложно —
а потому что без него проект остаётся invisible для потенциальных пользователей.

Что нужно:
```ruby
# Вот что разработчик должен написать
App = Igniter.interactive_app :my_app do
  service :tasks, Services::TaskService

  agent :coordinator, Agents::Coordinator do
    wakeup every: 60, if: -> { tasks.has_pending? }
  end

  surface :workspace, at: "/"
  endpoint :stream, at: "/stream", format: :sse
end

# И в config.ru:
run App.rack_app
```

Эта facade уже спроектирована в `expert-review.md`. Примитивы уже существуют.
Нужен только тонкий delegation layer.

Acceptance: `examples/companion/app.rb` умещается в один экран.

### 4.2 ПРИОРИТЕТ #2: examples/companion как настоящее приложение

`examples/companion` должен стать flagship reference app. Не smoke test, не
заглушка — работающее впечатляющее приложение:

- Проактивный агент (мониторит задачи, инициирует диалог)
- Wizard flow (multi-step structured interaction)
- Live-обновления (SSE push, не polling)
- LLM-powered tool loop (реальный вызов Anthropic/OpenAI)
- Capsule packaging + transfer demonstration

Это должен быть ответ на вопрос: "Можете показать Igniter в действии?" — "Да,
запусти `ruby examples/companion/app.rb`."

Без этого артефакта нет adoption. Без adoption нет significance.

### 4.3 ПРИОРИТЕТ #3: SSE/WebSocket — первый класс, не afterthought

Сейчас interactive POC использует polling (GET /events). Это неприемлемо для
production. Проактивный агент завершил задачу — пользователь должен увидеть
это немедленно, без 5-секундного polling интервала.

Рекомендуемая модель:
```ruby
endpoint :stream, at: "/stream", format: :sse do
  emit :task_created, from: :tasks
  emit :agent_message, from: :coordinator
  emit :suggestion, from: :coordinator
end
```

Rack chunked response + Arbre rendering на клиенте — это достижимо без
внешних зависимостей. Это critical missing piece для "живого" feel.

### 4.4 ПРИОРИТЕТ #4: Enterprise Vision Document

Нужен отдельный документ (или сокращённая landing page версия), который
отвечает на вопрос enterprise buyer'а:

"Почему Igniter, а не [Rails + Sidekiq + custom agents + CI/CD]?"

Ответ существует, но он разбросан по 50 документам:

- **Validated delivery**: capsule transfer с receipt chain — не git push,
  не docker pull, а verifiable chain-of-custody
- **Compliance-ready**: activation evidence, refusal-first design,
  операции только через явный adapter с idempotency key
- **Agent-supervised**: агенты участвуют в delivery как reviewers, не только
  как executors
- **Zero prod deps**: встраивается в любую enterprise среду без vendor lock-in
- **Audit trail**: transfer receipt + activation receipt = два независимых
  свидетельства жизненного цикла

Этот нарратив нужно написать один раз и хорошо.

### 4.5 ПРИОРИТЕТ #5: Не растягивать разработку на бесконечные design tracks

Текущий процесс (research → supervisor → track → docs/design → implementation)
правильный и дисциплинированный. Но есть риск: слишком много design phase,
слишком мало shipped features.

Конкретная проблема: Interactive web POC остановился на "repeatability synthesis".
Это хорошая работа — но где следующий POC slice? Где SSE? Где `flow` primitive?

Рекомендация: каждый завершённый design track должен в течение **2 недель**
порождать хотя бы один implementation slice. Если не порождает — нужно спросить
"зачем мы это проектировали?"

### 4.6 ПРИОРИТЕТ #6: Выбрать и зафиксировать публичный namespace

В документах есть несколько конкурирующих терминов для одних и тех же вещей:
`surface` / `board` / `operator` / `screen` — все используются. `flow` / `wizard`
/ `composition` — все используются.

До v1 это нормально. Но для adoption нужна стабильная документация. Нужно
принять решение по ключевым терминам публичного API и зафиксировать его:

| Термин | Финальное решение |
|--------|------------------|
| Корневой DSL | `Igniter.interactive_app` |
| Экран пользователя | `surface` |
| Долгоживущий процесс | `flow` |
| Взаимодействие с агентом | `chat` |
| Структурированный ввод | `ask` |
| Команда | `action` |
| Реальтайм поток | `stream` |

---

## 5. Инсайты и Идеи

### 5.1 Igniter как "Rails для агентных приложений" — правильный pitch, но неполный

"Rails для агентных приложений" — понятный positioning, и он верный по духу.
Но Rails был силён не только API. Rails был силён **конвенциями, которые
исключали плохие решения**.

Igniter должен сделать то же самое. Примеры "rails-like" принятия решений
за разработчика:

- По умолчанию capsule transfer — не голый git push. Не потому что "фича",
  а потому что это **правильный способ**.
- По умолчанию activation — с evidence packet и receipt. Не потому что
  "enterprise", а потому что **это ожидаемое поведение серьёзного инструмента**.
- По умолчанию сессии долгоживущие и durable. Не потому что "распределённые
  системы", а потому что **современные приложения так работают**.

Conventions > Configuration. Именно это сделало Rails success story.

### 5.2 Contracts Compiler как скрытый секрет проекта

Compile-time validation dependency graphs — это технически невозможно переоценить.
Это то, что делает Igniter quality-gate для бизнес-логики.

Но этот компилятор можно использовать не только для contracts. Capsule dependency
graphs? Тот же компилятор. Flow session graph? Тот же компилятор. Agent tool
dependency graph (agent A зависит от agent B)? Тот же компилятор.

**Идея**: "Universal Graph Compiler" — один компилятор для всех DAG-структур в
Igniter. Это не дополнительная работа, это обнаружение того, что уже есть.
Маркетингово: "весь Igniter — это validated dependency graphs at every layer."

### 5.3 Agent-as-Reviewer — нераскрытый differentiator

В Capsule Transfer агенты будущих фаз будут выступать не только как исполнители
(delivering files), но и как **reviewers** (verifying activation evidence,
checking adapter capability map, signing off on commit).

Это паттерн, который можно расширить на весь Igniter:

- **Contracts**: агент-ревьюер может проверить граф перед запуском
- **Application boot**: агент проверяет provider lifecycle report перед
  тем как app становится active
- **Deployment**: агент проверяет capsule evidence перед activation commit

**"Agent-as-Reviewer" pattern** — это уникальная Igniter-идея, которой нигде
больше нет. Это должно стать именованным паттерном в документации.

### 5.4 The "One Process" Test

Для каждой фичи Igniter применяй простой тест: может ли всё это работать в
**одном Ruby процессе**, без cluster, без docker, без сетевых зависимостей?

Если да — это правильно. Если нет — добавили слишком много зависимостей.

`ruby examples/companion/app.rb` должен запустить полноценное приложение с
агентом, web-surface, и LLM integration — в одном процессе. Это и есть
"zero production dependencies" в действии.

### 5.5 Capsule Marketplace как долгосрочная бизнес-модель

Phase 6 roadmap упоминает "internal app marketplaces". Это достойно более
глубокого исследования.

Capsule + transfer receipt + activation receipt = **верифицируемый артефакт,
который можно опубликовать, найти, перенести и установить**. Это app store для
enterprise Ruby applications.

Аналог: Shopify App Store, но для agent-native enterprise apps. Каждый capsule
в marketplace имеет:
- Manifest (что делает, что требует)
- Transfer history (откуда пришёл)
- Activation receipt (где работает)
- Compliance evidence (что прошёл)

Это не фантастика — это Phase 6, и фундамент уже строится.

### 5.6 MCP Adapter как Immediate Enterprise Bridge

В dev docs уже есть `mcp-adapter-package-spec.md`. MCP (Model Context Protocol)
— это сейчас то, что объединяет AI tooling.

Игра: если Igniter contracts могут быть exposed как MCP tools — то любой
Claude/GPT/agent может вызвать Igniter contract как tool. Это:

- Мгновенная интеграция с AI tooling ecosystem
- Contracts становятся "callable business logic" для внешних агентов
- Capsule с MCP manifest = publishable enterprise tool набор

Это высокоприоритетная bridge feature для enterprise adoption.

### 5.7 The Discipline Advantage

Одно из самых недооценённых преимуществ Igniter — **дисциплина разработки**.
Refusal-first design. Explicit evidence. Docs-only tracks перед implementation.
Supervisor gate перед каждым решением.

В мире, где AI-агенты могут генерировать код бесконечно быстро — эта дисциплина
становится ценностью, а не overhead'ом. Это то, что отличает "наброски" от
"серьёзного фреймворка".

Это должно быть частью public story: **"Igniter был спроектирован с той же
строгостью, с которой должны быть спроектированы enterprise системы."**

---

## 6. Диагноз и Финальный Вывод

### 6.1 Что работает

Igniter имеет правильную архитектурную DNA:
- Compile-time validation (редкость в Ruby)
- Refusal-first design (зрелость мышления)
- Zero production dependencies (discipline)
- Agent as first-class participant (differentiation)
- Capsule supply chain (enterprise readiness)

Это не "очередной наброск". Это архитектурно зрелый проект с правильными
принципами. Это сильное основание.

### 6.2 Что мешает росту

**Invisible**: нет публичного showcase. Разработчик не может посмотреть и
немедленно понять ценность.

**Too spread**: слишком много открытых направлений одновременно. Contracts,
Application, Web, Agents, Cluster, Capsule Transfer, Ignite lifecycle,
Credentials, DTO layer, MCP Adapter — всё это одновременно в design или
early implementation.

**No "aha moment"**: нет простого пути от "установил gem" до "понял, зачем
это существует" за 15 минут.

### 6.3 Путь к значимости

**Формула**: один killer showcase + компактный authoring DX + завершённый
enterprise story = Igniter занимает уникальную нишу.

Конкретно:

1. **`Igniter.interactive_app` facade** — прямо сейчас, архитектура позволяет
2. **`examples/companion` как flagship** — настоящее working app, не smoke test
3. **SSE push as first class** — table stakes для interactive apps
4. **Enterprise Vision doc** — один документ, который отвечает на вопрос buyer'а
5. **Evidence & Receipt track** — закрыть, это разблокирует Phase 3-6

После этих пяти шагов Igniter — не "ещё один Ruby framework". Это:

> Единственная Ruby платформа для enterprise-grade, agent-native, interactive
> приложений с verifiable supply chain и compile-time validated business logic.

Эту позицию не занял никто. Окно открыто. Вопрос в том, будет ли достаточно
фокуса и скорости, чтобы его занять раньше, чем оно закроется.
