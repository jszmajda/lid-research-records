Assumptions (invented, since SHEET-MARK-003 alone doesn't fix these):

1. `Cents = i64` per the stated integer-cents money type.
2. An upstream parser already classifies a raw Sheets cell into `PriceCell { Numeric(Cents), NotAvailable, Loading, Other(String) }` — this function does not parse GOOGLEFINANCE output itself.
3. "Bounded retry window" is wall-clock time, not a poll count, so state tracks `first_bad_at: Option<Instant>` and compares against a caller-supplied `Duration`. Clock is injected (`now: Instant`) for testability, not read internally.
4. State is per-symbol and persists across settle passes; caller owns a `HashMap<Symbol, MarkState>`.
5. `Other(String)` (e.g. `#REF!`, `#ERROR!`) isn't named by this EARS. Chosen interpretation: fold it into the same transient/retry bucket as `#N/A`/`Loading...` rather than special-casing or immediately degrading it — conservative default, most permissive reading of "non-numeric."
6. Edge case: cell is non-numeric on the very *first* observation (no prior good mark exists yet). There is no "prior good cached mark" to keep, so the outcome is `Pending` (distinct from `Cached`) until the retry window expires, at which point it becomes `Degraded` — same window, but nothing to show meanwhile.
7. On crossing the retry window, the cached mark is cleared (`no mark`, per spec text) rather than kept-but-flagged-stale; a subsequent numeric reading immediately produces `Fresh`, since the spec doesn't require history after degrade.
8. Publishing `Degraded` to the sheets-view tab is out of scope — this is kernel-side mark-tracking only, matching the sheets-view crate's "owns no accounting" boundary.

```rust
use std::time::{Duration, Instant};

pub type Cents = i64;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum PriceCell<'a> {
    Numeric(Cents),
    NotAvailable,      // #N/A
    Loading,           // "Loading..."
    Other(&'a str),    // any other non-numeric (out of spec scope; treated as transient)
}

#[derive(Clone, Copy, Debug, Default)]
pub struct MarkState {
    last_good: Option<Cents>,
    first_bad_at: Option<Instant>,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum MarkOutcome {
    Fresh(Cents),   // numeric this pass
    Cached(Cents),  // transient, still within window, showing prior good mark
    Pending,        // transient, within window, but no prior good mark ever recorded
    Degraded,       // transient past the retry window; mark cleared
}

impl MarkState {
    pub fn update(&mut self, cell: PriceCell, now: Instant, retry_window: Duration) -> MarkOutcome {
        match cell {
            PriceCell::Numeric(c) => {
                self.last_good = Some(c);
                self.first_bad_at = None;
                MarkOutcome::Fresh(c)
            }
            PriceCell::NotAvailable | PriceCell::Loading | PriceCell::Other(_) => {
                let started = *self.first_bad_at.get_or_insert(now);
                if now.duration_since(started) < retry_window {
                    match self.last_good {
                        Some(c) => MarkOutcome::Cached(c),
                        None => MarkOutcome::Pending,
                    }
                } else {
                    self.last_good = None;
                    MarkOutcome::Degraded
                }
            }
        }
    }
}
```