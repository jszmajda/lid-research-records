# SHEET-MARK-006 Implementation Sketch

```rust
use std::result::Result;

/// Represents a price/value snapshot
#[derive(Clone, Debug)]
pub struct Mark {
    pub symbol: String,
    pub price_cents: i64,  // Integer cents; matches money model
    pub timestamp: u64,    // Unix timestamp
}

/// Transport layer errors (network, timeout, invalid response)
#[derive(Debug, Clone)]
pub enum TransportError {
    NetworkFailure(String),
    Timeout,
    InvalidResponse(String),
}

/// Manages marks read-back pass with atomic cache updates
pub struct MarksReadBack {
    cached_marks: Vec<Mark>,
}

impl MarksReadBack {
    pub fn new() -> Self {
        Self {
            cached_marks: Vec::new(),
        }
    }
    
    /// Executes one marks read-back pass.
    /// On success: returns new marks, updates cache atomically.
    /// On transport failure: propagates error WITHOUT updating cache.
    /// Caller MUST NOT emit marks on Err; runtime uses get_cached_marks() instead.
    pub fn pass(&mut self) -> Result<Vec<Mark>, TransportError> {
        // Fetch new marks from Google Sheets (GOOGLEFINANCE rows + settle pass).
        // If transport fails at ANY point, Err is returned; cache untouched.
        let new_marks = fetch_marks_from_sheets()?;
        
        // Only reached on success. Atomic: cache is updated only after full fetch.
        self.cached_marks = new_marks.clone();
        
        Ok(new_marks)
    }
    
    /// Returns last successfully cached marks.
    /// Runtime calls this when pass() returns Err to provide carry-forward.
    pub fn get_cached_marks(&self) -> Vec<Mark> {
        self.cached_marks.clone()
    }
}

// Placeholder: actual implementation fetches from Google Sheets API,
// parses GOOGLEFINANCE, runs settle pass, returns complete set or TransportError.
fn fetch_marks_from_sheets() -> Result<Vec<Mark>, TransportError> {
    // If any step fails (network, timeout, parse), return early.
    // Partial results never escape this function.
    Ok(vec![])
}
```

---

## Assumptions

1. **Mark type**: Snapshot of (symbol, price_cents, timestamp); assumes prices are integer cents per domain.
2. **TransportError scope**: Covers network/timeout/parse failures; does not include data validation errors (assumed handled separately).
3. **Atomicity guarantee**: Entire fetch succeeds or fails; no partial-mark buffering. Cache updates only on `Ok`.
4. **Cache ownership**: `MarksReadBack` owns cache; runtime calls `get_cached_marks()` on error for carry-forward (error return signals: "don't emit, use cache").
5. **Fetch consolidation**: `fetch_marks_from_sheets()` includes Google Sheets API call, GOOGLEFINANCE parsing, and settle pass; all-or-nothing.
6. **Clone semantics**: Small mark count; cloning is acceptable for cache updates. If marks scale, use `Arc<[Mark]>`.
7. **Error propagation**: Err is returned as-is; caller logs and decides fallback (no retry inside `pass()`).
8. **Interpretation**: "Emit no marks" → do not return marks from `pass()` on error (not a no-op write, but a failed call). Runtime implements fallback by checking `Ok`/`Err`.

{lid-checkout}/docs/research/experiments/b10-differential-catch-rate/answer-key