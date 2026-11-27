```rust
use std::time::Duration;
use tokio::sync::{mpsc, oneshot};

#[derive(Debug)]
pub struct PublishError(pub String);

/// Work items the single serialized loop consumes. Republish covers both
/// "after successful append" and "on demand"; MarkRefresh is the periodic tick.
enum PublishRequest {
    Republish { done: Option<oneshot::Sender<Result<(), PublishError>>> },
    MarkRefresh,
}

#[derive(Clone)]
pub struct PublishHandle {
    tx: mpsc::Sender<PublishRequest>,
}

impl PublishHandle {
    /// Fire-and-forget trigger, called right after an event append commits.
    pub async fn notify_appended(&self) {
        let _ = self.tx.send(PublishRequest::Republish { done: None }).await;
    }

    /// On-demand republish; caller awaits completion/error.
    pub async fn republish_now(&self) -> Result<(), PublishError> {
        let (tx, rx) = oneshot::channel();
        self.tx.send(PublishRequest::Republish { done: Some(tx) }).await
            .map_err(|_| PublishError("publish loop closed".into()))?;
        rx.await.map_err(|_| PublishError("publish loop closed".into()))?
    }
}

/// Spawns the one serialized loop. Only this task calls do_republish/
/// do_mark_refresh, so the two operations (and repeats of each) can never
/// overlap — the channel enforces one-at-a-time execution.
pub fn spawn_publish_loop(mark_refresh_interval: Duration) -> PublishHandle {
    let (tx, mut rx) = mpsc::channel::<PublishRequest>(64);
    let tick_tx = tx.clone();

    tokio::spawn(async move {
        let mut ticker = tokio::time::interval(mark_refresh_interval);
        loop {
            ticker.tick().await;
            let _ = tick_tx.send(PublishRequest::MarkRefresh).await;
        }
    });

    tokio::spawn(async move {
        while let Some(req) = rx.recv().await {
            match req {
                PublishRequest::Republish { done } => {
                    let result = do_republish().await;
                    if let Some(d) = done { let _ = d.send(result); }
                }
                PublishRequest::MarkRefresh => { let _ = do_mark_refresh().await; }
            }
        }
    });

    PublishHandle { tx }
}

async fn do_republish() -> Result<(), PublishError> { Ok(()) /* project kernel -> sheet tabs */ }
async fn do_mark_refresh() -> Result<(), PublishError> { Ok(()) /* read GOOGLEFINANCE-settled marks, reconcile */ }
```

Assumptions:
1. Runtime is tokio; "one serialized loop" implemented as a single-consumer mpsc channel so only one task ever executes either operation — this is the chosen reading of "never concurrently" (a mutex around two independently-scheduled tasks was rejected as weaker/racier than single-consumer ownership).
2. Event-append success and on-demand both map to the same `Republish` request; no distinct type since the requirement treats them as the same trigger for the same action.
3. No coalescing/debouncing: a burst of appends queues one `Republish` per call, executed serially in FIFO order. Requirement doesn't ask for merging, so none was added.
4. No priority between `Republish` and `MarkRefresh`; both interleave strictly by channel arrival order.
5. `notify_appended` is fire-and-forget (drops errors) since post-append callers aren't assumed to await; `republish_now` surfaces failure via `PublishError` since on-demand callers likely need to know.
6. The periodic ticker task never calls sheet APIs itself — it only enqueues, so timer jitter can't bypass serialization.
7. Channel bound (64) and `do_republish`/`do_mark_refresh` bodies are placeholders; actual sheets-view/kernel/marks logic is out of scope for this sketch.
8. Loop-closed (channel send/recv failure) is treated as a hard error for on-demand calls, silently dropped for append notifications and mark-refresh ticks.