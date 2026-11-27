```rust
/// SHEET-PUB-001: republish after append + on-demand, and periodic
/// mark-refresh, share one serialized loop — never concurrent.
use tokio::sync::{mpsc, oneshot};
use tokio::time::{interval, Duration};

pub enum Trigger {
    AfterAppend,
    OnDemand(oneshot::Sender<Result<(), PublishError>>),
    MarkRefreshTick,
}

#[derive(Debug)]
pub struct PublishError(pub String);

pub struct PublishLoop {
    rx: mpsc::UnboundedReceiver<Trigger>,
    mark_refresh_period: Duration,
}

impl PublishLoop {
    /// Single consumer task. No `tokio::spawn` per-trigger, so every
    /// republish and every mark-refresh pass runs to completion before
    /// the next is even pulled — serialization is structural, not
    /// mutex-enforced.
    pub async fn run(mut self, kernel: impl SheetsPublisher) {
        let mut ticker = interval(self.mark_refresh_period);
        loop {
            tokio::select! {
                maybe_trigger = self.rx.recv() => {
                    match maybe_trigger {
                        Some(Trigger::AfterAppend) => {
                            let _ = kernel.republish().await;
                        }
                        Some(Trigger::OnDemand(reply)) => {
                            let res = kernel.republish().await;
                            let _ = reply.send(res);
                        }
                        Some(Trigger::MarkRefreshTick) => {
                            let _ = kernel.mark_refresh().await;
                        }
                        None => break, // channel closed: shutdown
                    }
                }
                _ = ticker.tick() => {
                    let _ = kernel.mark_refresh().await;
                }
            }
        }
    }
}

pub trait SheetsPublisher {
    async fn republish(&self) -> Result<(), PublishError>;
    async fn mark_refresh(&self) -> Result<(), PublishError>;
}
```

Assumptions:
1. Long-running async process (tokio); "one serialized loop" realized as a single-consumer `select!` over one channel plus a ticker — no per-trigger spawn — so mutual exclusion is structural, not lock-based.
2. `republish()`/`mark_refresh()` are already-idempotent async ops on a `kernel`/`SheetsPublisher`-like object; their internals (Sheets API calls, projection) are out of scope.
3. "After each successful event append" modeled as an `AfterAppend` message sent by the ledger-append path only on success (failed appends never enqueue).
4. "On demand" modeled with a `oneshot` reply so a caller can await completion/error; fire-and-forget wasn't assumed sufficient since callers likely want confirmation.
5. Mark-refresh period is a caller-supplied `Duration`; no default value specified by the EARS, so none is hardcoded.
6. Errors are swallowed (`let _ =`) and the loop continues — chosen because the spec is about serialization/scheduling, not error policy; a real system would log/metric here.
7. Trigger queue is unbounded; no coalescing of rapid-fire triggers — spec doesn't request debouncing, so triggers process one-by-one in arrival order, potentially redundantly.
8. Loop exits only on channel closure (graceful shutdown); no explicit cancellation token, since not specified.
9. `AfterAppend` and `OnDemand` both map to the same `republish` action — spec doesn't distinguish their payloads.