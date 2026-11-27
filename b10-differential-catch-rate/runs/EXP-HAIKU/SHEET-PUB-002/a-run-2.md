```rust
use google_sheets4::api::{BatchUpdateSpreadsheetRequest, Request, UpdateValuesRequest};

/// Rewrite a view tab atomically: write new data range, clear residual tail to exact row count.
pub fn rewrite_tab_atomic(
    tab_name: &str,
    data: Vec<Vec<String>>,  // rows of data; each row a vec of cell strings
    sheets_client: &google_sheets4::Sheets,
    spreadsheet_id: &str,
) -> Result<(), Box<dyn std::error::Error>> {
    let row_count = data.len();
    let col_count = data.iter().map(|r| r.len()).max().unwrap_or(1).max(1);
    
    // Convert column count to A1 notation (1 → A, 27 → AA, etc.)
    let col_letter = col_index_to_letters(col_count);
    
    let mut requests = vec![];
    
    // Request 1: Write new data (A1:Z<row_count>)
    requests.push(Request {
        update_values: Some(UpdateValuesRequest {
            range: format!("'{}'!A1:{}{}", tab_name, col_letter, row_count),
            values: Some(data),
            major_dimension: Some("ROWS".to_string()),
            ..Default::default()
        }),
        ..Default::default()
    });
    
    // Request 2: Clear tail rows beyond new data (A<row_count+1>:ZZ)
    // Use a large row number as ceiling; Google Sheets ignores out-of-bounds writes
    requests.push(Request {
        update_values: Some(UpdateValuesRequest {
            range: format!("'{}'!A{}:ZZ1000000", tab_name, row_count + 1),
            values: Some(vec![]),  // empty values clears the range
            major_dimension: Some("ROWS".to_string()),
            ..Default::default()
        }),
        ..Default::default()
    });
    
    let batch = BatchUpdateSpreadsheetRequest {
        requests: Some(requests),
        ..Default::default()
    };
    
    sheets_client.spreadsheets()
        .batch_update(batch, spreadsheet_id)
        .doit()?;
    
    Ok(())
}

fn col_index_to_letters(idx: usize) -> String {
    if idx == 0 { return "A".to_string(); }
    let mut result = String::new();
    let mut n = idx;
    while n > 0 {
        result.insert(0, (((n - 1) % 26) as u8 + b'A') as char);
        n = (n - 1) / 26;
    }
    result
}
```

**Assumptions (invented):**

1. **Data shape**: `Vec<Vec<String>>` where each inner vec is a row; all rows assumed rectangular (same column count or padded to max).
2. **Empty data**: 0 rows → clears entire tab; handled naturally by clearing tail from row 1.
3. **Column count**: Computed as `max(row.len())` across all rows; minimum 1 to avoid empty range error.
4. **Sheet ID**: Tab identified by name (string); spreadsheet ID passed as string (known externally).
5. **Tail truncation**: Second request clears range `A<row_count+1>:ZZ1000000`; using a ceiling row prevents "half-written" tail (any prior stale rows are overwritten with empty cells).
6. **Out-of-bounds safety**: Google Sheets API ignores writes beyond actual sheet bounds; no error if data is small.
7. **Atomicity**: Both requests bundled in single `batchUpdate` call → no intermediate inconsistent state.
8. **Error handling**: Returns `Result<>` on API failure; bubbles to caller.
9. **Interpretation choice**: "residual tail" = rows beyond new data count; clearing via empty `values: Some(vec![])` in UpdateValuesRequest (not DeleteRangeRequest, which shifts rows).

**Why this design**: Single `batchUpdate` with two sequential requests ensures atomicity—write completes and tail clears before any reader sees intermediate state. No formulas or formatting preserved in tail (clean slate per spec).