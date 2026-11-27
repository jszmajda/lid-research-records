```rust
/// @spec SHEET-FORMULA-005
/// Builds the `Est. Tax Rate` cell payload for the sheets-view publish pass.
/// Must be sent via `spreadsheets.values.update` with
/// `valueInputOption = USER_ENTERED` (not RAW) — only USER_ENTERED runs
/// Sheets' own parser on the string, coercing a "%"-suffixed value into a
/// numeric, percent-formatted cell. RAW would store it as literal text and
/// downstream `Est. Unrealized Tax` / `Net Unrealized` formulas multiplying
/// against it would evaluate to #VALUE!.
pub struct SheetCell {
    pub value: String,
    pub input_option: ValueInputOption,
}

pub enum ValueInputOption {
    UserEntered,
}

/// `rate_bps`: signed basis points (1 bp = 0.01%), mirroring the ledger's
/// integer-arithmetic convention for Money/Cents elsewhere in the workspace.
/// `None` means no rate could be computed (e.g. zero unrealized-gain basis).
pub fn est_tax_rate_cell(rate_bps: Option<i32>) -> SheetCell {
    let value = match rate_bps {
        Some(bps) => {
            let sign = if bps < 0 { "-" } else { "" };
            let abs = bps.unsigned_abs();
            format!("{sign}{}.{:02}%", abs / 100, abs % 100)
        }
        None => String::new(), // blank cell: downstream formulas see empty, not text
    };
    SheetCell { value, input_option: ValueInputOption::UserEntered }
}
```

Interpretation chosen: the EARS is ambiguous between (a) the Sheets API `batchUpdate` path, setting `userEnteredValue.numberValue` directly plus a `PERCENT` `numberFormat`, versus (b) the `values.update` path, writing a plain string like `"8.00%"` with `valueInputOption=USER_ENTERED` and letting Sheets' input parser do the coercion. The requirement's own phrasing — "Sheets *parses* it," and its example "a `%`-suffixed value" — points at (b), so the sketch targets that path and calls out `USER_ENTERED` as load-bearing.

Assumptions:
1. Tax rate is represented internally as signed basis points (`i32`), matching the codebase's integer-money convention; no float type is used.
2. Two decimal places (hundredths of a percent) are sufficient precision; no rounding-mode requirement was given, so integer division/modulo truncates.
3. Negative rates (tax credits/loss offsets) are valid and rendered with a leading `-`; the EARS doesn't say, so I preserved sign rather than clamping to zero.
4. Undefined/uncomputable rate (`None`) falls back to an empty string rather than `"0.00%"` or an error marker, so multiplying formulas see a blank rather than a false zero or literal text.
5. The write path is `values.update` with `USER_ENTERED`; if the actual publish pipeline instead uses `batchUpdate`/`CellData`, this must be re-expressed as `numberValue` + `numberFormat{type: PERCENT}` instead of a string.
6. No explicit rounding/overflow bound on `rate_bps` magnitude (e.g. >10000 for >100%) — formatting is assumed to tolerate any signed value.