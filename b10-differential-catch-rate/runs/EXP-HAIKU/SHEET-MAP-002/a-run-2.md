```rust
use std::collections::HashMap;

#[derive(Debug, Clone)]
pub struct MarkRow {
    pub symbol: String,
    // Other fields (price, timestamp, etc.)
}

pub fn key_mark_readback(rows: Vec<MarkRow>) -> Result<HashMap<String, MarkRow>, String> {
    let mut marks = HashMap::new();
    
    for row in rows {
        // Validate symbol is not empty
        if row.symbol.trim().is_empty() {
            return Err("Symbol cannot be empty".to_string());
        }
        
        // Assert exactly one row per symbol
        if marks.contains_key(&row.symbol) {
            return Err(format!(
                "MARK_READBACK_VIOLATION: duplicate symbol '{}' (expected one row per symbol)",
                row.symbol
            ));
        }
        
        marks.insert(row.symbol.clone(), row);
    }
    
    Ok(marks)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn valid_marks_keyed_by_symbol() {
        let rows = vec![
            MarkRow { symbol: "AAPL".to_string() },
            MarkRow { symbol: "GOOG".to_string() },
        ];
        let result = key_mark_readback(rows).unwrap();
        assert_eq!(result.len(), 2);
        assert!(result.contains_key("AAPL"));
    }

    #[test]
    fn duplicate_symbol_errors() {
        let rows = vec![
            MarkRow { symbol: "AAPL".to_string() },
            MarkRow { symbol: "AAPL".to_string() },
        ];
        let err = key_mark_readback(rows).unwrap_err();
        assert!(err.contains("MARK_READBACK_VIOLATION"));
    }

    #[test]
    fn empty_symbol_errors() {
        let rows = vec![
            MarkRow { symbol: "".to_string() },
        ];
        let err = key_mark_readback(rows).unwrap_err();
        assert!(err.contains("empty"));
    }
}
```

**Assumptions:**

1. **MarkRow type**: Struct with `symbol: String` field; extends with price/timestamp as needed
2. **Input format**: `Vec<MarkRow>` from sheets read pipeline
3. **Empty input**: Valid (empty HashMap returned)
4. **Symbol validation**: Empty or whitespace-only symbols rejected (requirement: symbols are row identities, must be non-empty)
5. **Case sensitivity**: Symbol matching is case-sensitive (AAPL ≠ aapl); normalization (uppercase) deferred to caller if needed
6. **Error handling**: `Result<HashMap, String>` follows Rust convention; error message prefixed "MARK_READBACK_VIOLATION" for "loud" emission
7. **Duplicate detection**: HashMap::contains_key before insert; O(n) pass guarantees one-per-symbol invariant
8. **No mutation of rows**: Keys and values cloned, original rows unchanged
9. **Return type**: HashMap<String, MarkRow> for O(1) lookup by symbol after validation

**Interpretation:** "Key by row identity (symbol)" → index rows by their symbol field. "Assert one row per symbol" → validate no duplicates during keying. "Error loudly" → return Err with descriptive message naming the violation and offending symbol.