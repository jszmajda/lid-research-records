```rust
/// A previously observed good price, in integer Cents.
#[derive(Clone, Copy, Debug)]
struct Mark {
    cents: i64,
    observed_at: u64, // monotonic tick or unix seconds
}

#[derive(Clone, Debug)]
enum PriceCell {
    Numeric(f64),
    Transient, // "#N/A" or "Loading..."
    OtherError(String), // any other non-numeric, non-transient value
}

#[derive(Clone, Debug)]
struct SymbolMarkState {
    cached: Option<Mark>,
    first_bad_at: Option<u64>, // start of current non-numeric streak
    retry_window: u64,         // bounded window, in same time unit as `now`
}

#[derive(Debug, PartialEq)]
enum MarkOutcome {
    Fresh(Mark),
    Stale(Mark),  // kept prior good mark, still retrying
    Degraded,     // retry window exhausted, no mark
}

impl SymbolMarkState {
    fn update(&mut self, cell: PriceCell, now: u64) -> MarkOutcome {
        match cell {
            PriceCell::Numeric(v) => {
                let m = Mark { cents: (v * 100.0).round() as i64, observed_at: now };
                self.cached = Some(m);
                self.first_bad_at = None;
                MarkOutcome::Fresh(m)
            }
            PriceCell::Transient => {
                let bad_since = *self.first_bad_at.get_or_insert(now);
                if now.saturating_sub(bad_since) < self.retry_window {
                    match self.cached {
                        Some(m) => MarkOutcome::Stale(m),
                        None => MarkOutcome::Degraded, // never had a good mark
                    }
                } else {
                    self.cached = None;
                    MarkOutcome::Degraded
                }
            }
            PriceCell::OtherError(_) => {
                // Not covered by SHEET-MARK-003 (transient-only); treat
                // conservatively as immediate degrade, no retry countdown.
                self.cached = None;
                self.first_bad_at = None;
                MarkOutcome::Degraded
            }
        }
    }
}
```

Assumptions:
1. `PriceCell` parsing (splitting `#N/A`/`Loading...` vs. numeric vs. other errors) happens upstream; this module only consumes the classified enum.
2. Mark stored as `Cents` (i64) per project convention; conversion from GOOGLEFINANCE's `f64` rounds half-away-from-zero.
3. Retry window is time-based (ticks/seconds), not a fixed retry count, since EARS says "window" not "N attempts."
4. First transient reading with no prior cached mark yields `Degraded` immediately (no mark to keep) — EARS is silent here; chosen as safest reading.
5. A non-transient error string is out of scope for this spec's retry logic and degrades immediately rather than consuming the window — EARS only names `#N/A`/`Loading...` as transient.
6. A numeric reading at any point resets the bad-streak clock entirely (no partial memory of prior degraded runs).
7. `retry_window` and its unit are configuration, not fixed constants, since EARS says "bounded" without a number.
8. Thread/concurrency safety and persistence of `SymbolMarkState` across process restarts are out of scope for this sketch.