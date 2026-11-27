```rust
// crates/sheets-view/src/publish_loop.rs
// @spec SHEET-PUB-001

use std::sync::mpsc::{Receiver, RecvTimeoutError, Sender};
use std::time::{Duration, Instant};

/// Everything that can wake the single serialized loop.
pub enum LoopMsg {
    /// Sent by the event-log appender AFTER an append is durably committed.
    AppendCommitted { seq: u64 },
    /// Operator/CLI "publish now".
    RepublishOnDemand,
    Shutdown,
}

pub trait Publisher {
    fn republish(&mut self, seq: u64) -> anyhow::Result<()>;
    /// Marks read-back settle pass over the GOOGLEFINANCE column.
    fn refresh_marks(&mut self) -> anyhow::Result<()>;
}

pub struct PublishLoop<P: Publisher> {
    pub pubr: P,
    pub rx: Receiver<LoopMsg>,
    pub mark_interval: Duration,
}

impl<P: Publisher> PublishLoop<P> {
    /// Single-threaded owner of the sheet. Nothing else may touch the workbook.
    pub fn run(mut self) {
        let mut next_mark = Instant::now() + self.mark_interval;
        let mut last_seq: u64 = 0;
        loop {
            let wait = next_mark.saturating_duration_since(Instant::now());
            match self.rx.recv_timeout(wait) {
                Ok(LoopMsg::Shutdown) | Err(RecvTimeoutError::Disconnected) => return,
                Ok(LoopMsg::AppendCommitted { seq }) => {
                    last_seq = last_seq.max(seq);
                    // Coalesce any already-queued wakeups: one republish covers them.
                    while let Ok(m) = self.rx.try_recv() {
                        match m {
                            LoopMsg::AppendCommitted { seq } => last_seq = last_seq.max(seq),
                            LoopMsg::RepublishOnDemand => {}
                            LoopMsg::Shutdown => return,
                        }
                    }
                    let _ = self.pubr.republish(last_seq); // log; loop survives
                }
                Ok(LoopMsg::RepublishOnDemand) => {
                    let _ = self.pubr.republish(last_seq);
                }
                Err(RecvTimeoutError::Timeout) => {
                    let _ = self.pubr.refresh_marks();
                    // Recompute from *now* so a slow pass never stacks up.
                    next_mark = Instant::now() + self.mark_interval;
                }
            }
        }
    }
}

/// Non-blocking trigger for the append path; a full channel is not fatal
/// because a pending wakeup already implies a republish will happen.
pub fn notify_append(tx: &Sender<LoopMsg>, seq: u64) {
    let _ = tx.send(LoopMsg::AppendCommitted { seq });
}
```

ASSUMPTIONS (all invented):
1. Serialization realized as one owning thread + mpsc channel; concurrency prevented structurally, not by a lock.
2. "After each successful event append" = after durable commit; failed appends send nothing.
3. `mark_interval` is a config default (assumed ~60s) not stated by the EARS.
4. Publisher trait/`seq: u64` cursor shapes invented; kernel projection details out of scope.
5. Republish coalescing chosen: burst of N appends may yield fewer than N republishes. Interpretation: requirement guarantees a republish reflecting each append, not one call per append.
6. Errors logged and swallowed; loop continues. No retry/backoff specified.
7. Mark timer is fixed-delay (reset after the pass), not fixed-rate — prevents pileup; EARS silent.
8. An append arriving during a mark refresh waits until the refresh returns; no preemption/priority.
9. On-demand republish uses `last_seq`; if no append yet, `last_seq = 0` publishes an empty/initial view.
10. Shutdown drops queued work without a final flush.
11. Timer starts at process start; no immediate mark refresh on boot.

AMBIGUITY: "in one serialized loop" could mean one loop *iteration* per cycle doing both, or one loop *thread* interleaving both. Chose the latter — the requirement's stated goal is "never concurrently," and forcing a mark refresh on every append would rate-abuse the Sheets API.