```rust
// sheets_view/src/settle.rs
use std::time::{Duration, Instant};

#[derive(Debug, Clone, PartialEq)]
pub enum CellState {
    Pending,           // blank / formula not yet evaluated
    Numeric(f64),      // GOOGLEFINANCE resolved to a price
    Error(String),     // terminal sheet error, e.g. "#N/A", "#ERROR!"
}

pub struct CellRef { pub row: u32, pub col: u32 }

pub trait SheetReader {
    fn read_price_cells(&self, refs: &[CellRef]) -> Result<Vec<CellState>, String>;
}

pub struct SettleConfig { pub poll_interval: Duration, pub timeout: Duration }

#[derive(Debug)]
pub enum SettleError {
    Timeout { unresolved: Vec<CellRef> },
    Api(String),
}

/// Separate settle pass: called only after the formula-write call has
/// already returned. Never invoked inline with that write.
pub fn settle_marks(
    reader: &impl SheetReader,
    cells: Vec<CellRef>,
    cfg: &SettleConfig,
) -> Result<Vec<CellState>, SettleError> {
    let start = Instant::now();
    let mut resolved: Vec<Option<CellState>> = vec![None; cells.len()];

    loop {
        let states = reader.read_price_cells(&cells).map_err(SettleError::Api)?;
        for (slot, state) in resolved.iter_mut().zip(states) {
            if slot.is_none() && !matches!(state, CellState::Pending) {
                *slot = Some(state); // numeric or terminal error: settled
            }
        }
        if resolved.iter().all(Option::is_some) {
            return Ok(resolved.into_iter().flatten().collect());
        }
        if start.elapsed() >= cfg.timeout {
            let unresolved = cells.into_iter()
                .zip(resolved)
                .filter(|(_, r)| r.is_none())
                .map(|(c, _)| c)
                .collect();
            return Err(SettleError::Timeout { unresolved });
        }
        std::thread::sleep(cfg.poll_interval);
    }
}
```

Assumptions invented:
1. Cell values classify into `Pending` (blank/unevaluated), `Numeric(f64)`, or terminal `Error(String)`; the sheet's actual value type is abstracted behind `SheetReader`.
2. Any Sheets error string (`#N/A`, `#ERROR!`, `#REF!`, etc.) is treated as terminal on first sighting — no distinction between transient vs. permanent errors, since EARS says "terminally errored" without qualifying which errors self-heal.
3. Numeric zero counts as resolved, not pending — no special-casing.
4. "Bounded timeout" = wall-clock deadline via `Instant`; poll interval and timeout are both caller-supplied config with no hardcoded defaults, since none are specified.
5. Once a cell resolves it is never re-read/re-classified even if a later poll would show it flipping back to pending (race-guard: first resolution wins).
6. On timeout, the function returns which specific cells never settled rather than failing the whole batch silently — a reasonable interpretation of "bounded timeout" absent specified failure semantics.
7. Implementation is synchronous/blocking (`thread::sleep`) for simplicity; the requirement is agnostic to async vs. sync scheduling.
8. "Never inline with the formula write" is enforced structurally — `settle_marks` lives in a separate module/function and is assumed called from a distinct call site after the write call returns, not by any runtime guard inside this code.
9. Price values are raw floats (GOOGLEFINANCE output), not the ledger's integer-Cents type — Cents conversion is assumed to happen downstream, outside this settle pass.