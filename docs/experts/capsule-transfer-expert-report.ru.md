# Capsule Transfer — Экспертный Отчёт

Date: 2026-04-26.
Perspective: эксперт в распределённых агентных системах и интерактивных платформах.
Subject: трек Capsule Transfer и его стратегическое значение для Igniter.

---

## 1. Визионерский взгляд

Capsule Transfer — это не механизм деплоя. Это **первый класс словаря доставки
программного обеспечения под надзором агентов**.

Когда мы смотрим на всю цепочку — declaration → handoff manifest → bundle plan →
artifact verification → applied verification → receipt — мы видим нечто принципиально
иное, чем `git push` или `docker pull`. Это протокол с явным **chain-of-custody**:
каждый шаг создаёт свидетельство, каждое свидетельство становится входом для
следующего, и **ни один мутирующий шаг не выполняется без предшествующей проверки**.

В мире, где AI-агенты координируют доставку и активацию программного обеспечения
между хостами, тенантами и узлами кластера, — этот протокол становится несущей
конструкцией. Не инфраструктурой. **Новым примитивом**.

Ключевое визионерское утверждение:

> Capsule Transfer — это foundation для enterprise application supply chain под
> управлением агентов. Это то, чем `npm publish` + `CI/CD` мог бы стать, если бы
> был спроектирован с первого дня как аудируемый, refusal-first, агент-контролируемый
> процесс.

Сравнение с тем, что уже существует:

| Механизм | Доставка | Аудит | Отказ явный | Активация отделена |
|---|---|---|---|---|
| `gem install` | файлы | нет | нет | нет |
| Docker | образ | частично | нет | нет |
| CI/CD pipeline | артефакт | лог | нет | нет |
| **Capsule Transfer** | **капсула** | **receipt chain** | **да** | **да** |

Разделение `"файлы перемещены"` и `"runtime активирован"` — это не детальная
реализация. Это **принципиальная архитектурная граница**, которая даёт системе её
силу.

---

## 2. Идея, Модель, Усиление

### 2.1 Идея

Capsule — это единица портируемого приложения. Не Docker-образ (не хватает
семантики хоста), не gem (нет бизнес-логики декларации), не zip-архив (нет
намерения). Capsule — это **объявленное намерение** плюс **верифицированная
полезная нагрузка** плюс **протокол активации**.

Handoff manifest — это контракт между источником и назначением. Transfer receipt —
это закрывающее свидетельство. Activation receipt — будущее второе свидетельство,
которое закрывает жизненный цикл активации отдельно.

### 2.2 Модель

Всю модель можно выразить тремя ортогональными измерениями:

```
Capsule Transfer Model
├── TRANSPORT LAYER
│   ├── Declaration      → что хочет переехать
│   ├── Inventory        → что реально существует
│   ├── Bundle           → что упаковано и верифицировано
│   └── Apply            → что применено к назначению
│
├── EVIDENCE LAYER
│   ├── Transfer Receipt → "файлы перемещены" (закрыто)
│   ├── Commit Readiness → "активация возможна" (только описательно)
│   └── Activation Receipt → "runtime активирован" (будущий)
│
└── REFUSAL LAYER
    ├── Dry-run gate     → любой шаг выполнен сначала как dry-run
    ├── Manifest guard   → отклонение при расхождении плана и факта
    └── Commit boundary  → только narrow application-owned операции
```

Это **не конвейер**, это **контрактная цепочка**. Каждый уровень независим и
может быть остановлен или отклонён без нарушения предыдущих свидетельств.

### 2.3 Усиление

Usиление — через **agents as activation reviewers**.

Сегодня: человек читает `commit_readiness`, человек решает, запускать ли активацию.

Завтра: агент получает transfer receipt, анализирует activation evidence, проверяет
адаптер, подписывает решение, и только тогда узкая application-owned операция
выполняется. Агент здесь — не исполнитель, а **аудитор с полномочиями на решение**.

Это открывает следующий уровень: **automated compliance gate** — когда регуляторные
требования (SOC2, HIPAA) выражены как activation predicates, и capsule физически
не может стать активной без прохождения через них.

