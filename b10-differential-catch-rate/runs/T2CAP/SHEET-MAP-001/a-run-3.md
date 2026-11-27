```rust
// crates/sheets-view/src/price_formula.rs
// @spec SHEET-MAP-001

use std::collections::BTreeMap;

/// Ledger symbol (kernel-side identity).
#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub struct Symbol(pub String);

/// A resolved GOOGLEFINANCE ticker, e.g. "NASDAQ:AAPL" or "AAPL".
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Ticker(pub String);

/// View-layer config slice owning the alias map.
#[derive(Debug, Default, Clone)]
pub struct Config {
    /// Symbol -> GOOGLEFINANCE ticker overrides. Absent key => identity.
    pub ticker_aliases: BTreeMap<Symbol, Ticker>,
}

impl Config {
    /// Resolve a ledger Symbol to its GOOGLEFINANCE ticker.
    /// Identity when no alias is configured.
    pub fn resolve_ticker(&self, symbol: &Symbol) -> Ticker {
        self.ticker_aliases
            .get(symbol)
            .cloned()
            .unwrap_or_else(|| Ticker(symbol.0.clone()))
    }
}

/// Escape a ticker for embedding in a Sheets string literal:
/// doubled double-quotes, per Sheets formula literal rules.
fn escape_formula_literal(s: &str) -> String {
    s.replace('"', "\"\"")
}

/// Build the Price column formula for one holding row.
/// Shape: `=GOOGLEFINANCE("<TICKER>","price")`
pub fn price_formula(config: &Config, symbol: &Symbol) -> String {
    let ticker = config.resolve_ticker(symbol);
    format!(
        "=GOOGLEFINANCE(\"{}\",\"price\")",
        escape_formula_literal(&ticker.0)
    )
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn identity_when_unset() {
        let c = Config::default();
        assert_eq!(
            price_formula(&c, &Symbol("AAPL".into())),
            "=GOOGLEFINANCE(\"AAPL\",\"price\")"
        );
    }

    #[test]
    fn alias_applied() {
        let mut c = Config::default();
        c.ticker_aliases
            .insert(Symbol("BRKB".into()), Ticker("NYSE:BRK.B".into()));
        assert_eq!(
            price_formula(&c, &Symbol("BRKB".into())),
            "=GOOGLEFINANCE(\"NYSE:BRK.B\",\"price\")"
        );
    }
}
```

ASSUMPTIONS (all invented; none stated by the EARS):

1. `Symbol` is a newtype over `String`; `Ticker` is a distinct newtype so resolved tickers can't be confused with ledger symbols.
2. Alias map is `BTreeMap<Symbol, Ticker>` on a `Config` struct field named `ticker_aliases`; the EARS says "config's alias map" without naming the field or container type. Deterministic ordering chosen over `HashMap` for reproducible view output.
3. Resolution is total and infallible — an unmapped symbol yields identity rather than an error, per "(identity when unset)". No validation that the identity result is a *valid* GOOGLEFINANCE ticker; an unknown ticker becomes a `#N/A` in the sheet, which the marks read-back settle pass must tolerate. Chose this over `Result` because the EARS names no failure mode.
4. Lookup is exact-match, case-sensitive. The EARS gives no normalization rule.
5. Formula shape: `=GOOGLEFINANCE("TICKER","price")` with an explicit `"price"` attribute. The EARS says only "build the `Price` formula"; explicit attribute chosen over the one-arg default form for readability in the published tab.
6. `Price` is capitalized in the EARS, suggesting a domain type. Interpreted as the *sheet column* named Price, not a Rust `Price` type — the return is `String` because the sheets API writes a formula string. A `PriceFormula(String)` newtype would be the alternative.
7. Empty-string symbol and whitespace-only symbol pass through unchanged (no trimming, no rejection) — no boundary rule given.
8. Quote-escaping (doubled `"`) invented defensively; no injection/escaping requirement appears in the EARS. Leading `=` is emitted here, assuming the writer sends `USER_ENTERED` values.
9. No `Cents` involvement — this builds a formula string only; the numeric price arrives back via read-back.
10. Pure function, no I/O, no logging of unmapped symbols.