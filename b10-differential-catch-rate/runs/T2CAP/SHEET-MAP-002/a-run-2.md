```rust
//! sheets-view: mark read-back keying (SHEET-MAP-002)

use std::collections::HashMap;

/// A single row read back from the marks range of the sheet.
#[derive(Debug, Clone)]
pub struct MarkRow {
    /// 1-based sheet row number, used only for error reporting.
    pub row: usize,
    /// Row identity. Normalized (trim + ASCII uppercase) before keying.
    pub symbol: String,
    /// The settled mark, already parsed to integer Cents by the caller.
    pub mark: Cents,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Cents(pub i64);

#[derive(Debug, thiserror::Error)]
pub enum MarkKeyError {
    #[error("duplicate symbol {symbol:?} in mark read-back at rows {first} and {dup}")]
    DuplicateSymbol { symbol: String, first: usize, dup: usize },
    #[error("empty symbol in mark read-back at row {row}")]
    EmptySymbol { row: usize },
}

/// Key mark read-back rows by symbol, asserting exactly one row per symbol.
/// Errors loudly (no last-wins, no silent drop) on any duplicate.
pub fn key_marks_by_symbol(
    rows: impl IntoIterator<Item = MarkRow>,
) -> Result<HashMap<String, Cents>, MarkKeyError> {
    let mut out: HashMap<String, Cents> = HashMap::new();
    let mut seen_at: HashMap<String, usize> = HashMap::new();

    for r in rows {
        let key = r.symbol.trim().to_ascii_uppercase();
        if key.is_empty() {
            return Err(MarkKeyError::EmptySymbol { row: r.row });
        }
        if let Some(&first) = seen_at.get(&key) {
            return Err(MarkKeyError::DuplicateSymbol { symbol: key, first, dup: r.row });
        }
        seen_at.insert(key.clone(), r.row);
        out.insert(key, r.mark);
    }
    Ok(out)
}
```

ASSUMPTIONS (all invented; none stated by the EARS):

1. Type shapes: `MarkRow { row, symbol, mark }`, `Cents(i64)`, and a `MarkKeyError` enum are all invented. Money is Cents per the workspace convention.
2. Parsing of the raw sheet cell into `Cents` happens upstream; this function receives already-parsed rows. The EARS says nothing about parsing.
3. Return type is `HashMap<String, Cents>` — the "keyed" product. EARS names the key but not the value or container.
4. Symbol normalization: trim + ASCII uppercase before comparison, so `"aapl "` and `"AAPL"` collide as duplicates. EARS is silent; I chose normalize-then-assert because sheet-entered symbols vary in case/whitespace and a case-sensitive key would silently admit two rows for one instrument, defeating the requirement's intent.
5. "Erroring loudly" = returning `Err` (a typed, recoverable, reportable error carrying both offending row numbers), not `panic!`. Chosen because the sheets-view crate reads untrusted user-editable sheet input; a panic on user data is a crash, not a diagnostic. If "loudly" was meant as `panic!`/`assert!`, swap the `Err` returns.
6. Fail-fast on the first duplicate rather than collecting all duplicates. EARS is silent; fail-fast is simpler and the row pair is enough to fix the sheet.
7. Empty/blank symbol is treated as an error, not as a valid key — otherwise multiple blank rows would falsely collide and blank keys would be meaningless. EARS does not mention it.
8. Zero rows is legal (empty map), not an error — the EARS asserts at most/exactly one row *per symbol present*, not that any symbol must be present. It says nothing about expected-symbol coverage, so no cross-check against the position set is performed here.
9. Row-order is not significant; the retained value on success is the sole row's mark, so no precedence rule is needed.
10. `thiserror` is available in the crate.