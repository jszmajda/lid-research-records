```rust
//! sheets-view: Positions tab `Quote Date` column (SHEET-MARK-008)

/// A1-style ref of the cell holding the GOOGLEFINANCE price formula's symbol
/// argument for this row (e.g. "$A2"). Assumption: the Positions tab already
/// has a symbol column and the price column is built the same way.
pub struct SymbolRef(pub String);

/// Days since the Unix epoch, as parsed back from the sheet.
#[derive(Copy, Clone, PartialEq, Eq, Debug)]
pub struct QuoteEpochDay(pub i64);

/// Header text for the companion column.
pub const QUOTE_DATE_HEADER: &str = "Quote Date";

/// Sheets serial 0 == 1899-12-30; 1970-01-01 is serial 25569.
const EPOCH_SERIAL: i64 = 25569;

/// Render the formula for one row's `Quote Date` cell.
///
/// GOOGLEFINANCE(sym,"tradetime") yields a datetime serial; INT() floors to the
/// day, minus 25569 gives days since 1970-01-01. TEXT(...,"0") forces a
/// locale-proof plain integer string in the values read-back. IFERROR + the
/// empty-string guard render "" while loading or on error.
pub fn quote_date_formula(sym: &SymbolRef) -> String {
    let s = &sym.0;
    format!(
        r#"=IFERROR(IF(N(GOOGLEFINANCE({s},"tradetime"))=0,"",TEXT(INT(GOOGLEFINANCE({s},"tradetime"))-{EPOCH_SERIAL},"0")),"")"#
    )
}

/// Parse one read-back cell into a quote-epoch stamp.
/// Empty / whitespace / non-integer -> None (no stamp; settle pass skips row).
pub fn parse_quote_epoch(cell: &str) -> Option<QuoteEpochDay> {
    let t = cell.trim();
    if t.is_empty() {
        return None;
    }
    t.parse::<i64>().ok().map(QuoteEpochDay)
}
```

Assumptions invented (all of them):

1. Sheets' serial-date origin is 1899-12-30, so the epoch offset constant is 25569; the workbook is not in the 1904 date system.
2. `GOOGLEFINANCE(sym,"tradetime")` is the trade-date attribute used. (`"datadelay"`/`"tradetime"` naming is not given by the EARS.)
3. The symbol argument is a cell reference, not a literal — formula built per row from an existing symbol column.
4. Loading state surfaces as either an error or a blank/zero serial; both map to `""`. I chose `N(...)=0` as the loading sentinel plus `IFERROR` for `#N/A`, `#REF!`, etc.
5. `TEXT(...,"0")` is the locale-proof encoder: no thousands separator, no decimal separator, so no locale can reinterpret it. Negative values (pre-1970, implausible) still parse via `i64`.
6. `INT()` truncates toward -inf, so the stamp is the trade *date* in the spreadsheet's timezone; timezone is whatever the workbook is set to — no conversion attempted.
7. Read-back returns cell values as `String` (UNFORMATTED_VALUE or FORMATTED_VALUE both yield the same digits given `TEXT`).
8. `None` on unparseable input is a soft skip, not an error: the settle pass treats a missing stamp as "no fresh quote for this symbol" rather than failing the pass. Chosen because the EARS makes empty a normal loading state.
9. No `Cents`/money interaction — this column is purely a date stamp; the kernel owns any staleness policy applied to the parsed day.
10. Column placement ("companion") interpreted as immediately right of the price column; the caller owns actual placement.