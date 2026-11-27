```rust
use std::error::Error;

#[derive(Clone, Debug)]
pub struct Marks {
    pub entries: Vec<(String, i64)>, // symbol, price in cents
}

pub struct MarksRuntime {
    cached_marks: Option<Marks>,
}

impl MarksRuntime {
    pub fn new() -> Self {
        MarksRuntime {
            cached_marks: None,
        }
    }

    /// Atomically fetch marks via transport; propagate errors without cache mutation.
    /// On success, updates cache and returns marks.
    /// On failure, retains cached marks and propagates error.
    pub fn read_back_marks<F>(
        &mut self,
        transport: F,
    ) -> Result<Marks, Box<dyn Error>>
    where
        F: FnOnce() -> Result<Marks, Box<dyn Error>>,
    {
        // Execute transport—if it fails, return error immediately.
        // Cache is not mutated; last cached marks remain available.
        let new_marks = transport()?;

        // Only reach here on success; atomically cache.
        self.cached_marks = Some(new_marks.clone());
        Ok(new_marks)
    }

    /// Retrieve last successful cached marks (post-failure fallback).
    pub fn last_cached(&self) -> Option<Marks> {
        self.cached_marks.clone()
    }
}

// Example transport call:
// let mut rt = MarksRuntime::new();
// let marks = rt.read_back_marks(|| fetch_from_sheets())?;  // Success: cache updated, marks returned
// let err = rt.read_back_marks(|| Err("network timeout".into()));  // Failure: error propagated, cache untouched
// let fallback = rt.last_cached();  // Still available
```

**Assumptions (invented):**

1. `Marks` is a struct holding `Vec<(String, i64)>` — symbol and price in cents.
2. Transport failures are `Result<Marks, Box<dyn Error>>` — covering network, I/O, format errors.
3. `cached_marks: Option<Marks>` — `None` until first successful pass; `Some` thereafter.
4. Atomicity by early-return: transport must succeed fully before cache update occurs.
5. No partial emission: `?` operator aborts on transport error; cache remains unmodified.
6. `runtime` is the `MarksRuntime` struct; it owns carry-forward via `cached_marks` field.
7. Caller passes closure to abstract transport layer (sheets API, HTTP client, etc.).
8. Error type is boxed `dyn Error`; specific transport errors bubbled up unchanged.
9. `Marks` is cloneable; cache holds last-successful snapshot.
10. No retry logic; transport error immediately propagates; caller decides retry policy.

**Interpretation:** "Emit no marks" means the function returns error without yielding marks to downstream—cache becomes the sole recovery point for the caller.