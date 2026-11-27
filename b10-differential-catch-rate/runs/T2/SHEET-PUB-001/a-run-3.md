```rust
use tokio::sync::mpsc;
use tokio::time::{interval, Duration};

/// What woke the serialized loop.
enum Trigger {
    AfterAppend,
    OnDemand,
    MarkRefreshTick,
}

#[derive(Clone)]
pub struct Publisher {
    tx: mpsc::Sender<Trigger>,
}

impl Publisher {
    /// Call after a successful event-log append.
    pub fn notify_append(&self) {
        let _ = self.tx.try_send(Trigger::AfterAppend);
    }
    /// Call for an explicit user-initiated republish.
    pub fn request_on_demand(&self) {
        let _ = self.tx.try_send(Trigger::OnDemand);
    }
}

/// Spawns the ONE loop that owns all publishing. Caller must not spawn more
/// than one; there is no lock guarding concurrent instances.
pub fn spawn(mark_refresh_period: Duration) -> Publisher {
    let (tx, mut rx) = mpsc::channel::<Trigger>(1); // capacity 1: coalesces bursts
    let ticker_tx = tx.clone();

    tokio::spawn(async move {
        let mut ticker = interval(mark_refresh_period);
        loop {
            tokio::select! {
                _ = ticker.tick() => { let _ = ticker_tx.try_send(Trigger::MarkRefreshTick); }
                msg = rx.recv() => {
                    match msg {
                        Some(Trigger::AfterAppend | Trigger::OnDemand) => republish().await,
                        Some(Trigger::MarkRefreshTick) => {
                            mark_refresh_settle().await;
                            republish().await; // settle changes ledger state, so it publishes too
                        }
                        None => break,
                    }
                }
            }
        }
    });

    Publisher { tx }
}

async fn republish() { /* project kernel -> read-only sheet tabs */ }
async fn mark_refresh_settle() { /* read back GOOGLEFINANCE marks, settle */ }
```

Assumptions:
1. "Serialized loop" = a single task consuming one mpsc channel — mutual exclusion by construction (one consumer), not a mutex around parallel spawns.
2. Async runtime is Tokio; not stated in the requirement.
3. Trigger delivery is fire-and-forget signals, not full request/response — callers don't await completion or get errors back.
4. Channel capacity 1 with `try_send`: concurrent/rapid triggers of the same kind coalesce (extra signals silently dropped) rather than queuing unboundedly. This is an invented backpressure policy — requirement doesn't say whether bursts should coalesce, queue, or error.
5. Mark-refresh period is caller-supplied; no default duration is specified in the EARS, so none is hardcoded.
6. On a mark-refresh tick, I assumed settle is followed by a republish (since settling changes ledger state that should reach the sheet) — the EARS only says both run "in one serialized loop," not that one calls the other; this coupling is invented.
7. On-demand and after-append triggers are treated identically (both just call `republish()`) since the EARS doesn't distinguish their handling, only their sources.
8. No retry/backoff on publish failure is specified — errors inside `republish`/`mark_refresh_settle` are assumed handled/logged inside those functions and don't crash the loop; boundary behavior on repeated failure is unspecified and left as a TODO.
9. Shutdown: loop exits when the sender is dropped (`rx.recv()` returns `None`); no explicit shutdown signal was specified.