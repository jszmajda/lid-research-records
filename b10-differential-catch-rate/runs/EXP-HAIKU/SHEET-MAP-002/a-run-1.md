```rust
use std::collections::HashMap;

/// Row identity for mark read-back validation
#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub struct Symbol(String);

/// A mark from sheets read-back, keyed by row identity (symbol)
#[derive(Clone, Debug)]
pub struct Mark {
    pub symbol: Symbol,
    pub price_cents: i32,
    // ... other fields per spec
}

#[derive(Debug)]
pub enum MarkReadbackError {
    /// Multiple rows with the same symbol violate the one-per-symbol invariant
    DuplicateSymbol(String),
    /// Empty or whitespace symbol is invalid
    EmptySymbol(usize), // row index
}

impl std::fmt::Display for MarkReadbackError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::DuplicateSymbol(sym) => write!(
                f,
                "MARK READ-BACK ERROR: Symbol '{}' appears more than once. Invariant violated: exactly one row per symbol.",
                sym
            ),
            Self::EmptySymbol(row) => write!(
                f,
                "MARK READ-BACK ERROR: Row {} has empty/missing symbol. All rows must have row identity.",
                row
            ),
        }
    }
}

impl std::error::Error for MarkReadbackError {}

/// Validate and key mark read-back by symbol (row identity).
/// Asserts exactly one row per symbol; errors loudly on violation.
pub fn validate_mark_readback(
    marks: Vec<Mark>,
) -> Result<HashMap<Symbol, Mark>, MarkReadbackError> {
    let mut validated = HashMap::new();

    for (idx, mark) in marks.into_iter().enumerate() {
        if mark.symbol.0.is_empty() || mark.symbol.0.trim().is_empty() {
            return Err(MarkReadbackError::EmptySymbol(idx));
        }

        if validated.insert(mark.symbol.clone(), mark.clone()).is_some() {
            return Err(MarkReadbackError::DuplicateSymbol(mark.symbol.0));
        }
    }

    Ok(validated)
}
```

**Assumptions (all explicit):**

1. **Symbol type**: `Symbol` is a newtype wrapping `String` for type safety; symbols are case-sensitive
2. **Mark source**: Input is `Vec<Mark>` (already parsed from Sheets); row index is implicit in iteration order
3. **Validation scope**: Validates *this batch only*; doesn't cross-reference prior settle passes
4. **Empty symbol rule**: Whitespace-only symbols treated as empty; error on first violation, fail-fast
5. **"Loudly" interpretation**: `impl Display` with explicit "ERROR" prefix and full context; caller propagates or panics
6. **Output**: `HashMap<Symbol, Mark>` keyed by symbol, ready for settle-pass correlation with prices
7. **Duplicate handling**: First duplicate detected is reported; order of error vs. insertion is fail-fast (error wins)
8. **Invalid rows**: Rows with valid structure but empty symbol are errors, not skipped
9. **Price field**: Assumed `i32` (Cents) per your context; not validated here (schema assumes it's valid)
10. **Return type**: `Result<HashMap, Error>` — caller decides to propagate, log, or panic

**Ambiguity resolved:** "key mark read-back by row identity" could mean either "use symbol as the dictionary key" or "retrieve mark read-back rows by symbol lookup." Chose the first (build a keyed map) because it enables the assertion (one row per symbol) most directly.