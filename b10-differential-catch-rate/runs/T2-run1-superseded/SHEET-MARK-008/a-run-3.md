```rust
//! sheets-view: Positions tab "Quote Date" companion column.
//! @spec SHEET-MARK-008

/// Builds the Quote Date formula for one Positions row, given the A1
/// reference to that row's ticker-symbol cell (e.g. "A2").
pub fn quote_date_formula(symbol_ref: &str) -> String {
    format!(
        "=IFERROR(IF(ISNUMBER(GOOGLEFINANCE({s},\"tradetime\")),\
          TEXT(INT(GOOGLEFINANCE({s},\"tradetime\")-DATE(1970,1,1)),\"0\"),\"\"),\"\")",
        s = symbol_ref
    )
}

/// Settle-pass counterpart: parses the column's read-back *value*
/// (not formula) into a Unix-epoch day count.
#[derive(Debug, thiserror::Error)]
pub enum QuoteDateParseError {
    #[error("Quote Date cell non-empty but not an integer day count: {0:?}")]
    NotAnInteger(String),
}

pub fn parse_quote_epoch_days(raw: &str) -> Result<Option<i64>, QuoteDateParseError> {
    let t = raw.trim();
    if t.is_empty() {
        return Ok(None); // loading or errored
    }
    t.parse::<i64>()
        .map(Some)
        .map_err(|_| QuoteDateParseError::NotAnInteger(raw.to_string()))
}
```

Interpretation: "GOOGLEFINANCE's trade date" is the `"tradetime"` real-time attribute (a Sheets datetime serial). Locale-proofing comes from subtracting `DATE(1970,1,1)` — itself a serial number — so the result is pure serial arithmetic, never a parsed/formatted date string; `TEXT(...,"0")` then forces a bare-digit string on read-back regardless of the sheet's locale/number-format.

Assumptions:
1. Formula-builder takes only the row's symbol-cell A1 ref; row layout/injection is owned elsewhere in sheets-view.
2. `INT()` truncates `tradetime`'s time-of-day fraction, isolating the trade *date* (time-of-day intentionally dropped — spec says "trade date," not time).
3. Both loading (`"Loading..."`, caught via `ISNUMBER`) and error (`#N/A`, caught via `IFERROR`) states collapse to `""`, since the requirement doesn't ask them distinguished.
4. `i64` for epoch-day count (ample range; integer per spec, not `f64`).
5. Parser treats empty as `None` (skip); any non-empty, non-integer content is a hard `Err` — the column's contract guarantees digits-or-empty, so anything else signals a broken formula, not a value to silently skip.
6. No range/sanity validation on the parsed day count (negative, zero, far-future) — treated as the settle pass's business-logic concern, out of scope for rendering this column.
7. Two separate `GOOGLEFINANCE` calls per formula (inside `ISNUMBER` and inside `TEXT`/`INT`) rather than referencing a shared helper cell — assumed acceptable duplication; not deduped against an existing "Trade Time" column since none is specified in this EARS.
8. `thiserror` assumed available in this crate for the error enum; swap for a hand-rolled `Display` impl if not.