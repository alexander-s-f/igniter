# Igniter Contract Language — OLAP Point, внутренняя структура History и путешествие во времени

Дата: 2026-04-27.
Статус: ★ ВЕРШИНА — текущий пик исследовательского трека.
Приоритет: ВЫСОКИЙ — OLAP Point является кандидатом в фундаментальные конструкции
языка наравне с `contract`; внутренняя структура History открывает нативную
кластерную параллельность.
Область: OLAP Point как языковой примитив, внутренняя структура History для
кластерной параллельности, спецификация путешествия во времени (назад и вперёд).

*Основывается на: [igniter-lang-temporal-deep.md](igniter-lang-temporal-deep.md)*

---

## § 0. Центральный инсайт

`History[T]` — одномерная OLAP-структура: значение, параметризованное единственным
измерением (время). Но данные предприятия по сути **многомерны**:

- Цена = f(время, продукт, уровень_клиента, регион)
- Выручка = f(время, продукт, канал, регион)
- Запас = f(время, склад, продукт, артикул)

Естественное обобщение: **OLAP Point** — это значение в конкретной точке
многомерного пространства. `History[T]` становится частным случаем:
`OLAPPoint[T, time: DateTime]`.

Это не аналитическая надстройка. Это кандидат в **первоклассные конструкции
языка** наравне с `contract`, `rule`, `entity` и `invariant`. Причина: та же
декларативная, компонуемая, верифицируемая модель, которая делает контракты
мощными, в равной мере применима к многомерным данным — а именно здесь
большинство корпоративных систем тратит основной бюджет сложности.

---

## § 1. Внутренняя структура History

### § 1.1 Цели проектирования

Внутренняя структура `History[T]` должна поддерживать:
- **Неизменяемое прошлое**: записанные интервалы никогда не меняются
- **Только-добавление**: новые интервалы расширяют голову; старые сегменты запечатываются
- **Контент-адресуемые сегменты**: каждый сегмент хэширован → дедупликация и безопасность кэша
- **Доступ к точке за O(log n)**: бинарный поиск по списку интервалов
- **Параллельное чтение без координации**: запечатанные сегменты свободно распределяются
- **Шардирование по времени**: узлы кластера владеют непересекающимися временны́ми окнами

### § 1.2 Структура сегмента

```
// Один неизменяемый кусок истории (запечатывается при заполнении или явном snapshot)
type HistorySegment[T] = {
  id:           SegmentId          // глобально уникальный (хэш содержимого)
  intervals:    Interval[T][]      // отсортированные, непересекающиеся, смежные
  valid_range:  DateRange          // временно́й диапазон этого сегмента
  sealed:       Bool               // true = неизменяем, может кэшироваться/распределяться
  checksum:     Bytes              // SHA-256 отсортированных данных интервалов
  node_id:      NodeId?            // узел кластера-владельца (nil = реплицирован)
}

// History — структура указателей на сегменты
type History[T] = {
  type_tag:     TypeTag[T]
  segments:     SegmentId[]        // упорядочены хронологически (старые первыми)
  head_id:      SegmentId          // единственный изменяемый сегмент (цель добавления)
  snapshots:    Map[DateTime, SegmentId]   // быстрый индекс перехода к точке времени
  segment_size: Int                // макс. интервалов на сегмент (по умолчанию: 1_000)
}
```

### § 1.3 Путь записи — только добавление

```
append_interval(history, interval):
  head = load_segment(history.head_id)

  if head.sealed:
    error "cannot write to sealed segment"

  if head.intervals.count >= history.segment_size:
    seal(head)
    new_segment = create_segment(node_id: local_node)
    history.segments.append(new_segment.id)
    history.head_id = new_segment.id
    head = new_segment

  head.intervals.append(interval)
  -- прошлые сегменты никогда не изменяются
```

Сегмент **запечатывается** когда:
- Достигает `segment_size` интервалов
- Выполняется явный вызов `snapshot`
- Балансировщик кластера передаёт ответственность за этот диапазон

После запечатывания сегмент:
- **Неизменяем** — содержимое никогда не меняется
- **Контент-адресуемый** — его `id` является хэшем содержимого
- **Свободно распределяем** — любой узел может кэшировать его без координации
- **Верифицируется при чтении** — пересчитать хэш, сравнить с `id`

