```rust
use std::time::{Duration, Instant};

/// Integer cents (workspace-wide money type).
pub type Cents = i64;

/// One poll's raw read of a Price cell.
pub enum PriceCell {
    Numeric(Cents),
    NonNumeric(String), // "#N/A", "Loading...", or any other non-numeric text
}

/// Per-symbol state carried across poll cycles by the marks settle pass.
pub struct MarkState {
    cached: Option<Cents>,       // last known-good mark, if any
    first_failure: Option<Instant>, // when the current failure streak began
    degraded: bool,
}

/// Bound on how long a symbol may stay non-numeric before it is
/// recorded as degraded. EARS does not state the exact bound.
const RETRY_WINDOW: Duration = Duration::from_secs(90);

impl MarkState {
    pub fn new() -> Self {
        Self { cached: None, first_failure: None, degraded: false }
    }

    /// Apply one poll's reading; returns the mark to publish (None = degraded/no mark yet).
    pub fn observe(&mut self, cell: PriceCell, now: Instant) -> Option<Cents> {
        match cell {
            PriceCell::Numeric(c) => {
                self.cached = Some(c);
                self.first_failure = None;
                self.degraded = false;
            }
            PriceCell::NonNumeric(_) => {
                let started = *self.first_failure.get_or_insert(now);
                if now.duration_since(started) > RETRY_WINDOW {
                    self.degraded = true;
                    self.cached = None; // "no mark"
                }
                // else: keep self.cached untouched, retry next cycle
            }
        }
        self.cached
    }

    pub fn is_degraded(&self) -> bool {
        self.degraded
    }
}
```

Assumptions:
1. `Price` cell reading modeled as `PriceCell::Numeric(Cents)` vs `NonNumeric(String)`; the string payload (`#N/A`, `Loading...`, other) is not distinguished — EARS names those two only as examples, so any non-numeric text is treated identically as "transient candidate."
2. No separate "permanent error" category (e.g. `#REF!`) — EARS gives no criterion to distinguish permanent from transient non-numeric, so all non-numeric reads go through the same retry logic.
3. "Bounded retry window" interpreted as wall-clock duration since the failure streak began (`RETRY_WINDOW = 90s`), not a fixed poll count, since the sheet's GOOGLEFINANCE refresh cadence is external/unspecified. A count-based window is an equally valid reading; duration was chosen because sheet recalculation intervals aren't controlled by this crate.
4. "Keep the prior good cached mark" is implemented as simply not touching `cached` during the retry window — including on the very first-ever read for a symbol, where `cached` is `None` (no prior mark exists yet); degrading such a symbol still yields `None`, so behavior is indistinguishable but semantically both are "no mark."
5. Recovery: a numeric read at any time (even after `degraded=true`) clears `degraded` and resets the failure streak — EARS doesn't address post-degrade recovery explicitly, but "retry" implies eventual recovery is expected.
6. Single-threaded, one `MarkState` per symbol, externally driven by the settle pass's poll loop; no internal timer/async.
7. "Recording the symbol degraded" is exposed via `is_degraded()` rather than a separate log/event sink, since EARS doesn't specify the recording mechanism.