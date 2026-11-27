```rust
// crates/sheets-view/src/quote_date.rs
// @spec SHEET-MARK-008
//
// Positions tab renders, beside the live-price column, a `Quote Date` column
// whose formula yields an integer day-count since the Unix epoch, as *text*,
// so the settle pass can parse it with `str::parse::<i64>()` and never touch a
// locale-dependent datetime parser.

/// Column header rendered in row 1 of the Positions tab.
pub const QUOTE_DATE_HEADER: &str = "Quote Date";

/// Sheets serial 0 is 1899-12-30; 1970-01-01 is serial 25569.
const UNIX_EPOCH_SERIAL: i32 = 25569;

/// Formula for the `Quote Date` cell of the row holding `symbol`.
///
/// `IFERROR(..., "")` covers both the errored case and — because
/// GOOGLEFINANCE yields `#N/A "getting data"` while resolving — the loading
/// case, so the cell reads back as an empty string in both.
/// `INT(...)` drops the intraday time fraction; `TEXT(..., "0")` forces an
/// unformatted, unlocalized integer string (no grouping separator, no date
/// coercion by the sheet's locale).
pub fn quote_date_formula(symbol: &str) -> String {
    format!(
        r#"=IFERROR(TEXT(INT(GOOGLEFINANCE("{sym}","tradetime"))-{epoch},"0"),"")"#,
        sym = escape_formula_string(symbol),
        epoch = UNIX_EPOCH_SERIAL,
    )
}

/// Sheets string literals escape `"` by doubling it.
fn escape_formula_string(s: &str) -> String {
    s.replace('"', "\"\"")
}

/// Settle-pass side: parse one read-back `Quote Date` cell.
///
/// `Ok(None)` = still loading or errored (blank cell) — the caller leaves the
/// prior mark's epoch untouched rather than settling this symbol.
pub fn parse_quote_epoch_days(cell: &str) -> Result<Option<i64>, QuoteDateError> {
    let t = cell.trim();
    if t.is_empty() {
        return Ok(None);
    }
    t.parse::<i64>()
        .map(Some)
        .map_err(|_| QuoteDateError::Unparsable(t.to_owned()))
}

#[derive(Debug, Clone, PartialEq, Eq, thiserror::Error)]
pub enum QuoteDateError {
    #[error("quote-date cell not an integer day count: {0:?}")]
    Unparsable(String),
}
```

Assumptions invented (all of them):

1. Attribute name `"tradetime"` is GOOGLEFINANCE's trade-date attribute; the price column presumably uses `"price"`.
2. Serial-date origin is the Sheets/Excel 1899-12-30 epoch → constant 25569. Chosen over emitting a `DATE(1970,1,1)` subtrahend for cheapness; either is locale-proof.
3. `INT` truncation, not rounding — the requirement says *count of days*, so intraday time is floored to the quote's date. Truncation toward zero equals floor for all post-1899 serials.
4. Interpretation chosen for "empty while loading/errored": one `IFERROR` covers both, because in-flight GOOGLEFINANCE surfaces as an error value. No separate loading sentinel is emitted — the requirement asks for empty in both cases, so the settle pass cannot distinguish them and must treat both as "no fresh stamp."
5. Return shape is `String` formula text (A1-style, per-row generated), not a batch range; the tab renderer owns row/`symbol` pairing. Symbol is inlined as a literal rather than referencing the symbol cell, so column ordering changes cannot break it.
6. `Ok(None)` (skip) rather than an error for blank cells; a non-empty non-integer is an error rather than a silent skip, since it means the formula or a user edit broke.
7. Dates before 1970 yield negative counts and are accepted (`i64`, not `u64`); no clamping.
8. No accounting/tax math here — day count is an opaque stamp passed to the kernel; no Cents involvement.
9. `thiserror` is already a workspace dependency.
10. Sheet locale may use `;` as the formula argument separator, but the API writes formulas in the en-US canonical form with `,`, so `,` is used.