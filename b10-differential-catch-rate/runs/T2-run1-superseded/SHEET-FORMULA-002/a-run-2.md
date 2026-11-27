```rust
// sheets_view::formula: SHEET-FORMULA-002
// Per-row formulas reference only that row's own cells, anchored beneath
// a frozen, never-rewritten header, so row shifts can't mis-pair refs.

pub const HEADER_ROWS: u32 = 1;
pub const ANCHOR_START_ROW: u32 = HEADER_ROWS + 1; // fixed first data row

/// 0-indexed column number -> A1 column letters ("A", "Z", "AA", ...).
fn col_letter(mut col: u32) -> String {
    let mut s = Vec::new();
    loop {
        s.push(b'A' + (col % 26) as u8);
        if col < 26 { break; }
        col = col / 26 - 1;
    }
    s.reverse();
    String::from_utf8(s).unwrap()
}

/// A1 ref for (0-indexed col, 1-indexed row).
fn cell_ref(col: u32, row: u32) -> String {
    format!("{}{}", col_letter(col), row)
}

/// Formula template: reads named input columns from ONE row, no cross-row refs.
pub struct RowFormulaSpec {
    pub input_cols: Vec<u32>,
    pub template: fn(&[String]) -> String,
}

/// Build one row's formula, referencing only that row's own cells.
pub fn build_row_formula(spec: &RowFormulaSpec, row: u32) -> Result<String, String> {
    if row < ANCHOR_START_ROW {
        return Err(format!("row {row} is above anchor {ANCHOR_START_ROW}; header is frozen"));
    }
    let refs: Vec<String> = spec.input_cols.iter().map(|&c| cell_ref(c, row)).collect();
    Ok((spec.template)(&refs))
}

fn googlefinance_price(refs: &[String]) -> String {
    format!("=GOOGLEFINANCE({}, \"price\")", refs[0])
}

/// Emit (target_cell, formula) pairs for n_rows starting at the anchor.
/// Never emits into HEADER_ROWS.
pub fn build_column_formulas(ticker_col: u32, formula_col: u32, n_rows: u32) -> Vec<(String, String)> {
    let spec = RowFormulaSpec { input_cols: vec![ticker_col], template: googlefinance_price };
    (0..n_rows)
        .map(|i| {
            let row = ANCHOR_START_ROW + i;
            (cell_ref(formula_col, row), build_row_formula(&spec, row).expect("row >= anchor by construction"))
        })
        .collect()
}
```

Assumptions:
1. "Frozen header" = exactly `HEADER_ROWS` (assumed 1) row(s) at the top; header content/write path is out of scope and this module never emits into rows `< ANCHOR_START_ROW`.
2. Anchor is a compile-time constant, not configurable per-sheet — "fixed" read as fixed-in-code, not fixed-but-parameterized.
3. Row-to-formula mapping is purely positional (`row = ANCHOR_START_ROW + i`) — no keyed/sparse rows, no gaps, matching an append-only ledger projection.
4. `n_rows` is the caller-supplied count of ledger rows to project; 0 yields an empty vec (valid, not an error).
5. Same-row-only references are enforced structurally: `RowFormulaSpec.template` only ever receives refs built from the current `row`, so cross-row references are impossible by construction rather than checked at runtime.
6. Out-of-range row (`row < ANCHOR_START_ROW`) is treated as a caller bug — returns `Result::Err` rather than panicking or silently clamping, since this indicates the anchor invariant was violated upstream.
7. Column indices are 0-indexed internally, converted to 1-indexed A1 letters; no bound on max column (Sheets' own limit applies, not checked here).
8. `GOOGLEFINANCE` is the sole example template shown per the scenario's live-price oracle; the module is generic over templates via `RowFormulaSpec`, not hardcoded to one formula.
9. No handling of frozen-row *count* changing at runtime — assumed static per workbook, matching "never-rewritten."