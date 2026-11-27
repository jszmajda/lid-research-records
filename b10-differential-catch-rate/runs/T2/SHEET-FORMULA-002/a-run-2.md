```rust
/// SHEET-FORMULA-002: per-row formulas reference only that row's own cells,
/// generated from a fixed anchored start row beneath a frozen header.
///
/// Interpretation chosen: "fixed anchored start row" = a compile-time/config
/// constant, not something read back from the sheet each publish. Formulas
/// are regenerated fresh every publish (never patched in place), so a row
/// insert/delete anywhere is harmless: row N always gets the formula for row N,
/// computed from N itself rather than copied from a prior cell.

/// Row 1 is the frozen header; this module never emits anything for it.
pub const FROZEN_HEADER_ROWS: u32 = 1;
pub const DATA_START_ROW: u32 = FROZEN_HEADER_ROWS + 1; // row 2

/// Semantic column layout, fixed per tab. Single-letter columns only
/// (assumption: fewer than 26 columns per view tab).
pub struct ColumnLayout {
    pub ticker: char,     // e.g. 'A'
    pub quantity: char,   // e.g. 'B'
    pub live_price: char, // e.g. 'C' (GOOGLEFINANCE formula lives here)
}

/// Build the live-price formula for a single data row, referencing only
/// that row's own ticker cell.
fn row_formula(row: u32, cols: &ColumnLayout) -> String {
    format!("=GOOGLEFINANCE({}{})", cols.ticker, row)
}

/// Generate formulas for `num_rows` data rows starting at the fixed anchor.
/// Returns (row_number, formula) pairs so the caller writes them via a
/// full-range overwrite (never a partial patch) each publish.
pub fn build_formula_column(num_rows: u32, cols: &ColumnLayout) -> Vec<(u32, String)> {
    (0..num_rows)
        .map(|i| {
            let row = DATA_START_ROW + i;
            (row, row_formula(row, cols))
        })
        .collect()
}
```

Assumptions invented:
1. "Fixed anchored start row" is a compile-time constant (`DATA_START_ROW = 2`), not read back from the live sheet — the anchor is defined by the publisher, not discovered.
2. Frozen header occupies exactly 1 row (`FROZEN_HEADER_ROWS = 1`); header content/freezing is written by a separate, never-called-here function, satisfying "never-rewritten."
3. "Row shift cannot mis-pair" is achieved by always regenerating the entire formula range on every publish (full overwrite, not incremental patch) — so even if the sheet's row count changed since last publish, row N's formula is freshly derived from N, never copied/offset from a stale prior state.
4. Row indices are 1-based, matching Sheets A1 notation.
5. Columns are single letters (<26 per tab); multi-letter columns (AA+) unsupported by this sketch — would need a `column_letter(u32) -> String` helper.
6. "That row's own cells" is illustrated with one cross-reference (live-price formula reads the same row's ticker cell); other per-row formulas (e.g., cost basis) follow the identical pattern, omitted for brevity.
7. `num_rows == 0` is valid and yields an empty vec, not an error.
8. Ticker cell being empty/invalid is out of scope here — the formula is still emitted; Sheets surfaces `#N/A`/`#ERROR!` at evaluation time, not construction time.
9. No handling for exceeding Sheets' max row/cell limits — assumed enforced by the caller/workbook-sizing step upstream.
10. Quantity column included in the layout for completeness but unused in this specific formula; other formula-builders in the module would consume it.