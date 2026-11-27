```rust
/// Google Sheets formula generation with row-anchored references
/// Implements SHEET-FORMULA-002: each formula references its own row cells
/// with absolute column refs to prevent mis-pairing on row shifts.

pub struct FormulaGenerator {
    header_row: u32,           // Frozen header row (e.g., 1)
    data_start_row: u32,       // First data row (e.g., 2)
}

impl FormulaGenerator {
    pub fn new(header_row: u32, data_start_row: u32) -> Self {
        Self { header_row, data_start_row }
    }

    /// Convert 1-indexed column number to letter (1→A, 26→Z, 27→AA)
    fn col_to_letter(mut col: u32) -> String {
        let mut result = String::new();
        while col > 0 {
            col -= 1;
            result.insert(0, (b'A' + (col % 26) as u8) as char);
            col /= 26;
        }
        result
    }

    /// Generate a single formula for a data row.
    /// Uses absolute column references ($C, $D) + row-relative refs (C2, D2).
    /// Row N formula naturally references row N; row shifts don't mis-pair.
    pub fn formula_for_row(
        &self,
        row: u32,
        source_cols: &[u32],  // 1-indexed: 1=A, 2=B, 3=C, etc.
        operation: &str,      // "SUM", "PRODUCT", "GOOGLEFINANCE"
    ) -> String {
        let refs: Vec<String> = source_cols
            .iter()
            .map(|&col| {
                let letter = Self::col_to_letter(col);
                format!("${}{}", letter, row) // Absolute column, row-relative
            })
            .collect();

        match operation {
            "SUM" => format!("=SUM({})", refs.join(",")),
            "PRODUCT" => format!("={}", refs.join("*")),
            "GOOGLEFINANCE" => {
                // Per-row ticker lookup: `=GOOGLEFINANCE($C2, "price")`
                format!("=GOOGLEFINANCE({}, \"price\")", refs[0])
            }
            _ => format!("={}", refs.join("+")),
        }
    }

    /// Batch generate formulas for rows [start, end]
    pub fn formulas_for_range(
        &self,
        start: u32,
        end: u32,
        source_cols: &[u32],
        operation: &str,
    ) -> Vec<(u32, String)> {
        (start..=end)
            .map(|row| (row, self.formula_for_row(row, source_cols, operation)))
            .collect()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_absolute_col_row_relative() {
        let gen = FormulaGenerator::new(1, 2);
        let formula = gen.formula_for_row(2, &[3, 4], "PRODUCT");
        assert_eq!(formula, "=$C2*$D2");
        
        // Same row structure for row 5: $C5*$D5
        let formula = gen.formula_for_row(5, &[3, 4], "PRODUCT");
        assert_eq!(formula, "=$C5*$D5");
    }

    #[test]
    fn test_googlefinance_per_row() {
        let gen = FormulaGenerator::new(1, 2);
        let formula = gen.formula_for_row(2, &[3], "GOOGLEFINANCE");
        assert_eq!(formula, "=GOOGLEFINANCE($C2, \"price\")");
    }

    #[test]
    fn test_range_generation() {
        let gen = FormulaGenerator::new(1, 2);
        let formulas = gen.formulas_for_range(2, 4, &[3], "GOOGLEFINANCE");
        assert_eq!(formulas.len(), 3);
        assert_eq!(formulas[0].1, "=GOOGLEFINANCE($C2, \"price\")");
        assert_eq!(formulas[2].1, "=GOOGLEFINANCE($C4, \"price\")");
    }
}
```

**Assumptions:**

1. **Formula syntax**: Google Sheets (uses `=`, `GOOGLEFINANCE()`, `SUM()`, `$` anchors).
2. **Row indexing**: 1-indexed; row 1 is header (frozen), data ≥ row 2.
3. **Column indexing**: 1-indexed (1=A, 2=B, 3=C).
4. **Absolute/relative strategy**: Absolute columns (`$C`, `$D`), row-relative refs (`2`, `5`) so row N formula naturally references row N. If rows shift, formula in new row N still computes row N (no mis-pair).
5. **Source columns**: Caller specifies 1-indexed column numbers; not validated for bounds.
6. **Operations**: SUM, PRODUCT, GOOGLEFINANCE; extensible via pattern match.
7. **No deep nesting**: Formulas assumed ≤3 source columns; complex operations handled by caller.
8. **No header row rewrite**: Generator assumes header is immutable; produces only data-row formulas.
9. **Invalid inputs**: Negative/zero rows accepted (Sheets will error); no validation added.
10. **Fallback**: Unknown operations default to `+` chain (conservative, avoids silent failures).

**Interpretation choice**: Row-relative refs (not fully absolute) because the requirement emphasizes "row's own cells" — each row formula knows its row implicitly. Absolute columns prevent ticker/price columns from drifting if columns shift. This avoids accidental row offsets when copying formulas.

{lid-checkout}/docs/research/experiments/b10-differential-catch-rate/answer-key