```rust
//! sheets-view: republish loop (SHEET-PUB-001)

use std::sync::mpsc::{Receiver, RecvTimeoutError, SyncSender};
use std::time::{Duration, Instant};

/// Why the loop woke up.
pub enum Trigger {
    /// Emitted by the kernel *after* an append is durably committed.
    EventAppended { seq: u64 },
    /// Operator/CLI request.
    OnDemand,
    Shutdown,
}

pub struct Publisher<K, S> {
    kernel: K,               // read-only projection source
    sheets: S,               // Google Sheets client
    mark_interval: Duration, // periodic mark-refresh cadence
}

pub trait Kernel { fn project(&self) -> Result<ViewSet, Error>; }
pub trait Sheets {
    fn write_tabs(&self, v: &ViewSet) -> Result<(), Error>;
    /// Reads back the GOOGLEFINANCE column; feeds the marks settle pass.
    fn read_marks(&self) -> Result<Marks, Error>;
}

impl<K: Kernel, S: Sheets> Publisher<K, S> {
    /// Single-threaded owner of all Sheets writes. Republish and
    /// mark-refresh are branches of one loop, so they cannot interleave.
    pub fn run(&mut self, rx: Receiver<Trigger>) {
        let mut next_mark = Instant::now() + self.mark_interval;
        loop {
            let wait = next_mark.saturating_duration_since(Instant::now());
            match rx.recv_timeout(wait) {
                Ok(Trigger::Shutdown) => return,
                Ok(_) => {
                    // Coalesce: drain any triggers queued behind this one.
                    while let Ok(t) = rx.try_recv() {
                        if matches!(t, Trigger::Shutdown) { return; }
                    }
                    let _ = self.republish();
                }
                Err(RecvTimeoutError::Timeout) => {
                    let _ = self.refresh_marks();
                    next_mark = Instant::now() + self.mark_interval;
                }
                Err(RecvTimeoutError::Disconnected) => return,
            }
        }
    }

    fn republish(&mut self) -> Result<(), Error> {
        let views = self.kernel.project()?;
        self.sheets.write_tabs(&views)
    }

    fn refresh_marks(&mut self) -> Result<(), Error> {
        let marks = self.sheets.read_marks()?;
        let views = self.kernel.project_with_marks(&marks)?;
        self.sheets.write_tabs(&views)
    }
}
```

ASSUMPTIONS INVENTED

1. Serialization mechanism: a single owning thread + `mpsc` channel. The requirement says "one serialized loop"; I chose a thread-per-publisher over a mutex because a mutex permits concurrent *entry* attempts and unbounded queueing, while a loop structurally cannot overlap.
2. "After each successful event append" = the appender sends `EventAppended` post-commit; publishing is asynchronous/decoupled, not inline in the append call. Interpretation chosen so a Sheets outage cannot block the append path (append-only log is the source of truth).
3. Trigger coalescing: N triggers arriving during one republish collapse to one subsequent republish (last-writer-wins semantics; views are full snapshots, not deltas). Not stated in the EARS.
4. Errors are swallowed (`let _ =`) and the loop continues; no retry/backoff specified. Real impl needs a logged retry policy.
5. Mark-refresh cadence is a fixed `Duration` config; no default value implied by the EARS.
6. Mark-refresh timer is reset after each refresh, not on republish — so a busy append stream can starve marks up to `mark_interval`+republish duration. Alternative (deadline-preserving) is defensible.
7. `ViewSet`, `Marks`, `Error`, `Cents` shapes invented; `project_with_marks` assumed on `Kernel` (the settle pass feeds read-back prices back into projection).
8. Shutdown trigger and `Disconnected` termination invented; the EARS says nothing about lifecycle.
9. Assumed a single workbook / single publisher instance — the "never concurrently" guarantee holds only within one process.

AMBIGUITY: "republish ... on demand" does not say whether an on-demand republish also settles marks. I treated them as distinct branches (republish = project+write; mark-refresh = read-back+settle+write), since the EARS names them as two things in one loop.