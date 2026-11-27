```rust
// Single serialized publish loop: one consumer task owns the Sheets client,
// so republish and mark-refresh can never run concurrently with each other
// or with themselves.

enum LoopMsg {
    Republish(RepublishTrigger),
    MarkRefreshTick,
    Shutdown,
}

enum RepublishTrigger { AfterAppend, OnDemand }

struct PublishLoop {
    rx: mpsc::Receiver<LoopMsg>,
    sheets: SheetsClient,
    kernel: KernelHandle,
}

impl PublishLoop {
    async fn run(mut self) {
        while let Some(msg) = self.rx.recv().await {
            match msg {
                LoopMsg::Republish(trigger) => {
                    if let Err(e) = self.do_republish(trigger).await {
                        tracing::error!(?e, "republish failed");
                    }
                }
                LoopMsg::MarkRefreshTick => {
                    if let Err(e) = self.do_mark_refresh().await {
                        tracing::error!(?e, "mark-refresh failed");
                    }
                }
                LoopMsg::Shutdown => break,
            }
        }
    }

    async fn do_republish(&mut self, _trigger: RepublishTrigger) -> anyhow::Result<()> {
        let views = self.kernel.project_views()?;
        self.sheets.publish_tabs(views).await
    }

    async fn do_mark_refresh(&mut self) -> anyhow::Result<()> {
        let marks = self.sheets.read_back_marks().await?;
        self.kernel.settle_marks(marks)
    }
}

// Producers, all funneling into the same channel:

async fn append_event(tx: &mpsc::Sender<LoopMsg>, kernel: &mut KernelHandle, ev: Event) -> anyhow::Result<()> {
    kernel.append(ev)?; // send only fires on Ok
    let _ = tx.send(LoopMsg::Republish(RepublishTrigger::AfterAppend)).await;
    Ok(())
}

async fn request_republish_on_demand(tx: &mpsc::Sender<LoopMsg>) {
    let _ = tx.send(LoopMsg::Republish(RepublishTrigger::OnDemand)).await;
}

async fn mark_refresh_ticker(tx: mpsc::Sender<LoopMsg>, period: Duration) {
    let mut iv = tokio::time::interval(period);
    loop {
        iv.tick().await;
        if tx.send(LoopMsg::MarkRefreshTick).await.is_err() { break; }
    }
}
```

Assumptions invented (EARS gives only the loop-serialization requirement):

1. Serialization is achieved structurally (single-task consumer of an mpsc channel), not via a mutex around a concurrently-invoked function — no evidence either way in the text.
2. Channel is bounded (backpressure); capacity value itself is invented/unspecified.
3. No coalescing/debouncing of queued republish requests — each trigger produces one queued republish, processed FIFO. Alternative (collapse redundant pending republishes) is plausible but unstated.
4. "successful event append" is interpreted as `kernel.append` returning `Ok`; failed appends never enqueue a republish.
5. "on demand" is modeled as an external caller sending the same `Republish` message type, distinguished only by a `trigger` tag carried for logging/metrics, not for behavior — since the spec doesn't say on-demand should differ in effect.
6. Mark-refresh period/value is not given by this EARS; `period: Duration` is left as an external config input, no default hardcoded here.
7. Failure handling (republish or mark-refresh error) is assumed non-fatal: log and continue the loop rather than exit, since the spec is silent and crashing would break "after each successful append" guarantee for subsequent events.
8. Shutdown/cancellation (`LoopMsg::Shutdown`) is invented for lifecycle completeness; not specified by the requirement.
9. Sheets I/O and kernel projection are treated as fallible async boundary calls; internal money/tax math is explicitly out of scope per the given context and not modeled here.