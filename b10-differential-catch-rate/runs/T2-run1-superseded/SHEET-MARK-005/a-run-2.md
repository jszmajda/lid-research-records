```rust
/// Quote-epoch: monotonic id of the live-price refresh cycle a mark was read from.
#[derive(Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Debug)]
pub struct QuoteEpoch(pub u64);

pub type Cents = i64;

#[derive(Clone, Copy, Debug)]
pub struct Mark {
    pub price: Cents,
    pub epoch: QuoteEpoch,
    pub degraded: bool,
}

/// Feed into ledger-core's per-symbol degradation state (LEDGER-PNL-007).
pub trait DegradationSink {
    fn mark_degraded(&mut self, symbol: &str, epoch: QuoteEpoch);
}

#[derive(Default)]
pub struct MarkCache(std::collections::HashMap<String, Mark>);

pub enum MarkError {
    /// No cached mark exists to fall back to (never observed online, or degraded from first read).
    NoMarkAvailable,
}

/// Resolve the mark to use for `symbol` this cycle.
///
/// - If freshly read and degraded, reports it to ledger-core immediately.
/// - If offline, ignores the freshly-read value entirely and serves the last
///   cached mark, unmodified, with its original quote-epoch stamp.
pub fn resolve_mark(
    symbol: &str,
    fresh: Option<Mark>,
    online: bool,
    cache: &mut MarkCache,
    sink: &mut dyn DegradationSink,
) -> Result<Mark, MarkError> {
    if !online {
        return cache.0.get(symbol).copied().ok_or(MarkError::NoMarkAvailable);
    }

    match fresh {
        Some(m) if m.degraded => {
            sink.mark_degraded(symbol, m.epoch);
            // Degraded fresh read: still prefer last good cached mark if one exists,
            // else surface the degraded mark itself as last resort.
            Ok(cache.0.get(symbol).copied().unwrap_or(m))
        }
        Some(m) => {
            cache.0.insert(symbol.to_string(), m);
            Ok(m)
        }
        None => cache.0.get(symbol).copied().ok_or(MarkError::NoMarkAvailable),
    }
}
```

Assumptions (interpretation choices, all invented — not sourced from any file):

1. "Degraded symbol mark" = a per-cycle read (e.g. GOOGLEFINANCE returning `#N/A`/error/stale) flagged via `Mark.degraded: bool`; the exact detection rule isn't in this EARS, so I model it as an upstream-supplied boolean.
2. "Feed ledger-core's per-symbol degradation" is a push, not a pull: modeled as a `DegradationSink` trait ledger-core implements, called once per degraded observation. Assumed idempotent on ledger-core's side (repeated calls for the same epoch are harmless) since idempotency isn't specified.
3. "Kernels" (plural) are valuation/PNL consumers downstream of this resolver; sketch shows one shared resolution function they'd all call rather than per-kernel duplication.
4. Offline behavior takes precedence: when offline, I assumed the *fresh* read (if any arrived) is discarded entirely in favor of cache, since the EARS says "shall use the last cached marks," not "prefer fresh when available."
5. No cached mark yet (cold start while offline, or first-ever read is degraded with empty cache): treated as an error (`MarkError::NoMarkAvailable`) — the EARS doesn't specify this edge, and returning a fabricated price seemed worse than surfacing absence.
6. `QuoteEpoch` is an opaque monotonic `u64`; cache is a plain in-memory `HashMap`, no persistence/eviction policy assumed.
7. Connectivity (`online: bool`) is assumed to be determined and supplied by a caller outside this module's scope.