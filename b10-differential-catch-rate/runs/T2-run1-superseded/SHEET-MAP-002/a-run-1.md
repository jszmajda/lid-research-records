```rust
use std::collections::HashMap;
use std::fmt;

/// Ticker symbol — the row identity for mark read-back.
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct Symbol(pub String);

/// One row read back from the sheet's GOOGLEFINANCE mark column.
#[derive(Debug, Clone)]
pub struct MarkRow {
    pub symbol: Symbol,
    pub row_index: usize, // sheet row, for diagnostics
    pub price_cents: i64, // Money = integer Cents
}

#[derive(Debug)]
pub struct DuplicateSymbolError {
    pub symbol: Symbol,
    pub first_row: usize,
    pub dup_row: usize,
}

impl fmt::Display for DuplicateSymbolError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            f,
            "mark read-back invariant violated: symbol {:?} appears in rows {} and {} \
             (row identity must be unique per symbol)",
            self.symbol.0, self.first_row, self.dup_row
        )
    }
}
impl std::error::Error for DuplicateSymbolError {}

/// Keys mark read-back rows by symbol (row identity), erroring on any duplicate.
/// @spec SHEET-MAP-002
pub fn key_marks_by_symbol(
    rows: impl IntoIterator<Item = MarkRow>,
) -> Result<HashMap<Symbol, MarkRow>, DuplicateSymbolError> {
    let mut out: HashMap<Symbol, MarkRow> = HashMap::new();
    for row in rows {
        if let Some(existing) = out.get(&row.symbol) {
            return Err(DuplicateSymbolError {
                symbol: row.symbol.clone(),
                first_row: existing.row_index,
                dup_row: row.row_index,
            });
        }
        out.insert(row.symbol.clone(), row);
    }
    Ok(out)
}
```

Caller in the settle pass propagates the `Err` with `?` up to a top-level that aborts the run (not logged-and-swallowed), satisfying "erroring loudly."

Assumptions:
1. "Row identity (symbol)" is the sole key; symbols are assumed already case/whitespace-normalized upstream, so equality is exact-match — this function does no canonicalization.
2. "One row per symbol" is asserted only over rows actually present; a symbol with zero rows (missing entirely) is out of scope here — that's a completeness check, not an identity/uniqueness check, and this spec covers only the latter.
3. "Erroring loudly" is interpreted as a propagated `Result::Err` (not `assert!`/`debug_assert!`, which vanish or panic inconsistently across build profiles, and not a log-and-continue) since the input is externally-sourced sheet state, and silently picking one of several ambiguous rows would corrupt the settle pass.
4. Detection is fail-fast (stops at first duplicate) rather than accumulating every duplicate found — assumed sufficient for "loudly"; a multi-error accumulator variant was considered and rejected as unneeded complexity for this spec.
5. `row_index` is assumed available from the sheet reader purely for diagnostic detail in the error; if unavailable, the symbol alone still satisfies the requirement.
6. `price_cents` is assumed already parsed from the `GOOGLEFINANCE` cell into integer Cents before reaching this function — parsing/formula evaluation is a separate upstream concern, not part of keying by row identity.
7. Which row is labeled "first" vs. "dup" reflects iteration order only, not sheet-authoritative ordering — no meaning is assumed beyond "these two rows collide."