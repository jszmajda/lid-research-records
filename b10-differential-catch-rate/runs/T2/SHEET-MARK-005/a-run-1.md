```rust
// sheets-view: mark cache + degradation feed (SHEET-MARK-005)
// @spec SHEET-MARK-005

use std::collections::HashMap;

pub type Cents = i64;
pub type Symbol = String;
/// Monotonic quote timestamp from the price source (e.g. GOOGLEFINANCE poll tick).
pub type QuoteEpoch = u64;

#[derive(Clone, Debug)]
pub struct SymbolMark {
    pub symbol: Symbol,
    pub price: Cents,
    pub quote_epoch: QuoteEpoch,
    pub degraded: bool,
}

/// Trait boundary into ledger-core; sheets-view owns no accounting logic itself.
pub trait LedgerCoreDegradation {
    /// LEDGER-PNL-007: per-symbol degradation feed.
    fn mark_symbol_degraded(&mut self, symbol: &str, quote_epoch: QuoteEpoch);
    fn mark_symbol_ok(&mut self, symbol: &str, quote_epoch: QuoteEpoch);
}

#[derive(Default)]
pub struct MarkCache {
    last_good: HashMap<Symbol, SymbolMark>,
    offline: bool,
}

impl MarkCache {
    /// Called each poll cycle with a freshly observed mark (may itself be degraded,
    /// e.g. GOOGLEFINANCE returned #N/A). Feeds ledger-core and updates cache.
    pub fn ingest(&mut self, mark: SymbolMark, ledger: &mut impl LedgerCoreDegradation) {
        if mark.degraded {
            ledger.mark_symbol_degraded(&mark.symbol, mark.quote_epoch);
            // Do not overwrite cache with a degraded reading — cache holds last *good* mark.
        } else {
            ledger.mark_symbol_ok(&mark.symbol, mark.quote_epoch);
            self.last_good.insert(mark.symbol.clone(), mark);
        }
    }

    /// While offline, kernels resolve marks through here instead of live ingest.
    pub fn resolve(&self, symbol: &str) -> Option<&SymbolMark> {
        self.last_good.get(symbol)
    }

    pub fn set_offline(&mut self, offline: bool) {
        self.offline = offline;
    }

    pub fn is_offline(&self) -> bool {
        self.offline
    }
}
```

Assumptions (explicitly invented, not given by the EARS text):

1. "Degraded symbol mark" = a per-poll observation for one symbol flagged degraded (e.g. formula error), distinct from cell-wide sheet failure; degradation is symbol-scoped per LEDGER-PNL-007's name.
2. A degraded mark does NOT overwrite the cache — cache holds only the last known-good mark, since "use the last cached marks" implies a good-mark cache, not a degraded one.
3. "Feed" = an explicit call into a `LedgerCoreDegradation` trait, chosen as the sheets-view/ledger-core boundary since sheets-view "owns no accounting math."
4. Non-degraded marks also report `mark_symbol_ok` — not stated, but needed so degradation can clear; assumed transient (auto-clears on next good mark) rather than sticky, since no un-degrade signal is specified otherwise.
5. "Offline" is a distinct boolean mode (network/sheet unreachable), separate from per-symbol degradation; ambiguous whether these are the same concept — I treated them as orthogonal: degraded = bad data present, offline = no polling occurring at all.
6. `resolve()` returns `Option` — no cached mark ever seen is unhandled by this EARS; assumed caller-level fallback (e.g. error/None-price display) out of scope.
7. `quote_epoch` type/monotonicity and cache eviction policy (unbounded HashMap, no TTL/expiry) are invented; EARS doesn't bound cache lifetime or memory.
8. Kernels reading from `resolve()` only during `is_offline()==true` is assumed rather than enforced in code — a real system would gate kernel calls, omitted here for brevity.