---

## 3. Развитие Перспективы

### 3.1 Где мы сейчас

Трек прошёл огромный путь:

- ✅ Transfer chain: 14 шагов, end-to-end verified
- ✅ Activation review chain: 7 шагов, dry-run + commit-readiness
- ✅ Boundary review: принята только narrow application-owned граница
- 🔄 Активный: Evidence and Receipt track (docs/design only)
- ⏸ Заблокировано: activation commit implementation

Текущая остановка — намеренная и правильная. Это не стагнация. Это дисциплина.

### 3.2 Критический развилок

Самое важное проектное решение, которое ещё не принято — **форма activation receipt**.

Transfer receipt существует и закрывает транспортный слой. Activation receipt будет
закрывать runtime слой. Но между ними — **evidence packet**: точные поля, которые
должны войти в будущий activation commit.

Этот пакет свидетельств — высочайшей важности проектное решение. Если его форма
будет слабой (неполные поля, нет operation digest, нет idempotency key) — Phase 3
будет хрупкой. Если форма будет избыточной — implementation станет тяжёлой.

**Нужно получить это правильно прежде чем двигаться дальше.**

### 3.3 Долгосрочная траектория

```
Phase 1: Stable transport chain (DONE)
Phase 2: Boundary review (DONE)
Phase 3: Narrow activation commit ← requires evidence/receipt shape first
Phase 4: Activation verification + receipt ← closes the activation lifecycle
Phase 5: Web/host mount activation ← separate lane, not application-owned
Phase 6: Enterprise orchestration ← the real prize
```

Phase 6 — это то место, куда всё это ведёт: CI/CD gates, compliance audit,
internal app marketplaces, agent-assisted migrations. Это уровень, на котором
Capsule Transfer становится product-level feature, а не internal tooling.

### 3.4 Связь с агентной платформой

В контексте Igniter как interactive agent platform (vision из expert-review.md),
Capsule Transfer — это **инфраструктурный enabler** для:

- **Multi-tenant agent environments**: агент-приложения переезжают между тенантами
  с полным audit trail
- **Agent marketplace**: капсулы публикуются, инспектируются, переносятся с
  explicit receipts — как App Store, но для AI-агентов
- **Hot deployment без downtime**: transfer receipt → activation evidence →
  activation commit → activation receipt, всё под надзором live supervisor agent

---

## 4. Рекомендации

### 4.1 Приоритет #1: Сделать Evidence & Receipt track образцовым

Текущий активный трек — docs/design only. Это правильно. Но форма evidence
packet должна быть **исчерпывающей**, не минимальной. Каждое поле должно иметь
явное обоснование:

- **operation_digest**: без него любой replay-атака или race condition может
  применить устаревший план — это не паранойя, это корректность
- **idempotency_key**: капсула может быть применена дважды при network failure —
  без ключа нет safe retry
- **adapter_capability_map**: прежде чем commit, адаптер должен декларировать что
  умеет — это предотвращает silent failures на хостах с урезанными правами
- **caller_metadata + receipt_sink**: кто решил и куда отправить результат —
  essential для enterprise audit

Оба агента (Application и Web) должны выдать полные shapes, не наброски.

### 4.2 Сохранить hard separation: transfer receipt ≠ activation receipt

Это архитектурный принцип, не деталь. Эти два события должны оставаться
независимыми свидетельствами навсегда — у них разные жизненные циклы, разные
потребители, разный аудит. Не поддаваться соблазну "объединить для простоты".

### 4.3 Phase 6 заслуживает отдельного vision документа

Enterprise Orchestration (Phase 6) сегодня описана как 7 bullet points в
roadmap. Это мало. Это та часть, которая делает всю предыдущую работу
экономически оправданной. Рекомендую написать отдельный `docs/experts/capsule-enterprise-orchestration.md`
или `docs/dev/capsule-enterprise-vision.md` с:

- конкретными use cases (air-gapped delivery, compliance gates, marketplace)
- кто является покупателем этой фичи (DevOps lead, CTO, compliance officer)
- как capsule receipt chain интегрируется с существующими tools (GitHub Actions,
  Kubernetes admission webhooks, OPA/Gatekeeper)

