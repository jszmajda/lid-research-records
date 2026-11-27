```rust
// crates/sheets-view/src/marks.rs
// @spec SHEET-MARK-003

use std::collections::HashMap;

pub type Cents = i64;
pub type Symbol = String;

/// Raw text read back from the workbook `Price` column.
#[derive(Debug, Clone)]
pub enum PriceCell {
    Numeric(Cents),
    /// `#N/A`, `Loading...`, `#ERROR!`, empty, or any other non-numeric text.
    NonNumeric(String),
}

#[derive(Debug, Clone)]
pub struct CachedMark {
    pub mark: Cents,
    pub as_of: u64,      // settle-pass sequence number when last good
}

#[derive(Debug, Clone, Default)]
pub struct MarkState {
    pub cached: Option<CachedMark>,
    pub consecutive_non_numeric: u32,
}

#[derive(Debug, PartialEq)]
pub enum MarkOutcome {
    Fresh(Cents),
    /// Prior good mark reused; caller must retry next pass.
    StaleRetry { mark: Cents, attempt: u32 },
    /// Past the retry window, or non-numeric with no prior good mark.
    Degraded { reason: String },
}

pub struct MarkResolver {
    /// Max consecutive non-numeric reads tolerated before degrading.
    pub retry_budget: u32, // default 3
    state: HashMap<Symbol, MarkState>,
}

impl MarkResolver {
    pub fn new(retry_budget: u32) -> Self {
        Self { retry_budget: retry_budget.max(1), state: HashMap::new() }
    }

    pub fn observe(&mut self, sym: &str, cell: PriceCell, pass: u64) -> MarkOutcome {
        let st = self.state.entry(sym.to_string()).or_default();
        match cell {
            PriceCell::Numeric(c) => {
                st.consecutive_non_numeric = 0;
                st.cached = Some(CachedMark { mark: c, as_of: pass });
                MarkOutcome::Fresh(c)
            }
            PriceCell::NonNumeric(text) => {
                st.consecutive_non_numeric += 1;
                let attempt = st.consecutive_non_numeric;
                match (&st.cached, attempt <= self.retry_budget) {
                    (Some(c), true) => MarkOutcome::StaleRetry { mark: c.mark, attempt },
                    (Some(_), false) | (None, _) => {
                        st.cached = None; // no mark published while degraded
                        MarkOutcome::Degraded { reason: text }
                    }
                }
            }
        }
    }
}
```

ASSUMPTIONS (all invented):
1. Retry window is counted in *consecutive settle passes*, not wall-clock; default budget 3. Chosen because the settle pass is the natural tick and is deterministic/testable.
2. "Transient" is not distinguishable at read time — every non-numeric cell (`#N/A`, `Loading...`, `#ERROR!`, blank) enters the retry path identically; the text is retained only for the degraded reason.
3. Prices arrive already normalized to `Cents` by the cell parser; rounding/precision lives upstream.
4. Non-numeric with *no* prior cached mark degrades immediately (no mark exists to keep). Ambiguity: the EARS only covers the has-cache case.
5. On degrade the cache is cleared, so a later recovery publishes a genuinely fresh mark rather than a resurrected stale one.
6. A single numeric read resets the counter fully (no hysteresis / no decay).
7. Staleness age is recorded (`as_of`) but no max-age expiry is enforced — the EARS names only the retry window.
8. State is per-symbol, in-memory, and lives across passes within one publish run; unknown symbols default to empty state.
9. `retry_budget == 0` is clamped to 1, since a zero window would make "retry" meaningless.
10. Retries are driven by the caller re-invoking `observe` on the next pass; this module does not sleep, schedule, or perform I/O.
11. Degraded means "no mark published for that symbol" — the projection layer decides the visible rendering; no accounting or tax math occurs here.