# Igniter Contract Language — Спецификация языка v0.1

Дата: 2026-04-27.
Статус: черновая спецификация — не реализована.
Область: система типов, примитивные конструкции, контрактная модель, система аннотаций.

*Теоретическая база: [igniter-lang-theory.md](igniter-lang-theory.md) и [igniter-lang-theory2.md](igniter-lang-theory2.md)*

---

## § 0. Нотация

```
::=    определение
|      альтернатива
[x]    ноль или один вхождение x
{x}    ноль или более вхождений x
(x)    группировка
UPPER  терминальный токен
lower  нетерминал
'x'    литеральное ключевое слово
⊢      выводит / типизируется как
→      отображает в / тип функции
⊑      подтип
```

---

## § 1. Система типов

### § 1.1 Примитивные типы

```
prim ::=
  | 'Bool'                     -- true | false
  | 'Int'                      -- целое число произвольной точности
  | 'Float'                    -- число двойной точности IEEE 754
  | 'String'                   -- текст в кодировке UTF-8
  | 'Symbol'                   -- интернированный атом, напр. :pending
  | 'DateTime'                 -- временная метка с часовым поясом
  | 'Date'                     -- календарная дата
  | 'Duration'                 -- временной промежуток
  | 'Money'                    -- десятичное число + код валюты
  | 'Id'                       -- непрозрачный идентификатор (UUID / целое)
  | 'Json'                     -- нетипизированное JSON-значение
  | 'Bytes'                    -- последовательность байтов
  | 'Null'                     -- отсутствующее значение (дно Option)
```

`Money` — полноправный примитив (не `Float`). Арифметика над `Money` выполняется
в точной десятичной нотации; операции со смешанными валютами являются ошибкой типов.

### § 1.2 Составные типы

```
type_expr ::=
  | prim                                   -- примитив
  | IDENT                                  -- именованный тип
  | '{' {field_decl ','} '}'              -- запись (анонимная)
  | 'Enum' '[' {SYMBOL ','} ']'           -- перечисление
  | '[' type_expr ']'                      -- список (упорядоченный, однородный)
  | '{' type_expr '}'                      -- множество (неупорядоченное, уникальное)
  | type_expr '?'                          -- опция  (T? = Option[T])
  | type_expr 'where' predicate            -- уточнение (refinement)
  | '~' type_expr                          -- приближённое значение
  | type_expr '→' type_expr               -- функция
  | 'Contract' '(' type_expr ')' '→' type_expr  -- сигнатура контракта

field_decl ::= IDENT ':' type_expr ['=' expr]
```

### § 1.3 Объявления типов

```
type_decl ::=
  | 'type' IDENT '=' type_expr                          -- псевдоним
  | 'type' IDENT '{' {field_decl} '}'                   -- запись
  | 'type' IDENT '=' IDENT 'where' predicate            -- псевдоним с уточнением
```

**Примеры:**

```
type OrderStatus = Enum[:pending, :processing, :complete, :cancelled]

type Product {
  id:        Id
  name:      String
  available: Bool
  stock:     Int where stock >= 0
  price:     Money where price > 0
  category:  Enum[:physical, :digital]
}

type Manager {
  id:             Id
  approved:       Bool
  approval_limit: Money where approval_limit > 0
}

type AvailableProduct = Product where available = true && stock > 0
type ApprovedManager  = Manager  where approved = true
```

### § 1.4 Правила подтипизации

