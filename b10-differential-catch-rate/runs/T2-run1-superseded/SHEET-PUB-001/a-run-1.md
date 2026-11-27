```rust
/// SHEET-PUB-001: single serialized loop drives both republish and
/// periodic mark-refresh; no two jobs ever execute concurrently.

enum Job {
    Republish,          // triggered by event-append or on-demand request
    MarkRefresh,         // triggered by the periodic timer
}

struct PublishLoop {
    jobs: tokio::sync::mpsc::Receiver<Job>,
    sheets: SheetsClient,
    ledger: LedgerHandle,
}

impl PublishLoop {
    /// The one serialized loop. Jobs are processed strictly one at a time
    /// in receive order — this is what makes republish and mark-refresh
    /// mutually exclusive without a mutex.
    async fn run(mut self) {
        while let Some(job) = self.jobs.recv().await {
            let result = match job {
                Job::Republish => self.sheets.republish(&self.ledger).await,
                Job::MarkRefresh => {
                    // settle pass: read back marks, then republish so the
                    // refreshed marks are reflected in the same pass.
                    self.ledger.settle_marks().await
                        .and_then(|_| self.sheets.republish(&self.ledger))
                }
            };
            if let Err(e) = result {
                tracing::error!(?e, "publish job failed; loop continues");
            }
        }
    }
}

/// Producers — all just enqueue; they never touch sheets/ledger directly.
fn on_event_appended(tx: &tokio::sync::mpsc::Sender<Job>) {
    let _ = tx.try_send(Job::Republish); // dedupe: drop if one is already queued
}
fn on_demand_republish(tx: &tokio::sync::mpsc::Sender<Job>) {
    let _ = tx.try_send(Job::Republish);
}
fn spawn_periodic_mark_refresh(tx: tokio::sync::mpsc::Sender<Job>, period: std::time::Duration) {
    tokio::spawn(async move {
        let mut tick = tokio::time::interval(period);
        loop {
            tick.tick().await;
            let _ = tx.try_send(Job::MarkRefresh);
        }
    });
}
```

Assumptions:
1. "Successful event append" = the append call returns `Ok`; only that path enqueues a republish, not failed appends.
2. "On demand" = an external trigger (CLI/API) modeled as another producer into the same channel — its exact interface is unspecified so I left it abstract.
3. Serialization is implemented as a single-consumer actor loop (one task owns `SheetsClient`/`LedgerHandle`), not a mutex around concurrent tasks — this is the natural reading of "one serialized loop."
4. Mark-refresh period/interval is unspecified; modeled as an injected `Duration` with no default chosen here.
5. Assumed mark-refresh's "settle pass" implies a republish afterward too, since refreshed marks must reach the sheet — EARS doesn't explicitly say this, but leaving marks refreshed-but-unpublished seemed inconsistent with the doc's intent.
6. Used `try_send` on a small bounded channel to coalesce bursts (e.g., many rapid appends collapse to one pending republish) rather than queuing every trigger — EARS doesn't specify backpressure/dedup behavior, so this is invented.
7. On job failure, the loop logs and continues rather than terminating — failure/retry behavior is unstated in the EARS.
8. No distinction made between "republish" and "mark-refresh" sheet-writing mechanics themselves (out of scope per the requirement, which only governs scheduling/exclusivity).