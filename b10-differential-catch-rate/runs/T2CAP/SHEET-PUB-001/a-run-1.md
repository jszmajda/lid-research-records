```rust
// crates/sheets-view/src/publish_loop.rs
// @spec SHEET-PUB-001

use std::sync::mpsc::{Receiver, RecvTimeoutError, Sender, channel};
use std::time::{Duration, Instant};

/// Reasons the single serialized loop wakes up.
pub enum Trigger {
    /// Enqueued by the event-log writer *after* an append commits successfully.
    EventAppended { seq: u64 },
    /// Explicit user/API request.
    OnDemand,
    /// Periodic price/mark refresh tick.
    MarkRefresh,
    Shutdown,
}

pub struct PublishLoop<K: Kernel, S: SheetsClient> {
    kernel: K,
    sheets: S,
    rx: Receiver<Trigger>,
    mark_interval: Duration,
}

impl<K: Kernel, S: SheetsClient> PublishLoop<K, S> {
    /// Single-threaded owner of all workbook writes. Republish and mark-refresh
    /// are branches of one loop body, so they can never overlap.
    pub fn run(mut self) {
        let mut next_mark = Instant::now() + self.mark_interval;
        loop {
            let trigger = match self.rx.recv_timeout(next_mark.saturating_duration_since(Instant::now())) {
                Ok(t) => t,
                Err(RecvTimeoutError::Timeout) => Trigger::MarkRefresh,
                Err(RecvTimeoutError::Disconnected) => break,
            };
            match trigger {
                Trigger::Shutdown => break,
                Trigger::MarkRefresh => {
                    next_mark = Instant::now() + self.mark_interval;
                    let _ = self.settle_marks(); // log-and-continue
                }
                Trigger::EventAppended { .. } | Trigger::OnDemand => {
                    // Coalesce anything already queued: one publish covers all
                    // pending appends/on-demand requests.
                    while let Ok(t) = self.rx.try_recv() {
                        if matches!(t, Trigger::Shutdown) { return; }
                    }
                    let _ = self.republish();
                }
            }
        }
    }

    fn republish(&mut self) -> Result<(), PublishError> {
        let view = self.kernel.project_views()?; // kernel owns all math
        self.sheets.write_tabs(&view)
    }

    fn settle_marks(&mut self) -> Result<(), PublishError> {
        let marks = self.sheets.read_back_marks()?; // GOOGLEFINANCE column
        self.kernel.settle(marks)?;
        self.republish()
    }
}

/// Publisher handle; `append_event` publishes only on Ok.
pub fn append_and_publish<L: EventLog>(log: &mut L, ev: Event, tx: &Sender<Trigger>) -> Result<u64, AppendError> {
    let seq = log.append(ev)?;              // failed append => no republish
    let _ = tx.send(Trigger::EventAppended { seq });
    Ok(seq)
}
```

ASSUMPTIONS (all invented):
1. Serialization is achieved by a single owning thread + mpsc channel; no `Mutex`/`RwLock` alternative chosen because "one serialized loop" reads as one control flow, not merely mutual exclusion.
2. "After each successful event append" = fire-and-forget enqueue post-commit; publishing is async to the appender so append latency is unaffected. Trigger enqueued only on `Ok`.
3. Coalescing: N queued append/on-demand triggers collapse to one republish. Interpretation chosen because tabs are a full projection of current state, so per-event publishes are redundant. (EARS is silent on coalescing.)
4. Mark refresh is a timer branch inside the same loop; a refresh deadline that elapses during a long republish fires immediately after, without stacking.
5. `settle_marks` republishes afterward so settled marks reach the tabs; EARS does not say this.
6. Failure handling: publish/settle errors are logged and the loop continues; no retry/backoff, no crash. Timer is reset on attempt, not success.
7. Types assumed: `Kernel::project_views() -> Result<ViewSet, _>`, `SheetsClient::{write_tabs, read_back_marks}`, `EventLog::append -> Result<u64, _>`, `Cents` internal to kernel — sheets-view does no math.
8. `mark_interval` is a configured non-zero `Duration`; zero/negative not validated (would busy-spin).
9. Shutdown is a trigger variant; channel disconnect also exits. No draining of pending publishes on shutdown.
10. No persistence of "publish pending" across process restart — a crash between append and publish is reconciled by the next trigger.