### § 1.4 Путь чтения — бинарный поиск + индекс сегментов

```
read_at(history, t):
  -- Быстрый путь: проверить индекс снимков
  if snapshot_id = history.snapshots[t]:
    segment = load_segment(snapshot_id)
    return segment.intervals.find { |i| i.covers?(t) }

  -- Найти нужный сегмент по диапазону времени (бинарный поиск)
  segment = binary_search(history.segments) { |s| s.valid_range.covers?(t) }
  return segment.intervals.binary_search { |i| i.covers?(t) }

-- Итого: O(log S + log N), где S = число сегментов, N = интервалов на сегмент
-- Амортизированно O(log n) для n суммарных интервалов
```

### § 1.5 Распределение по кластеру

```
type HistoryPartition = {
  node_id:    NodeId
  time_range: DateRange            // этот узел владеет интервалами в этом диапазоне
  segments:   SegmentId[]          // запечатанные сегменты в этом диапазоне
}

type DistributedHistory[T] = {
  local:      History[T]           // активная для записи партиция этого узла
  partitions: HistoryPartition[]   // карта кластера (только чтение)
  replication_factor: Int          // сколько узлов хранят каждый запечатанный сегмент
}
```

**Чтение из распределённой истории:**

```
read_distributed(dh, t):
  partition = dh.partitions.find { |p| p.time_range.covers?(t) }
  if partition.node_id == local_node:
    return read_at(dh.local, t)
  else:
    segment_id = partition.segments.find_for(t)
    segment = fetch_or_cache(segment_id, from: partition.node_id)
    -- сегмент контент-адресуемый: безопасно кэшировать где угодно
    return segment.intervals.binary_search { |i| i.covers?(t) }
```

Запечатанные сегменты **распространяются через gossip**: узел, прочитавший
сегмент, кэширует его локально. Последующие чтения с любого узла находят его
в кэше. Контент-адресуемость гарантирует корректность кэша без координации.

### § 1.6 Свойства параллельности

| Операция | Параллельность | Координация |
|----------|--------------|-------------|
| Чтение точки `h[t]` | Полная параллельность между узлами | Нет (неизменяемые сегменты) |
| Чтение диапазона `h[t1..t2]` | Параллельное чтение сегментов | Нет |
| Добавление в голову | Единственный писатель на партицию | Блокировка партиции (локальная) |
| Запечатывание сегмента | Единственный писатель | Блокировка партиции (локальная) |
| OLAP rollup | Параллельно по сегментам | Шаг reduce в конце |
| Снимок | Единственный писатель | Блокировка партиции (локальная) |
| Ребалансировка партиций | Фоновая, неблокирующая | Gossip-протокол |

---

## § 2. Спецификация путешествия во времени

### § 2.1 Путешествие назад

Путешествие назад уже полностью специфицировано: `value[t]` для любого прошлого `t`.

Дополнительная интроспекция на пути назад:

```
-- Точка во времени
product.price[3.months.ago]

-- Ближайшее записанное значение (если точная точка не имеет интервала)
product.price.nearest(3.months.ago)

-- Шаг назад до обнаружения изменения
product.price.last_change_before(3.months.ago)

-- Вся история до точки
product.price.history_until(3.months.ago)   -- подпоследовательность History[T]

-- Воспроизведение: выполнить контракт на прошлый момент
OrderTotal { order: order, as_of: 3.months.ago }
```

### § 2.2 Путешествие вперёд

Путешествие вперёд оценивает то, какими будут (или могут быть) значения в будущем.
Три режима с нарастающей неопределённостью:

**Режим 1 — Детерминированный (известные будущие правила)**

```
-- Правило уже объявлено с будущим applies:
rule ChristmasSale : Product {
  applies: { from: :december_20, until: :january_2 }
  compute: fn(product) -> Float = 0.25
}

-- Оценка будущего использует запланированные правила
product.price[2.months.from_now]   -- детерминировано если ChristmasSale покрывает эту дату
```

Результат: `T` (точный).

