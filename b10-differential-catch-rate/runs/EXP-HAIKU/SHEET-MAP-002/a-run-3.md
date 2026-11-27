# Rust Implementation: Mark Read-Back Key-By-Symbol Validation

```rust
use std::collections::HashMap;

#[derive(Debug, Clone)]
pub struct Mark {
    pub symbol: String,
    pub price: f64, // or i64 for Cents depending on portfolio representation
}

#[derive(Debug)]
pub enum MarkReadbackError {
    /// Contains (symbol, count) pairs for all duplicated symbols
    DuplicateSymbols(Vec<(String, usize)>),
}

impl std::fmt::Display for MarkReadbackError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::DuplicateSymbols(dups) => {
                write!(f, "Symbol uniqueness violation in mark read-back: ")?;
                let details = dups
                    .iter()
                    .map(|(sym, count)| format!("{} appeared {} times", sym, count))
                    .collect::<Vec<_>>()
                    .join("; ");
                write!(f, "{}", details)
            }
        }
    }
}

impl std::error::Error for MarkReadbackError {}

/// Keys marks by symbol, enforcing exactly one row per symbol.
/// Returns HashMap<symbol, mark> on success, or error with all duplicates listed.
pub fn key_marks_by_symbol(
    marks: impl IntoIterator<Item = Mark>,
) -> Result<HashMap<String, Mark>, MarkReadbackError> {
    let mut symbol_counts: HashMap<String, usize> = HashMap::new();
    let mut keyed_marks: HashMap<String, Mark> = HashMap::new();

    for mark in marks {
        *symbol_counts.entry(mark.symbol.clone()).or_insert(0) += 1;
        keyed_marks.insert(mark.symbol.clone(), mark);
    }

    // Collect all violations
    let duplicates: Vec<(String, usize)> = symbol_counts
        .into_iter()
        .filter(|(_, count)| *count > 1)
        .collect();

    if !duplicates.is_empty() {
        return Err(MarkReadbackError::DuplicateSymbols(duplicates));
    }

    Ok(keyed_marks)
}
```

## Assumptions (Exhaustive)

1. **Input type**: `Mark` is a simple struct with `symbol: String` and `price: f64`; symbol is the row identity
2. **Empty input**: Allowed; returns empty `HashMap`
3. **Null/empty symbol**: Treated as a valid (though pathological) symbol; duplicates would be caught
4. **Type choice — price field**: Assumed `f64` for GOOGLEFINANCE compatibility; easily swapped to `i64` (Cents) per portfolio context
5. **Duplicate detection criterion**: Count occurrence; any symbol appearing >1 time is a violation
6. **Error scope**: Return ALL duplicates in one error, not fail-fast on first; lets reader fix in one pass
7. **Owned vs. borrowed**: Takes owned `Mark` (via iterator), not references; allows flexibility in call site (Vec, vec!, computed stream)
8. **Last-write-wins for keyed map**: On duplicates, the last occurrence wins the map slot; irrelevant because we error anyway
9. **"Loudly"** → detailed error message listing each duplicate symbol and its count
10. **No silent truncation**: Zero filtering or data loss; validation is pure assertion

## Interpretation Choice

I chose to validate **structure** (uniqueness) over **content** (mark validity). The requirement says "key mark read-back by symbol" — I interpret this as: produce a symbol-indexed map only if the precondition (one row per symbol) holds. Errors are structural, not semantic (e.g., price bounds, currency consistency).

`{lid-checkout}/docs/research/experiments/b10-differential-catch-rate/answer-key/sheet_map_002_mark_keyby_symbol.rs`