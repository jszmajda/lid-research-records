# Rust Implementation Sketch: SHEET-MAP-001

```rust
use std::collections::HashMap;

pub struct TickerResolver {
    alias_map: HashMap<String, String>,
}

impl TickerResolver {
    pub fn new(alias_map: HashMap<String, String>) -> Self {
        Self { alias_map }
    }

    /// Resolve a ledger Symbol to its GOOGLEFINANCE ticker via alias map,
    /// then build the Price formula string.
    pub fn resolve_and_build_formula(&self, symbol: &str) -> String {
        // Identity resolution: return alias if present, else symbol itself
        let ticker = self.alias_map.get(symbol).map(|s| s.as_str()).unwrap_or(symbol);
        
        // Build GOOGLEFINANCE formula for price column
        format!("=GOOGLEFINANCE(\"{}\", \"price\")", ticker)
    }
}

// Usage:
// let mut aliases = HashMap::new();
// aliases.insert("BRK".to_string(), "BRK.B".to_string());
// let resolver = TickerResolver::new(aliases);
// resolver.resolve_and_build_formula("BRK") → "=GOOGLEFINANCE(\"BRK.B\", \"price\")"
// resolver.resolve_and_build_formula("AAPL") → "=GOOGLEFINANCE(\"AAPL\", \"price\")"
```

## Explicit Assumptions

1. **Type of Symbol**: `&str` (ledger symbol is immutable string slice)
2. **Alias map type**: `HashMap<String, String>` — keyed by original symbol, valued by ticker
3. **Formula format**: `=GOOGLEFINANCE("TICKER", "price")` — standard Google Sheets syntax with `"price"` attribute to extract numeric value
4. **"Identity when unset"**: if symbol has no alias entry, use symbol directly as ticker
5. **No validation**: assumes all symbols and tickers are valid; GOOGLEFINANCE handles malformed tickers gracefully (returns error cell)
6. **No escaping**: assumes symbols/tickers contain no quotes or special chars requiring escaping; if quotes appear, the formula will be malformed (this is caller's responsibility)
7. **Empty symbol behavior**: caller must ensure symbol is non-empty; the code does not validate
8. **Config location**: config is passed directly (via `TickerResolver` struct); assumes caller provides fully initialized alias map
9. **Single attribute**: "price" is hardcoded; assumes this is the only Price attribute needed (not "currency", "name", or other GOOGLEFINANCE attributes)
10. **Return type**: formula is a `String` (owned), ready to write to Google Sheets cell; no error variant (assumption: input is valid)

## Interpretation Choice

The requirement says "resolve...and build the `Price` formula" as two sequential steps. I interpreted this as: (1) lookup symbol in alias map, defaulting to identity, then (2) construct a GOOGLEFINANCE formula string. The formula is a side-effect of the resolution, not a separate operation. The `"price"` parameter is inferred from the requirement's context (this is the live-price oracle column).

---

**File location assumption**: This code would live in `sheets-view` crate as `src/ticker.rs` or similar.