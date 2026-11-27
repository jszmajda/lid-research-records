```rust
//! Positions tab: locale-proof "Quote Date" companion column (SHEET-MARK-008).

/// A1 reference to this row's ticker/symbol cell, e.g. "B2".
pub struct TickerCell<'a>(pub &'a str);

/// Days since 1970-01-01, recovered from a "Quote Date" cell's read-back
/// string value — the per-symbol quote-epoch stamp the settle pass consumes.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct QuoteEpochDays(pub i64);

/// Builds the `Quote Date` formula for one Positions row.
///
/// GOOGLEFINANCE(symbol,"tradedate") returns a Sheets serial date (epoch
/// 1899-12-30). Subtracting DATE(1970,1,1) — a serial number in the same
/// day-count system — yields the Unix-epoch day offset; any Sheets
/// leap-bug quirk cancels out since both sides share the same serial
/// system. TEXT(...,"0") forces a bare unlocalized digit string (no
/// grouping separators, no re-parsed date). IFERROR collapses
/// loading/#N/A/#ERROR! to "".
pub fn quote_date_formula(ticker: TickerCell<'_>) -> String {
    format!(
        r#"=IFERROR(TEXT(GOOGLEFINANCE({sym},"tradedate")-DATE(1970,1,1),"0"),"")"#,
        sym = ticker.0
    )
}

/// Parses a read-back `Quote Date` cell value into an epoch-day stamp.
/// Empty (loading/errored) => None. Otherwise parsed as a bare base-10
/// integer — never as a date/time — per the "no locale-dependent
/// datetime parsing" requirement.
pub fn parse_quote_date(cell_value: &str) -> Option<QuoteEpochDays> {
    let t = cell_value.trim();
    if t.is_empty() {
        return None;
    }
    t.parse::<i64>().ok().map(QuoteEpochDays)
}
```

Assumptions invented beyond the EARS text:

1. `quote_date_formula` takes a caller-supplied A1 ticker-cell reference; Positions tab's exact column layout isn't specified.
2. Interpreted "GOOGLEFINANCE's trade date" as the `"tradedate"` attribute string (vs. default price/no-attribute call).
3. Used `DATE(1970,1,1)` subtraction (both operands same Sheets serial-day system) to get the Unix-epoch offset; assumed this cancels Sheets' historical 1900-leap-year serial quirk rather than needing a manual +1/-1 correction.
4. Chose `TEXT(...,"0")` as the format string specifically to suppress locale-dependent thousands separators — assumed no locale renders bare `"0"` with grouping.
5. Assumed the loading state manifests as a Sheets error (`#N/A`/`#ERROR!`) so `IFERROR` alone satisfies "empty while loading" — a blank-but-non-error loading state isn't distinguished.
6. Modeled the parsed result as `QuoteEpochDays(i64)`, a bare day count, not a full timestamp/DateTime — assumed the settle pass only needs a comparable integer stamp, no time-of-day component (GOOGLEFINANCE tradedate has none).
7. `parse_quote_date` treats malformed/non-numeric non-empty content the same as empty (`None`) rather than erroring — an interpretive leniency choice the EARS doesn't explicitly cover (it only names the empty case).
8. No range/sanity validation on the parsed integer (e.g., rejecting negative or far-future values); deferred to the caller.
9. Function signatures assume `String`/`&str` as the sheets-view crate's formula/value representation, with no dependency on a specific Sheets API client type.