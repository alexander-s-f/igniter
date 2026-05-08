# META-EXPERT-012: Document Lifecycle and Rotation Methodology v0

Card: S3-R4-C4-S (внетрековая задача)
Agent: [Igniter-Lang Meta Expert]
Role: meta-expert
Track: igniter-lang/docs/meta-proposals/META-EXPERT-012-document-lifecycle-and-rotation-v0.md
Date: 2026-05-08
Status: active governance

---

## I. Проблема

По состоянию на S3-R4 накопились структурные дисфункции документооборота:

```
Симптом                                              Диагноз
──────────────────────────────────────────────────────────────────────────────
177 track-документов, ни один не в архиве            нет критерия ротации
16 proposals со Status: proposal                     lifecycle не закрывается
PROP-026, PROP-027 «закрыты» в README, файлы — нет  двойное состояние
META-EXPERT-008 «superseded» в active section        нет разделения зон
Spec ch4 (fragment class) последний раз обновлялся   spec дрейфует от кода
  в S2-R7; TEMPORAL fragment в Stage 3 не отражён
current-status.md обновляется каждый раунд           это работает ✅
discussions/ всегда закрываются с маршрутом           это работает ✅
```

Корневая причина: документы имеют разные жизненные циклы, но единый статусный
словарь не определён. Нет правил перехода между состояниями и нет
per-round обязательств по актуализации.

---

## II. Принципы

**P1. Каждый тип документа имеет свой lifecycle, не один общий.**
Track-документ «готов» после handoff и не должен обновляться.
Spec-глава — живая и должна следовать за реализацией.

**P2. Актуализация != переписывание.**
Большинство переходов — это смена одного поля (Status) или добавление
одной строки в индекс. Не нужна полная реструктуризация.

**P3. Ответственность за ротацию — per-round, не ad hoc.**
Meta Expert проверяет lifecycle checklist в каждом round-curation слайсе.

**P4. Архив — не мусоропровод.**
Документ уходит в архив только когда замещён или доказательство неактуально.
«Старый» ≠ «архивный».

**P5. Single source of truth по lifecycle — этот документ.**
Все роли следуют этому словарю.

---

## III. Типы документов и их lifecycle

### 3.1 `current-status.md`

**Тип:** живая доска  
**Владелец:** Meta Expert + Supervisor  
**Lifecycle:** один документ, не архивируется

```
Состояния: всегда active
Обновляется: каждый round-curation слайс
Триггер обновления: любой track или proposal меняет статус Stage 3
Признак устаревания: последнее обновление > 2 rounds назад
```

→ **Не имеет archive-состояния.** Историческое состояние хранится в
git history и в stage-close snapshots.

---

### 3.2 Track-документы (`docs/tracks/*.md`)

**Тип:** срезовое доказательство (slice evidence)  
**Владелец:** назначенный агент на slice

```
Состояния:
  in_progress   написан, слайс ещё идёт
  done          handoff закончен, доказательство зафиксировано
  blocked       явно ждёт другого слайса
  superseded    заменён более поздним треком (добавить ссылку)
  archived      ушёл в archive/ (только stage-close или pre-crystallization)

Переход done → archived:
  - автоматически при stage close snapshot
  - вручную если трек явно устарел (superseded > 2 rounds назад)
  
Переход done → superseded:
  - когда вышел новый трек с тем же scope
  - добавить в файл: [Superseded by: <track-name>]
```

**Правило:** track-документ не редактируется после статуса `done`.
Если нужна корректировка — создаётся новый трек с `-errata-` или `-v1` суффиксом.

**Ротация per-round (для Meta Expert):**
- Отметить треки прошлых rounds как `done` если это не сделано.
- Если round насчитывает >20 новых треков — создать sub-index в tracks/README.md.
- При stage close: переместить все треки текущего stage в archive/snapshots/.

---

### 3.3 Proposals (`docs/proposals/PROP-*.md`)

**Тип:** формальное языковое предложение  
**Владелец:** Compiler/Grammar Expert (authorship); Meta Expert (lifecycle)

```
Lifecycle:
  authored      написан, ещё не прошёл верификацию
  proposal      принят к рассмотрению (текущий main state для большинства)
  verified      прошёл experiment PASS (прим: PROP-026, PROP-027)
  closed        доказательство принято, спецификация обновлена
  rejected      формально отклонён с обоснованием
  superseded    заменён более новым PROP (добавить ссылку)

Текущий дефект (май 2026):
  PROP-026 — Status: proposal, но verified/closed в README
  PROP-027 — Status: proposal, но verified/closed в README
  → Требуется разовая актуализация: обновить Status: в файлах до "closed"

Правило:
  Status: в файле PROP должен совпадать со статусом в proposals/README.md.
  Расхождение = дефект.
```

**Переход proposal → closed:**
- Experiment PASS зафиксирован в track-документе.
- Spec-глава обновлена (или scheduled к обновлению).
- Meta Expert обновляет Status: в файле PROP.
- proposals/README.md обновляется.

**Переход → superseded:**
- Новый PROP явно заменяет старый.
- В старом файле добавить строку: `Superseded by: PROP-NNN`.
- В README пометить как `superseded`.

