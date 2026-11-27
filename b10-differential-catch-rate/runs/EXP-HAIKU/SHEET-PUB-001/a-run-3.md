```rust
use tokio::sync::mpsc;
use tokio::time::{interval, Duration};

pub enum PublishTrigger {
    EventAppended,
    OnDemand,
}

pub struct PublishService {
    trigger_rx: mpsc::UnboundedReceiver<PublishTrigger>,
    mark_refresh_interval: Duration,
}

impl PublishService {
    pub async fn run(mut self) {
        let mut mark_tick = interval(self.mark_refresh_interval);
        
        loop {
            tokio::select! {
                Some(trigger) = self.trigger_rx.recv() => {
                    // Republish on event append or on-demand
                    if let Err(e) = self.publish_cycle().await {
                        eprintln!("publish_cycle failed: {e}");
                    }
                }
                _ = mark_tick.tick() => {
                    // Periodic mark-refresh (GOOGLEFINANCE read-back + settle)
                    if let Err(e) = self.publish_cycle().await {
                        eprintln!("periodic mark-refresh failed: {e}");
                    }
                }
            }
        }
    }

    async fn publish_cycle(&self) -> Result<(), PublishError> {
        self.republish().await?;
        self.mark_refresh().await?;
        Ok(())
    }

    async fn republish(&self) -> Result<(), PublishError> {
        // Project kernel output (append-only event log) to Google Sheets tabs
        Ok(())
    }

    async fn mark_refresh(&self) -> Result<(), PublishError> {
        // Read GOOGLEFINANCE column, settle marks, update Sheets
        Ok(())
    }
}

#[derive(Debug)]
pub enum PublishError {
    SheetsApi(String),
    Settlement(String),
}
```

---

**ASSUMPTIONS:**

1. **Serialization method**: `tokio::select!` with single-threaded `.run()` guarantees no concurrent publish/mark-refresh (never spawns tasks).

2. **Trigger channel**: "On demand" is `mpsc::UnboundedReceiver<PublishTrigger>` (caller sends `PublishTrigger::OnDemand` from elsewhere).

3. **Event append triggering**: Append handler calls `trigger_tx.send(PublishTrigger::EventAppended)` after successful append.

4. **Mark-refresh period**: Default 5 min (configurable in struct); fires independently of republish.

5. **Error handling**: Failed operations log and continue (don't halt loop); unclear from EARS whether to cascade or isolate errors.

6. **Serialization interpretation**: Both operations run *in the same cycle* (republish → mark_refresh sequentially) when either triggers; they never overlap.

7. **Semantics of "one serialized loop"**: A single `tokio::select!` loop, not concurrent spawns; operations block each other by design.

8. **Return value**: Errors are swallowed; alternative: return `Result` and let caller handle retries.

**AMBIGUITIES CHOSEN:**

- "On demand" assumed to be event-channel-driven (not HTTP endpoint shown here).
- Whether mark-refresh runs *alone* on tick or *with* republish: chosen "always both in sequence per cycle" as it matches "one serialized loop" most literally.