```
─────────────────
τ ⊑ τ                                  (рефлексивность)

τ₁ ⊑ τ₂   τ₂ ⊑ τ₃
──────────────────
τ₁ ⊑ τ₃                                (транзитивность)

{ x: τ | P(x) ∧ Q(x) } ⊑ { x: τ | P(x) }   (ослабление уточнения)

{ x: τ | P(x) } ⊑ τ                   (стирание уточнения)

τ ⊑ τ?                                 (вложение в опцию)

τ₁ ⊑ τ₂
──────────────────
[τ₁] ⊑ [τ₂]                            (ковариантность списка)

τ₁ ⊑ τ₂
──────────────────
τ₁? ⊑ τ₂?                              (ковариантность опции)

{ l₁: τ₁, l₂: τ₂, l₃: τ₃ } ⊑ { l₁: τ₁, l₂: τ₂ }   (ширина записи)

τ₁' ⊑ τ₁   τ₂ ⊑ τ₂'
──────────────────────────────────────
(τ₁ → τ₂) ⊑ (τ₁' → τ₂')              (контр./ковариантность функции)
```

### § 1.5 Приближённый тип `~T`

`~T` (читается: «приближённо T») представляет значение типа `T`, известное лишь
в пределах доверительного интервала. Производится узлами с аннотацией `@approximate`
и потребляется узлами, объявившими `@tolerance`.

```
~T несёт:  { value: T, lo: T, hi: T, confidence: Float }
```

Подтипизация: `T ⊑ ~T` (точное значение — вырожденное приближение с lo = hi = value).

Операции над `~T`:
- Арифметические операторы подняты: `~T + ~T → ~T` (интервальная арифметика)
- Сравнение `~T > literal` → `Bool | Uncertain` (трёхзначная логика)
- Приведение `.exact`: принудительно точное вычисление, тип становится `T`

### § 1.6 Метки эффектов

Каждое выражение несёт множество меток эффектов:

```
ε ::= ∅          -- чистое
    | IO          -- читает/пишет внешнее состояние
    | Cache       -- читает/пишет кэш узлов
    | Rand        -- недетерминированное (сэмплирование)
    | Fail        -- может поднять ошибку
    | ε₁ ∪ ε₂    -- объединение
```

Тип функции с эффектами: `τ₁ →[ε] τ₂`

Чистые функции: `τ₁ →[∅] τ₂` (сокращённо `τ₁ → τ₂`)

Вычислительные узлы с эффектом `IO` помечаются `@effect` и выполняются после
всех чистых узлов того же страта.

---

## § 2. Выражения

### § 2.1 Грамматика выражений

```
expr ::=
  | literal                              -- Bool, Int, Float, String, Symbol
  | path                                 -- node_name | node_name.field
  | IDENT '(' {expr ','} ')'            -- вызов функции
  | expr '|>' expr                       -- конвейер (лево-ассоциативный)
  | expr 'op' expr                       -- инфикс (арифметика, сравнение, логика)
  | 'if' expr 'then' expr 'else' expr   -- условное выражение
  | '{' {stmt} expr '}'                  -- блок (последнее выражение — результат)
  | '[' {expr ','} ']'                   -- литерал списка
  | IDENT '{' {IDENT ':' expr ','} '}'  -- конструирование записи
  | expr '.' IDENT                       -- доступ к полю
  | expr '?.' IDENT                      -- безопасный доступ к полю (Option)
  | '~' expr                             -- подъём в приближённое значение
  | expr '@exact'                        -- принудительное точное вычисление
  | IDENT '{' {mapping} '}'             -- вызов контракта (инлайн compose)

literal ::= BOOL | INT | FLOAT | STRING | SYMBOL | NULL
path    ::= IDENT {'.' IDENT}
mapping ::= IDENT ':' expr
```

### § 2.2 Оператор конвейера

`a |> f` — синтаксический сахар для `f(a)`.
`a |> f(x, y)` — синтаксический сахар для `f(a, x, y)` (частичное применение слева).

Конвейеры объединяются без промежуточных имён:

```
compute :result =
  raw_data
  |> validate
  |> normalize
  |> transform(config)
  |> classify
```

### § 2.3 Блочные выражения

Блок вводит локальные привязки, видимые только внутри блока:

```
compute :total = {
  let subtotal = sum(items |> map { |i| i.price * i.qty })
  let discount = if coupon.active then subtotal * coupon.rate else 0
  subtotal - discount
}
```

