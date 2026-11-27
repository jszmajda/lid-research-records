```rust
//! sheets-view: per-row formula projection (SHEET-FORMULA-002)

/// Header occupies rows 1..=FROZEN_HEADER_ROWS and is never rewritten by
/// this path. DATA_START_ROW is a compile-time constant (not derived from
/// sheet inspection), so a row shift elsewhere in the workbook can't move
/// where formula-writing begins.
pub const FROZEN_HEADER_ROWS: u32 = 1;
pub const DATA_START_ROW: u32 = FROZEN_HEADER_ROWS + 1;

/// Produces the formula text for one column, given the row it will occupy.
/// Contract: the returned formula must reference ONLY `row` — no other row.
pub type RowFormulaFn = fn(row: u32) -> String;

pub struct FormulaColumn {
    pub sheet_column: &'static str, // destination column letter, e.g. "E"
    pub formula: RowFormulaFn,
}

/// One row's writes: (A1 destination, formula text) pairs.
pub fn render_row(row: u32, columns: &[FormulaColumn]) -> Vec<(String, String)> {
    columns
        .iter()
        .map(|c| (format!("{}{row}", c.sheet_column), (c.formula)(row)))
        .collect()
}

/// Builds all writes for `row_count` data rows, anchored at DATA_START_ROW.
/// row_count == 0 is a no-op; header rows are structurally unreachable
/// since row indices start at DATA_START_ROW by construction.
pub fn build_formula_writes(row_count: u32, columns: &[FormulaColumn]) -> Vec<(String, String)> {
    (0..row_count)
        .map(|i| DATA_START_ROW + i)
        .flat_map(|row| render_row(row, columns))
        .collect()
}

// Example column: live price via same-row ticker cell.
// FormulaColumn { sheet_column: "E", formula: |row| format!("=GOOGLEFINANCE(B{row},\"price\")") }
```

Assumptions (invented, not in the EARS text):

1. `FROZEN_HEADER_ROWS` = 1 and `DATA_START_ROW` is a source-code constant, not computed by reading current sheet state — chosen because "never-rewritten frozen header" implies the header's extent is known statically, not discovered per-run.
2. Column-to-field mapping (`sheet_column` letters) is defined statically by the caller; no dynamic header-parsing to locate columns.
3. `row_count == 0` writes nothing and leaves the sheet untouched — no error.
4. No upper bound / overflow check against Google Sheets' max row limit — out of scope for this spec, left to the sheets-view crate's write layer.
5. "References to that row's own cells" interpreted strictly as same-row-only A1 refs; cross-row formulas (e.g. prior-day comparisons) are excluded by contract on `RowFormulaFn`, enforced only by convention/doc comment, not the type system (Rust can't statically forbid a closure from hardcoding a different row number).
6. Re-publishing overwrites existing formulas in rows ≥ `DATA_START_ROW` each pass (only the header is "never-rewritten"); this is treated as idempotent republish, not a violation.
7. Formula text is plain `String` (e.g. `GOOGLEFINANCE`), not a typed AST — sufficient since the requirement concerns row-alignment, not formula semantics.
8. Ambiguity: "fixed anchored start row" could mean (a) a constant literal, or (b) dynamically detected-once-then-pinned. I chose (a), since it's the only interpretation immune to a row shift by definition.