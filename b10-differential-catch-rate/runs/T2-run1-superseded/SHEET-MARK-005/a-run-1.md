```rust
/// SHEET-MARK-005: degraded marks feed per-symbol degradation (LEDGER-PNL-007);
/// offline kernels fall back to last cached marks + their quote-epoch stamps.

use std::collections::HashMap;

pub type Symbol = String;
pub type Cents = i64;
pub type QuoteEpoch = u64; // monotonically increasing tick per successful quote fetch cycle

#[derive(Clone, Debug)]
pub struct SymbolMark {
    pub symbol: Symbol,
    pub price: Cents,
    pub quote_epoch: QuoteEpoch,
    pub degraded: bool, // true if this mark is stale/estimated (e.g. GOOGLEFINANCE error/blank)
}

/// Per-symbol degradation state tracked by ledger-core (LEDGER-PNL-007).
#[derive(Default)]
pub struct DegradationState {
    degraded_symbols: HashMap<Symbol, QuoteEpoch>, // symbol -> epoch it went degraded
}

impl DegradationState {
    /// Feed a degraded mark into per-symbol degradation tracking.
    pub fn record_mark(&mut self, mark: &SymbolMark) {
        if mark.degraded {
            self.degraded_symbols
                .entry(mark.symbol.clone())
                .or_insert(mark.quote_epoch);
        } else {
            self.degraded_symbols.remove(&mark.symbol);
        }
    }

    pub fn is_degraded(&self, symbol: &Symbol) -> bool {
        self.degraded_symbols.contains_key(symbol)
    }
}

/// Cache of last-known marks, consulted while offline.
#[derive(Default)]
pub struct MarkCache {
    last_marks: HashMap<Symbol, SymbolMark>,
}

impl MarkCache {
    pub fn update(&mut self, mark: SymbolMark) {
        self.last_marks.insert(mark.symbol.clone(), mark);
    }

    /// Offline read path: kernels use the last cached mark, carrying its
    /// original quote-epoch stamp (not "now") so staleness is auditable.
    pub fn get_for_offline_kernel(&self, symbol: &Symbol) -> Option<&SymbolMark> {
        self.last_marks.get(symbol)
    }
}

/// Combined feed used by the kernel scheduler each tick.
pub fn ingest_mark(cache: &mut MarkCache, degradation: &mut DegradationState, mark: SymbolMark) {
    degradation.record_mark(&mark);
    cache.update(mark);
}
```

Assumptions (all invented, none stated in the EARS text):
1. "Degraded" is a boolean flag on a mark, not a separate type; produced upstream (marks read-back settle pass), not derived here.
2. `quote_epoch` is a monotonic counter per fetch cycle, not a wall-clock timestamp — EARS says "stamps" but not their type; chose epoch over `DateTime` since GOOGLEFINANCE has no reliable per-cell fetch time.
3. Degradation is sticky per symbol (first degraded epoch retained) until a non-degraded mark clears it — EARS doesn't say whether degradation is instantaneous-only or accumulates; chose accumulate since "per-symbol degradation" implies state, not an event.
4. Offline detection itself (network/connectivity check) is out of scope — assumed the caller only invokes `get_for_offline_kernel` when already known offline.
5. Missing cache entry for a requested symbol (never quoted before) returns `None`; no synthetic default mark is fabricated, since inventing a price would violate the "read-only projection, no accounting math" boundary.
6. No mark is ever evicted from cache (unbounded retention) — no TTL/expiry semantics were given.