Привязки `let` неизменяемы и не видны за пределами блока.

---

## § 3. Конструкции контракта

### § 3.1 Объявление контракта

```
contract_decl ::=
  'contract' IDENT [':' IDENT] '{' {node_decl} '}'
```

Необязательное `: IDENT` задаёт родительский контракт для расширения.
Расширение контракта наследует все узлы и может добавлять новые или уточнять охранники.

```
contract PriceQuote {
  in vendor_id: Id
  in zip_code:  Zip
  ...
}

contract UrgentPriceQuote : PriceQuote {
  // наследует vendor_id, zip_code
  in deadline:  DateTime       // добавляет новый вход
  guard :not_expired { deadline > now() }
}
```

### § 3.2 `in` — Входной узел

```
in_node ::= 'in' IDENT ':' type_expr ['=' expr]
```

Объявляет именованное входное значение. Необязательное `= expr` — **выражение по умолчанию**,
вычисляемое лениво, если вызывающий код не предоставил входное значение.
Выражение по умолчанию может ссылаться на другие узлы `in`.

**Правило типизации:**
```
─────────────────────────────────────────────────────
Γ ⊢ (in :a : τ) : Γ ∪ { a : τ }
```

**Примеры:**
```
in vendor_id:   Id
in zip_code:    Zip
in as_of:       DateTime = now()
in max_results: Int where max_results > 0 = 100
```

### § 3.3 `compute` — Вычислительный узел

```
compute_node ::=
  'compute' IDENT [':' type_expr] '=' expr {annotation}
```

Объявляет именованное вычисляемое значение. Зависимости **выводятся** из свободных
переменных выражения `expr`, ссылающихся на другие узлы контракта.

**Правило типизации:**
```
Γ ⊢ expr : τ   [τ_ann ⊑ τ при наличии аннотации]
──────────────────────────────────────────────────
Γ ⊢ (compute :y = expr) : Γ ∪ { y : τ }
```

**Примеры:**
```
compute :vendor  = fetch_vendor(vendor_id)
compute :slots   = vendor.slots |> select { |s| s.zip == zip_code && s.available }
compute :count   = slots |> count
compute :subtotal: Money = items |> sum { |i| i.price * i.qty }
```

**Чистота**: узел `compute` чистый по умолчанию. Если выражение имеет эффект `IO`,
узел должен быть аннотирован `@effect`.

### § 3.4 `const` — Константа времени компиляции

```
const_node ::= 'const' IDENT '=' literal
```

Вычисляется во время компиляции. Не имеет зависимостей. Эквивалентен `compute`
на литерале, но компилятор проверяет, что значение является константой.

```
const :tax_rate    = 0.20
const :max_retries = 3
const :default_tz  = :UTC
```

### § 3.5 `guard` — Узел ограничения

```
guard_node ::=
  'guard' IDENT '{' guard_body '}'

guard_body ::=
  ['when' expr]
  {guard_clause}
  ['on_fail' ':' SYMBOL]

guard_clause ::=
  | expr                          -- предикат (должен быть истинным)
  | IDENT 'must' 'be' expr        -- именованное утверждение
  | IDENT 'in' expr               -- утверждение о принадлежности
```

Охранник утверждает условия, которые должны выполняться для продолжения контракта.
Если условие нарушено, контракт поднимает ошибку объявленного типа
(по умолчанию: `:guard_violation`).

`when:` делает охранник условным — он активируется только когда выражение `when`
истинно.

**Правило типизации:**
```
Γ ⊢ cond : Bool   (для каждого предложения)
Γ ⊢ when_expr : Bool   (при наличии)
────────────────────────────────────────────────
Γ ⊢ (guard :g { ... }) : Γ   -- охранник не вводит новую привязку,
                               -- но уточняет типы проверенных узлов
```

