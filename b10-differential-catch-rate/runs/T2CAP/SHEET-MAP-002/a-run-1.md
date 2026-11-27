```rust
// crates/sheets-view/src/marks.rs
// @spec SHEET-MAP-002

use std::collections::HashMap;

/// Money in integer minor units.
pub type Cents = i64;

/// Canonical row identity for the marks tab.
pub type Symbol = String;

/// One row read back from the marks tab.
#[derive(Debug, Clone)]
pub struct MarkRow {
    pub symbol: Symbol,
    /// Row index in the sheet (1-based, as Sheets reports it) — carried only for error reporting.
    pub row: usize,
    pub price: Option<Cents>,
}

#[derive(Debug, thiserror::Error, PartialEq)]
pub enum MarkReadBackError {
    #[error("duplicate symbol {symbol:?} in marks read-back at rows {first} and {duplicate}")]
    DuplicateSymbol { symbol: Symbol, first: usize, duplicate: usize },
    #[error("blank symbol in marks read-back at row {row}")]
    BlankSymbol { row: usize },
}

/// Key mark read-back by row identity (symbol), asserting exactly one row per symbol.
/// Errors loudly on the first violation — no silent last-write-wins, no dedup.
pub fn key_marks_by_symbol(
    rows: impl IntoIterator<Item = MarkRow>,
) -> Result<HashMap<Symbol, MarkRow>, MarkReadBackError> {
    let mut by_symbol: HashMap<Symbol, MarkRow> = HashMap::new();
    for row in rows {
        let key = row.symbol.trim().to_ascii_uppercase();
        if key.is_empty() {
            return Err(MarkReadBackError::BlankSymbol { row: row.row });
        }
        if let Some(first) = by_symbol.get(&key) {
            return Err(MarkReadBackError::DuplicateSymbol {
                symbol: key,
                first: first.row,
                duplicate: row.row,
            });
        }
        by_symbol.insert(key, row);
    }
    Ok(by_symbol)
}
```

Assumptions invented (all of them):

1. Symbol is the sole key; sheet row index is metadata for diagnostics only, not identity.
2. Symbol normalization: trim + ASCII-uppercase before comparison, so `aapl `/`AAPL` collide as duplicates. Chose strict-collide because a silent case-variant split would produce two ledger marks for one holding.
3. Blank/whitespace-only symbol is an error, not a skipped row — "one row per symbol" implies every row has a symbol. (Alternative: skip trailing blank rows from a padded range; rejected as silent data loss. Callers should truncate the sheet range before calling.)
4. `price: Option<Cents>` — a `#N/A`/pending GOOGLEFINANCE cell yields `None`; this function does not validate prices (SHEET-MAP-002 covers keying only). No price-parsing here.
5. "Erroring loudly" = a typed `Result` error naming the symbol and both offending rows, fail-fast on the first duplicate rather than accumulating all violations. Chose fail-fast for a smaller surface; the caller (settle pass) is expected to abort the whole read-back, not partially settle. `panic!` was rejected — a library crate should not abort the process.
6. `Cents = i64`; `thiserror` is a workspace dependency.
7. Empty input is legal and yields an empty map (no holdings ⇒ no marks).
8. Function is pure and total over its input; it performs no I/O and no accounting/tax math, per the sheets-view crate's boundary.
9. Ownership: returns owned `MarkRow` values in the map rather than borrowing, so the settle pass can consume rows independently of the source vector.
10. No assumption that the marks tab is sorted, contiguous, or aligned with the positions tab — ordering is irrelevant to keying.