```rust
//! sheets-view: Positions tab "Quote Date" companion column.
//! Emits the cell formula and parses its values-read-back string;
//! no accounting/tax math lives here.

/// Epoch-day count parsed from the settle pass's values read-back.
/// `None` means the source cell was blank/loading/errored.
pub struct QuoteEpochDays(pub i64);

/// Builds the Quote Date formula for one Positions row.
/// `symbol_cell` is the row's ticker-symbol cell reference (e.g. "$A2").
pub fn quote_date_formula(symbol_cell: &str) -> String {
    let gf = format!("GOOGLEFINANCE({symbol_cell},\"tradetime\")");
    format!(
        "=IFERROR(IF(ISNUMBER({gf}),TEXT(INT({gf})-DATE(1970,1,1),\"0\"),\"\"),\"\")"
    )
}

/// Parses one read-back cell value into a locale-proof epoch-day count.
/// Empty/whitespace-only -> None (loading/errored/blank upstream).
pub fn parse_quote_epoch_days(raw: &str) -> Option<QuoteEpochDays> {
    let t = raw.trim();
    if t.is_empty() {
        return None;
    }
    t.parse::<i64>().ok().map(QuoteEpochDays)
}
```

Assumptions (invented beyond the EARS text):

1. **GOOGLEFINANCE call/attribute**: the requirement says "GOOGLEFINANCE's trade date" but doesn't name the attribute. I chose `GOOGLEFINANCE(symbol,"tradetime")` (the documented attribute returning the last-trade datetime) rather than assuming a fabricated `"tradedate"` attribute.
2. **Independent formula, not a shared helper cell**: I assumed the Quote Date column calls `GOOGLEFINANCE` itself (referencing the row's symbol cell) rather than reading a hidden Price-column cell, since the spec calls it a standalone "companion column" with its own formula.
3. **Loading/error detection**: "empty while loading/errored" is ambiguous between a sheets *error value* (`#N/A`) and the transient literal string Sheets shows while a quote resolves. I treat both: `IFERROR(...,"")` catches thrown errors; `ISNUMBER(...)` false-branches any non-numeric result (including the loading placeholder text) to `""`.
4. **Epoch arithmetic**: `INT(...) - DATE(1970,1,1)` strips any time-of-day component before differencing, since only whole trade-date days are meaningful for a settle-pass epoch stamp.
5. **`TEXT(...,"0")` mask**: chosen to force plain integer digits with no locale-dependent thousands/decimal separators, satisfying "locale-proof."
6. **Read-back type**: the settle pass receives the cell's *values* (strings), so `parse_quote_epoch_days` takes `&str`, trims whitespace, and returns `Option<i64>` wrapped in `QuoteEpochDays`; malformed non-empty content (defensive case not in the EARS) also maps to `None` via `.ok()` rather than panicking.
7. **Negative/pre-1970 values**: not special-cased — `i64::parse` naturally accepts a leading `-` should `INT(...)` ever precede 1970-01-01, which cannot occur for real equity trade dates but costs nothing to allow.
8. **Row-scoped formula generation**: the function takes a single cell reference and is invoked once per Positions row by the caller; no batching/range logic is assumed since the EARS describes a per-row column formula, not a bulk API shape.