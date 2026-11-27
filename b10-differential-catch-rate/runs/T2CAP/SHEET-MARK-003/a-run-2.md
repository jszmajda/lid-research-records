```rust
//! SHEET-MARK-003 — transient GOOGLEFINANCE price-cell handling.

use std::collections::HashMap;

#[derive(Clone, Copy, PartialEq, Eq)]
pub struct Cents(pub i64);

/// Raw `Price` cell as read back from the sheet.
pub enum PriceCell {
    Numeric(Cents),
    /// `#N/A`, `Loading...`, `#ERROR!`, blank, or any other non-numeric text.
    NonNumeric(String),
}

#[derive(Clone, Copy)]
pub struct CachedMark {
    pub price: Cents,
    pub as_of: u64, // settle-pass sequence number
}

#[derive(Default, Clone, Copy)]
pub struct SymbolState {
    pub cached: Option<CachedMark>,
    pub consecutive_non_numeric: u32,
}

pub enum MarkOutcome {
    /// Fresh numeric read; cache updated.
    Fresh(Cents),
    /// Transient non-numeric; prior good mark reused, retry scheduled.
    HeldStale { price: Cents, attempt: u32 },
    /// Past the retry window (or never had a mark): degraded, no mark.
    Degraded,
}

pub struct MarkSettler {
    pub max_retries: u32, // bounded retry window; default 3
    states: HashMap<String, SymbolState>,
}

impl MarkSettler {
    pub fn new(max_retries: u32) -> Self {
        Self { max_retries: max_retries.max(1), states: HashMap::new() }
    }

    pub fn observe(&mut self, symbol: &str, cell: PriceCell, seq: u64) -> MarkOutcome {
        let st = self.states.entry(symbol.to_string()).or_default();
        match cell {
            PriceCell::Numeric(price) => {
                st.cached = Some(CachedMark { price, as_of: seq });
                st.consecutive_non_numeric = 0;
                MarkOutcome::Fresh(price)
            }
            PriceCell::NonNumeric(_) => {
                st.consecutive_non_numeric = st.consecutive_non_numeric.saturating_add(1);
                match st.cached {
                    Some(m) if st.consecutive_non_numeric <= self.max_retries => {
                        MarkOutcome::HeldStale { price: m.price, attempt: st.consecutive_non_numeric }
                    }
                    _ => MarkOutcome::Degraded, // window exhausted, or no prior good mark
                }
            }
        }
    }

    /// True while the caller should re-read the cell rather than settle it.
    pub fn should_retry(&self, symbol: &str) -> bool {
        self.states.get(symbol).is_some_and(|s| {
            s.consecutive_non_numeric > 0 && s.consecutive_non_numeric <= self.max_retries
        })
    }
}
```

Assumptions invented:
1. Retry window is a count of consecutive non-numeric reads (`max_retries`, default 3), not wall-clock; "bounded" left unquantified in the EARS. Chose count because settle passes are discrete read-backs and a count is deterministic/testable.
2. Any non-numeric cell text is treated as transient on first sight — the EARS names `#N/A`/`Loading...` but distinguishing them from permanent `#N/A` (bad ticker) is not observable at read time; the retry window is the discriminator.
3. Cache is per-symbol, in-memory, and persists across settle passes within a run; no on-disk persistence specified.
4. Symbol with no prior good mark and a non-numeric cell degrades immediately (nothing to hold) — the EARS's "keep the prior good cached mark" is vacuous without one.
5. A single numeric read resets the counter fully (no hysteresis).
6. Degraded means "no mark emitted", not "emit stale" — a degraded symbol contributes no price to downstream projection; caller decides tab rendering.
7. Held-stale marks are still stale; `as_of` seq is carried so a view tab can flag staleness. The EARS doesn't require exposing it, but a mark with no age is unusable downstream.
8. Prices are integer `Cents`; parsing sheet floats to Cents happens upstream of `observe`.
9. `max_retries == 0` is clamped to 1 (a zero window would defeat "retry").
10. Not thread-safe; single settle pass assumed sequential.
11. Symbols are `String` tickers, case-sensitive as supplied.