**Эффект уточнения**: охранник, проверяющий `x.available = true`, уточняет тип
`x` с `Product` до `AvailableProduct` в узлах, зависящих от `:g`.

**Примеры:**
```
guard :product_ok {
  product.available = true
  product.stock > 0
  on_fail: :out_of_stock
}

guard :discount_consistent {
  when marketing.campaign_active
  marketing.discount_applied must be true
}

guard :within_budget {
  total <= manager.approval_limit
  on_fail: :approval_limit_exceeded
}
```

### § 3.6 `branch` — Условная диспетчеризация

```
branch_node ::=
  'branch' IDENT '{' {branch_arm} [default_arm] '}'

branch_arm ::=
  'on' expr '=>' (expr | inline_contract)

default_arm ::=
  'default' '=>' (expr | inline_contract)

inline_contract ::=
  IDENT '{' {mapping} '}'
```

Ветвление выбирает ровно одну ветвь. Ветви проверяются сверху вниз; выбирается
первая совпавшая. Ветвь `default` обязательна, если ветви не покрывают все
возможные значения.

**Правило типизации:**
```
Γ ⊢ c₁ : Bool  Γ ⊢ e₁ : τ
...
Γ ⊢ cₙ : Bool  Γ ⊢ eₙ : τ
Γ ⊢ e_default : τ
────────────────────────────────────────────────────
Γ ⊢ (branch :b { on c₁ => e₁; ...; default => e_d })
  : Γ ∪ { b : τ }
```

Все ветви должны иметь одинаковый тип результата `τ`. Если они возвращают
подконтракты, типы их выходов должны быть структурно совместимы.

**Примеры:**
```
branch :routing {
  on order.total > 10_000 => HighValueFlow { order: order }
  on order.type == :digital => DigitalFlow  { order: order }
  default                   => StandardFlow { order: order }
}

branch :slot_result {
  on slots.count > 0 => slots.first
  default            => Null
}
```

### § 3.7 `compose` — Встраивание подконтракта

```
compose_node ::=
  'compose' IDENT '=' IDENT '{' {mapping} '}'

mapping ::= IDENT ':' expr
```

Встраивает именованный контракт. Блок `{ }` отображает выражения текущего
контекста на входные узлы подконтракта. Значение узла compose — запись выходов
подконтракта.

**Правило типизации:**
```
C : Contract({ a: τ_a, b: τ_b }) → { x: τ_x, y: τ_y }
Γ ⊢ expr_a : τ_a'   τ_a' ⊑ τ_a
Γ ⊢ expr_b : τ_b'   τ_b' ⊑ τ_b
────────────────────────────────────────────────────────
Γ ⊢ (compose :sub = C { a: expr_a, b: expr_b })
  : Γ ∪ { sub: { x: τ_x, y: τ_y } }
```

Поля составного вывода доступны как `sub.x`, `sub.y`.

**Пример:**
```
compose :pricing  = PriceQuote {
  vendor_id: order.vendor_id
  zip_code:  order.shipping_zip
}

compute :final_price = pricing.quote.total
```

### § 3.8 `collection` — Функтор над списком

```
collection_node ::=
  'collection' IDENT '='
    ('map' '(' expr ',' IDENT ')' |          -- применить контракт к каждому
     expr '|>' 'select' block    |           -- фильтрация
     expr '|>' 'map' block)                  -- преобразование
    {annotation}
```

Применяет контракт или функцию к каждому элементу списка.

**Правило типизации:**
```
Γ ⊢ source : [τ_elem]
C : Contract({ input: τ_elem }) → τ_out
────────────────────────────────────────────────
Γ ⊢ (collection :ys = map(source, C))
  : Γ ∪ { ys : [τ_out] }
```

**Примеры:**
```
collection :quoted_items = map(order.items, ItemQuote)

collection :available_slots =
  vendor.slots |> select { |s| s.available && s.zip == zip_code }
```