**Режим 2 — Контрфактуальный (предлагаемые правила)**

```
-- Какой была бы цена если активировать это предлагаемое правило?
product.price.with(ProposedRule)[2.months.from_now]

-- Эквивалентно:
OrderTotal {
  order:       order,
  as_of:       2.months.from_now,
  extra_rules: [ProposedRule]
}
```

Результат: `T` (точный при данном наборе правил).

**Режим 3 — Приближённый (экстраполяция тренда)**

```
-- Статистическая экстраполяция наблюдаемого тренда
~product.price[6.months.from_now]
  @approximate(method: :trend_extrapolation, window: 12.months, confidence: 0.70)

-- Сезонная модель (повторяющийся ежегодный паттерн)
~product.price[next_december]
  @approximate(method: :seasonal, cycle: :yearly, confidence: 0.80)
```

Результат: `~T` (приближённый) с объявленной достоверностью.

### § 2.3 Конструкция «машина времени»

Для многосценарного прогнозирования:

```
time_machine :price_forecast {
  subject:     product.price
  horizon:     6.months
  granularity: :weekly

  scenarios: [
    {
      name:  :baseline
      rules: system.current_rules
    }
    {
      name:  :holiday_promotion
      rules: system.current_rules + [ChristmasSale]
    }
    {
      name:  :competitor_response
      rules: system.current_rules + [PriceMatch]
      @approximate(confidence: 0.65)
    }
  ]
}
```

Возвращает запись `Forecast`:

```
type Forecast[T] = {
  subject:    String
  horizon:    DateRange
  scenarios:  Map[Symbol, ForecastScenario[T]]
}

type ForecastScenario[T] = {
  name:       Symbol
  values:     History[T] | History[~T]    -- точные или приближённые
  confidence: Float?
}
```

### § 2.4 Инварианты путешествия во времени

```
invariant TimeConsistency {
  -- Путешествие назад не может выйти за пределы самого раннего записанного интервала
  as_of >= system.earliest_recorded_at
}

invariant ForwardDeterminism {
  -- Точное путешествие вперёд допустимо только для правил с объявленным будущим applies:
  -- Приближённое путешествие вперёд всегда допустимо, но возвращает ~T
  when as_of > DateTime.now() && result_type == :exact {
    applied_rules.all? { |r| r.applies_spec.covers_future? }
  }
}
```

---

## § 3. OLAP Point — языковая конструкция

### § 3.1 Мотивация

`History[T]` = `OLAPPoint[T, time: DateTime]` — значение, параметризованное
только временем.

Обобщение: OLAP Point — это **многомерная функция**, отображающая точку в
пространстве измерений на значение меры. Измерения могут включать время, но
также продукт, регион, уровень клиента, канал — любую категориальную или
порядковую ось.

Это не концепция базы данных, перенесённая в язык. Это **естественное
обобщение History**, возникающее из наблюдения, что большинство корпоративных
значений зависят более чем от одного измерения.

### § 3.2 Синтаксис объявления

```
olap_decl ::=
  'olap_point' IDENT '{'
    'dimensions' ':' '{' {dim_decl ','} '}'
    'measure'    ':' type_expr
    ['granularity' ':' '{' {grain_decl} '}']
    ['source'    ':' expr]
    ['indexed'   ':' '[' {SYMBOL ','} ']']
  '}'

dim_decl   ::= IDENT ':' type_expr
grain_decl ::= IDENT ':' SYMBOL    -- напр. time: :daily
```

**Примеры:**

```
olap_point Revenue {
  dimensions: {
    time:     DateTime
    product:  Product
    region:   Region
    channel:  Enum[:online, :retail, :wholesale]
  }
  measure:   Money

  granularity: {
    time:   :daily      -- единица агрегации по умолчанию
    region: :country    -- уровень rollup по умолчанию
  }

  source: fn(t, product, region, channel) -> Money =
    FulfilledOrders {
      period:  t.day
      product: product
      region:  region
      channel: channel
    }.total

  indexed: [:time, :product]   -- ключи шардирования кластера
}

olap_point Price {
  dimensions: {
    time:          DateTime
    product:       Product
    customer_tier: Enum[:standard, :vip, :wholesale]
  }
  measure: Money

  source: fn(t, product, tier) -> Money =
    product.base_price[t]
    |> apply(TierRules[t], for: tier)
    |> apply(SeasonalRules[t], for: product)
}
```

