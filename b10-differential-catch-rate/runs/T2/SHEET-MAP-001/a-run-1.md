```rust
// sheets-view: symbol -> GOOGLEFINANCE ticker resolution + formula build

use std::collections::HashMap;

/// Ledger symbol, e.g. "VOO", "BRK.B".
pub struct Symbol(pub String);

/// Config's alias map: ledger Symbol string -> GOOGLEFINANCE ticker string.
/// Assumption: keys/values are plain strings (newtype-wrapped where useful),
/// loaded from config elsewhere; this module only consumes the map.
pub struct AliasMap(pub HashMap<String, String>);

impl AliasMap {
    /// Resolve a ledger Symbol to its GOOGLEFINANCE ticker.
    /// Identity fallback when the symbol has no alias entry.
    pub fn resolve_ticker(&self, symbol: &Symbol) -> String {
        self.0
            .get(&symbol.0)
            .cloned()
            .unwrap_or_else(|| symbol.0.clone())
    }
}

/// Build the GOOGLEFINANCE Price formula for a resolved ticker, targeting
/// a specific cell reference (e.g. the row's ticker cell) for the formula
/// to reference rather than embedding the literal ticker string.
///
/// Assumption: "Price" formula = current price attribute, the default
/// GOOGLEFINANCE attribute when omitted. Formula references the ticker
/// cell (not a literal), so a manual override typed into that cell also
/// takes effect — consistent with sheets-view owning no accounting math
/// and treating the sheet as the live-price oracle surface.
pub fn build_price_formula(ticker_cell_ref: &str) -> String {
    format!("=GOOGLEFINANCE({ticker_cell_ref})")
}

/// Convenience: resolve + build in one call, given the ticker cell's
/// A1-style reference where the resolved ticker string will itself be
/// written by the caller.
pub fn price_formula_for_symbol(
    aliases: &AliasMap,
    symbol: &Symbol,
    ticker_cell_ref: &str,
) -> (String, String) {
    let ticker = aliases.resolve_ticker(symbol);
    let formula = build_price_formula(ticker_cell_ref);
    (ticker, formula)
}
```

Assumptions invented:
1. `AliasMap` is a `HashMap<String, String>` (ledger symbol string -> ticker string); config loading/parsing is out of scope here.
2. "Identity when unset" means: absent key -> return the original `Symbol` string unchanged (no error, no `Option`, no panic).
3. Alias lookup is exact-string match, case-sensitive; no normalization (uppercasing, whitespace trim) is specified, so none is applied.
4. Empty-string symbol is treated identically to any other string — resolves via map or falls back to itself; no special-cased validation, since EARS doesn't mention invalid input.
5. "Price" formula = GOOGLEFINANCE's default attribute (current price), since no attribute is named; equivalent to `GOOGLEFINANCE(ticker)` with no second argument.
6. The formula is built to reference a cell containing the resolved ticker rather than inlining the ticker literal in the formula string — chosen because sheets-view "owns no accounting or tax math" and the workbook is described as read-only-view-plus-marks-settle, implying the ticker cell is itself a visible, potentially-referenced value; the literal-embedding alternative (`=GOOGLEFINANCE("VOO")`) was rejected as it hides the resolved ticker from the sheet.
7. No caching/memoization of resolved tickers is implemented; each call does a fresh map lookup (map is assumed small/in-memory).
8. No handling for a ticker resolving to an empty string or a ticker containing characters requiring escaping — out of scope per the EARS text.