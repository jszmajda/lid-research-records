```rust
/// SHEET-TAB-003: view-tab republish is destructive-by-default.
/// Saved Filter Views are the ONLY thing that survives; basic filters,
/// manual sorts, and human-inserted rows are wiped every publish.
mod view_tab_republish {
    use google_sheets4::api::{
        BatchUpdateSpreadsheetRequest, ClearBasicFilterRequest, Request as SheetReq,
    };

    pub struct ViewTab {
        pub sheet_id: i64,
        pub tab_name: String,
        pub used_row_count: u32, // last known extent, incl. any human-inserted rows
    }

    pub enum CellValue { Str(String), Num(f64), Formula(String), Empty }
    pub type Row = Vec<CellValue>;

    #[derive(Debug)]
    pub enum RepublishError { ClearFilterFailed, ClearRangeFailed, WriteFailed }

    /// Regenerates one tab from kernel-projected rows. Never reads
    /// existing cell contents back; never touches `sheet.filterViews`
    /// (that's precisely why saved Filter Views survive untouched).
    pub fn republish_tab(
        api: &impl SheetsApi,
        spreadsheet_id: &str,
        tab: &ViewTab,
        rows: Vec<Row>,
    ) -> Result<(), RepublishError> {
        // 1. Drop any basic filter (manual sort/filter state lives here).
        //    Absence-of-filter errors are treated as success (idempotent).
        let clear_filter = BatchUpdateSpreadsheetRequest {
            requests: Some(vec![SheetReq {
                clear_basic_filter: Some(ClearBasicFilterRequest { sheet_id: tab.sheet_id, ..Default::default() }),
                ..Default::default()
            }]),
            ..Default::default()
        };
        api.batch_update(spreadsheet_id, clear_filter)
            .or_else(|e| if api.is_no_filter_error(&e) { Ok(()) } else { Err(RepublishError::ClearFilterFailed) })?;

        // 2. Clear the FULL used range, not just today's row count, so a
        //    human-inserted row past the kernel's data still gets erased.
        let full_range = format!("{}!A1:ZZ{}", tab.tab_name, tab.used_row_count.max(rows.len() as u32) + 1);
        api.values_clear(spreadsheet_id, &full_range).map_err(|_| RepublishError::ClearRangeFailed)?;

        // 3. Rewrite kernel-owned rows verbatim; row order == kernel order,
        //    which is how a manual sort gets discarded (no special-case code).
        api.values_update(spreadsheet_id, &tab.tab_name, rows).map_err(|_| RepublishError::WriteFailed)
    }

    pub trait SheetsApi {
        fn batch_update(&self, id: &str, req: BatchUpdateSpreadsheetRequest) -> Result<(), String>;
        fn is_no_filter_error(&self, e: &String) -> bool;
        fn values_clear(&self, id: &str, range: &str) -> Result<(), String>;
        fn values_update(&self, id: &str, tab: &str, rows: Vec<Row>) -> Result<(), String>;
    }
}
```

Assumptions:
1. `CellValue`/`Row`/`ViewTab` shapes invented; kernel hands republish a flat `Vec<Row>` already tax/accounting-free.
2. Saved Filter Views need zero code to "survive" — survival means never issuing delete/replace requests against `sheet.filterViews`; interpreted the requirement as a negative constraint (don't touch), not a preserve-and-restore mechanism.
3. Basic filter is explicitly cleared each run; "already absent" API error is swallowed as success (invented idempotency rule, no filter previously existed on first publish).
4. Manual sort has no independent persisted state beyond row order, so it's discarded implicitly by writing kernel-ordered rows — no dedicated sort-detection code.
5. Human-inserted rows: must clear the full historical used-range (tracked via `used_row_count`), not just today's row count, or an inserted row past current data would survive. Assumed caller tracks/persists `used_row_count` from the prior publish.
6. "Read-only" interpreted as *pipeline never reads tab edits back into the ledger*, not Sheets ACL/protection — the requirement's own examples (filter, sort, inserted row) presuppose edits are physically possible, so hard-blocking edits was rejected as the reading.
7. Failure mode: fail-closed/abort on any step (filter-clear, range-clear, write) rather than partial regeneration, to avoid stale filter + partial data — no rollback mechanism assumed to exist.
8. Republish is safe to call unconditionally on every publish cycle (no dirty-check), since full overwrite is the defined behavior.