`History[T]` — частный случай:
```
-- History[Money] это в точности:
olap_point PriceHistory {
  dimensions: { time: DateTime }
  measure:    Money
  source:     product.price_history
}
```

### § 3.3 OLAP-операции

OLAP-операции над `OLAPPoint` возвращают новые значения `OLAPPoint` — они
компонуемы и ленивы (вычисляются по требованию).

**Slice** — зафиксировать одно измерение, уменьшить размерность на единицу:

```
Revenue[time: :q4_2026]                 -- OLAPPoint[product, region, channel]
Revenue[product: laptop]                -- OLAPPoint[time, region, channel]
Revenue[channel: :online]               -- OLAPPoint[time, product, region]

-- Цепочка срезов (dice):
Revenue[time: :q4_2026][region: :west]  -- OLAPPoint[product, channel]
```

**Rollup** — агрегировать по измерению:

```
Revenue.rollup(:region)                         -- сумма по всем регионам
Revenue.rollup(:region, fn: :avg)               -- среднее вместо суммы
Revenue.rollup(:time, grain: :monthly)          -- месячные итоги
Revenue.rollup(:time, grain: :quarterly)        -- квартальные итоги
```

**Drill-down** — увеличить детализацию измерения:

```
Revenue.drill(:time, :hourly)                   -- от дневных к почасовым
Revenue.drill(:region, :city)                   -- от страны к городу
```

**Pivot** — преобразовать в 2D-матрицу:

```
Revenue[time: :q4_2026].pivot(:product, :region)
-- Возвращает: Map[Product, Map[Region, Money]]
-- Таблица: строки = продукты, столбцы = регионы, ячейки = выручка
```

**Compare** — сравнить два OLAP Point (одинаковые измерения):

```
Revenue[time: :q4_2026].compare(Revenue[time: :q3_2026])
-- Возвращает: OLAPPoint дельт (те же измерения, мера = Money со знаком)
```

**Правила типизации:**

```
-- Slice уменьшает размерность
op: OLAPPoint[T, {d₁: D₁, d₂: D₂, d₃: D₃}] [ d₁: v ] →
    OLAPPoint[T, {d₂: D₂, d₃: D₃}]

-- Rollup устраняет измерение
op: OLAPPoint[T, {d₁: D₁, d₂: D₂}].rollup(d₁) →
    OLAPPoint[T, {d₂: D₂}]

-- Полный rollup: становится скаляром
op: OLAPPoint[T, {}] → T

-- History = одномерный OLAP:
History[T]  ≡  OLAPPoint[T, {time: DateTime}]
```

### § 3.4 OLAP Point в контрактах

`OLAPPoint` — значение первого класса в языке контрактов:

```
contract RegionalReport {
  in period:  DateRange
  in region:  Region

  compute :revenue =
    Revenue[time: period, region: region]
    .rollup(:time, grain: :monthly)

  compute :top_products =
    Revenue[time: period, region: region]
    .rollup(:time)
    .pivot_to_list(:product)
    |> sort_by { .measure }
    |> take(10)

  compute :vs_last_year =
    revenue.compare(
      Revenue[time: period.shift(-1.year), region: region]
      .rollup(:time, grain: :monthly)
    )

  out report: RegionalReport = {
    monthly_revenue: revenue
    top_10_products: top_products
    yoy_comparison:  vs_last_year
  }
}
```

**Никакого SQL. Никаких join-ов. Никаких ETL-конвейеров.** OLAP Point —
нативный аналитический примитив контракта.

---

## § 4. History как одномерный OLAP Point — Унификация

Ключевая унификация в системе типов:

```
History[T]  ≡  OLAPPoint[T, {time: DateTime}]

-- Все операции History — частные случаи OLAP-операций:
price[t]                  ≡  Price[time: t]
price[t1..t2]             ≡  Price[time: t1..t2]
price.avg[period]         ≡  Price[time: period].rollup(:time, fn: :avg)
price.rollup(:week)       ≡  Price[time: all].rollup(:time, grain: :weekly)
```

