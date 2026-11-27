```rust
/// Configuration for formula generation anchored to a frozen header
pub struct SheetFormulaAnchor {
    header_row: usize,      // 1-indexed; frozen, never rewritten
    data_start_row: usize,  // 1-indexed; first data row beneath header
}

impl SheetFormulaAnchor {
    /// Create anchor with header at given row; data rows start at header_row + 1
    pub fn new(header_row: usize) -> Self {
        SheetFormulaAnchor {
            header_row,
            data_start_row: header_row + 1,
        }
    }

    /// Generate formula for a data row that references cells in that same row.
    /// Uses INDIRECT + ROW() for dynamic self-reference, so row shifts don't break pairing.
    pub fn generate_row_formula(&self, ticker_col: char) -> String {
        // INDIRECT("A" & ROW()) resolves to the current row's ticker cell.
        // If this row is moved (inserted/deleted rows), ROW() adapts, maintaining the pairing.
        format!("=GOOGLEFINANCE(INDIRECT(\"{}\"&ROW()),\"price\")", ticker_col)
    }

    /// Returns the 1-indexed row number where data formulas begin
    pub fn formula_start_row(&self) -> usize {
        self.data_start_row
    }

    /// Apply formula to all data rows in a range
    pub fn write_formulas(&self, end_row: usize) -> Vec<(usize, String)> {
        let formula = self.generate_row_formula('A'); // ticker in column A
        (self.data_start_row..=end_row)
            .map(|row| (row, formula.clone()))
            .collect()
    }
}
```

**Interpretation chosen:** The requirement mandates that formulas reference "that row's own cells" robustly across row shifts. I interpret this as: each formula must always reference cells from its own current row, regardless of row insertion/deletion. This is achieved via `INDIRECT("A"&ROW())`, which dynamically constructs the cell address using the current row number. If the row moves, `ROW()` returns the new number, maintaining the pairing.

**Assumptions (each invented):**
1. Header is at row 1 (configurable in `new()`); data rows start at row 2.
2. Ticker symbol is in column A of each data row.
3. "Row shift" = insertion or deletion of rows anywhere in the sheet.
4. `GOOGLEFINANCE(ticker, "price")` is the target formula.
5. All formulas are uniform (same for every row after header).
6. Cell references use 1-indexed row numbers (Google Sheets standard).
7. No manual row editing after formula write; rows are only appended or deleted.
8. `INDIRECT()` and `ROW()` functions are available (standard Google Sheets).
9. Formula generation assumes valid column letters (A–Z, then AA–ZZ).
10. No edge case handling for rows before `data_start_row` or missing header row.