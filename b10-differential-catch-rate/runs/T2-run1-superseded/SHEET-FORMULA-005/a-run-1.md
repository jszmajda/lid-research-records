```rust
use serde_json::{json, Value};

/// Tax rate expressed in basis points (1500 == 15.00%) to keep integer
/// precision consistent with the Cents convention used for money elsewhere
/// in the kernel.
pub type Bps = i64;

/// Builds the `userEnteredValue`/`userEnteredFormat` pair for the
/// "Est. Tax Rate" cell of a Sheets `batchUpdate` request.
///
/// Writes a `numberValue` (a fraction, e.g. 0.15) with a PERCENT
/// `numberFormat`, never a `stringValue`. The Sheets API does not
/// re-parse `stringValue` text the way the UI parses keystrokes, so a
/// literal `"15%"` string would land as TEXT and poison any live
/// formula (`Est. Unrealized Tax`, `Net Unrealized`) that multiplies it.
pub fn est_tax_rate_cell(rate_bps: Option<Bps>) -> Value {
    let fraction = rate_bps.unwrap_or(0) as f64 / 10_000.0;
    json!({
        "userEnteredValue": { "numberValue": fraction },
        "userEnteredFormat": {
            "numberFormat": { "type": "PERCENT", "pattern": "0.00%" }
        }
    })
}
```

Assumptions:

1. **Ambiguity resolved**: the EARS's `"%"-suffixed value` example is read as describing the *displayed* format (a PERCENT `numberFormat` pattern ending in `%`), not a literal string to write — because `userEnteredValue.stringValue` is never numerically reinterpreted by the Sheets API (only interactive UI keystrokes get that treatment). Writing `numberValue` + `numberFormat.type = "PERCENT"` is the only way to satisfy "parses it as a number."
2. **Rate representation**: modeled as integer basis points (`Bps = i64`, 1500 = 15.00%), mirroring the integer-Cents convention for money, rather than a raw `f64` percentage the kernel might hand the crate directly.
3. **Missing/absent rate**: no tax rate available (e.g., no cost basis, non-taxable lot) defaults to `0` bps → `0.0` numeric, not a blank/`"N/A"` text cell — preserves "always numeric" for the downstream multiply at the cost of visually implying a 0% rate rather than "unknown."
4. **Out-of-range / negative bps**: passed through uninterpreted (no clamping to `[0, 10000]`); validation of rate bounds is assumed to be the kernel's responsibility, not the sheets-view projection's.
5. **Format pattern**: `"0.00%"` (two decimal places) is an invented display convention, not specified by the EARS; any consistent PERCENT pattern satisfies the requirement's numeric-parsing intent.
6. **Serialization shape**: modeled as a raw `serde_json::Value` fragment matching the Sheets API v4 `CellData` schema (`userEnteredValue`/`userEnteredFormat`), assuming the crate builds `batchUpdate` requests via JSON rather than strongly-typed `google-sheets4` structs — reasonable given no crate/type info was supplied.
7. **No currency/Cents involvement**: a tax *rate* is a ratio, not money, so it deliberately does not use the Cents integer type despite the workspace's stated money convention — assumed out of scope for the Cents invariant.