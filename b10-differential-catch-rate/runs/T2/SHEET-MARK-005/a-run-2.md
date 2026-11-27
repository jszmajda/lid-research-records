```rust
/// Quote-epoch stamp: monotonic tick at which a mark was fetched/cached.
#[derive(Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Debug)]
pub struct QuoteEpoch(pub u64);

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum MarkStatus {
    Live,
    Degraded, // e.g. GOOGLEFINANCE returned #N/A, stale formula, parse failure
}

#[derive(Clone, Debug)]
pub struct SymbolMark {
    pub symbol: String,
    pub price_cents: i64,
    pub status: MarkStatus,
    pub epoch: QuoteEpoch,
}

/// Per-symbol cache the kernel consults offline; owned by ledger-core.
#[derive(Default)]
pub struct MarkCache {
    last_good: std::collections::HashMap<String, SymbolMark>,
}

impl MarkCache {
    /// @spec LEDGER-PNL-007
    /// Feeds a symbol's degradation state into ledger-core's per-symbol
    /// tracking. Called on every mark ingest, live or degraded.
    pub fn record_mark(&mut self, mark: SymbolMark) {
        match mark.status {
            MarkStatus::Live => {
                self.last_good.insert(mark.symbol.clone(), mark);
            }
            MarkStatus::Degraded => {
                // Degraded marks feed degradation tracking but do NOT
                // overwrite last_good; the cache retains the last live mark.
                ledger_core::mark_symbol_degraded(&mark.symbol, mark.epoch);
            }
        }
    }

    /// @spec SHEET-MARK-005
    /// Offline resolution: return the last cached mark, stamped with the
    /// epoch it was originally quoted at (not the current time).
    pub fn resolve_offline(&self, symbol: &str) -> Option<SymbolMark> {
        self.last_good.get(symbol).cloned()
    }
}

mod ledger_core {
    use super::QuoteEpoch;
    pub fn mark_symbol_degraded(_symbol: &str, _epoch: QuoteEpoch) {
        // per-symbol degradation bookkeeping (LEDGER-PNL-007) lives here
    }
}
```

Assumptions (invented, not stated by the EARS):

1. "Degraded" is a two-state signal (`Live`/`Degraded`) on a mark, not a numeric quality score.
2. `record_mark` is the feed point invoked for every mark, live or degraded — the EARS only says degraded marks feed degradation, so live marks are assumed to reset/not-trigger it.
3. Degraded marks do not overwrite `last_good` in the cache — only live marks do — since "while offline, use last cached marks" implies the cache holds real prices, not degraded placeholders.
4. "Offline" is a caller-determined precondition; `resolve_offline` itself doesn't detect connectivity — no offline-detection mechanism is specified.
5. `QuoteEpoch` is an opaque monotonic tick, not a wall-clock timestamp — EARS says "stamps," not units.
6. Missing-symbol case on `resolve_offline` (never cached) returns `None`; no fallback value is specified.
7. `mark_symbol_degraded`'s internal per-symbol bookkeeping (e.g., consecutive-degraded counts) is left as a stub — `LEDGER-PNL-007`'s actual mechanics are out of scope for this EARS.
8. Price type is `i64` cents, per stated project convention.
9. No error/Result type is used for ingest failures — assumed all inputs are pre-validated `SymbolMark`s; malformed upstream data is out of scope for this spec.