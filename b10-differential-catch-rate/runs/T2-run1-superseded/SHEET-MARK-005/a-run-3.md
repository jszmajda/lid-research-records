```rust
/// Money in integer cents (project convention).
pub type Cents = i64;
/// Interned symbol handle.
pub type SymbolId = u32;
/// Monotonic counter bumped each time the sheet's GOOGLEFINANCE column is read back.
pub type QuoteEpoch = u64;

/// One symbol's mark as read back from the sheet.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct SymbolMark {
    pub symbol_id: SymbolId,
    pub price: Cents,
    pub quote_epoch: QuoteEpoch,
    pub degraded: bool,
}

/// ledger-core's per-symbol degradation tracking (LEDGER-PNL-007).
pub trait DegradationSink {
    fn mark_symbol_degraded(&mut self, symbol_id: SymbolId, since_epoch: QuoteEpoch);
    fn clear_symbol_degraded(&mut self, symbol_id: SymbolId);
}

/// Cache of last-known-good marks, keyed by symbol, for offline fallback.
#[derive(Default)]
pub struct MarkCache {
    last_good: std::collections::HashMap<SymbolId, SymbolMark>,
}

impl MarkCache {
    /// SHEET-MARK-005, first clause: feed a degraded mark into ledger-core's degradation
    /// tracking; a healthy mark clears prior degradation and updates the cache.
    pub fn ingest(&mut self, mark: SymbolMark, sink: &mut impl DegradationSink) {
        if mark.degraded {
            sink.mark_symbol_degraded(mark.symbol_id, mark.quote_epoch);
            // No usable price on a degraded reading -> do not overwrite the cache.
        } else {
            sink.clear_symbol_degraded(mark.symbol_id);
            self.last_good.insert(mark.symbol_id, mark);
        }
    }

    /// SHEET-MARK-005, second clause: while offline, kernels use the last cached mark,
    /// stamped with ITS original quote-epoch (not the current cycle's).
    pub fn resolve(&self, symbol_id: SymbolId, fresh: Option<SymbolMark>) -> Option<SymbolMark> {
        match fresh {
            Some(m) if !m.degraded => Some(m),
            _ => self.last_good.get(&symbol_id).copied(),
        }
    }
}
```

Assumptions (invented, not in the EARS text):

1. `Cents = i64`, `SymbolId = u32`, `QuoteEpoch = u64` (monotonic, bumped per read-back cycle) — no shapes given.
2. "Feed... degradation" implemented as calling a `DegradationSink` trait method, not a direct field write — ledger-core owns the state; sheets-view only reports into it.
3. "Degraded symbol mark" modeled as a `SymbolMark` with a `degraded: bool` flag rather than a separate error/enum type.
4. Assumed (not stated) that a subsequent healthy mark clears degradation via `clear_symbol_degraded`; the EARS only specifies the degraded-feed direction, not recovery — chosen because a latch with no clear path seemed less plausible for a live oracle.
5. Cache holds only the single most recent non-degraded mark per symbol, not history.
6. Degraded readings are never written to the cache — only "good" marks count as "last cached marks."
7. "Offline" interpreted structurally as "no fresh non-degraded mark available this cycle" (`fresh` is `None` or `degraded`), since no explicit connectivity signal is defined by this EARS.
8. Critical interpretive choice: on fallback, the returned mark keeps its *original* `quote_epoch`, not the current one — required so kernels can detect staleness; bumping it would silently hide degradation.
9. Boundary: unseen symbol + offline → `resolve` returns `None`; how kernels handle a missing mark is left to `LEDGER-PNL-007`/callers, out of scope for this EARS.