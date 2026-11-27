```rust
use std::collections::HashMap;

/// One decoded row from the marks read-back range of the sheets tab.
#[derive(Debug, Clone)]
pub struct MarkRow {
    pub symbol: String,      // as it appears in the sheet cell, e.g. "NASDAQ:AAPL"
    pub price_cents: i64,    // GOOGLEFINANCE output, normalized to integer Cents
}

#[derive(Debug)]
pub struct DuplicateSymbolError {
    pub symbol: String,
    pub row_indices: Vec<usize>, // 0-based positions within the read-back range
}

impl std::fmt::Display for DuplicateSymbolError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "marks read-back invariant violated: symbol {:?} appears in rows {:?} (expected exactly one row per symbol)",
            self.symbol, self.row_indices
        )
    }
}
impl std::error::Error for DuplicateSymbolError {}

/// Keys mark read-back rows by symbol (row identity). Errors on the first
/// symbol found in more than one row; the error carries every offending
/// row index so the caller can surface a loud, actionable message.
pub fn key_marks_by_symbol(
    rows: &[MarkRow],
) -> Result<HashMap<String, &MarkRow>, DuplicateSymbolError> {
    let mut indices_by_symbol: HashMap<&str, Vec<usize>> = HashMap::with_capacity(rows.len());
    for (i, row) in rows.iter().enumerate() {
        indices_by_symbol.entry(row.symbol.as_str()).or_default().push(i);
    }
    if let Some((symbol, idxs)) = indices_by_symbol.iter().find(|(_, v)| v.len() > 1) {
        return Err(DuplicateSymbolError {
            symbol: symbol.to_string(),
            row_indices: idxs.clone(),
        });
    }
    Ok(rows.iter().map(|r| (r.symbol.clone(), r)).collect())
}
```

Assumptions:
1. "Row identity (symbol)" = exact, case-sensitive string equality on `symbol` as decoded from the cell — no trimming/uppercasing/exchange-prefix normalization, since the EARS gives no normalization rule and silently folding cases could mask a real distinct-symbol collision.
2. "Erroring loudly" is implemented as a typed `Result::Err` with a `Display` naming the symbol and every colliding row index (not a panic, not a silent log) — this is a library crate (sheets-view), so panicking would be an inappropriate policy choice for a function; the caller (settle pass) decides whether to `expect()`/abort, which is where "loudly" (visible failure, not swallowed) actually gets enforced.
3. Empty-string symbol is treated as a normal key — two blank-symbol rows are a duplicate violation like any other, since the spec carves out no exception for blanks.
4. Zero input rows vacuously satisfies "one row per symbol": returns `Ok(empty map)`, not an error.
5. Detection is fail-fast on the first duplicate symbol found (arbitrary iteration order via `HashMap`), not an aggregate report of all violations — chosen for a minimal function surface; a fuller variant could collect all offending symbols before erroring.
6. Scope is symbol-uniqueness only; other row fields (e.g. missing/invalid price) are out of scope for this spec and unchecked here.
7. Input `rows: &[MarkRow]` is assumed already parsed from the raw sheet grid — this function operates post-decode, not on raw A1 ranges.