```rust
use std::collections::HashMap;

/// A ledger security symbol, e.g. "AAPL".
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct Symbol(pub String);

/// Sheets-view config subset relevant to ticker mapping.
#[derive(Debug, Default)]
pub struct SheetMapConfig {
    /// Symbol -> GOOGLEFINANCE ticker. A missing key means "unset";
    /// resolution falls back to the symbol's own text (identity).
    pub ticker_aliases: HashMap<Symbol, String>,
}

impl SheetMapConfig {
    /// SHEET-MAP-001: resolve `symbol` to its GOOGLEFINANCE ticker.
    pub fn resolve_ticker(&self, symbol: &Symbol) -> String {
        self.ticker_aliases
            .get(symbol)
            .cloned()
            .unwrap_or_else(|| symbol.0.clone())
    }
}

/// SHEET-MAP-001: build the live-price GOOGLEFINANCE formula for `symbol`.
pub fn build_price_formula(config: &SheetMapConfig, symbol: &Symbol) -> String {
    let ticker = config.resolve_ticker(symbol);
    format!("=GOOGLEFINANCE(\"{}\",\"price\")", ticker)
}
```

Assumptions (invented, not stated by the EARS text):

1. `Symbol` is a newtype over `String` (ledger symbols are plain text identifiers), deriving `Eq`/`Hash` so it can key a map.
2. `config`'s alias map is `HashMap<Symbol, String>` named `ticker_aliases`; field name and container type are invented — EARS only says "config's alias map."
3. "Unset" is interpreted as *key absent from the map* (not present-but-empty-string). A present empty-string alias is treated as a valid (if degenerate) resolved ticker, not as "unset."
4. Identity fallback returns the symbol's raw text unchanged — no case-folding, trimming, or exchange-prefix normalization (e.g. no auto "NASDAQ:" insertion).
5. No validation of the resolved ticker (empty string, whitespace, embedded quote/comma characters) is performed here; malformed tickers would still be interpolated into the formula string as-is, since the EARS gives no error/rejection path.
6. The GOOGLEFINANCE attribute is hardcoded to `"price"` — the EARS says "build the `Price` formula" and I read `Price` as the specific GOOGLEFINANCE attribute argument, not a generic label for any formula the caller wants.
7. Output is a plain formula string (leading `=...`) intended for direct placement in a sheet cell; no `A1`-notation cell reference, no additional formula wrapping (e.g. `IFERROR`), and no batching for multiple symbols — single-symbol scope only.
8. No quoting/escaping of the ticker substring beyond direct interpolation — assumed tickers never contain `"` characters, since neither Symbol nor alias-map shapes are specified as needing sanitization.
9. Resolution is a pure, synchronous, side-effect-free lookup (no I/O, no network call to validate the ticker against GOOGLEFINANCE) — this function only maps symbol → ticker → formula text; it does not evaluate the formula.
10. Ambiguity resolved: "alias map (identity when unset)" is read as applying per-symbol (each symbol independently falls back), not as an all-or-nothing toggle for the whole map being present/absent in config.