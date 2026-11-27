```rust
use std::collections::HashMap;

/// Resolves a ledger Symbol to its GOOGLEFINANCE ticker via an alias map,
/// then builds a Google Sheets PRICE formula.
/// 
/// EARS SHEET-MAP-001: Resolve symbol to GOOGLEFINANCE ticker via config's alias map
/// (identity when unset) and build Price formula from resolved ticker.
pub fn build_price_formula(symbol: &str, alias_map: &HashMap<String, String>) -> String {
    // Resolve: alias_map lookup, fallback to identity
    let ticker = alias_map.get(symbol).map(|s| s.as_str()).unwrap_or(symbol);
    
    // Build GOOGLEFINANCE formula string for Sheets
    format!(r#"=GOOGLEFINANCE("{}","price")"#, ticker)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn aliased_symbol() {
        let mut aliases = HashMap::new();
        aliases.insert("AAPL".into(), "NASDAQ:AAPL".into());
        assert_eq!(
            build_price_formula("AAPL", &aliases),
            r#"=GOOGLEFINANCE("NASDAQ:AAPL","price")"#
        );
    }

    #[test]
    fn unaliased_symbol_identity() {
        let aliases = HashMap::new();
        assert_eq!(
            build_price_formula("TSLA", &aliases),
            r#"=GOOGLEFINANCE("TSLA","price")"#
        );
    }
}
```

## Assumptions

1. **Symbol type**: `&str` (immutable reference) — simple, borrowable; production might use newtype `Symbol`.
2. **Alias map**: `HashMap<String, String>` — caller owns and passes by reference; could be wrapped in a Config struct, but function signature is clearer for a sketch.
3. **GOOGLEFINANCE formula syntax**: `=GOOGLEFINANCE("TICKER","price")` — standard Google Sheets syntax; "price" is the field (not "change", "name", etc.) because spec says "Price formula" and price is the live-oracle value.
4. **Fallback**: `identity when unset` → if symbol not in map, return symbol unchanged as ticker.
5. **Return type**: `String` — the Sheets formula as a cell value; callers write directly to sheet cells.
6. **Quoting & escaping**: None — assumes resolved tickers contain no quotes, newlines, or control chars; Sheets formula injection is caller's responsibility.
7. **Empty symbol**: Passed through; produces invalid formula `=GOOGLEFINANCE("","price")` which is caller's validation problem.
8. **Invalid/unknown symbols**: No validation — assumes upstream ledger ensures symbols are well-formed; only alias lookup is performed.
9. **Config access pattern**: Alias map passed as parameter, not fetched from a global Config object — spec says "via config's alias map" but doesn't prescribe the access pattern; dependency injection is cleanest.
10. **Missing map**: Empty map treated like a map with no entries — all symbols resolve to identity.

**Interpretation choice**: Spec is silent on whether to escape tickers, validate formats, or handle parse errors. I chose to pass through transparently (no escaping, no validation), treating formula construction as a pure projection — the responsibility to provide valid tickers belongs upstream.