### § 3.9 `aggregate` — Свёртка над списком

```
aggregate_node ::=
  'aggregate' IDENT '='
    (agg_op '(' expr ')'                     -- встроенная агрегация
    | expr '|>' 'fold' '(' expr ',' fn ')')  -- пользовательская свёртка

agg_op ::= 'count' | 'sum' | 'avg' | 'min' | 'max' | 'group_by'
```

**Правила типизации:**
```
Γ ⊢ source : [τ]
──────────────────────────────────────────────────────────────
Γ ⊢ (aggregate :n = count(source))    : Γ ∪ { n : Int }
Γ ⊢ (aggregate :s = sum(source))      : Γ ∪ { s : τ }      -- τ числовой
Γ ⊢ (aggregate :a = avg(source))      : Γ ∪ { a : Float }

Γ ⊢ source : [τ]
Γ ⊢ init : τ_acc
Γ ⊢ fn : (τ_acc, τ) → τ_acc
──────────────────────────────────────────────────────────────
Γ ⊢ (aggregate :r = source |> fold(init, fn)) : Γ ∪ { r : τ_acc }
```

**Примеры:**
```
aggregate :total_value = sum(items |> map { |i| i.price * i.qty })
aggregate :item_count  = count(items)
aggregate :by_category = group_by(items, :category)
```

### § 3.10 `effect` — Узел побочного эффекта

```
effect_node ::=
  'effect' IDENT '=' IDENT '{' {mapping} '}' {effect_annotation}

effect_annotation ::=
  | '@idempotent'
  | '@compensate' ':' IDENT
  | '@on_success' ':' IDENT
```

Выполняет зарегистрированный эффект (IO, внешний вызов, генерация события). Эффекты
выполняются после всех чистых узлов того же страта. Узлы эффектов по умолчанию
не производят вычисляемого значения (их результат — `Unit`, если только эффект
не возвращает значение — тогда тип объявляется явно).

```
effect :send_confirmation =
  EmailEffect {
    to:      customer.email
    subject: "Заказ #{order.id} подтверждён"
    body:    render_template(:order_confirmed, order: order)
  }
  @idempotent
  @compensate: CancelEmailEffect
```

### § 3.11 `await` — Приостановка распределённого события

```
await_node ::=
  'await' IDENT ',' 'event' ':' SYMBOL
  [',' 'timeout' ':' duration_expr]
  [',' 'payload' ':' type_expr]
```

Приостанавливает выполнение контракта до прибытия именованного события
(распределённый рабочий процесс). Контракт сохраняет своё состояние; выполнение
возобновляется при доставке события через `Contract.deliver_event`.

```
await :payment_confirmed, event: :payment_received,
                          timeout: 24.hours,
                          payload: PaymentPayload
```

### § 3.12 `out` — Объявление выхода

```
out_node ::= 'out' IDENT [':' type_expr] '=' expr
```

Объявляет именованное выходное значение. Несколько узлов `out` определяют
тип выходной записи контракта. Компилятор проверяет согласованность всех типов `out`.

**Правило типизации:**
```
Γ ⊢ expr : τ   [τ_ann ⊑ τ при наличии аннотации]
─────────────────────────────────────────────────────────────
Γ ⊢ (out :x = expr) добавляет { x: τ } к выходам контракта
```

**Примеры:**
```
out quote:  Quote  = pricing.quote
out vendor: Vendor = vendor
out status: OrderStatus = order_status
```

---

## § 4. Сигнатура и композиция контрактов

### § 4.1 Сигнатура контракта

**Сигнатура** контракта выводится из его объявлений `in` и `out`:

```
contract Foo {
  in a: A
  in b: B
  ...
  out x: X = ...
  out y: Y = ...
}
```

Сигнатура: `Foo : Contract({ a: A, b: B }) → { x: X, y: Y }`