**Архивирование:** closed и superseded PROPs перемещаются в `accepted/` при
stage close. `accepted/` — read-only.

---

### 3.4 Spec-главы (`docs/spec/ch*.md`)

**Тип:** канонический эталон языка  
**Владелец:** Meta Expert + одобренный имплементатор

```
Lifecycle:
  draft         написана, ещё не соответствует implementation
  current       соответствует текущей реализации
  stale         реализация ушла вперёд, глава не обновлена
  frozen        stage закрыт, глава заморожена (Stage 1 = frozen)

Признаки stale:
  - В classifier.rb есть fragment_class которого нет в ch4
  - В SemanticIREmitter есть node types которых нет в ch6
  - Раунд closed, новые nodes доказаны, глава не тронута

Правило "spec lag":
  Spec может отставать от реализации максимум на 1 stage.
  Т.е. Stage 3 может начаться со stale spec из Stage 2.
  Но к stage close spec должен быть current.
```

**Per-round trigger:**
Если в round зафиксировано изменение в classifier/typechecker/emitter — Meta
Expert добавляет запись в backlog обновлений spec. При наступлении `spec-sync`
трека — обновление выполняется.

**Текущий долг по spec (май 2026):**

| Глава | Последнее обновление | Долг |
|-------|---------------------|------|
| ch4 (fragment classification) | S2-R7 | TEMPORAL fragment class (PROP-028) не отражён |
| ch6 (semanticir) | S2-R9 | temporal_input_node / temporal_access_node не отражены |
| ch5 (compiler pipeline) | S2-R7 | emit_typed path не описан |
| ch7 (runtime) | S2-R6 | cache key contract (C3) не отражён |

→ Требуется spec-sync трек в S3-R4 или S3-R5.

---

### 3.5 Meta-proposals (`docs/meta-proposals/META-EXPERT-*.md`)

**Тип:** стратегические решения и управление  
**Владелец:** Meta Expert

```
Lifecycle:
  active        текущее действующее решение
  supporting    поддерживающий контекст для active
  decision      принятое одноразовое решение (не меняется)
  superseded    заменён более новым META-EXPERT
  done          задача выполнена (процессный документ)
  research-note не-governance материал, только давление
  vision        стратегический horizon без governance force

Правило active:
  Только ONE META-EXPERT может иметь статус active на каждую тему.
  META-EXPERT-008 (Stage 2 governance) = superseded.
  META-EXPERT-011 (Stage 3 governance) = active.
  Если оба в active section README — это дефект.

Ротация:
  При смене stage → архивировать завершённые governance документы.
  При stage close → добавить в README секцию "Stage N Governance (closed)".
  Superseded документы → перемещать в closed-секцию, не удалять.
```

**Текущий дефект:** META-EXPERT-008 в README присвоен статус "superseded" но
находится в секции "Stage 2 Governance (closed)", что фактически корректно.
Дополнительно: signal-ledger-index.md не обновлялся с S2. Добавить признак stale.

---

### 3.6 Discussions (`docs/discussions/*.md`)

**Тип:** ограниченная дискуссия  
**Владелец:** инициатор (Supervisor / Meta Expert / user)

```
Lifecycle:
  open          дискуссия идёт
  complete      закончена, маршрут определён (PROP / track / backlog / reject)

Правило:
  Discussion не переходит в archive.
  После complete — остаётся в discussions/ как исторический сигнал.
  Индексируется в discussions/README.md.
  Не редактируется после complete.
```

→ Текущий процесс работает корректно. Никаких изменений не требуется.

---

## IV. Per-Round Lifecycle Checklist

Выполняется в каждом `*-status-curation-v0` слайсе Meta Expert.

```markdown
## Round N Lifecycle Checklist

### current-status.md
- [ ] Все треки round N отражены в scoreboard
- [ ] Статусы lanes актуальны
- [ ] Дата "last updated" обновлена

### Track docs
- [ ] Все треки round N имеют Status: done / blocked
- [ ] Если track superseded — добавить [Superseded by:]
- [ ] tracks/README.md обновлён с новой секцией Round N

### Proposals
- [ ] proposals/README.md синхронизирован с файлами PROP
- [ ] Все PROP с experiment PASS обновлены до Status: closed
- [ ] Нет расхождений между README и файлами

### Spec
- [ ] Определить какие spec-главы требуют обновления
- [ ] Если долг > 1 round — запланировать spec-sync трек
- [ ] ch4/ch6 проверить на соответствие с последними classifier/emitter изменениями

### Meta-proposals
- [ ] README.md отражает текущие active documents
- [ ] Superseded documents в correct section
- [ ] signal-ledger-index.md обновлён если были изменения в META-EXPERT
```

---

## V. Матрица ответственности

