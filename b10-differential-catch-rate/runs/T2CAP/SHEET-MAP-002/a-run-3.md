```rust
// crates/sheets-view/src/marks.rs
// @spec SHEET-MAP-002

use std::collections::HashMap;

/// Money as integer Cents (workspace-wide newtype; assumed to exist).
pub struct Cents(pub i64);

/// One row as read back from the marks tab.
pub struct MarkRow {
    pub row_index: usize, // 1-based sheet row, for error messages only
    pub symbol: String,
    pub mark: Option<Cents>, // None = blank / unresolved GOOGLEFINANCE cell
}

#[derive(Debug, thiserror::Error)]
pub enum MarkReadbackError {
    #[error("duplicate symbol {symbol:?} in marks read-back at rows {first} and {dup}")]
    DuplicateSymbol { symbol: String, first: usize, dup: usize },
    #[error("blank symbol in marks read-back at row {row}")]
    BlankSymbol { row: usize },
}

/// Key the marks read-back by row identity (symbol), asserting one row per symbol.
pub fn index_marks_by_symbol(
    rows: Vec<MarkRow>,
) -> Result<HashMap<String, MarkRow>, MarkReadbackError> {
    let mut by_symbol: HashMap<String, MarkRow> = HashMap::with_capacity(rows.len());
    for row in rows {
        let key = normalize_symbol(&row.symbol);
        if key.is_empty() {
            return Err(MarkReadbackError::BlankSymbol { row: row.row_index });
        }
        if let Some(prev) = by_symbol.get(&key) {
            return Err(MarkReadbackError::DuplicateSymbol {
                symbol: key,
                first: prev.row_index,
                dup: row.row_index,
            });
        }
        by_symbol.insert(key, row);
    }
    Ok(by_symbol)
}

fn normalize_symbol(s: &str) -> String {
    s.trim().to_ascii_uppercase()
}
```

Interpretation chosen: "row identity (symbol)" means the symbol column — not the sheet row number — is the join key between written rows and read-back rows, so read-back is matched positionally-independently. "Erroring loudly" = a typed `Err` returned to the settle pass that aborts the settle (no panic), because a sheets-view crate should not abort the process on remote-data shape problems; panic/`assert!` was rejected as it would take down the publisher on user-editable sheet content.

Assumptions invented:
1. `Cents` newtype exists workspace-wide; mark values are `Option<Cents>` because a GOOGLEFINANCE cell can read back blank/`#N/A` — parsing that cell is a different spec, so `None` is passed through unvalidated here.
2. Input arrives as an already-parsed `Vec<MarkRow>`; cell-to-row parsing is out of scope.
3. `row_index` is carried only for diagnostics; it is not the key.
4. Symbols are normalized (trim + ASCII uppercase) before comparison, so `"aapl "` and `"AAPL"` collide as duplicates rather than silently forming two keys.
5. Blank/whitespace-only symbol is an error, not a skipped row — a keyless row cannot participate in read-back.
6. Fail-fast on the first duplicate rather than collecting all violations; the requirement says "erroring loudly," and one duplicate already invalidates the settle.
7. Empty input is valid and yields an empty map (vacuously one-row-per-symbol).
8. Duplicate detection is within a single read-back batch only; cross-tab uniqueness is not asserted.
9. `thiserror` is available; error is returned, not logged, so the caller controls the loudness channel.
10. Case-insensitive equality only — no exchange-prefix normalization (`NASDAQ:AAPL` vs `AAPL` are distinct symbols).