Сигнатура — это тип контракта как значения. Она используется в `compose`,
`collection` и `branch` для проверки совместимости во время компиляции.

### § 4.2 Контракт как значение

Контракты — значения первого класса. Имя контракта, использованное как выражение,
имеет тип `Contract(I) → O`. Это позволяет:

```
fn choose_strategy(order: Order) -> Contract({order: Order}) → {result: Result} =
  if order.total > 10_000 then HighValueStrategy else StandardStrategy

compose :result = choose_strategy(order) { order: order }
```

### § 4.3 Законы композиции

Пусть `A : Contract(I_A) → O_A` и `B : Contract(I_B) → O_B`, где `O_B ⊇ I_A`
(выходы B включают все входы A):

```
(A after B) : Contract(I_B) → O_A
```

Последовательная композиция ассоциативна:
```
(A after B) after C = A after (B after C)
```

Тождественный контракт:
```
id[τ] : Contract(τ) → τ    -- передаёт все входы напрямую на выходы
```

---

## § 5. Система аннотаций

Аннотации изменяют поведение узлов, не меняя их типы.
Все аннотации начинаются с `@`.

### § 5.1 Аннотации кэширования

```
@cache(ttl)          -- кэшировать результат узла на время `ttl`
@cache(:forever)     -- кэшировать до явной инвалидации
@coalesce            -- дедуплицировать параллельные запросы с теми же входами
@fingerprint         -- использовать ключ кэша по содержимому (для изменяемых входов)
```

`ttl` — литерал типа `Duration`: `60s`, `5min`, `1h`, `1d`.

Эти аннотации применяются только к узлам `compute`. Ключ кэша определяется
именем узла и значениями всех объявленных зависимостей.

### § 5.2 Аннотации приближённых вычислений

```
@approximate(method: :monte_carlo, samples: 1_000)
@approximate(method: :interval)
@approximate(method: :delta)
@confidence(0.95)          -- минимально требуемая достоверность
@tolerance(0.01)           -- максимально допустимая относительная погрешность (1%)
```

Применяются к узлам `compute` для объявления стратегии приближённого вычисления.
Узел с аннотацией `@approximate` имеет тип `~T` (где `T` — точный тип).

Нижестоящие узлы объявляют требования к точности:
```
@exact                     -- требовать полного вычисления вышестоящего
@tolerance(0.05)           -- допускать приближение с погрешностью до 5%
```

### § 5.3 Аннотации выполнения

```
@parallel             -- подсказка: этот узел может выполняться параллельно с соседями
@sequential           -- подсказка: этот узел не должен выполняться параллельно
@timeout(duration)    -- завершить с ошибкой, если не разрешён за указанное время
@retry(n)             -- повторить при временном сбое, до n раз
@fallback(expr)       -- при неудаче этого узла использовать expr вместо него
```

### § 5.4 Интроспекция и наблюдаемость

```
@trace                -- генерировать трассировочное событие при разрешении узла
@audit                -- включить этот узел в журнал аудита
@label("описание")    -- описание для инструментов в удобочитаемой форме
```

---

## § 6. Объявления функций

Функции — именованные переиспользуемые выражения. Они не являются контрактами —
у них нет графа зависимостей, кэширования, эффектов. Они компилируются в обычные
функции целевой среды выполнения.

```
fn_decl ::=
  'fn' IDENT '(' {param ','} ')' ['->' type_expr] '=' expr

param ::= IDENT ':' type_expr
```

**Правило типизации:**
```
x₁: τ₁, ..., xₙ: τₙ ⊢ body : τ_ret
────────────────────────────────────────────────────────
⊢ fn f(x₁: τ₁, ..., xₙ: τₙ) -> τ_ret = body
  : τ₁ → ... → τₙ → τ_ret
```

