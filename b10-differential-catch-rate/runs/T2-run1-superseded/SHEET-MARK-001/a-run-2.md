```rust
use std::collections::{BTreeMap, HashSet};
use std::time::{Duration, Instant};
use std::thread;

pub type Cents = i64;
pub type RowId = u32;

/// One `Price` cell's observed state on a settle-pass poll.
pub enum CellState {
    Numeric(Cents),   // GOOGLEFINANCE resolved; converted to integer cents
    Error(String),    // terminal sheet error, e.g. "#N/A", "#ERROR!"
    Pending,          // still computing / blank
}

pub enum MarkResult {
    Settled(Cents),
    TerminalError(String),
    TimedOut,
}

pub trait SheetReader {
    fn read_price_cell(&self, row: RowId) -> CellState;
}

/// Runs only after the formula-write call has returned — never called inline
/// with it. Polls each row's `Price` cell until numeric, terminally errored,
/// or the shared deadline elapses.
pub fn settle_marks(
    sheets: &impl SheetReader,
    rows: &[RowId],
    poll_interval: Duration,
    timeout: Duration,
) -> BTreeMap<RowId, MarkResult> {
    let deadline = Instant::now() + timeout;
    let mut pending: HashSet<RowId> = rows.iter().copied().collect();
    let mut results = BTreeMap::new();

    while !pending.is_empty() && Instant::now() < deadline {
        let mut done = Vec::new();
        for &row in &pending {
            match sheets.read_price_cell(row) {
                CellState::Numeric(c) => { results.insert(row, MarkResult::Settled(c)); done.push(row); }
                CellState::Error(e)   => { results.insert(row, MarkResult::TerminalError(e)); done.push(row); }
                CellState::Pending    => {}
            }
        }
        done.into_iter().for_each(|r| { pending.remove(&r); });
        if !pending.is_empty() { thread::sleep(poll_interval); }
    }
    pending.into_iter().for_each(|r| { results.insert(r, MarkResult::TimedOut); });
    results
}
```

Assumptions:
1. `Cents` = `i64`; float price from GOOGLEFINANCE rounded to nearest cent by the reader impl, not shown here.
2. `RowId` is an opaque row/handle type; actual sheet range addressing lives in `SheetReader`.
3. Single shared timeout/deadline across all rows (requirement says "a bounded timeout," singular), not one per cell.
4. Any `#`-prefixed cell string (`#N/A`, `#ERROR!`, `#REF!`) is treated as terminal, not retried — chosen because GOOGLEFINANCE errors for a bad/delisted ticker don't self-resolve.
5. Blank or non-numeric/non-error content = `Pending`, keeps polling.
6. Transport/API read failures aren't modeled as terminal; treated as a no-op poll tick (implicitly retried) until timeout — no separate retry-count cap, since none was specified.
7. Rows still `Pending` at deadline become `TimedOut`, distinct from `TerminalError`, since the spec separates "numeric or terminally errored" from timeout.
8. Synchronous/blocking poll loop (`thread::sleep`) chosen over async for sketch simplicity; interpretation, not a requirement constraint.
9. Poll interval isn't specified by the EARS — left as a caller-supplied parameter rather than a hardcoded default.
10. Enforcement of "never inline" is structural only (separate function called after write returns); no runtime guard against a caller misusing it inline.