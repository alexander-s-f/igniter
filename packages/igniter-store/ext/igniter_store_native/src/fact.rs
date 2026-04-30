use magnus::{
    r_hash::ForEach, prelude::*, Error, IntoValue, RArray, RHash, Ruby, Symbol, Value,
};
use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;

/// Pure-Rust representation of an immutable fact.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FactData {
    pub id: String,
    pub store: String,
    pub key: String,
    /// Stable-sorted JSON with symbol-tagged strings (":foo" = Ruby :foo).
    pub value: serde_json::Value,
    pub value_hash: String,
    pub causation: Option<String>,
    pub timestamp: f64,
    pub term: i64,
    pub schema_version: i64,
}

/// Ruby-visible Fact class backed by Rust.
#[magnus::wrap(class = "Igniter::Store::Fact", free_immediately, size)]
pub struct Fact(pub FactData);

// ── Class method ─────────────────────────────────────────────────────────────

pub fn rb_build(
    store: String,
    key: String,
    rb_value: RHash,
    causation: Option<String>,
    term: i64,
    schema_version: i64,
) -> Result<Fact, Error> {
    let json_val = ruby_hash_to_json_sorted(rb_value.as_value());
    let json_str = serde_json::to_string(&json_val)
        .map_err(|e| Error::new(magnus::exception::runtime_error(), e.to_string()))?;
    let value_hash = blake3::hash(json_str.as_bytes()).to_hex().to_string();

    Ok(Fact(FactData {
        id: uuid::Uuid::new_v4().to_string(),
        store,
        key,
        value: json_val,
        value_hash,
        causation,
        timestamp: current_time(),
        term,
        schema_version,
    }))
}

// ── Instance methods ──────────────────────────────────────────────────────────

impl Fact {
    pub fn rb_id(&self) -> String { self.0.id.clone() }
    pub fn rb_store(&self) -> String { self.0.store.clone() }
    pub fn rb_key(&self) -> String { self.0.key.clone() }

    pub fn rb_value(&self) -> Value {
        let ruby = unsafe { Ruby::get_unchecked() };
        json_to_ruby_value(&ruby, &self.0.value)
    }

    pub fn rb_value_hash(&self) -> String { self.0.value_hash.clone() }

    pub fn rb_causation(&self) -> Value {
        let ruby = unsafe { Ruby::get_unchecked() };
        match &self.0.causation {
            Some(s) => s.as_str().into_value_with(&ruby),
            None    => ruby.qnil().as_value(),
        }
    }

    pub fn rb_timestamp(&self)      -> f64  { self.0.timestamp }
    pub fn rb_term(&self)           -> i64  { self.0.term }
    pub fn rb_schema_version(&self) -> i64  { self.0.schema_version }
    pub fn rb_frozen(&self)         -> bool { true }

    pub fn rb_to_h(&self) -> Result<RHash, Error> {
        let ruby = unsafe { Ruby::get_unchecked() };
        let h = RHash::new();
        h.aset(Symbol::new("id"),             self.0.id.as_str())?;
        h.aset(Symbol::new("store"),          Symbol::new(self.0.store.as_str()))?;
        h.aset(Symbol::new("key"),            self.0.key.as_str())?;
        h.aset(Symbol::new("value"),          json_to_ruby_value(&ruby, &self.0.value))?;
        h.aset(Symbol::new("value_hash"),     self.0.value_hash.as_str())?;
        match &self.0.causation {
            Some(s) => h.aset(Symbol::new("causation"), s.as_str())?,
            None    => h.aset(Symbol::new("causation"), ruby.qnil())?,
        }
        h.aset(Symbol::new("timestamp"),      self.0.timestamp)?;
        h.aset(Symbol::new("term"),           self.0.term)?;
        h.aset(Symbol::new("schema_version"), self.0.schema_version)?;
        Ok(h)
    }