### 4.4 Activation commit должен быть agent-readable

Когда Phase 3 откроется — activation commit должен возвращать данные, которые
AI-агент может разобрать и принять решение на основе. Не только human-readable
описание. Structured result: operation_id, committed?, skipped_operations, reason_map.

Это даёт фундамент для automated activation review agents в Phase 6.

### 4.5 Не спешить с Phase 3

Текущая позиция (блокировать implementation до определения evidence shapes) —
правильная. Добавить один критерий к acceptance для Phase 3: должен существовать
хотя бы один реальный adapter (не stub), прежде чем implementation открывается.
Без real adapter тест корректности evidence packet невозможен.

---

## 5. Инсайты и Идеи

### 5.1 Capsule as a Trust Boundary

Capsule не просто переносит файлы — она переносит **trust context**. Transfer
receipt — это подписанное утверждение: "эти файлы были верифицированы перед
переносом". В distributed agent world это означает, что агент на принимающем
хосте может принять capsule без повторной верификации содержимого (trust the
receipt), но должен самостоятельно верифицировать соответствие своей среды
(activation readiness).

Это изоморфно JWT: содержимое подписано, получатель проверяет подпись, не
перепроверяет содержимое.

### 5.2 Receipt Chain как Distributed Event Log

Цепочка receipt'ов (transfer → activation) — это фактически **append-only
distributed event log** для lifecycle приложения. Это открывает возможность:

- temporal queries: "какое состояние было у host-X в момент T?"
- diff между двумя receipts: что изменилось между двумя активациями одной капсулы
- agent subscription: агент подписывается на receipt events и принимает решения

### 5.3 "Activation Budget" Pattern

Интересная идея для Phase 3: вместо того чтобы перечислять allowed operations,
определить **activation budget** — максимальное количество filesystem mutations,
maximum depth, maximum file count. Если commit превышает budget — автоматический
отказ без ручного review. Это defence-in-depth поверх explicit boundary review.

### 5.4 Capsule Composition как Dependency Graph

Capsule может зависеть от другой capsule (base capsule). Тогда transfer chain
превращается в topologically sorted dependency graph. Igniter contracts — это
именно validated dependency graphs. Использовать тот же компилятор для валидации
capsule dependencies — это не просто красивая идея, это natural fit.

### 5.5 "Evidence Accumulation" vs "Evidence Snapshot"

Текущая модель: evidence snapshot — набор полей, которые должны присутствовать
в момент commit. Альтернативная модель: evidence accumulation — каждый шаг
добавляет evidence в растущий объект (immutable append), и commit является
simply последним append'ом.

Advantage: аудитор видит полную историю принятия решений, а не только финальный
срез. Это особенно ценно для regulated environments.

### 5.6 Capsule as the Agent Deployment Primitive

В контексте interactive agent platform: когда пользователь "устанавливает" нового
агента-ассистента в своё рабочее пространство — это capsule transfer. Манифест
описывает агента (capabilities, tools, LLM requirements), receipt подтверждает
установку, activation receipt подтверждает что агент live. Пользователь видит
это как "Install Agent", но под капотом — полная verifiable supply chain.

Это то, что отличает Igniter от просто "ещё одного AI framework" — **agents
deployable as first-class auditable artifacts**.

---

## 6. Итоговый Вывод

Capsule Transfer — стратегически правильная и хорошо дисциплинированная работа.
Текущая пауза перед activation commit — это не медлительность, это зрелость.

Единственный риск — что Evidence & Receipt track будет сделан "достаточно хорошо"
а не "правильно". Форма evidence packet — это один из тех решений, которые
дорого переделывать после того как поверх них написан код.

**Основная рекомендация**: потратить на Evidence & Receipt track столько времени,
сколько нужно. Этот документ становится контрактом для всего Phase 3–6.
После его принятия roadmap разворачивается быстро и чисто.

Capsule Transfer может стать тем, чем Apple Notarization является для macOS —
verifiable chain-of-custody для software delivery — но с агентами как
active participants в процессе, а не только пассивными инструментами CI.