Эта унификация имеет практические последствия:

**1. Кластерная модель применяется единообразно**: сегменты History = одномерные
OLAP-партиции. Вся логика распределения по кластеру работает для любого OLAP Point.

**2. OLAP-операции работают над History**:

```
product.price.rollup(:month)            -- среднемесячные цены
product.price.compare(competitor.price) -- ценовой разрыв во времени
product.price.drill(:hour)              -- внутридневное движение цен
```

**3. History может быть повышена до многомерного OLAP**:

```
-- Начинаем с 1D истории:
product.price: History[Money]

-- Повышаем до многомерного при добавлении уровня клиента:
olap_point Price {
  dimensions: { time: DateTime, tier: CustomerTier }
  measure:    Money
}

-- 1D история теперь — срез 2D OLAP Point:
product.price[t]  ≡  Price[time: t, tier: :standard]
```

Повышение измерений не ломает существующий код — оно добавляет новые паттерны доступа.

---

## § 5. API интроспекции OLAP

Только доступ к данным — без вычислений. Эти операции читают из History/OLAP
без запуска оценки правил.

### § 5.1 Интроспекция History

```
-- Прямой доступ к интервалам
product.price.intervals                 -- [Interval[Money]] (все записанные интервалы)
product.price.intervals_in(period)      -- интервалы, пересекающие период
product.price.interval_at(t)            -- Interval[Money]? (точный интервал, покрывающий t)

-- События изменений
product.price.changes                   -- [ChangeEvent[Money]] (все изменения значений)
product.price.changes_in(period)        -- изменения в пределах периода
product.price.last_change               -- самое последнее изменение
product.price.first_recorded            -- самое раннее изменение

-- Структурные запросы
product.price.covered?                  -- Bool: покрыт ли весь временно́й домен?
product.price.gap_at(t)                 -- Bool: есть ли пробел в момент t?
product.price.gaps                      -- [DateRange]: непокрытые интервалы

-- Статистика по записанной истории
product.price.count_changes_in(period)  -- Int
product.price.duration_of(value)        -- Duration: как долго было активно это значение?
product.price.volatility(period)        -- Float: стандартное отклонение изменений
```

### § 5.2 Интроспекция OLAP Point

```
-- Инспекция измерений
Revenue.dimensions                       -- { time: DateTime, product: Product, ... }
Revenue.measure_type                     -- Money

-- Запросы покрытия
Revenue.covered?[time: period]           -- Bool: все ли ячейки в периоде заполнены?
Revenue.missing_cells[time: :q4_2026]    -- список (product, region, channel) без данных

-- Распределение
Revenue[time: :q4_2026].distribution(:product)   -- гистограмма выручки по продуктам
Revenue[time: :q4_2026].percentile(0.90)          -- 90-й процентиль значения ячейки

-- Обнаружение аномалий (только данные, без вычислений)
Revenue.outliers[time: :q4_2026]         -- ячейки > 3σ от среднего
Revenue.trend(:time)[product: laptop]    -- коэффициенты линейного тренда по времени
```

### § 5.3 Срезы как значения первого класса

OLAP-срез — значение первого класса: его можно передавать в контракты, хранить
в выходах и сериализовывать:

```
type OLAPSlice[T, Dims] = {
  source:     OLAPPointRef
  fixed_dims: Map[Symbol, Any]           -- зафиксированные значения измерений
  free_dims:  Map[Symbol, TypeTag]       -- оставшиеся запрашиваемые измерения
  measure:    TypeTag[T]
}

-- Использование в выходе контракта:
out regional_revenue: OLAPSlice[Money, {time: DateTime}] =
  Revenue[region: region]               -- 1D срез: временно́й ряд для этого региона
```

Получатель может дополнительно слайсить, сворачивать или пивотировать вывод.

---

## § 6. OLAP, нативный для кластера

### § 6.1 Стратегия партиционирования

OLAP Points партиционируются по узлам кластера через их измерения `indexed:`:

```
olap_point Revenue {
  ...
  indexed: [:time, :product]   -- шардирование по time × product
}
```

