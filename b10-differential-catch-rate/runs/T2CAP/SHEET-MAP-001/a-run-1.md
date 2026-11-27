```rust
// crates/sheets-view/src/price_formula.rs
// @spec SHEET-MAP-001

use std::collections::BTreeMap;

/// Ledger-side instrument identifier (newtype over the ledger's symbol string).
#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub struct Symbol(pub String);

/// A resolved GOOGLEFINANCE ticker, e.g. "NASDAQ:AAPL" or "VTSAX".
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Ticker(pub String);

/// Slice of `config` this unit needs: the alias map only.
#[derive(Debug, Default, Clone)]
pub struct SheetsConfig {
    /// ledger Symbol -> GOOGLEFINANCE ticker. Absent key => identity.
    pub ticker_aliases: BTreeMap<String, String>,
}

impl SheetsConfig {
    /// Identity when unset: no alias map entry => the Symbol *is* the ticker.
    pub fn resolve_ticker(&self, symbol: &Symbol) -> Ticker {
        match self.ticker_aliases.get(&symbol.0) {
            Some(alias) => Ticker(alias.clone()),
            None => Ticker(symbol.0.clone()),
        }
    }
}

/// A rendered cell formula destined for a view tab's Price column.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct PriceFormula(pub String);

/// Build the Price column formula for a ledger Symbol.
pub fn price_formula(config: &SheetsConfig, symbol: &Symbol) -> PriceFormula {
    let Ticker(t) = config.resolve_ticker(symbol);
    PriceFormula(format!(
        "=GOOGLEFINANCE(\"{}\",\"price\")",
        escape_sheets_string(&t)
    ))
}

/// Sheets string literals escape `"` by doubling it.
fn escape_sheets_string(s: &str) -> String {
    s.replace('"', "\"\"")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn identity_when_unset() {
        let c = SheetsConfig::default();
        assert_eq!(
            price_formula(&c, &Symbol("AAPL".into())).0,
            "=GOOGLEFINANCE(\"AAPL\",\"price\")"
        );
    }

    #[test]
    fn alias_applied() {
        let mut c = SheetsConfig::default();
        c.ticker_aliases.insert("BRKB".into(), "NYSE:BRK.B".into());
        assert_eq!(
            price_formula(&c, &Symbol("BRKB".into())).0,
            "=GOOGLEFINANCE(\"NYSE:BRK.B\",\"price\")"
        );
    }
}
```

ASSUMPTIONS (all invented):
1. `Symbol` is a newtype over `String`; alias map keyed by the raw string.
2. `config` exposes the alias map as `BTreeMap<String,String>` on a sheets-view-owned struct; the real config may be TOML-deserialized and larger — this is the needed slice.
3. Lookup is exact/case-sensitive; no normalization, trimming, or uppercasing.
4. "Identity when unset" covers both an absent map and an absent key — same fallback, infallible, so the fn returns `Ticker` not `Result`.
5. Formula shape is `=GOOGLEFINANCE("TICKER","price")` with the `"price"` attribute explicit rather than defaulted.
6. `Price` in the EARS names the view's Price *column formula*, not a Cents value — this unit emits a formula string, never a number (kernel/settle pass reads marks back).
7. Empty or whitespace symbols, and aliases mapping to empty strings, are passed through unvalidated — no error type here; validation is assumed upstream at config load.
8. Embedded `"` escaped by doubling; no other sanitization (no locale/argument-separator handling — `,` assumed).
9. One alias per symbol, no chaining (an alias value is never re-resolved).
10. No currency/exchange-suffix inference; a needed exchange prefix must be encoded in the alias.

AMBIGUITY / INTERPRETATION: "(identity when unset)" is read as attaching to the *alias entry* (per-symbol miss → passthrough), not merely to the whole map being absent — the stricter reading would make unaliased symbols an error, which contradicts a live-price column that should work for plain tickers with zero config.