```rust
/// Fixed row (1-indexed, Sheets convention) where formula rows begin,
/// directly beneath the frozen header row. Anchored — never recomputed
/// from current sheet state.
const START_ROW: u32 = 2;

/// A column's formula, expressed relative to the row it will occupy.
/// `{row}` is the only substitution token and must reference that same row.
pub struct FormulaColumn {
    pub column: char, // A-Z only (see assumptions)
    pub template: &'static str, // e.g. "=GOOGLEFINANCE(B{row},\"price\")"
}

/// Renders one row's formula, anchoring substitution to that row's own
/// index — never a neighbor's.
pub fn render_row_formula(col: &FormulaColumn, row: u32) -> String {
    col.template.replace("{row}", &row.to_string())
}

/// Builds the full formula column: one row per ledger position, starting
/// at the fixed anchored row beneath the frozen header. Always rewrites
/// the whole contiguous block on publish — no partial diffing — so no
/// stale row/formula pairing can survive a shift.
pub fn build_formula_column(col: &FormulaColumn, row_count: u32) -> Vec<(String, String)> {
    (0..row_count)
        .map(|i| {
            let row = START_ROW + i;
            (format!("{}{}", col.column, row), render_row_formula(col, row))
        })
        .collect()
}

/// The header row this pass must never write to. Callers must exclude
/// this row from every formula-column batch update.
pub fn header_row() -> u32 {
    START_ROW - 1
}
```

Assumptions (invented, not stated by the EARS):

1. Sheets rows are 1-indexed; header occupies row 1; `START_ROW = 2` is a compile-time constant, not derived from current sheet contents.
2. "Own cells" = every reference inside a row's formula points only into that same row (e.g. `B{row}`); cross-row or absolute-row references are out of contract, not just discouraged.
3. Formula templates are static, known-at-config-time strings (one per output column, e.g. the GOOGLEFINANCE oracle column), not synthesized dynamically.
4. "Never-rewritten frozen header" is enforced structurally: the row-builder's range starts at `START_ROW` and never includes `header_row()`; actual Sheets API freeze-pane/gridline setting is assumed handled elsewhere (view bootstrap), out of this module's scope.
5. Row-shift safety is achieved by always rewriting the full contiguous formula block on each publish pass (no partial/incremental diff), so row index and formula are regenerated together — never left mismatched from a prior layout.
6. `row_count == 0` is valid: yields an empty vec, no formulas written, header untouched.
7. Column identifiers assumed single-letter (A–Z); multi-letter (AA+) A1 encoding is not implemented — flagged simplification, not a hidden requirement.
8. No runtime validation that a template's `{row}` substitution excludes other row numbers embedded literally in the template string; correctness of "own cells only" is assumed guaranteed by whoever authors `FormulaColumn::template`, not checked here.
9. "Fixed anchored start row" is interpreted as a single global constant shared by all formula columns on the tab, not a per-column offset.