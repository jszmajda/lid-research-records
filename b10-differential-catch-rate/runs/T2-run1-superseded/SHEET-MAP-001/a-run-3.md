```rust
use std::collections::HashMap;

/// Ledger symbol → GOOGLEFINANCE ticker alias table, sourced from `config`.
/// Missing entries mean "no alias configured" and fall back to identity.
pub struct TickerAliases(HashMap<String, String>);

impl TickerAliases {
    /// Resolve a ledger `Symbol` to its GOOGLEFINANCE ticker string.
    /// Looks up the alias map by the symbol's canonical text; if no entry
    /// exists (map absent, or this symbol simply unlisted), the ticker is
    /// the symbol's own text (identity).
    pub fn resolve(&self, symbol: &Symbol) -> String {
        self.0
            .get(symbol.as_str())
            .cloned()
            .unwrap_or_else(|| symbol.as_str().to_string())
    }
}

/// Build the `Price` column's GOOGLEFINANCE formula from an already-resolved ticker.
/// Attribute is fixed to "price" since this formula backs the Price column;
/// embedded double quotes in the ticker are escaped defensively for sheet-formula safety.
pub fn price_formula(ticker: &str) -> String {
    format!(
        r#"=GOOGLEFINANCE("{}", "price")"#,
        ticker.replace('"', "\"\"")
    )
}

/// Full SHEET-MAP-001 pipeline: Symbol -> resolved ticker -> Price formula.
pub fn build_price_formula(symbol: &Symbol, aliases: &TickerAliases) -> String {
    price_formula(&aliases.resolve(symbol))
}
```

Assumptions (invented, not stated in the EARS text):

1. **`Symbol` shape**: an existing newtype elsewhere in the kernel exposing `as_str()` (or `AsRef<str>`); not redefined here.
2. **Alias map shape**: `HashMap<String, String>` keyed by the symbol's exact text, value the ticker string — simplest structure satisfying "config's alias map." No `Symbol`-keyed map assumed, to avoid requiring `Hash`/`Eq` on `Symbol` itself.
3. **"Unset" scope**: read as covering both "alias map absent/empty" and "this particular symbol absent from the map" — both collapse to the same identity fallback, since `HashMap::get` on an empty map already returns `None`. Treated as one case, not two.
4. **Case/whitespace**: no normalization — lookup and identity fallback use the symbol's text byte-for-byte. Spec gives no hint of case-folding.
5. **Empty-string alias value**: if config explicitly maps a symbol to `""`, that literal (empty) ticker is used as configured — not treated as another "unset" signal, since the requirement only names the *entry's presence/absence* as the fallback trigger, not its content.
6. **GOOGLEFINANCE attribute**: hardcoded to `"price"` since this builds *the* `Price` column formula per the target description; the EARS doesn't name an attribute, so the column's declared purpose is used to pick one, not left as a caller parameter.
7. **Quote escaping**: tickers are assumed normally quote-free; doubling embedded `"` is defensive only, not implied by the requirement.
8. **No error/Result type**: resolution and formula-building are treated as total functions (always succeed) since identity fallback removes any failure path — no `Option`/`Result` needed at this boundary.