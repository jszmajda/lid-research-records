```rust
type Cents = i64;
type QuoteEpoch = u64; // opaque, orderable "as-of" stamp for a quote

#[derive(Clone, Copy, PartialEq, Eq, Hash)]
struct SymbolId(u32);

/// A single fetched reading, prior to caching decisions.
enum MarkReading {
    Live { price: Cents, epoch: QuoteEpoch },
    Degraded, // GOOGLEFINANCE cell returned #N/A, error, or unparsable
}

enum Connectivity { Online, Offline }

#[derive(Clone, Copy)]
struct Mark { price: Cents, epoch: QuoteEpoch, stale: bool }

/// Sink owned by ledger-core; exact API assumed (LEDGER-PNL-007 not given here).
trait PerSymbolDegradation {
    fn mark_degraded(&mut self, symbol: SymbolId, at: QuoteEpoch);
}

#[derive(Default)]
struct MarkCache(std::collections::HashMap<SymbolId, Mark>);

impl MarkCache {
    /// Resolves the mark a kernel should use for `symbol` this tick.
    fn resolve(
        &mut self,
        degradation: &mut dyn PerSymbolDegradation,
        symbol: SymbolId,
        reading: MarkReading,
        connectivity: Connectivity,
        now: QuoteEpoch,
    ) -> Option<Mark> {
        match reading {
            MarkReading::Live { price, epoch } => {
                let mark = Mark { price, epoch, stale: false };
                self.0.insert(symbol, mark); // only successful reads refresh cache
                Some(mark)
            }
            MarkReading::Degraded => {
                degradation.mark_degraded(symbol, now); // feed LEDGER-PNL-007 unconditionally
                match connectivity {
                    Connectivity::Offline => self.0.get(&symbol).map(|m| Mark { stale: true, ..*m }),
                    Connectivity::Online => None, // degraded but online, no cache fallback specified
                }
            }
        }
    }
}
```

Assumptions:
1. `Cents = i64`; `QuoteEpoch = u64` as an opaque, orderable stamp (not necessarily wall-clock) since EARS doesn't define its representation.
2. "Degraded symbol mark" interpreted as a per-symbol reading that failed/returned N/A from the GOOGLEFINANCE oracle, modeled as `MarkReading::Degraded`.
3. `PerSymbolDegradation`/`mark_degraded` signature is invented — LEDGER-PNL-007's real interface isn't given; assumed a minimal trait so this sketch stays decoupled from ledger-core internals.
4. Degradation feed happens on every degraded reading regardless of online/offline state — treated as clause 1's own trigger, independent of clause 2's fallback behavior.
5. "Offline" is an externally-supplied `Connectivity` enum; this EARS doesn't specify offline detection, only kernel reaction to it, so detection is out of scope and passed in.
6. Cache is unbounded, keyed by symbol, updated only on successful live reads; degraded/offline reads never overwrite it.
7. Cold-start edge case (offline, degraded, no prior cached mark for that symbol): resolves to `None` — no invented synthetic mark, since the EARS says "use last cached marks," implying none exist to use.
5b. Online + degraded is out of this EARS's stated scope; sketch returns `None` rather than silently reusing cache, to avoid inventing unstated fallback behavior.
8. `stale: bool` added to distinguish cache-served marks from fresh ones downstream, since kernels must be able to tell they're consuming a quote-epoch-stamped cached value rather than a live one.
9. This logic is placed conceptually in/near ledger-core (not sheets-view), since sheets-view owns no accounting math and this function writes directly into ledger-core's degradation tracking.