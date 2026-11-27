```rust
/// Sheet column layout for the marks/formula view. Column indices are
/// 0-based; conversion to A1 letters happens in `col_letter`.
struct FormulaColumns {
    ticker_col: u32,   // source cell each row reads its ticker from
    price_col: u32,    // column this module writes GOOGLEFINANCE formulas into
}

/// Row 1 is the frozen header (never rewritten by this pass).
/// Data/formula rows are anchored starting at this row.
const FIRST_DATA_ROW: u32 = 2;

/// Builds the live-price formula for a single row, referencing only that
/// row's own ticker cell — never a fixed/absolute row or another row's cell.
fn price_formula_for_row(cols: &FormulaColumns, row: u32) -> String {
    debug_assert!(row >= FIRST_DATA_ROW, "row must be at/after the anchored start row");
    let ticker_ref = format!("{}{}", col_letter(cols.ticker_col), row);
    format!("=GOOGLEFINANCE({ticker_ref},\"price\")")
}

/// Writes formulas for every row in [FIRST_DATA_ROW, FIRST_DATA_ROW + row_count),
/// each formula pinned to its own row number so a later row insertion/deletion
/// shifts formula and referent together (Sheets rewrites in-formula refs on
/// shift; row number is derived per-row here rather than cached, so this
/// function is also safe to call again after an external shift).
fn build_price_formulas(cols: &FormulaColumns, row_count: u32) -> Vec<(u32, String)> {
    (0..row_count)
        .map(|i| {
            let row = FIRST_DATA_ROW + i;
            (row, price_formula_for_row(cols, row))
        })
        .collect()
}

fn col_letter(mut idx: u32) -> String {
    let mut s = Vec::new();
    loop {
        s.push(b'A' + (idx % 26) as u8);
        if idx < 26 { break; }
        idx = idx / 26 - 1;
    }
    s.reverse();
    String::from_utf8(s).unwrap()
}
```

Assumptions (invented, not in the EARS text):
1. "Frozen header" = row 1 only; data/formulas start at row 2 (`FIRST_DATA_ROW`). EARS doesn't state header height.
2. Formula payload is a `GOOGLEFINANCE` price lookup, per the scenario's stated oracle column — EARS-002 itself is generic about which formula.
3. Column layout (`ticker_col`, `price_col`) is a caller-supplied struct; EARS doesn't specify sheet schema.
4. "That row's own cells" means every cell reference in the formula uses the *same* row number as the row being written (relative, not `$`-absolute) — chosen because absolute row refs would defeat "row shift cannot mis-pair," and this is the interpretation that satisfies the stated guarantee.
5. Row numbers are recomputed per call from `FIRST_DATA_ROW + index`, not stored/cached, so re-invocation after an external insert/delete still derives correct pairing — this is my read of "a row shift cannot mis-pair them" as a re-entrancy property, not just a one-time write property.
6. Boundary: `row_count == 0` yields an empty vec (no-op), no error.
7. Invalid input (row < FIRST_DATA_ROW) is a `debug_assert!` (programmer error), not a runtime `Result` — EARS gives no error-handling directive, so I chose the cheaper contract-violation treatment over inventing an error type.
8. Header write/rewrite is out of scope for this function entirely (enforces "never-rewritten" by omission, not by a guard).