**Примеры:**
```
fn effective_price(price: Money, discount: Float) -> Money =
  price * (1.0 - discount)

fn classify_risk(score: Float) -> Symbol =
  if score > 0.8 then :high
  else if score > 0.5 then :medium
  else :low

fn ~estimate_revenue(summary: SampleSummary, rate: Float) -> ~Money =
  summary.mean * rate
  @confidence(0.95) @method(:delta)
```

Префикс `~` в имени функции объявляет приближённый подъём соответствующей
точной функции (см. документ о предвычислении).

---

## § 7. Полная грамматика

```
program ::= {declaration}

declaration ::=
  | type_decl
  | fn_decl
  | contract_decl
  | model_decl           -- модель свойств (синтез; см. спецификацию propmodel)

-- Типы
type_decl ::=
  | 'type' IDENT '=' type_expr
  | 'type' IDENT '{' {field_decl} '}'
  | 'type' IDENT '=' IDENT 'where' predicate

field_decl ::= IDENT ':' type_expr ['=' expr]

type_expr ::=
  | IDENT
  | '{' {field_decl ','} '}'
  | 'Enum' '[' {SYMBOL ','} ']'
  | '[' type_expr ']'
  | '{' type_expr '}'
  | type_expr '?'
  | type_expr 'where' predicate
  | '~' type_expr
  | type_expr '→' type_expr
  | 'Contract' '(' type_expr ')' '→' type_expr

-- Функции
fn_decl ::=
  ['~'] 'fn' IDENT '(' {param ','} ')' ['->' type_expr] '=' expr

param ::= IDENT ':' type_expr

-- Контракты
contract_decl ::=
  'contract' IDENT [':' IDENT] '{' {node_decl} '}'

node_decl ::=
  | 'in'         IDENT ':' type_expr ['=' expr]
  | 'const'      IDENT '=' literal
  | 'compute'    IDENT [':' type_expr] '=' expr {annotation}
  | 'guard'      IDENT '{' guard_body '}'
  | 'branch'     IDENT '{' {branch_arm} [default_arm] '}'
  | 'compose'    IDENT '=' IDENT '{' {mapping} '}'
  | 'collection' IDENT '=' collection_expr {annotation}
  | 'aggregate'  IDENT '=' aggregate_expr
  | 'effect'     IDENT '=' IDENT '{' {mapping} '}' {effect_annotation}
  | 'await'      IDENT ',' 'event' ':' SYMBOL {await_option}
  | 'out'        IDENT [':' type_expr] '=' expr

guard_body ::=
  ['when' expr]
  {expr | IDENT 'must' 'be' expr | IDENT 'in' expr}
  ['on_fail' ':' SYMBOL]

branch_arm ::= 'on' expr '=>' (expr | IDENT '{' {mapping} '}')
default_arm ::= 'default' '=>' (expr | IDENT '{' {mapping} '}')

collection_expr ::=
  | 'map' '(' expr ',' IDENT ')'
  | expr '|>' 'select' block
  | expr '|>' 'map' block

aggregate_expr ::=
  | ('count' | 'sum' | 'avg' | 'min' | 'max') '(' expr ')'
  | 'group_by' '(' expr ',' SYMBOL ')'
  | expr '|>' 'fold' '(' expr ',' fn_expr ')'

mapping     ::= IDENT ':' expr
annotation  ::= '@' IDENT ['(' {arg ','} ')']

-- Выражения
expr ::=
  | literal
  | IDENT
  | expr '.' IDENT
  | expr '?.' IDENT
  | IDENT '(' {expr ','} ')'
  | IDENT '{' {mapping} '}'
  | expr '|>' expr
  | expr op expr
  | 'if' expr 'then' expr 'else' expr
  | '{' {('let' IDENT '=' expr)} expr '}'
  | '[' {expr ','} ']'
  | '~' expr
  | expr '@exact'
  | 'fn' '(' {param ','} ')' '=>' expr

literal ::= BOOL | INT | FLOAT | STRING | SYMBOL | 'null'
op      ::= '+' | '-' | '*' | '/' | '%' | '==' | '!=' | '<' | '>'
          | '<=' | '>=' | '&&' | '||' | '!'
```

