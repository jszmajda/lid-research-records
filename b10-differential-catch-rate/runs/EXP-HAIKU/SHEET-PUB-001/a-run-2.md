```rust
use tokio::sync::mpsc;

/// Manages serialized republish and mark-refresh operations.
/// Ensures republish + mark_refresh run atomically in sequence,
/// triggered by event append success or on-demand request.
pub struct PublishLoop {
    tx: mpsc::UnboundedSender<PublishCommand>,
}

#[derive(Debug)]
enum PublishCommand {
    EventAppended,
    OnDemand,
}

impl PublishLoop {
    pub fn new() -> Self {
        let (tx, mut rx) = mpsc::unbounded_channel::<PublishCommand>();

        tokio::spawn(async move {
            while let Some(cmd) = rx.recv().await {
                // Single-threaded loop: commands serialized, never concurrent
                Self::republish().await;
                Self::mark_refresh().await;
            }
        });

        PublishLoop { tx }
    }

    /// Signal that an event append succeeded; triggers republish cycle
    pub fn trigger_append_success(&self) {
        let _ = self.tx.send(PublishCommand::EventAppended);
    }

    /// Signal an on-demand republish request
    pub fn trigger_on_demand(&self) {
        let _ = self.tx.send(PublishCommand::OnDemand);
    }

    async fn republish() {
        // Project kernel state → Google Sheets tabs
    }

    async fn mark_refresh() {
        // Refresh marks (prices) via GOOGLEFINANCE oracle
    }
}
```

**Assumptions:**

1. **Async context** — `tokio` runtime; operations are async.
2. **Trigger coalescence** — Multiple commands queued before loop iteration (e.g., rapid appends) coalesce into one cycle; EARS does not forbid this, and batching improves throughput.
3. **No backpressure** — `UnboundedSender::send()` cannot fail; callers fire-and-forget. If unbounded queue risk is unacceptable, swap `mpsc::channel(N)` with backpressure handling.
4. **No error propagation** — Failures in `republish()` or `mark_refresh()` do not cascade or halt the loop; callers must handle via logging inside those functions.
5. **No graceful shutdown** — Loop runs indefinitely. Add `Option<mpsc::UnboundedReceiver>` ownership and shutdown signal for production.
6. **Mark-refresh is fast relative to append rate** — "Periodic" in EARS is satisfied by running after every republish cycle, not by independent timer.
7. **Republish is idempotent** — Safe to call on every trigger; overwrite (not append) sheets tabs.
8. **Single kernel instance** — `Self::` statics assume shared state; or pass `&self` if `PublishLoop` holds kernel reference.

**Ambiguity / Interpretation:**
- "Periodic mark-refresh" could mean time-driven, but EARS couples it to republish in one loop. I interpret as: run mark-refresh after every republish, not independently on a timer.
- "On demand" source (HTTP endpoint, CLI, internal) is unspecified; I assume callers invoke `trigger_on_demand()` directly.