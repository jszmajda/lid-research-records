```rust
use tokio::sync::mpsc;
use tokio::time::{interval, Duration};

enum PublishCommand {
    Republish,
}

pub struct PublishLoop {
    command_rx: mpsc::Receiver<PublishCommand>,
    ledger: Ledger,
    sheets_view: SheetsView,
    mark_refresh_interval: Duration,
}

impl PublishLoop {
    pub fn new(
        ledger: Ledger,
        sheets_view: SheetsView,
        mark_refresh_interval: Duration,
    ) -> (Self, mpsc::Sender<PublishCommand>) {
        let (tx, rx) = mpsc::channel(100);
        (
            Self {
                command_rx: rx,
                ledger,
                sheets_view,
                mark_refresh_interval,
            },
            tx,
        )
    }

    pub async fn run(&mut self) {
        let mut mark_refresh_timer = interval(self.mark_refresh_interval);
        
        loop {
            tokio::select! {
                Some(cmd) = self.command_rx.recv() => {
                    match cmd {
                        PublishCommand::Republish => {
                            if let Err(e) = self.republish().await {
                                eprintln!("Republish failed: {}", e);
                            }
                        }
                    }
                }
                
                _ = mark_refresh_timer.tick() => {
                    if let Err(e) = self.mark_refresh().await {
                        eprintln!("Mark refresh failed: {}", e);
                    }
                }
            }
        }
    }

    async fn republish(&mut self) -> Result<(), Box<dyn std::error::Error>> {
        let view = self.ledger.compute_view()?;
        self.sheets_view.publish(view).await?;
        Ok(())
    }

    async fn mark_refresh(&mut self) -> Result<(), Box<dyn std::error::Error>> {
        self.sheets_view.refresh_marks_from_sheets().await?;
        Ok(())
    }
}

pub fn append_event(
    ledger: &mut Ledger,
    event: Event,
    tx: &mpsc::Sender<PublishCommand>,
) -> Result<(), Box<dyn std::error::Error>> {
    ledger.append(event)?;
    let _ = tx.try_send(PublishCommand::Republish);
    Ok(())
}
```

**Assumptions (EXPLICIT):**

1. **Async runtime**: tokio with `tokio::select!` for serialized, non-blocking multiplexing
2. **Types exist**: `Ledger`, `SheetsView`, `Event` defined elsewhere; `Ledger::compute_view()`, `SheetsView::publish()`, `SheetsView::refresh_marks_from_sheets()` are async methods returning `Result`
3. **Mark-refresh is periodic**: timer-driven on fixed interval (e.g., 30s), not triggered on-demand; "periodic" read from context ("marks refresh" = GOOGLEFINANCE columns updating periodically)
4. **On-demand via channel**: `PublishCommand::Republish` sent by caller after `append_event()` succeeds
5. **Serialization via `tokio::select!`**: single async task, one operation at a time—no concurrent republish or mark-refresh
6. **Error handling**: failures logged, loop continues; no retry or exponential backoff
7. **No bounded republish queue**: channel capacity is 100; overflow drops commands (acceptable if append-driven commands are rare)
8. **Event append is external**: not in loop; caller invokes `append_event()` and loop reacts via channel
9. **Marks are read-back**: `refresh_marks_from_sheets()` fetches updated GOOGLEFINANCE values; republish always uses current marks
10. **Initial mark-refresh deferred**: first refresh happens at timer tick, not startup

**Interpretation Choice:**

"One serialized loop, never concurrently" → single async task with `tokio::select!` multiplexing commands and timer. Alternative (mutex + thread pool) would require explicit locking and reintroduce parallelism risk; `tokio::select!` enforces serial ordering by construction.