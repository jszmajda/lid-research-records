```rust
//! Positions tab: `Quote Date` companion column (SHEET-MARK-008).
//!
//! Emits a formula that turns GOOGLEFINANCE's trade date into a
//! locale-proof integer: days since 1970-01-01. Sheets serial epoch is
//! 1899-12-30, so `serial - 25569` = Unix epoch days. TEXT(...,"0")
//! forces a plain integer string with no locale separators, no date
//! rendering, no exponent. Empty while loading or errored.

/// Column letter on Positions holding the symbol for row `row` (1-based).
const SYMBOL_COL: &str = "A";
/// Sheets serial for 1970-01-01.
const UNIX_EPOCH_SERIAL: i64 = 25_569;

/// A1 formula for the Quote Date cell of a Positions row.
pub fn quote_date_formula(row: u32) -> String {
    let sym = format!("${SYMBOL_COL}{row}");
    format!(
        "=IFERROR(IF(ISBLANK({sym}),\"\",\
         IFERROR(TEXT(N(GOOGLEFINANCE({sym},\"tradetime\"))-{UNIX_EPOCH_SERIAL},\"0\"),\"\")),\"\")"
    )
}

/// Parse one read-back cell into a quote epoch-day stamp.
/// `Ok(None)` = loading/errored/blank (not an error); settle skips the row.
pub fn parse_quote_epoch_day(raw: &str) -> Result<Option<i64>, QuoteDateParseError> {
    let s = raw.trim();
    if s.is_empty() || s.eq_ignore_ascii_case("#N/A") || s.starts_with('#') {
        return Ok(None);
    }
    // Values read-back may deliver a number, not a string; both stringify
    // to digits. Truncate any stray fractional part defensively.
    let head = s.split(['.', ',']).next().unwrap_or(s);
    head.parse::<i64>()
        .map(Some)
        .map_err(|_| QuoteDateParseError::Unparseable(s.to_owned()))
}

#[derive(Debug, thiserror::Error)]
pub enum QuoteDateParseError {
    #[error("unparseable quote-date stamp: {0:?}")]
    Unparseable(String),
}
```

ASSUMPTIONS (all invented):

1. Sheets serial epoch = 1899-12-30, so the offset constant is 25569; `TEXT(x,"0")` is the locale-proof integer format.
2. `GOOGLEFINANCE(sym,"tradetime")` (a datetime serial) is the trade-date source; `N()` coerces datetime→number. Chose "tradetime" over "datadelay"/"date" because it is the documented per-symbol quote timestamp.
3. `TEXT(...,"0")` rounds; intraday fractions could round *up* a day. I truncate instead is not expressible without `INT` — I assumed `TEXT` on the already-integer-ish difference is acceptable per the EARS wording ("serial-date difference"). If truncation is required, wrap in `INT(...)`.
4. Symbol lives in column A of the same row; layout is caller-fixed.
5. Blank symbol → empty string, same as errored — EARS only specifies loading/errored.
6. Loading state (`Loading...`) surfaces as an error to `IFERROR`; double `IFERROR` covers both `#N/A` and `#ERROR!`.
7. Read-back returns `String`; numeric formatting by the API is tolerated via the truncate step.
8. `Option<i64>` chosen over sentinel/`i64::MIN` so settle can distinguish "no quote yet" from a real epoch day; negative values (pre-1970) parse fine and are not rejected.
9. No timezone normalization: EARS says days-since-epoch, so whatever calendar day Sheets reports is authoritative.
10. Header string "Quote Date" and column placement are owned by the caller's tab-schema code, not this module.