Кластер назначает каждый блок (диапазон_времени, диапазон_продуктов) узлу.
Запросы, указывающие оба индексированных измерения, идут к одному узлу.
Запросы, сканирующие много продуктов, идут к нескольким узлам параллельно.

### § 6.2 Параллельное выполнение OLAP-запросов

```
-- Выручка за Q4, все продукты, регион=запад
Revenue[time: :q4_2026, region: :west]
  .rollup(:product)
```

План выполнения (генерируется компилятором):

```
1. SCATTER: найти все партиции, покрывающие (Q4, все_продукты)
2. PARALLEL: для каждого узла партиции:
     fetch Revenue[time: partition.time_range, region: :west]
     rollup(:product)   -- локальный reduce
3. GATHER: объединить частичные rollup со всех узлов
4. REDUCE: слить в финальный результат
```

Это паттерн MapReduce, генерируемый автоматически из OLAP-операции.
Программист объявляет ЧТО — компилятор генерирует распределённое выполнение.

### § 6.3 Иерархия кэша OLAP Point

```
L1: Внутрипроцессный кэш  — запечатанные сегменты на локальном узле (без TTL)
L2: Локальный кэш узла    — недавно полученные удалённые сегменты (контент-адресуемые)
L3: Gossip-кэш кластера   — сегменты, реплицированные на replication_factor узлов
L4: Холодное хранилище    — архивные сегменты (объектное хранилище, S3-совместимое)
```

Поскольку запечатанные сегменты контент-адресуемы, попадание в кэш всегда
корректно — инвалидация кэша для запечатанных сегментов не нужна никогда.
Только голова (незапечатанный, изменяемый) требует синхронизации.

---

## § 7. Связь с графом контрактов

### § 7.1 OLAP Points как узлы контракта

Объявление `olap_point` создаёт специальный тип узла в графе контрактов:
**Аналитический узел**. Он обладает теми же свойствами, что и другие узлы:
- Типизирован (тип меры)
- Ленив (вычисляется по требованию)
- Кэшируется (контент-адресуемые запечатанные сегменты)
- Версионирован (цепочка сегментов — это история версий)

Но обслуживается не обычным движком выполнения контрактов, а **OLAP-движком**,
управляющим распределённым партиционированием и параллельной агрегацией.

### § 7.2 Мост операционные → аналитические данные

Система контрактов вычисляет факты (операционная часть). OLAP-система агрегирует
факты (аналитическая часть). Мост — функция `source:` в объявлении OLAP Point:

```
olap_point Revenue {
  source: fn(t, product, region, channel) -> Money =
    FulfilledOrders {          -- выполнение контракта (операционная часть)
      period:  t.day
      product: product
      region:  region
      channel: channel
    }.total                   -- OLAP-движок поглощает результат (аналитическая часть)
}
```

OLAP-движок вызывает исходный контракт для каждой уникальной комбинации
(t, product, region, channel) и сохраняет результат в структуре сегментов.
Последующие чтения приходят из кэша сегментов — контракт вызывается только
один раз для каждой уникальной комбинации входов.

---

## § 8. Открытые направления исследований

1. **Синтез OLAP Point** — дана цель по выручке как ограничение на OLAP Point,
   синтезировать контракт (или правило), её достигающий. Связывает синтез
   временны́х правил (§2 temporal-deep) с многомерными целями.

2. **Инкрементальный OLAP** — при выполнении нового заказа обновлять только
   затронутые OLAP-ячейки. Связь с инкрементальными вычислениями
   из [igniter-lang-precomp.md](igniter-lang-precomp.md).

3. **Инварианты OLAP Point** — объявлять ограничения на OLAP Points как
   инварианты: `Revenue.rollup(:all) >= cost.rollup(:all)` (система прибыльна).
   Компилятор проверяет статически.

4. **Приближённый OLAP** — использовать ячейки `~T` для высококардинальных
   измерений, где точное вычисление слишком дорого.

5. **OLAP как язык запросов** — операции slice/rollup/drill/pivot образуют
   полный язык запросов. Является ли он (подмножеством) SQL или MDX?
   Каковы формальные границы выразимости?
