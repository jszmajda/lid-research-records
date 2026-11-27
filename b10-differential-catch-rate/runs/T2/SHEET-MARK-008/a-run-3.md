```rust
//! @spec SHEET-MARK-008
//! Quote Date column: locale-proof epoch-day stamp for GOOGLEFINANCE's trade
//! date, read back by the settle pass via pure integer parsing.

/// Builds the Quote Date formula for one Positions row.
/// `ticker_cell`/`price_cell` are same-row A1 refs (e.g. "A2", "B2").
pub fn quote_date_formula(ticker_cell: &str, price_cell: &str) -> String {
    format!(
        "=IF(ISNUMBER({price}), \
           TEXT(INT(GOOGLEFINANCE({ticker},\"tradedate\")) - DATE(1970,1,1), \"0\"), \
           \"\")",
        price = price_cell,
        ticker = ticker_cell,
    )
}

/// Parses the settle pass's read-back cell value into days-since-epoch.
/// Returns `None` for the empty string (loading/errored) or anything
/// non-numeric — never invokes datetime parsing.
pub fn parse_quote_epoch_days(cell_value: &str) -> Option<i64> {
    let trimmed = cell_value.trim();
    if trimmed.is_empty() {
        return None;
    }
    trimmed.parse::<i64>().ok()
}
```

Assumptions (invented, none given by the EARS text):

1. **GOOGLEFINANCE attribute name**: assumed a `"tradedate"` attribute exists analogous to `"price"`, since the EARS says the formula "encodes GOOGLEFINANCE's trade date" — no attribute name was specified, and Google's documented attribute list doesn't officially list one for live quotes; this is the chosen interpretation, not a verified API fact.
2. **Epoch computed in-sheet, not hardcoded**: used `DATE(1970,1,1)` inside the formula rather than a literal serial constant (e.g. 25569), so the subtraction is correct regardless of the spreadsheet's date system (1900 vs 1904). A Rust-side epoch constant was deliberately omitted to avoid a value that could silently drift from the sheet's own setting.
3. **Loading/error gate**: gated on `ISNUMBER(price_cell)` rather than wrapping the date call in its own `IFERROR`, on the assumption price and date share fate (both blank while GOOGLEFINANCE is loading/erroring for that ticker) — avoids a second live call and avoids the two columns disagreeing on error state.
4. **`TEXT(...,"0")` format**: assumed a bare integer pattern (no grouping/decimal) to guarantee a plain digit string; no negative-value case handled since real trade dates postdate 1970-01-01.
5. **Parser symmetry**: `parse_quote_epoch_days` returns `None` uniformly for empty and non-numeric input, since the EARS only requires avoiding locale-dependent datetime parsing, not distinguishing loading from error.
6. **`i64`** chosen for headroom; no upper-bound/overflow case is realistically reachable.