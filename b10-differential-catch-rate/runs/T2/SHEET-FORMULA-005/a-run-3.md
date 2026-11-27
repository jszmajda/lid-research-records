```rust
// sheets-view: builds the `Est. Tax Rate` cell so Sheets stores/parses it
// as a number, not text, letting downstream multiply-formulas evaluate.
use google_sheets4::api::{CellData, CellFormat, ExtendedValue, NumberFormat};

/// `rate_bps`: estimated tax rate in basis points (1/100 of a percent).
/// `None` means "no estimate available" (e.g. no realized-basis data yet).
pub fn est_tax_rate_cell(rate_bps: Option<i32>) -> CellData {
    let fraction = rate_bps.map(|bps| bps as f64 / 10_000.0);

    CellData {
        user_entered_value: Some(ExtendedValue {
            number_value: fraction, // None -> blank cell, not 0.0
            ..Default::default()
        }),
        user_entered_format: Some(CellFormat {
            number_format: Some(NumberFormat {
                type_: Some("PERCENT".to_string()),
                pattern: Some("0.00%".to_string()),
            }),
            ..Default::default()
        }),
        ..Default::default()
    }
}
```

Assumptions (all invented, none given by the EARS text):

1. **Rate representation**: kernel supplies the tax rate as `i32` basis points, not a `f64` percent or `Cents`, to keep the same integer-precision discipline as the rest of the kernel while staying distinct from `Cents` (a rate isn't money).
2. **Missing/unknown rate**: `None` → cell written with no `number_value` (blank), not `0.0`. Rejected the "default to 0%" fallback because that asserts a false zero-tax fact; a blank cell requires downstream formulas to guard with `IFERROR`/`ISBLANK` rather than silently computing tax as zero.
3. **Core ambiguity resolved**: read "percent-typed `userEnteredValue`, e.g. a `%`-suffixed value" as describing the *rendered display* ("12.34%"), not the wire representation. Implemented as `ExtendedValue.number_value` (a plain fraction) plus `userEnteredFormat.numberFormat.type = PERCENT`. Rejected writing a literal `stringValue` like `"12.34%"`: under `batchUpdate`'s typed `CellData`, a `stringValue` lands as text and is never re-parsed the way `values.update` with `USER_ENTERED` input option would parse typed user input — so that path would not satisfy "Sheets parses it as a number."
4. **Out-of-range rates** (e.g. bps > 10_000 implying >100%, or negative bps for a tax-credit scenario) are passed through unvalidated — bounds-checking is kernel/tax-math territory, and sheets-view "owns no accounting or tax math."
5. **Display precision**: `"0.00%"` (2 decimals) chosen arbitrarily; EARS doesn't specify.
6. **API surface**: assumed `google-sheets4`'s `CellData`/`ExtendedValue`/`CellFormat`/`NumberFormat` types as the write mechanism, consistent with the project publishing read-only tabs via the Sheets API.
7. **Scope**: function is a pure builder for one cell's value/format; placement in a `batchUpdate` request (range, sheet id, row/col) is assumed to be the caller's responsibility, out of scope for this spec.