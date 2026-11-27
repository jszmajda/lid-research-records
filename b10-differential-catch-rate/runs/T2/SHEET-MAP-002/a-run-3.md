```rust
use std::collections::HashMap;
use thiserror::Error;

/// One row from the sheet's marks/settle read-back range.
#[derive(Debug, Clone)]
pub struct MarkRow {
    pub symbol: String,
    pub price_cents: Option<i64>, // None if GOOGLEFINANCE cell errored/blank
}

#[derive(Debug, Error)]
pub enum MarkReadbackError {
    #[error("duplicate mark row for symbol {symbol:?}: rows {first_row} and {dup_row}")]
    DuplicateSymbol { symbol: String, first_row: usize, dup_row: usize },
    #[error("mark row {row} has empty/blank symbol")]
    EmptySymbol { row: usize },
}

/// Keys mark read-back rows by symbol (row identity), asserting exactly
/// one row per symbol within this read-back pass. Returns a hard error
/// (never silently dropped/merged) on any violation.
pub fn key_marks_by_symbol(
    rows: &[MarkRow],
) -> Result<HashMap<String, &MarkRow>, MarkReadbackError> {
    let mut by_symbol: HashMap<String, (usize, &MarkRow)> = HashMap::with_capacity(rows.len());

    for (row, mark) in rows.iter().enumerate() {
        let symbol = mark.symbol.trim();
        if symbol.is_empty() {
            return Err(MarkReadbackError::EmptySymbol { row });
        }
        if let Some((first_row, _)) = by_symbol.get(symbol) {
            return Err(MarkReadbackError::DuplicateSymbol {
                symbol: symbol.to_string(),
                first_row: *first_row,
                dup_row: row,
            });
        }
        by_symbol.insert(symbol.to_string(), (row, mark));
    }

    Ok(by_symbol.into_iter().map(|(k, (_, m))| (k, m)).collect())
}
```

Assumptions:
1. `MarkRow` shape invented: `symbol: String` + `price_cents: Option<i64>`; only fields this spec's keying logic touches.
2. "Erroring loudly" interpreted as a returned `Result::Err` (propagated up, not logged-and-swallowed) rather than a `panic!`, since sheets-view is a library crate and callers (settle pass) decide surfacing/abort; a stricter reading could instead `panic!`/`expect` — noted as the rejected alternative.
3. Symbol matching is exact-string after `.trim()` only (defensive against incidental spreadsheet whitespace); no case-folding, since ticker symbols are assumed case-canonical as written by the kernel. Case-insensitive matching was considered and rejected absent evidence tickers vary in case in this workbook.
4. Scope of "one row per symbol" is per invocation (a single read-back of the current tab state), not cross-pass/historical — the function is stateless.
5. Empty/blank symbol string is treated as a distinct violation (`EmptySymbol`), not silently skipped or coalesced into "no row" — since it can't key anything and violates row identity by definition.
6. Zero rows present for a symbol the kernel expected is out of scope for this spec (a completeness/reconciliation concern elsewhere); this function only enforces *uniqueness* of whatever rows exist, not *coverage* of expected symbols.
7. Row index is 0-based over the given slice (not the sheet's 1-based row number) for error identity — a real implementation would map back to sheet row numbers for operator-facing errors.