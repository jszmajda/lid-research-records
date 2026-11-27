```rust
//! sheets-view: per-row formula emission (SHEET-FORMULA-002)

/// Fixed layout constants for a view tab.
pub const HEADER_ROWS: u32 = 1;        // frozen header, never rewritten
pub const FIRST_DATA_ROW: u32 = 2;     // anchored start row = HEADER_ROWS + 1

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct DataRow(u32); // 0-based index into the projected row slice

#[derive(Debug, PartialEq, Eq)]
pub enum FormulaError {
    RowOverflow,                 // sheet row index would exceed Sheets' 10M row cap
}

pub const MAX_SHEET_ROW: u32 = 10_000_000;

impl DataRow {
    /// Anchored absolute sheet row for this data row. The ONLY place
    /// a data index becomes a sheet row number.
    pub fn sheet_row(self) -> Result<u32, FormulaError> {
        FIRST_DATA_ROW
            .checked_add(self.0)
            .filter(|r| *r <= MAX_SHEET_ROW)
            .ok_or(FormulaError::RowOverflow)
    }
}

/// Columns are compile-time-known letters for this tab schema.
#[derive(Debug, Clone, Copy)]
pub struct Col(pub &'static str);

pub const TICKER: Col = Col("B");
pub const QTY: Col = Col("C");
pub const PRICE: Col = Col("D");
pub const VALUE: Col = Col("E");

/// A1 reference to a cell **on this row only** — relative row, so no
/// cross-row reference can be constructed by this API.
fn cell(col: Col, row: u32) -> String {
    format!("{}{}", col.0, row)
}

/// Live-price oracle cell: GOOGLEFINANCE over this row's own ticker cell.
pub fn price_formula(r: DataRow) -> Result<String, FormulaError> {
    let row = r.sheet_row()?;
    Ok(format!("=GOOGLEFINANCE({}, \"price\")", cell(TICKER, row)))
}

/// Market value: this row's qty × this row's price. No accounting math —
/// the sheet multiplies; the kernel owns Cents.
pub fn value_formula(r: DataRow) -> Result<String, FormulaError> {
    let row = r.sheet_row()?;
    Ok(format!("={}*{}", cell(QTY, row), cell(PRICE, row)))
}

/// Range written by the data pass — starts at the anchor, never row 1.
pub fn data_range(tab: &str, n_rows: u32) -> Result<String, FormulaError> {
    if n_rows == 0 {
        return Ok(format!("{tab}!A{FIRST_DATA_ROW}:{FIRST_DATA_ROW}")); // empty clear target
    }
    let last = DataRow(n_rows - 1).sheet_row()?;
    Ok(format!("{tab}!A{FIRST_DATA_ROW}:{}{}", VALUE.0, last))
}
```

Assumptions invented:
1. Header is exactly 1 frozen row; anchor is row 2. Requirement says "fixed anchored start row" without naming it.
2. Column letters are static per tab schema (B/C/D/E chosen illustratively); real schema comes from the tab definition.
3. "Anchored" interpreted as *code-side constant anchoring*, not `$` absolute-row A1 notation — I chose relative row refs deliberately: an absolute `$D$5` would survive a row shift pointing at the wrong row, whereas relative same-row refs are what actually cannot mis-pair. Absolute `$` is applied only to columns if a fill-right is ever used (not here).
4. Every formula is generated from exactly one `DataRow`; there is no API that accepts two row indices, so cross-row references are unrepresentable rather than merely discouraged.
5. Row-index overflow past the Sheets 10M cap is an error, not a wrap/clamp.
6. `n_rows == 0` yields a degenerate anchor-only range for the clear/update call rather than an error.
7. Writes are assumed to target `A{FIRST_DATA_ROW}:…` explicitly (never `A1`), so the header cannot be overwritten by a data write; enforcing that is `data_range`'s job.
8. Formulas are emitted as `USER_ENTERED` strings; escaping of ticker text is not needed because the ticker is a cell reference, never an inlined literal.
9. No i18n of formula argument separators — `,` assumed (locale is en_US).
10. Sheets uses 1-based rows; `DataRow` is 0-based and converted in exactly one function.