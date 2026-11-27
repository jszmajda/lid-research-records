```rust
/// Cached mark for one ticker symbol, updated each settle-pass poll of its
/// GOOGLEFINANCE `Price` cell.
pub struct SymbolMark {
    /// Last known-good price, in integer cents. `None` until the first
    /// successful read, or after the symbol is declared degraded.
    cached_cents: Option<i64>,
    /// Count of consecutive polls where the cell read non-numeric.
    consecutive_bad_polls: u32,
    /// True once the retry window has been exhausted without recovery.
    degraded: bool,
}

/// Bounded retry window: number of consecutive settle-pass polls a cell may
/// read non-numeric before we give up and declare it degraded.
const MAX_RETRIES: u32 = 3;

/// Raw content read back from the sheet's `Price` cell this poll.
pub enum PriceCellReading {
    Numeric(i64), // already parsed to integer cents by the caller
    Loading,      // literal "Loading..."
    NotAvailable, // literal "#N/A"
    OtherNonNumeric,
}

impl SymbolMark {
    /// Apply one poll's reading. Called once per settle pass per symbol.
    pub fn observe(&mut self, reading: PriceCellReading) {
        match reading {
            PriceCellReading::Numeric(cents) => {
                self.cached_cents = Some(cents);
                self.consecutive_bad_polls = 0;
                self.degraded = false;
            }
            PriceCellReading::Loading
            | PriceCellReading::NotAvailable
            | PriceCellReading::OtherNonNumeric => {
                self.consecutive_bad_polls += 1;
                if self.consecutive_bad_polls > MAX_RETRIES {
                    // Retry window exhausted: stop presenting the stale mark.
                    self.cached_cents = None;
                    self.degraded = true;
                }
                // Else: within window — cached_cents untouched, retry next pass.
            }
        }
    }
}
```

Assumptions:
1. "Price cell" reading is pre-classified into numeric-cents vs. `Loading...`/`#N/A`/other-non-numeric by an upstream sheet-read step (parsing raw cell strings is out of scope here).
2. "Bounded retry window" = a fixed count of consecutive settle-pass polls (`MAX_RETRIES = 3`), not wall-clock time, since the system's unit of retry is the discrete settle pass, not a timer.
3. Chosen interpretation of the ambiguous ordering: while `consecutive_bad_polls <= MAX_RETRIES`, the stale `cached_cents` is kept and served as-is (transient case). Only once the window is exceeded does the mark become "no mark" (`cached_cents = None`) with `degraded = true` — i.e., degraded is a terminal state, not a co-existing flag alongside a still-displayed stale price.
4. Any numeric reading at any point resets both counters immediately, including recovery after degradation (no separate "un-degrade" cooldown specified).
5. `SymbolMark` construction/defaults, persistence between settle passes, and concurrency are out of scope — assumed caller owns one instance per symbol living across polls.
6. Money type: `i64` cents per project convention, though `PriceCellReading::Numeric` conversion (dollars→cents, rounding) is assumed already done upstream.