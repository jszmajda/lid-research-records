```rust
/// Generates Google Sheets formulas with per-row self-references using INDIRECT + ROW()
/// to prevent mis-pairing when rows are inserted/deleted
pub mod formula_generator {
    /// Configuration for formula generation
    pub struct FormulaConfig {
        /// Columns to reference (e.g., ["A", "B", "C"])
        pub source_columns: Vec<String>,
        /// Operations to apply (e.g., ["*", "+", "/"])
        pub operations: Vec<String>,
        /// First data row (frozen header above)
        pub start_row: u32,
    }

    /// Generates an INDIRECT-based formula for a single row
    /// Uses ROW() to anchor to actual row position, preventing drift on row insertion/deletion
    pub fn generate_row_formula(
        row_num: u32,
        source_columns: &[String],
        operations: &[String],
    ) -> String {
        if source_columns.is_empty() {
            return String::new();
        }

        // Pattern: =INDIRECT("A"&ROW())*INDIRECT("B"&ROW())
        let mut formula = String::from("=");
        
        for (i, col) in source_columns.iter().enumerate() {
            if i > 0 && i - 1 < operations.len() {
                formula.push_str(&operations[i - 1]);
            }
            formula.push_str(&format!("INDIRECT(\"{0}\"&ROW())", col));
        }
        
        formula
    }

    /// Writes formulas to a row, capturing both formula text and validation
    pub fn write_row_formulas(
        row: &mut RowData,
        config: &FormulaConfig,
        row_index: u32,
    ) -> Result<(), String> {
        if row_index < config.start_row {
            return Err("Row below start_row boundary".into());
        }

        let formula = generate_row_formula(
            row_index,
            &config.source_columns,
            &config.operations,
        );

        // Annotate with spec: @spec SHEET-FORMULA-002
        row.formula = Some(formula);
        row.row_number = row_index;
        
        Ok(())
    }

    /// Represents a single spreadsheet row
    pub struct RowData {
        pub row_number: u32,
        pub formula: Option<String>,
        pub values: Vec<String>,
    }
}
```

**Assumptions (Invented)**

1. **Formula engine**: Google Sheets (INDIRECT/ROW functions available)
2. **Column specification**: Caller provides column letters; no discovery from sheet schema
3. **Operation count**: Must equal `len(columns) - 1` (binary ops between pairs)
4. **Start row**: Caller specifies; default implied as row 2 (row 1 = frozen header)
5. **Error handling**: Invalid row indices rejected; no auto-coercion
6. **Output format**: Formula as string, storable in `RowData.formula`
7. **Single formula per row**: Not multi-cell arrays; one formula column
8. **ROW() stability**: Assumes Google Sheets' ROW() is live/recalculated on structural changes

**Interpretation**

The EARS requires formulas that reference "that row's own cells" and remain paired if rows shift. I chose INDIRECT() + ROW() because:
- `ROW()` always returns the current row, even after inserts/deletes
- `INDIRECT("A"&ROW())` anchors to the actual row position dynamically
- This satisfies "fixed anchored start row" (formulas only in data rows, never the frozen header) and "row shift cannot mis-pair" (ROW() adapts automatically)

Alternative (rejected): Absolute row refs like `=$A$2` fail the requirement—they don't adapt when rows shift.