---

## § 8. Развёрнутый пример

Полная программа, иллюстрирующая основные конструкции:

```
// § Онтология
type OrderStatus = Enum[:pending, :processing, :complete, :cancelled]

type Product {
  id:        Id
  available: Bool
  stock:     Int where stock >= 0
  price:     Money where price > 0
}

type Marketing {
  campaign_active:  Bool
  discount_applied: Bool
  discount_rate:    Float where 0.0 <= discount_rate <= 1.0
}

type Manager {
  id:             Id
  approved:       Bool
  approval_limit: Money
}

// § Чистые функции
fn effective_price(price: Money, discount: Float, active: Bool) -> Money =
  if active then price * (1.0 - discount) else price

// § Контракты
contract FulfillOrder {
  // Входы
  in product:   Product
  in marketing: Marketing
  in manager:   Manager

  // Ограничения
  guard :product_ready {
    product.available = true
    product.stock > 0
    on_fail: :out_of_stock
  }

  guard :discount_consistent {
    when marketing.campaign_active
    marketing.discount_applied must be true
  }

  // Вычисление
  compute :unit_price: Money =
    effective_price(
      product.price,
      marketing.discount_rate,
      marketing.discount_applied
    )

  compute :within_limit: Bool =
    unit_price <= manager.approval_limit

  // Диспетчеризация
  branch :result {
    on manager.approved && within_limit =>
      Order {
        status: :complete
        total:  unit_price
      }
    on !manager.approved =>
      Order { status: :pending, total: unit_price }
    default =>
      Order { status: :cancelled, total: unit_price }
  }

  // Выходы
  out order:      Order       = result
  out unit_price: Money       = unit_price
}

// § Композиция
contract ProcessOrder {
  in order_id: Id

  compose :raw     = FetchOrder    { id: order_id }
  compose :product = FetchProduct  { id: raw.order.product_id }
  compose :mkt     = FetchMarketing { vendor_id: product.vendor_id }
  compose :mgr     = FetchManager  { order_id: order_id }

  compose :fulfilled = FulfillOrder {
    product:   product
    marketing: mkt
    manager:   mgr
  }

  effect :audit = AuditLog {
    entity: :order
    id:     order_id
    action: :fulfilled
    result: fulfilled.order.status
  } @idempotent

  out result: Order = fulfilled.order
}
```

---

## § 9. Гарантии времени компиляции

Программа, прошедшая проверку типов и компилятор, гарантирует:

| Свойство | Гарантия |
|----------|----------|
| **Типобезопасность** | Типовая ошибка во время выполнения невозможна для типизированных программ |
| **Полнота зависимостей** | Каждый упомянутый узел существует и достижим |
| **Ацикличность** | Граф контракта не содержит циклов (свойство DAG) |
| **Покрытие охранников** | Ветви по типам `Enum` покрывают все варианты или имеют `default` |
| **Полнота выходов** | Все узлы `out` достижимы из узлов `in` |
| **Изоляция эффектов** | Чистые узлы не имеют эффектов `IO` |
| **Завершимость** | Чистые DAG-контракты всегда завершаются (разрешимость Datalog) |

---

## § 10. Открытые вопросы для v0.2

1. **Рекурсивные контракты**: синтаксис и правило типизации для opt-in через `@recursive`
2. **Вероятностные типы**: формальные правила типизации для `~T` под композицией
3. **Интеграция с моделями свойств**: объявления `model` и триггер синтеза
4. **Система модулей**: `import` / `export` для многофайловых программ
5. **Типы ошибок**: типизированная иерархия ошибок и правила их распространения
6. **Потоковые контракты**: тип входа `stream` и непрерывное вычисление
7. **Обобщённые типы**: параметрические контракты `contract Mapper[T, U] { ... }`
