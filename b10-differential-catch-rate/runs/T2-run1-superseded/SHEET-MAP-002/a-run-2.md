```rust
use std::collections::HashMap;
use thiserror::Error;

/// One row as read back from the marks view tab (post GOOGLEFINANCE settle).
#[derive(Debug, Clone)]
pub struct MarkRow {
    pub symbol: String,
    pub price_cents: i64,
    pub as_of: String,
}

#[derive(Debug, Error)]
pub enum MarkReadBackError {
    #[error("duplicate mark row for symbol {symbol:?}: rows {first_row} and {dup_row}")]
    DuplicateSymbol { symbol: String, first_row: usize, dup_row: usize },
    #[error("row {0} has empty/missing symbol key")]
    MissingSymbol(usize),
}

/// Keys mark read-back rows by symbol (row identity). Asserts exactly one
/// row per symbol; errors loudly (typed Err, not silent overwrite) on violation.
pub fn key_marks_by_symbol(
    rows: impl IntoIterator<Item = MarkRow>,
) -> Result<HashMap<String, MarkRow>, MarkReadBackError> {
    let mut seen: HashMap<String, usize> = HashMap::new();
    let mut out: HashMap<String, MarkRow> = HashMap::new();
    for (idx, row) in rows.into_iter().enumerate() {
        if row.symbol.trim().is_empty() {
            return Err(MarkReadBackError::MissingSymbol(idx));
        }
        if let Some(&first_idx) = seen.get(&row.symbol) {
            return Err(MarkReadBackError::DuplicateSymbol {
                symbol: row.symbol,
                first_row: first_idx,
                dup_row: idx,
            });
        }
        seen.insert(row.symbol.clone(), idx);
        out.insert(row.symbol.clone(), row);
    }
    Ok(out)
}
```

Assumptions (invented, since only this one EARS line was given):

1. **Input shape**: `MarkRow` is already parsed from the Sheets API response (symbol/price/timestamp); raw JSON/Sheets-API parsing is out of scope for this spec.
2. **"Row identity (symbol)" is exact-match, case-sensitive**, with no normalization (no uppercasing/trimming beyond emptiness check) — the EARS doesn't specify symbol canonicalization, so no assumption is made beyond identity comparison.
3. **Empty/whitespace-only symbol is treated as an invalid row** and rejected via a distinct error variant, since "one row per symbol" presupposes a valid, non-empty key; this is not explicit in the EARS but is the minimal boundary case implied by "row identity."
4. **"Erroring loudly" is interpreted as a typed, specific `Result::Err`** (not a panic and not a silently-overwriting `HashMap::insert`) — chosen because the crate boundary (sheets-view) shouldn't panic internally per general Rust library convention; loudness is satisfied by an unambiguous, undiscardable error variant that the caller must handle, versus silent last-write-wins.
5. **Scope of the "one row" assertion is per read-back call/tab**, not persisted across calls — no cross-invocation duplicate-tracking state is assumed.
6. **Duplicate detection reports both the first and duplicate row indices** for diagnostics, since the spec says "erroring loudly" but doesn't specify error payload content — this is an invented enrichment, not a requirement.
7. **`price_cents`/`as_of` types are placeholders** (i64 cents, opaque String) — SHEET-MAP-002 governs only the symbol-keying/uniqueness behavior, not the row's other fields.