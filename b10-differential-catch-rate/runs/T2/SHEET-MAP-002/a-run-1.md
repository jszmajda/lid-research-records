```rust
use std::collections::HashMap;

/// One row read back from the sheet's live-mark range.
#[derive(Debug, Clone)]
pub struct MarkRow {
    pub symbol: String,
    pub mark_cents: i64,
}

#[derive(Debug, thiserror::Error)]
pub enum MarkReadBackError {
    #[error("row {row}: empty/blank symbol, cannot key mark read-back")]
    EmptySymbol { row: usize },
    #[error("row identity violated: symbol {symbol:?} appears at rows {first_row} and {dup_row}")]
    DuplicateSymbol {
        symbol: String,
        first_row: usize,
        dup_row: usize,
    },
}

/// Keys mark read-back rows by symbol, asserting exactly one row per symbol.
/// Errors (does not silently dedupe/overwrite) on any violation.
pub fn key_marks_by_symbol(
    rows: &[MarkRow],
) -> Result<HashMap<String, i64>, MarkReadBackError> {
    let mut by_symbol = HashMap::with_capacity(rows.len());
    let mut first_seen_at: HashMap<String, usize> = HashMap::with_capacity(rows.len());

    for (idx, row) in rows.iter().enumerate() {
        let key = row.symbol.trim();
        if key.is_empty() {
            return Err(MarkReadBackError::EmptySymbol { row: idx });
        }
        if let Some(&first_row) = first_seen_at.get(key) {
            return Err(MarkReadBackError::DuplicateSymbol {
                symbol: key.to_string(),
                first_row,
                dup_row: idx,
            });
        }
        first_seen_at.insert(key.to_string(), idx);
        by_symbol.insert(key.to_string(), row.mark_cents);
    }

    Ok(by_symbol)
}
```

Assumptions:
1. `MarkRow.mark_cents` is already-parsed `i64` Cents; parsing the raw GOOGLEFINANCE cell text/formula-error sentinels into Cents is a separate concern upstream of this function, out of scope for this EARS.
2. Row identity = exact string match on the symbol after `trim()`; no case-folding — ticker casing is assumed already normalized by whatever writes the sheet.
3. An empty/whitespace-only symbol is treated as a distinct invalid-row error (`EmptySymbol`), not silently skipped or coerced into a duplicate check.
4. "Erroring loudly" is interpreted as a typed `Result` error propagated with `?` (fails the settle pass hard, forces caller handling/logging) rather than a `panic!` — this is untrusted external sheet data, not a programmer invariant, so panicking would be the wrong kind of "loud."
5. Detection is first-duplicate-wins: the function returns on the *first* violation found rather than collecting all duplicates, since the requirement asks only for an assertion + loud error, not a full diagnostic report.
6. Zero input rows is not itself an error here — "one row per symbol" bounds the *maximum* per symbol; any minimum-row-count expectation (e.g., every ledger symbol must appear) belongs to a different EARS/spec, not this one.
7. Input `rows` is assumed pre-scoped to the marks range/tab only (no filtering of unrelated sheet rows needed inside this function).
8. Row index (`idx`) is used only for human-readable error diagnostics, not as part of the row's identity.