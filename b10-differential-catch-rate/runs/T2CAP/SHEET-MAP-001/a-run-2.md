```rust
//! sheets-view :: symbol → GOOGLEFINANCE formula mapping
//! @spec SHEET-MAP-001

use std::collections::BTreeMap;

/// Ledger-side instrument identifier (newtype over the ledger's symbol text).
#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub struct Symbol(pub String);

/// A GOOGLEFINANCE-addressable ticker, post-resolution.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Ticker(String);

impl Ticker {
    fn as_str(&self) -> &str { &self.0 }
}

/// The slice of `config` this function needs.
#[derive(Debug, Default, Clone)]
pub struct SheetsConfig {
    /// Ledger `Symbol` → GOOGLEFINANCE ticker. Absent entry ⇒ identity.
    pub ticker_aliases: BTreeMap<String, String>,
}

/// A rendered A1 cell formula string, ready to write to a view tab.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Formula(pub String);

/// Resolve `symbol` to its GOOGLEFINANCE ticker: alias map hit wins,
/// otherwise identity on the ledger symbol.
pub fn resolve_ticker(config: &SheetsConfig, symbol: &Symbol) -> Ticker {
    Ticker(
        config
            .ticker_aliases
            .get(&symbol.0)
            .cloned()
            .unwrap_or_else(|| symbol.0.clone()),
    )
}

/// Build the live-price oracle formula for `symbol`.
pub fn price_formula(config: &SheetsConfig, symbol: &Symbol) -> Formula {
    let t = resolve_ticker(config, symbol);
    Formula(format!("=GOOGLEFINANCE(\"{}\",\"price\")", escape(t.as_str())))
}

/// Sheets string literals escape `"` by doubling.
fn escape(s: &str) -> String { s.replace('"', "\"\"") }

#[cfg(test)]
mod tests {
    use super::*;

    fn cfg(pairs: &[(&str, &str)]) -> SheetsConfig {
        SheetsConfig {
            ticker_aliases: pairs.iter().map(|(k, v)| (k.to_string(), v.to_string())).collect(),
        }
    }

    #[test]
    fn identity_when_unset() {
        assert_eq!(resolve_ticker(&cfg(&[]), &Symbol("VTI".into())), Ticker("VTI".into()));
        assert_eq!(
            price_formula(&cfg(&[]), &Symbol("VTI".into())),
            Formula("=GOOGLEFINANCE(\"VTI\",\"price\")".into())
        );
    }

    #[test]
    fn alias_wins() {
        let c = cfg(&[("BRKB", "NYSE:BRK.B")]);
        assert_eq!(
            price_formula(&c, &Symbol("BRKB".into())),
            Formula("=GOOGLEFINANCE(\"NYSE:BRK.B\",\"price\")".into())
        );
    }

    #[test]
    fn alias_map_is_case_sensitive_exact_match() {
        let c = cfg(&[("brkb", "NYSE:BRK.B")]);
        assert_eq!(resolve_ticker(&c, &Symbol("BRKB".into())), Ticker("BRKB".into()));
    }
}
```

Assumptions invented (none of these are stated by SHEET-MAP-001):

1. `Symbol` is a newtype over `String` and is the map key; alias lookup is exact and case-sensitive (no normalization/uppercasing, no trimming).
2. `config` exposes the alias map as `ticker_aliases: BTreeMap<String, String>`; the whole map may be absent/empty, which is the "unset" identity case. "Unset" is read as *no entry for this symbol*, not *no map at all* — the per-symbol reading, since a global-only reading would make partial maps meaningless.
3. Resolution is total and infallible — returns `Ticker`, not `Result`. No validation of ticker syntax (exchange prefixes, dots, `MUTF:`/`CURRENCY:` forms pass through verbatim), because the requirement names no error case and the oracle itself reports `#N/A` in-sheet.
4. Empty-string symbol or empty alias value passes through unchanged; it yields `=GOOGLEFINANCE("","price")` which errors in-sheet rather than in Rust.
5. Alias values are not re-resolved (no chaining/transitive aliases, no cycle handling) — one hop only.
6. Formula shape: `=GOOGLEFINANCE("<ticker>","price")` with the explicit `"price"` attribute, US-style comma argument separator, leading `=`, returned as a plain string for the writer to place. The EARS says "the `Price` formula" without giving its text; I chose the canonical live-price form.
7. `"` in a ticker is escaped by doubling to keep the formula well-formed (defensive; real tickers contain none).
8. `Formula`/`Ticker` are view-layer types local to sheets-view; no `Cents`, no accounting or tax math touched, consistent with the crate's stated boundary.