| Документ | Создаёт | Закрывает/архивирует | Актуализирует |
|----------|---------|---------------------|---------------|
| current-status.md | Meta Expert | — | Meta Expert (каждый round) |
| Track docs | назначенный агент | Meta Expert (stage close) | — (не редактируется) |
| PROP files | Compiler/Grammar Expert | Meta Expert (lifecycle) | Compiler/Grammar Expert (minor errata) |
| proposals/README.md | Compiler/Grammar Expert | Meta Expert | Meta Expert |
| Spec chapters | Compiler/Grammar Expert | Meta Expert (stage close) | Compiler/Grammar Expert + Research Agent |
| Meta-proposals | Meta Expert | Meta Expert | Meta Expert |
| Discussions | инициатор | агент (после complete) | — (не редактируется) |

---

## VI. Немедленные Действия (S3-R4 debt)

Следующий status-curation слайс должен выполнить:

### Критические (дефекты состояния):

```text
[1] PROP файлы — обновить Status:
    PROP-026: Status: proposal → Status: closed
    PROP-027: Status: proposal → Status: closed
    (оба закрыты в Stage 2 по README, файлы не обновлены)

[2] Spec backlog — создать spec-sync трек
    ch4: добавить TEMPORAL fragment class (PROP-028)
    ch6: добавить temporal_input_node / temporal_access_node
    ch5: добавить emit_typed path description
    ch7: добавить cache key contract outline
    Трек: spec-stage3-sync-v0 [Compiler/Grammar Expert]
```

### Умеренные (накопленный долг):

```text
[3] signal-ledger-index.md — обновить или пометить как stale
    Последнее обновление S2. Новые Stage 3 сигналы не отражены.

[4] proposals/README.md header — обновить с "Stage 2 active" на "Stage 3"
    (выявлено ранее в S3-R1-X1-S review)

[5] META-EXPERT-008 в meta-proposals/README.md — убедиться что в "Stage 2
    Governance (closed)" section, не в "Active". (текущий статус корректен,
    требует проверки)
```

### Отложенные (при stage close):

```text
[6] При Stage 3 close → stage-close snapshot всех треков
[7] При Stage 3 close → переместить closed PROPs в accepted/
[8] При Stage 3 close → заморозить spec как frozen
```

---

## VII. Правила новых документов

При создании любого нового документа:

```markdown
Обязательные поля в заголовке:
  Status: <lifecycle state>     ← один из словаря типа
  Date: YYYY-MM-DD
  [Owner/Agent field]
  
Для tracks:
  Card: <S-R-C-suffix>         ← обязательно для трассируемости
  
Для PROPs:
  Depends on: <PROP list>
  Stage: <N>
  
Для meta-proposals:
  Supersedes: <predecessor> | nothing
```

Имена файлов:
- Треки: `<topic>-v0.md` → при revision: `<topic>-v1.md` (не overwrite)
- PROPs: `PROP-NNN-<topic>-v0.md`
- Meta-proposals: `META-EXPERT-NNN-<topic>-v0.md`
- Discussions: `<topic>-discussion-v0.md`

---

## VIII. Метрики здоровья документооборота

Признаки здорового состояния:

```text
✅ current-status.md обновлён в этом round
✅ proposals/README.md и файлы PROP синхронизированы по Status:
✅ spec-lag ≤ 1 stage (отставание spec от реализации)
✅ В active section meta-proposals/README.md только ОДИН active per-topic
✅ tracks/README.md имеет запись для каждого нового трека
✅ discussions/ закрыты с Route в течение одного round
```

Признаки долга:

```text
⚠️  proposals с Status: proposal после experiment PASS
⚠️  spec-глава не обновлялась > 2 rounds при активных изменениях в коде
⚠️  signal-ledger без обновлений при наличии новых META-EXPERT решений
⚠️  tracks/README.md отстаёт от track файлов на > 1 round
⚠️  Более 1 META-EXPERT в active статусе на одну тему
```

---

## Handoff

```text
Card: S3-R4-C4-S (внетрековая задача)
Agent: [Igniter-Lang Meta Expert]
Role: meta-expert
Track: META-EXPERT-012-document-lifecycle-and-rotation-v0.md
Status: done

[D] Decisions
- Определён единый lifecycle-словарь для 6 типов документов.
- Per-round lifecycle checklist добавлен в обязательства Meta Expert.
- Правила per-round: actuzalization, не ad hoc.
- Spec lag ≤ 1 stage — новый governance constraint.
- Status: в файлах PROP должен совпадать с proposals/README.md.

[S] Signals
- 16 proposals в статусе "proposal" без закрытия — выявлен системный дефект.
- PROP-026, PROP-027 — расхождение README vs файл — критический дефект.
- Spec: ch4, ch5, ch6, ch7 — долг Stage 3 не отражён.
- signal-ledger-index.md stale с S2.
- 177 track docs — нет ротации, нет архивирования, нет критерия.

[R] Recommendations
- Создать spec-stage3-sync-v0 трек [Compiler/Grammar Expert] в S3-R4 или R5.
- Выполнить PROP Status: обновление в следующем status-curation слайсе.
- Добавить lifecycle checklist в template status-curation трека.

[Next] Suggested next slice
- status-curation-v0 слайс: выполнить критические и умеренные debt items
- spec-stage3-sync-v0: [Compiler/Grammar Expert]
  scope: ch4 TEMPORAL, ch6 temporal nodes, ch5 emit_typed, ch7 cache key
```
