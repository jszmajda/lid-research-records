```rust
/// Single-consumer loop: all publish-affecting work funnels through one
/// channel so republish and mark-refresh never run concurrently.
enum PublishTrigger {
    EventAppended,
    OnDemand(tokio::sync::oneshot::Sender<Result<(), PublishError>>),
    MarkRefreshTick,
}

async fn run_publish_loop(
    mut triggers: tokio::sync::mpsc::UnboundedReceiver<PublishTrigger>,
    kernel: Arc<Kernel>,
    sheets: Arc<SheetsClient>,
) {
    while let Some(trigger) = triggers.recv().await {
        let result = match trigger {
            PublishTrigger::EventAppended => republish(&kernel, &sheets).await,
            PublishTrigger::MarkRefreshTick => {
                refresh_marks(&kernel, &sheets).await.and(republish(&kernel, &sheets).await)
            }
            PublishTrigger::OnDemand(ack) => {
                let r = republish(&kernel, &sheets).await;
                let _ = ack.send(r.clone());
                r
            }
        };
        if let Err(e) = result {
            tracing::error!(?e, "publish cycle failed; loop continues");
        }
    }
}

// Periodic timer is a separate producer feeding the same channel — it does
// NOT run its own loop, preserving single-loop serialization.
async fn drive_mark_refresh_timer(
    tx: tokio::sync::mpsc::UnboundedSender<PublishTrigger>,
    period: std::time::Duration,
) {
    let mut tick = tokio::time::interval(period);
    loop {
        tick.tick().await;
        if tx.send(PublishTrigger::MarkRefreshTick).is_err() {
            break;
        }
    }
}
```

Assumptions:
1. `republish` and `refresh_marks` are pre-existing async fns (kernel→sheets projection, marks read-back settle) returning `Result<(), PublishError>`; this sketch orchestrates only.
2. "One serialized loop" = single-consumer channel loop, not a mutex guarding concurrent tasks — chosen because it's the simplest construct that structurally forbids concurrency (no lock contention path exists).
3. Republish fires only after a *successful* append (event-append trigger is only sent by the caller on success; failed appends never enqueue).
4. On-demand requests use a oneshot ack so callers can await completion; fire-and-forget on-demand is not assumed adequate.
5. Mark-refresh always runs immediately before its follow-up republish (refresh then publish), since refreshed marks should appear in the same cycle.
6. Failures log and the loop continues (crash-only-on-panic); no requirement text implies the whole service should die on one bad publish.
7. Unbounded channel chosen over bounded+coalescing since correctness (never-concurrent) doesn't require dropping/merging triggers; backpressure/coalescing is an efficiency concern out of scope for this EARS.
8. Mark-refresh period value is unspecified — treated as an external config `Duration`, not hardcoded.
9. Loop exit = channel closed (all senders dropped), used as the shutdown signal; no explicit shutdown trigger was specified.