    pub fn rb_inspect(&self) -> String {
        format!(
            "#<Igniter::Store::Fact store={:?} key={:?} hash={}>",
            self.0.store,
            self.0.key,
            &self.0.value_hash[..12]
        )
    }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

pub fn ruby_hash_to_json_sorted(val: Value) -> serde_json::Value {
    ruby_to_json_inner(val)
}

fn ruby_to_json_inner(val: Value) -> serde_json::Value {
    if val.is_nil() {
        return serde_json::Value::Null;
    }
    // Symbol :foo → tagged string ":foo" (preserves round-trip identity)
    if let Some(sym) = Symbol::from_value(val) {
        let name = sym.name().unwrap_or_default();
        return serde_json::Value::String(format!(":{name}"));
    }
    // Array
    if let Some(arr) = RArray::from_value(val) {
        let len = arr.len();
        let items: Vec<serde_json::Value> = (0..len)
            .map(|i| {
                arr.entry(i as isize)
                    .map(ruby_to_json_inner)
                    .unwrap_or(serde_json::Value::Null)
            })
            .collect();
        return serde_json::Value::Array(items);
    }
    // Hash — keys sorted via BTreeMap for stable hashing
    if let Some(hash) = RHash::from_value(val) {
        let mut map: BTreeMap<String, serde_json::Value> = BTreeMap::new();
        let _ = hash.foreach(|k: Value, v: Value| {
            let key = if let Some(sym) = Symbol::from_value(k) {
                sym.name().unwrap_or_default().to_string()
            } else if let Ok(s) = String::try_convert(k) {
                s
            } else {
                k.inspect()
            };
            map.insert(key, ruby_to_json_inner(v));
            Ok(ForEach::Continue)
        });
        return serde_json::Value::Object(map.into_iter().collect());
    }
    // Integer (check before Float — Ruby Integers satisfy f64::try_convert too)
    if let Ok(i) = i64::try_convert(val) {
        return serde_json::json!(i);
    }
    // Float
    if let Ok(f) = f64::try_convert(val) {
        return serde_json::json!(f);
    }
    // String
    if let Ok(s) = String::try_convert(val) {
        return serde_json::Value::String(s);
    }
    // Boolean fallback via inspect
    match val.inspect().as_str() {
        "true"  => serde_json::Value::Bool(true),
        "false" => serde_json::Value::Bool(false),
        other   => serde_json::Value::String(other.to_string()),
    }
}

/// serde_json::Value → Ruby Value.
/// Strings prefixed with ":" are restored as Ruby Symbols.
pub fn json_to_ruby_value(ruby: &Ruby, val: &serde_json::Value) -> Value {
    match val {
        serde_json::Value::Null => ruby.qnil().as_value(),
        serde_json::Value::Bool(b) => {
            if *b { ruby.qtrue().as_value() } else { ruby.qfalse().as_value() }
        }
        serde_json::Value::Number(n) => {
            if let Some(i) = n.as_i64() {
                i.into_value_with(ruby)
            } else if let Some(f) = n.as_f64() {
                f.into_value_with(ruby)
            } else {
                ruby.qnil().as_value()
            }
        }
        serde_json::Value::String(s) => {
            if s.starts_with(':') {
                Symbol::new(&s[1..]).as_value()
            } else {
                s.as_str().into_value_with(ruby)
            }
        }
        serde_json::Value::Array(arr) => {
            let rb_arr = RArray::new();
            for item in arr {
                let _ = rb_arr.push(json_to_ruby_value(ruby, item));
            }
            rb_arr.as_value()
        }
        serde_json::Value::Object(obj) => {
            let rb_hash = RHash::new();
            for (k, v) in obj {
                let key = Symbol::new(k.as_str()).as_value();
                let _ = rb_hash.aset(key, json_to_ruby_value(ruby, v));
            }
            rb_hash.as_value()
        }
    }
}

fn current_time() -> f64 {
    std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs_f64()
}
