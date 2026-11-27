```rust
/// Ledger-side ticker symbol, e.g. "VTI".
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct Symbol(pub String);

/// Sheets-view config; alias_map maps ledger Symbol -> GOOGLEFINANCE ticker string.
pub struct Config {
    pub alias_map: std::collections::HashMap<String, String>,
}

/// Resolved GOOGLEFINANCE ticker (post-alias).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Ticker(pub String);

/// A spreadsheet formula string for the Price column.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Price(pub String);

/// Resolve `symbol` to its GOOGLEFINANCE ticker via `config`'s alias map;
/// falls back to the symbol itself (identity) when no alias entry exists.
pub fn resolve_ticker(symbol: &Symbol, config: &Config) -> Ticker {
    let resolved = config
        .alias_map
        .get(&symbol.0)
        .cloned()
        .unwrap_or_else(|| symbol.0.clone());
    Ticker(resolved)
}

/// Build the Price formula from an already-resolved ticker.
pub fn build_price_formula(ticker: &Ticker) -> Price {
    Price(format!("=GOOGLEFINANCE(\"{}\")", ticker.0))
}

/// Convenience: resolve then build, per-row entry point.
pub fn price_formula_for_symbol(symbol: &Symbol, config: &Config) -> Price {
    build_price_formula(&resolve_ticker(symbol, config))
}
```

Assumptions:
1. `Symbol`/`Ticker`/`Price` are newtype wrappers around `String`; distinct types for clarity, no validation logic assumed to exist elsewhere.
2. `Config.alias_map` is `HashMap<String, String>` keyed by ledger symbol, valued by GOOGLEFINANCE ticker; only this field is modeled, rest of `Config` elided.
3. "Identity when unset" interpreted as: unset = no key for this `Symbol` in `alias_map` (map itself always present, possibly empty) — not a tri-state Option on the whole map. `unwrap_or_else` implements the fallback.
4. Alias lookup is case-sensitive, exact string match; no normalization/trimming assumed since spec is silent.
5. No handling for empty-string symbols or symbols containing characters (e.g. `"`) that would break the formula string — spec text gives no validation/error requirement, so resolution is total (always succeeds) and formula-building does no escaping.
6. GOOGLEFINANCE formula uses the single-argument form `=GOOGLEFINANCE("TICKER")` (defaults to price attribute) since the spec names the column `Price` but doesn't specify an explicit attribute string or additional args (e.g. date range) — out of scope for this EARS.
7. No `Result`/error return type: since identity fallback guarantees a ticker always resolves, there is no failure path to model for this requirement alone.
8. Function split (`resolve_ticker` / `build_price_formula`) mirrors the two clauses in the requirement ("resolve... and build..."), with a combinator for callers needing both in one step.