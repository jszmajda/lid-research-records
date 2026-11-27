```rust
use std::time::{Duration, Instant};

pub type Cents = i64;

#[derive(Debug, Clone, PartialEq)]
pub enum PriceCell {
    Numeric(Cents),
    Transient, // "#N/A" or "Loading..."
}

#[derive(Debug, Clone)]
pub struct MarkState {
    pub cached: Option<Cents>,
    bad_since: Option<Instant>,
    pub degraded: bool,
}

impl MarkState {
    pub fn new() -> Self {
        Self { cached: None, bad_since: None, degraded: false }
    }
}

const RETRY_WINDOW: Duration = Duration::from_secs(300);

/// SHEET-MARK-003: on transient non-numeric, keep the cached mark and
/// retry; only flip to degraded once the transient run exceeds RETRY_WINDOW.
pub fn observe(state: &mut MarkState, cell: PriceCell, now: Instant) {
    match cell {
        PriceCell::Numeric(c) => {
            state.cached = Some(c);
            state.bad_since = None;
            state.degraded = false;
        }
        PriceCell::Transient => {
            let since = *state.bad_since.get_or_insert(now);
            if now.duration_since(since) >= RETRY_WINDOW {
                state.degraded = true; // cached left intact; publisher suppresses it
            }
        }
    }
}

pub enum Published { Mark(Cents), Degraded, NoDataYet }

pub fn published_value(s: &MarkState) -> Published {
    if s.degraded {
        Published::Degraded
    } else {
        s.cached.map(Published::Mark).unwrap_or(Published::NoDataYet)
    }
}
```

Assumptions:
1. `Price` cell is pre-parsed upstream into `Numeric(Cents)` or `Transient` — `#N/A` and `"Loading..."` collapsed into one class per the EARS wording ("non-numeric"); string/regex parsing itself is out of scope.
2. Retry window modeled as a wall-clock `Duration` (5 min, a placeholder pending real config) rather than a poll count, since polling cadence isn't stated; the boundary comparison is inclusive (`>=`).
3. Clock is passed in (`now: Instant`) rather than read internally, so the boundary is deterministically testable.
4. "Recording the symbol degraded (no mark)" is modeled as a boolean flag alongside the retained cache, not deletion of the cached value — the mark itself stays in state (satisfying "keep prior good cached mark"), but `published_value` withholds it once degraded, since downstream needs to distinguish "was good, now stale" from "never had data."
5. Recovery: any subsequent `Numeric` read unconditionally clears `degraded` and resets the transient timer. The EARS doesn't state post-degraded recovery explicitly, but "retry" implies retries never stop trying.
6. First-ever read is `Transient` with no prior cache: `cached` stays `None`, surfaced as `NoDataYet`, distinct from `Degraded` — the spec's "no mark" phrasing presupposes a prior mark existed to withhold.
7. Single symbol, single-threaded state; no concurrency/locking shown (assumed handled by a caller keyed per symbol).
8. No distinct "permanent error" class is modeled — any non-`Numeric` cell is `Transient` until the window elapses, at which point `Degraded` is the only failure state this EARS defines.