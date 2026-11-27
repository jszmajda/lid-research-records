```rust
/// SHEET-FORMULA-002: per-row formulas anchored beneath a frozen header.
///
/// Row 1 (and only row 1) is the frozen header — never included in any
/// write range this module emits. Data formulas always start at
/// `DATA_START_ROW`, a fixed constant, not a value computed from "current
/// last row" — so re-publishing never drifts the anchor even if prior
/// runs left stray rows.
const HEADER_ROWS: u32 = 1;
const DATA_START_ROW: u32 = HEADER_ROWS + 1; // row 2, fixed anchor

/// Column letters for the row's own input/output cells (A1-style).
const TICKER_COL: &str = "A";
const FORMULA_COL: &str = "C";

#[derive(Debug, Clone, PartialEq)]
pub struct RowFormula {
    pub cell: String,    // e.g. "C2"
    pub formula: String, // e.g. "=GOOGLEFINANCE(A2,\"price\")"
}

/// Build one formula per data row, each referencing only that row's own
/// cells, counting from the fixed anchor — never from an externally
/// supplied "current row" that could have shifted.
pub fn build_row_formulas(num_rows: u32) -> Vec<RowFormula> {
    (0..num_rows)
        .map(|i| {
            let row = DATA_START_ROW + i;
            RowFormula {
                cell: format!("{FORMULA_COL}{row}"),
                formula: format!("=GOOGLEFINANCE({TICKER_COL}{row},\"price\")"),
            }
        })
        .collect()
}

/// The write range for a publish pass — always starts at the fixed
/// anchor and spans exactly `num_rows`, so the header row is structurally
/// unreachable by this function.
pub fn write_range(num_rows: u32) -> String {
    let last_row = DATA_START_ROW + num_rows.saturating_sub(1);
    format!("{FORMULA_COL}{DATA_START_ROW}:{FORMULA_COL}{last_row}")
}
```

Assumptions (invented, not in the EARS text):

1. **Row/column model**: 1-indexed A1 notation; header occupies exactly row 1; frozen means "structurally excluded from write ranges," not a Sheets API freeze-pane call (out of scope for this crate per the stated boundary).
2. **Anchor is a compile-time constant** (`DATA_START_ROW = 2`), not derived from sheet inspection — chosen because "fixed anchored" reads as invariant-across-runs, and computing it from current sheet state would reintroduce the mis-pairing risk the requirement guards against.
3. **Fixed column letters** for ticker input and price-formula output (`A`, `C`) — the EARS doesn't name columns; a real system would parameterize per tab schema.
4. **`num_rows: u32`, including 0**: zero rows yields an empty `Vec` and a degenerate range (`C2:C2`) rather than an error — treated as a valid "no data yet" state, not a boundary violation.
5. **No mid-range insert/delete support**: this sketch only covers writing a contiguous block from the anchor; row insertion/deletion elsewhere in the sheet is explicitly the failure mode the requirement defends against, not something this function must detect or repair.
6. **Formula escaping**: ticker cell is referenced, not interpolated as a literal, so no string-escaping of user data is needed here.
7. **"Never-rewritten frozen header"** interpreted as: this module never emits a range touching row 1; enforcing actual immutability (e.g. rejecting an accidental header overwrite elsewhere) is assumed to be a caller-side invariant, not this function's job.