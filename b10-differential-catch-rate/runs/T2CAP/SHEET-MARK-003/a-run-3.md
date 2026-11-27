```rust
// crates/sheets-view/src/marks.rs
// @spec SHEET-MARK-003

use std::collections::HashMap;

pub type Cents = i64;

#[derive(Clone, Copy)]
pub struct MarkAttempts(pub u32);

#[derive(Clone)]
pub enum CellValue {
    Numeric(f64),          // parsed GOOGLEFINANCE Price cell
    Transient(String),     // "#N/A", "Loading...", "#ERROR!", ""
}

#[derive(Clone)]
pub struct CachedMark {
    pub price: Cents,
    pub as_of: u64,        // settle-pass sequence number
    pub misses: u32,       // consecutive non-numeric reads
}

#[derive(Clone)]
pub enum MarkOutcome {
    Fresh(Cents),
    Stale { price: Cents, misses: u32 },  // keep prior good mark, retry
    Degraded,                              // no mark
}

pub struct MarkSettler {
    pub retry_budget: u32,                 // bounded retry window, default 3
    cache: HashMap<String, CachedMark>,
}

impl MarkSettler {
    pub fn new(retry_budget: u32) -> Self {
        Self { retry_budget: retry_budget.max(1), cache: HashMap::new() }
    }

    /// One read-back per settle pass, per symbol.
    pub fn settle(&mut self, symbol: &str, cell: &CellValue, pass: u64) -> MarkOutcome {
        match cell {
            CellValue::Numeric(p) if p.is_finite() && *p >= 0.0 => {
                let price = (p * 100.0).round() as Cents;
                self.cache.insert(symbol.to_string(),
                    CachedMark { price, as_of: pass, misses: 0 });
                MarkOutcome::Fresh(price)
            }
            _ => match self.cache.get_mut(symbol) {
                Some(m) => {
                    m.misses += 1;
                    if m.misses > self.retry_budget {
                        self.cache.remove(symbol);
                        MarkOutcome::Degraded
                    } else {
                        MarkOutcome::Stale { price: m.price, misses: m.misses }
                    }
                }
                None => MarkOutcome::Degraded, // nothing good to keep
            },
        }
    }
}
```

ASSUMPTIONS (all invented):
1. Retry window is counted in consecutive settle-pass read-backs, not wall-clock. Chose count over duration because "bounded retry window" pairs with a discrete read-back loop; a `Duration`-based variant would swap `misses: u32` for `first_miss_at: Instant`.
2. Default budget 3; `retry_budget = 0` is clamped to 1 (at least one retry must exist for the requirement to be non-vacuous).
3. `misses > budget` (strictly) degrades, so budget N yields N stale-serving passes then degrade on N+1. Boundary chosen so "past the retry window" means exceeding it, not reaching it.
4. Non-numeric strings are not distinguished: `#N/A`, `Loading...`, `#ERROR!`, empty, and unparseable all take the transient path. The EARS names only two; treating all non-numeric alike is the conservative read since a hard `#ERROR!` is indistinguishable from transient at read-back.
5. A symbol with no prior good mark degrades immediately — no cached mark exists to keep, so the retry window is not applicable. (Alternative read: retry first-ever symbols too; rejected because the requirement's action is "keep the prior good cached mark", which presupposes one.)
6. Degrading evicts the cache entry, so recovery restarts the window cleanly.
7. Any numeric read resets `misses` to 0.
8. Negative or non-finite prices are treated as non-numeric (transient path), not as valid marks.
9. Cents conversion is `round()` at 2 dp; caller supplies already-parsed `f64` — locale/currency-symbol parsing of the raw cell lives upstream.
10. Cache is in-memory per run and not persisted across process restarts; a restart therefore has no prior good mark (see 5).
11. Staleness is not age-capped beyond the retry budget, and `as_of` is recorded for downstream display but not enforced here.
12. Single-threaded settle pass; no interior mutability or locking.
13. Emitting the degraded record to the view/audit log is the caller's job — this module only classifies.