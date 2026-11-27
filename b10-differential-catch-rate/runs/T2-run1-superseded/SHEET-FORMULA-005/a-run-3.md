```rust
//! sheets-view: formats the `Est. Tax Rate` cell so the Sheets API parses it
//! as a numeric, percent-typed value (not a text string), matching the
//! parsing Sheets performs for typed-in percentages under
//! `valueInputOption = USER_ENTERED`.

/// Tax rate in basis points; 1_500 == 15.00%. Matches the integer-cents
/// convention used for Money elsewhere in the kernel.
#[derive(Clone, Copy, Debug)]
pub struct TaxRateBps(pub i64);

/// Produces the JSON value to place in the `ValueRange` for this cell.
/// Caller must submit it via `spreadsheets.values.update` (or
/// `values.batchUpdate`) with `valueInputOption = USER_ENTERED`, the same
/// input option used for the sheet's other live cells (e.g. the
/// GOOGLEFINANCE formula column), so Sheets applies its normal
/// type-inference: a `%`-suffixed literal is parsed into a numeric
/// percent-formatted cell rather than stored as literal text.
pub fn tax_rate_cell_value(rate: Option<TaxRateBps>) -> serde_json::Value {
    let bps = rate.map(|r| r.0).unwrap_or(0);
    let sign = if bps < 0 { "-" } else { "" };
    let abs = bps.abs();
    let whole = abs / 100;
    let frac = abs % 100;
    serde_json::Value::String(format!("{sign}{whole}.{frac:02}%"))
}
```

Assumptions (explicitly invented, not stated by the EARS):

1. **Rate type/shape**: no tax-rate type is defined elsewhere in the given context, so I invented `TaxRateBps(i64)` (basis points, matching the integer-cents style of `Money`) rather than an `f64` fraction, to avoid float precision issues feeding a formatted string.
2. **API surface chosen**: the EARS's own example ("a `%`-suffixed value") most directly maps to the `values.update`/`values.batchUpdate` endpoint under `valueInputOption=USER_ENTERED`, which parses typed-looking strings the way the Sheets UI would (formulas starting with `=`, percents ending in `%`). I chose this over constructing a raw `CellData.numberValue` + `CellFormat.numberFormat(PERCENT)` via `batchUpdate`'s `UpdateCellsRequest`, since the latter doesn't accept an "input option" and wouldn't match the literal `%`-suffixed phrasing — but it is the more locale-independent alternative if USER_ENTERED parsing proves unreliable across spreadsheet locales.
3. **Missing/`None` rate**: falls back to `"0.00%"` rather than an empty string, since the requirement states the value must evaluate *numerically* in a multiplying formula — a blank/text cell would break `Est. Unrealized Tax` / `Net Unrealized` downstream.
4. **Negative rates**: passed through with a leading `-` (e.g. rebate/credit scenarios) rather than clamped or rejected, since no domain constraint against negative rates was given.
5. **Precision**: fixed at 2 decimal places (`NN.NN%`), an invented default since the EARS specifies no precision.
6. **No rounding/overflow guard** on values >100% or extreme basis-point magnitudes — treated as the upstream kernel's correctness responsibility, not this projection function's.