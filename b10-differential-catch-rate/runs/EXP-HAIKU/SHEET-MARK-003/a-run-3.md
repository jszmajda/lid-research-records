# Rust Implementation: SHEET-MARK-003 Price Cell Retry Cache

```rust
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum CellState {
    Valid,
    Transient,
    Degraded,
}

#[derive(Debug)]
pub struct PriceMark {
    /// Last known good numeric price value
    cached_mark: Option<f64>,
    
    /// Current cell state: Valid / Transient (#N/A, Loading) / Degraded (non-numeric after retries)
    state: CellState,
    
    /// Consecutive transient observations
    retry_count: u32,
    
    /// Bounded window: max consecutive transients before marking degraded
    max_retries: u32,
}

impl PriceMark {
    pub fn new(retry_window: u32) -> Self {
        Self {
            cached_mark: None,
            state: CellState::Transient,
            retry_count: 0,
            max_retries: retry_window,
        }
    }

    /// Call when price cell is polled from sheets.
    /// Returns the mark to display: prior good value, or None if degraded.
    pub fn observe(&mut self, cell_reading: CellReading) -> Option<f64> {
        match cell_reading {
            // Numeric value received — update cache, reset retry counter
            CellReading::Numeric(price) => {
                self.cached_mark = Some(price);
                self.state = CellState::Valid;
                self.retry_count = 0;
                Some(price)
            }
            // Transient error (#N/A, Loading, etc.) — keep cached, increment retry
            CellReading::Transient => {
                self.retry_count += 1;
                if self.retry_count > self.max_retries {
                    self.state = CellState::Degraded;
                    None  // "no mark" after retry window expires
                } else {
                    self.state = CellState::Transient;
                    self.cached_mark  // Return prior good, or None if never had one
                }
            }
        }
    }

    pub fn state(&self) -> CellState {
        self.state
    }
}

pub enum CellReading {
    Numeric(f64),
    Transient,  // Represents #N/A, Loading..., or parse error
}
```

## Assumptions (Explicit)

1. **Retry window is attempt-count-based**, not time-based (default 3–5 retries reasonable; caller provides bound).
2. **Price is `f64`** (Rust standard float; caller converts from Sheets numeric).
3. **Cell reading failure detection**: Caller parses Sheets cell and provides `CellReading::Transient` for `#N/A`, `Loading...`, or invalid format; `Numeric(f64)` for valid prices.
4. **No cached mark on first failure**: `observe()` returns `None` until first `Numeric` is seen, then switches to cached prior mark on retry.
5. **Degradation is permanent in this session**: Once `retry_count > max_retries`, `state == Degraded` and `observe()` always returns `None`. Caller may reset or expunge stale entries.
6. **Idempotent on Degraded**: Continued transient readings after degradation do not further increment retry_count (no overflow concern).
7. **Responsibility split**: `PriceMark` tracks state; caller owns polling loop, Sheets I/O, and re-triggering fetch after transient to allow retry.
8. **"No mark" interpretation**: Return `None` to signal downstream (sheets writer) to leave cell blank or show prior value as greyed/soft. Alternatively, caller handles display logic.