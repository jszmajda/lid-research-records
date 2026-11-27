```rust
use std::collections::HashMap;
use std::time::{Duration, Instant};

pub type CellRef = String; // e.g. "Holdings!C7"

#[derive(Debug, Clone)]
pub enum Mark {
    Settled(f64),      // numeric GOOGLEFINANCE result (dollars, not Cents)
    Errored(String),   // terminal spreadsheet error text, e.g. "#N/A"
    TimedOut,
}

pub enum CellValue {
    Number(f64),
    Text(String),
    Empty,
}

pub trait SheetReader {
    fn read_cells(&self, cells: &[CellRef]) -> HashMap<CellRef, CellValue>;
}

fn classify(v: &CellValue) -> Option<Mark> {
    match v {
        CellValue::Number(n) => Some(Mark::Settled(*n)),
        CellValue::Text(s) if s.starts_with('#') => Some(Mark::Errored(s.clone())),
        _ => None, // blank / "Loading..." / anything else: still pending
    }
}

/// Separate settle pass. Caller invokes this only after the formula-write
/// step has returned — never inline with it.
pub fn settle_marks(
    reader: &dyn SheetReader,
    price_cells: &[CellRef],
    poll_interval: Duration,
    timeout: Duration,
) -> HashMap<CellRef, Mark> {
    let deadline = Instant::now() + timeout;
    let mut results = HashMap::new();
    let mut pending: Vec<CellRef> = price_cells.to_vec();

    while !pending.is_empty() {
        let values = reader.read_cells(&pending);
        pending.retain(|cell| match values.get(cell).and_then(classify) {
            Some(mark) => { results.insert(cell.clone(), mark); false }
            None => true,
        });
        if pending.is_empty() { break; }
        let now = Instant::now();
        if now >= deadline {
            for cell in pending.drain(..) { results.insert(cell, Mark::TimedOut); }
            break;
        }
        std::thread::sleep(poll_interval.min(deadline - now));
    }
    results
}
```

Assumptions:
1. `CellRef` is an opaque address string; the Sheets client resolves it.
2. GOOGLEFINANCE's numeric result is a raw f64 (dollars); converting to integer Cents is accounting math and left to the kernel/caller, per "sheets-view owns no accounting math."
3. "Numeric or terminally errored" resolved via Google Sheets' convention that error values are text beginning with `#` (`#N/A`, `#ERROR!`, `#REF!`, etc.); any other non-numeric value (blank cell, `"Loading..."`, stale cached text) is treated as still-computing and re-polled.
4. A cell absent from a given `read_cells` response (e.g. transient read hiccup) is treated as still-pending rather than an error, and simply retried next poll.
5. The bounded timeout is a single deadline for the whole settle pass (all cells collectively), not per-cell, since the EARS uses singular "a bounded timeout."
6. On timeout, cells that never resolved are reported as `Mark::TimedOut` rather than aborting the whole pass — partial success is preserved for cells that did settle.
7. Polling is synchronous (blocking `thread::sleep`); an async executor is a valid alternative but out of scope for this sketch.
8. `poll_interval` has no hardcoded default — left as a caller-supplied parameter since the EARS doesn't specify a cadence.
9. Separation from the formula write is enforced structurally: `settle_marks` takes already-written cell references and is a distinct function/call the caller must invoke after write completes, not a step the write function performs itself.
10. Batch reads (`read_cells` taking a slice) are assumed for efficiency; per-cell reads would also satisfy the requirement but aren't precluded either way.