```rust
use std::collections::HashMap;

/// Configuration containing symbol-to-ticker alias mapping
#[derive(Debug)]
pub struct Config {
    /// Maps ledger symbols to GOOGLEFINANCE tickers
    pub symbol_aliases: HashMap<String, String>,
}

/// Resolves a ledger symbol to a GOOGLEFINANCE ticker and builds the price formula
/// 
/// - If `symbol` is in `config.symbol_aliases`, uses the mapped ticker
/// - Otherwise uses `symbol` as-is (identity)
/// - Returns a complete GOOGLEFINANCE formula string for Google Sheets
pub fn build_price_formula(symbol: &str, config: &Config) -> String {
    let ticker = config
        .symbol_aliases
        .get(symbol)
        .map(|s| s.as_str())
        .unwrap_or(symbol);
    
    format!(r#"=GOOGLEFINANCE("{}", "price")"#, ticker)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_resolves_via_alias() {
        let mut aliases = HashMap::new();
        aliases.insert("GOOG".to_string(), "NASDAQ:GOOGL".to_string());
        let config = Config { symbol_aliases: aliases };
        
        assert_eq!(
            build_price_formula("GOOG", &config),
            r#"=GOOGLEFINANCE("NASDAQ:GOOGL", "price")"#
        );
    }

    #[test]
    fn test_identity_when_unaliased() {
        let config = Config { symbol_aliases: HashMap::new() };
        
        assert_eq!(
            build_price_formula("AAPL", &config),
            r#"=GOOGLEFINANCE("AAPL", "price")"#
        );
    }
}
```

**Assumptions:**

1. **Symbol type**: `&str` (owned string or borrow depending on context)
2. **Config.symbol_aliases type**: `HashMap<String, String>` mapping symbol → ticker
3. **GOOGLEFINANCE formula format**: `=GOOGLEFINANCE("ticker", "price")` — the `"price"` attribute retrieves current market price in Sheets
4. **Return type**: `String` (complete formula, not just ticker)
5. **Empty/invalid input**: No validation — caller responsible for non-empty, valid symbols
6. **Ticker format allows exchange prefix**: e.g. `"NASDAQ:GOOGL"` or raw `"GOOGL"`
7. **No character escaping**: Tickers assumed safe (no embedded quotes)
8. **No error handling**: Always succeeds; no Result wrapper (matches "shall resolve" not "may fail")

**Ambiguity resolved:**
- Interpreted "build the Price formula" as outputting a complete `=GOOGLEFINANCE(...)` cell formula (ready to paste into Sheets), not just the resolved ticker. The "price" attribute is implicit in "Price formula"—retrieving the current market price is the sheet-view's core function.