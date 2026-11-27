```rust
// sheets-view: per-row formula emission (SHEET-FORMULA-002)

/// A1 column letters for the columns this view writes.
#[derive(Clone, Copy)]
pub struct FormulaLayout {
    pub ticker_col: &'static str,   // e.g. "B"
    pub qty_col: &'static str,      // e.g. "C"
    pub price_col: &'static str,    // GOOGLEFINANCE output, e.g. "D"
    pub value_col: &'static str,    // e.g. "E"
}

/// 1-based sheet row of the first data row. Header occupies rows 1..FIRST_DATA_ROW-1
/// and is written once at tab creation, never rewritten.
pub const FIRST_DATA_ROW: u32 = 2;

pub struct RowFormulas {
    pub price: String,
    pub value: String,
}

/// Formulas for the `idx`-th data row (0-based), anchored at FIRST_DATA_ROW.
/// Every reference is same-row and relative, so inserting/deleting/reordering
/// rows cannot pair row N's price with row M's quantity.
pub fn row_formulas(idx: u32, l: &FormulaLayout) -> RowFormulas {
    let r = FIRST_DATA_ROW
        .checked_add(idx)
        .expect("data row index overflow");
    RowFormulas {
        price: format!(
            "=IF({t}{r}=\"\",\"\",IFERROR(GOOGLEFINANCE({t}{r},\"price\"),\"\"))",
            t = l.ticker_col, r = r
        ),
        value: format!(
            "=IF(OR({p}{r}=\"\",{q}{r}=\"\"),\"\",{p}{r}*{q}{r})",
            p = l.price_col, q = l.qty_col, r = r
        ),
    }
}

/// Range the writer updates: data rows only. Never includes row < FIRST_DATA_ROW.
pub fn data_range(tab: &str, l: &FormulaLayout, n_rows: u32) -> String {
    if n_rows == 0 {
        return format!("{tab}!{a}{s}:{b}{s}", a = l.ticker_col, b = l.value_col,
                       s = FIRST_DATA_ROW); // empty write target, header untouched
    }
    let last = FIRST_DATA_ROW + n_rows - 1;
    format!("{tab}!{a}{s}:{b}{last}", a = l.ticker_col, b = l.value_col, s = FIRST_DATA_ROW)
}
```

Assumptions invented:
1. `FIRST_DATA_ROW = 2`; header is exactly one frozen row, written only at tab creation (a separate `ensure_header` call, not shown, is the only writer of rows < 2).
2. Column letters are single-letter A1 constants supplied per tab by `FormulaLayout`; no ZZ-style multi-letter or R1C1 handling.
3. "Anchored" interpreted as *fixed start row + purely same-row relative refs* (e.g. `D5*C5`), not `$`-absolute refs. Chosen because `$` locks a reference to one row, which is exactly the mis-pairing failure mode the requirement forbids; same-row relative refs survive Sheets' row-shift rewriting.
4. Formulas are emitted per-row from a computed row number rather than array-formula/spill from the header, so no single formula spans rows.
5. Blank ticker/qty guards yield `""` rather than an error, so trailing/partial rows do not poison the marks read-back.
6. Row index overflow (u32) panics — treated as unreachable for a personal ledger.
7. Only two formula columns (price, value) exist; other columns are literal values written by the kernel projection.
8. Formula text is not localized (US `,` argument separator).
9. No Cents math here: value formula is display-only; authoritative money stays integer Cents in the kernel.