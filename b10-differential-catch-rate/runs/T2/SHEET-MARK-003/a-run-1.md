```rust
/// Cached mark state for one symbol, updated each poll cycle.
struct MarkCache {
    last_good: Option<Cents>,      // most recent numeric price
    consecutive_bad: u32,          // count of consecutive non-numeric reads
    degraded: bool,                // true once retry window is exhausted
}

/// One poll of the `Price` cell for a symbol.
enum PriceCell {
    Numeric(Cents),
    NotAvailable,   // #N/A
    Loading,        // "Loading..."
}

const MAX_RETRIES: u32 = 3; // bounded retry window

impl MarkCache {
    fn observe(&mut self, cell: PriceCell) {
        match cell {
            PriceCell::Numeric(price) => {
                self.last_good = Some(price);
                self.consecutive_bad = 0;
                self.degraded = false;
            }
            PriceCell::NotAvailable | PriceCell::Loading => {
                self.consecutive_bad += 1;
                if self.consecutive_bad > MAX_RETRIES {
                    self.degraded = true;
                    // last_good intentionally left untouched; mark is
                    // reported as absent via `current_mark()`, not cleared.
                }
                // else: keep prior cached mark, no state change to degraded
            }
        }
    }

    /// Returns the mark to publish this cycle, or None if degraded (no mark).
    fn current_mark(&self) -> Option<Cents> {
        if self.degraded { None } else { self.last_good }
    }
}
```

Assumptions (explicitly invented, not sourced from the EARS text):

1. `Cents` is `i64`; `PriceCell` enum collapses "#N/A" and "Loading..." into one transient-bad category since the requirement treats them identically.
2. Retry window is a *count* of consecutive bad polls (`MAX_RETRIES = 3`), not a wall-clock duration — EARS says "bounded retry window" without units; count-based is simpler to make deterministic in a sheet-poll loop. A time-based alternative (e.g., 90s) was rejected for lack of a stated poll interval.
3. "Stays non-numeric past the window" is interpreted as strictly-greater-than the bound (`consecutive_bad > MAX_RETRIES`), i.e., the window allows exactly `MAX_RETRIES` transient reads before degrading — boundary chosen for symmetry with typical retry semantics.
4. Once degraded, a later numeric read fully recovers the symbol (resets `degraded` and `consecutive_bad`) — the EARS doesn't state recovery behavior explicitly, but "transient" implies recoverability.
5. `last_good` is never cleared on degradation — "no mark" is a reporting-layer decision (`current_mark()` returns `None`), preserving the cache in case of later recovery, per "keep the prior good cached mark."
6. First-ever poll with no prior good mark and an immediate bad read: `last_good` stays `None` throughout; this is out of scope for SHEET-MARK-003 (no prior mark to keep) and assumed handled by a separate cold-start rule.
7. No thread-safety/async concerns modeled — single-threaded poll-and-update sketch only.