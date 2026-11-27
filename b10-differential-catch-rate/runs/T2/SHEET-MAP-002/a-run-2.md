```rust
use std::collections::HashMap;

/// A single row read back from the settled Sheets tab after GOOGLEFINANCE
/// formulas have resolved to values.
#[derive(Debug, Clone)]
pub struct MarkRow {
    pub symbol: String,   // row identity key
    pub price_cents: i64, // resolved live price, integer Cents
    pub row_index: usize, // 0-based sheet row, for error reporting
}

#[derive(Debug)]
pub enum MarkReadbackError {
    DuplicateSymbol {
        symbol: String,
        first_row: usize,
        dup_row: usize,
    },
}

impl std::fmt::Display for MarkReadbackError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::DuplicateSymbol { symbol, first_row, dup_row } => write!(
                f,
                "mark read-back violated row-identity invariant: symbol \"{symbol}\" \
                 appears at rows {first_row} and {dup_row} (expected exactly one row per symbol)"
            ),
        }
    }
}
impl std::error::Error for MarkReadbackError {}

/// Keys mark read-back rows by symbol, asserting one row per symbol.
/// Returns Err on the first duplicate symbol encountered.
pub fn key_marks_by_symbol(
    rows: Vec<MarkRow>,
) -> Result<HashMap<String, MarkRow>, MarkReadbackError> {
    let mut by_symbol: HashMap<String, MarkRow> = HashMap::with_capacity(rows.len());
    for row in rows {
        if let Some(existing) = by_symbol.get(&row.symbol) {
            return Err(MarkReadbackError::DuplicateSymbol {
                symbol: row.symbol,
                first_row: existing.row_index,
                dup_row: row.row_index,
            });
        }
        by_symbol.insert(row.symbol.clone(), row);
    }
    Ok(by_symbol)
}
```

Assumptions:
1. "Erroring loudly" = returning a `Result::Err` that the settle pass must propagate/surface (not a silent log, not `unwrap`/`panic!`), so the caller cannot ignore it. A panic was considered but rejected — a settle pass crashing the process is worse than a returned error the caller is required to handle.
2. Symbol match is exact-string, case-sensitive, no trimming/normalization — normalization is assumed to happen upstream (kernel/ledger), not in this read-back keying step.
3. Empty input (`rows: Vec::new()`) is not an error here — "one row per symbol" only constrains symbols that *do* appear; verifying every ledger symbol got a row back is a different, unstated requirement (join-completeness), out of scope for SHEET-MAP-002.
4. Duplicate detection stops at the first violation rather than collecting all duplicates — chosen for simplicity and because EARS says "erroring," singular, not "reporting all violations."
5. `MarkRow` shape (symbol/price_cents/row_index) is invented; only `symbol` is required by this spec, others included for realistic error context.
6. Price type is `i64` Cents per project convention; not exercised by this requirement.
7. No retry/fallback behavior on violation — the function surfaces the error and does no recovery, since EARS specifies detection, not remediation.