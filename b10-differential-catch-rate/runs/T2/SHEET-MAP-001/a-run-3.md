```rust
use std::collections::HashMap;

/// Ledger-side instrument identifier (newtype to avoid raw-String mixups).
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct Symbol(pub String);

/// Subset of `config` relevant here: Symbol -> GOOGLEFINANCE ticker overrides.
/// Absent key => identity mapping.
#[derive(Debug, Default, serde::Deserialize)]
pub struct TickerAliasMap(pub HashMap<Symbol, String>);

impl TickerAliasMap {
    /// Resolve a ledger Symbol to its GOOGLEFINANCE ticker string.
    pub fn resolve(&self, symbol: &Symbol) -> String {
        self.0
            .get(symbol)
            .cloned()
            .unwrap_or_else(|| symbol.0.clone())
    }
}

/// Build the live-price formula for a resolved ticker.
pub fn price_formula(ticker: &str) -> String {
    format!(r#"=GOOGLEFINANCE("{ticker}","price")"#)
}

/// Full SHEET-MAP-001 pipeline: Symbol -> resolved ticker -> Price formula.
///
/// @spec SHEET-MAP-001
pub fn build_price_formula(symbol: &Symbol, aliases: &TickerAliasMap) -> String {
    price_formula(&aliases.resolve(symbol))
}
```

Assumptions (invented, none derivable from the EARS text alone):

1. `Symbol` is a newtype over `String` (`Eq + Hash + Clone`) rather than a bare `String`, since the ledger elsewhere treats domain identifiers as typed.
2. `TickerAliasMap` is `HashMap<Symbol, String>`, deserialized (`serde`) as a sub-field of the crate's `config` struct — chosen over `Vec<(Symbol,String)>` for O(1) lookup; no ordering/duplicate-key semantics specified so `HashMap`'s "last wins on parse" is accepted as-is.
3. "Identity when unset" interpreted as: absent map *entry* for that symbol, not an absent/empty map overall — both collapse to the same `unwrap_or_else` fallback.
4. No case-folding or whitespace trimming on the Symbol before lookup — exact match only; the EARS doesn't mention normalization, so none is invented.
5. An alias entry mapping to an *empty string* is passed through as-is (produces `GOOGLEFINANCE("","price")`); validating config content is assumed to be the config crate's job, not sheets-view's, since sheets-view "owns no accounting or tax math" but this module also shouldn't silently invent validation logic beyond its stated resolve step.
6. GOOGLEFINANCE attribute hard-coded to `"price"` — the requirement says "build the `Price` formula," read as the specific price-attribute variant of the formula, not a parameterized attribute.
7. No escaping of quote characters inside a resolved ticker string — assumed tickers/aliases never contain `"`; not in scope per the EARS.
8. Resolution is total/infallible (no `Result`/error path) because the identity fallback guarantees a value for every Symbol — no invalid-Symbol case exists at this layer.
9. No exchange-prefix (`NASDAQ:`) synthesis — assumed any such prefix is already baked into the alias map's stored ticker string, not derived here.