```rust
//! sheets-view: anchored per-row formula emission (SHEET-FORMULA-002)

/// A1 column letters for the formula's own-row cells.
#[derive(Clone, Copy)]
pub struct FormulaCols {
    pub symbol: &'static str,  // e.g. "B"
    pub qty: &'static str,     // e.g. "D"
}

pub struct TabLayout {
    /// 1-based row count of the frozen header. Never rewritten.
    pub header_rows: u32,
    /// 1-based first data row. Invariant: > header_rows.
    pub anchor_row: u32,
    pub cols: FormulaCols,
}

#[derive(Debug, PartialEq)]
pub enum LayoutError {
    AnchorInsideHeader { anchor: u32, header_rows: u32 },
    RowOverflow,
}

impl TabLayout {
    pub fn validate(&self) -> Result<(), LayoutError> {
        if self.anchor_row <= self.header_rows {
            return Err(LayoutError::AnchorInsideHeader {
                anchor: self.anchor_row,
                header_rows: self.header_rows,
            });
        }
        Ok(())
    }

    /// Absolute sheet row for the `idx`-th data row (0-based).
    fn row_for(&self, idx: usize) -> Result<u32, LayoutError> {
        u32::try_from(idx)
            .ok()
            .and_then(|i| self.anchor_row.checked_add(i))
            .ok_or(LayoutError::RowOverflow)
    }

    /// One GOOGLEFINANCE price formula per data row, self-referential only.
    pub fn price_formulas(&self, n_rows: usize) -> Result<Vec<String>, LayoutError> {
        self.validate()?;
        (0..n_rows)
            .map(|i| {
                let r = self.row_for(i)?;
                Ok(format!(
                    "=IF({s}{r}=\"\",\"\",GOOGLEFINANCE({s}{r},\"price\"))",
                    s = self.cols.symbol,
                    r = r
                ))
            })
            .collect()
    }

    /// Write range for the formula column; starts at the anchor, never row 1.
    pub fn formula_range(&self, sheet: &str, col: &str, n_rows: usize) -> Result<String, LayoutError> {
        self.validate()?;
        if n_rows == 0 {
            return Ok(String::new()); // caller skips the write
        }
        let end = self.row_for(n_rows - 1)?;
        Ok(format!("'{sheet}'!{col}{}:{col}{end}", self.anchor_row))
    }
}
```

Assumptions invented (all):
1. Formula content is a GOOGLEFINANCE price call; the requirement constrains only *reference shape*, so any per-row formula fits the same emitter.
2. `A1` notation, relative (unanchored) row refs — relative refs are what make a formula follow its own row; `$` on the row would be the mis-pairing bug.
3. Interpretation of "fixed anchored start row": the *start row is a constant of the layout*, not derived from current sheet contents; a shift of data rows never changes it. Chosen over "absolute `$` refs" because the stated failure mode is mis-pairing across rows, which absolute refs cause rather than cure.
4. Columns are static `&'static str` letters known at layout time, not computed from indices.
5. `header_rows` may be >1; anchor is explicit rather than `header_rows + 1` so a spacer row is expressible.
6. Invalid input (anchor inside/at header) is a hard `Err`, not a clamp — silently clamping would write over the frozen header.
7. `n_rows == 0` yields an empty range string and no write, rather than an inverted range.
8. Row arithmetic overflow is an error, not a wrap.
9. Blank symbol cell yields `""` rather than `#N/A`, so the marks read-back pass sees an empty, not an error sentinel.
10. Header rewriting is prevented structurally (no range ever starts above `anchor_row`); no separate guard is exposed.
11. No Cents involvement — this crate emits formula text only.