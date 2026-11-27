```rust
use std::sync::{Arc, Mutex};
use chrono::{DateTime, Utc};

/// Freshness state surfaced identically to the in-tab banner and the TUI.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ViewStatus {
    Fresh,
    Stale { since: DateTime<Utc>, reason: StaleReason },
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum StaleReason {
    RepublishFailed,
}

pub struct SheetsView {
    status: Arc<Mutex<ViewStatus>>,
}

impl SheetsView {
    /// Called once per sync tick. Reads kernel-projected rows only; has no
    /// handle to the event log, so a failure here structurally cannot touch
    /// the canonical log.
    pub fn republish(&self, rows: &ProjectedRows) -> ViewStatus {
        match self.push_tabs(rows) {
            Ok(()) => {
                *self.status.lock().unwrap() = ViewStatus::Fresh;
                ViewStatus::Fresh
            }
            Err(e) => {
                let stale = ViewStatus::Stale { since: Utc::now(), reason: StaleReason::RepublishFailed };
                *self.status.lock().unwrap() = stale;
                if let Err(banner_err) = self.write_stale_banner(stale) {
                    log::warn!("stale banner write failed (best-effort, ignored): {banner_err}");
                }
                log::warn!("republish failed, view marked stale, will retry next sync: {e}");
                stale
            }
        }
    }

    fn push_tabs(&self, _rows: &ProjectedRows) -> Result<(), PublishError> { unimplemented!() }
    fn write_stale_banner(&self, _s: ViewStatus) -> Result<(), PublishError> { unimplemented!() }

    /// Polled by the TUI render loop.
    pub fn tui_status(&self) -> ViewStatus {
        *self.status.lock().unwrap()
    }
}

/// Normal sync loop — retry is just "call again next tick"; no dedicated
/// backoff/retry scheduler is introduced.
pub fn sync_tick(view: &SheetsView, rows: &ProjectedRows) {
    let _ = view.republish(rows);
}

pub struct ProjectedRows;
#[derive(Debug)]
pub struct PublishError(pub String);
impl std::fmt::Display for PublishError { fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result { write!(f, "{}", self.0) } }
```

Assumptions:
1. "Canonical log unaffected" satisfied by construction (republish has no write path to the log), not by rollback/transaction logic — no error in publishing can reach the ledger.
2. "Retry on the next sync" = passive: the existing sync loop simply calls `republish` again next tick; no new backoff/scheduler/max-retry count invented.
3. Stale status is in-memory (`Arc<Mutex<ViewStatus>>`), not persisted — acceptable since it describes a live view, not canonical state; a process restart resets to `Fresh` until the next failure.
4. "Best-effort" banner = failure to write the banner is logged and swallowed, never escalated, never blocks status update or the next retry.
5. TUI surfacing modeled as a poll accessor (`tui_status`), not a push/event bus — no notification mechanism assumed.
6. All republish failures treated uniformly (single `StaleReason::RepublishFailed`); EARS gives no failure-kind discriminator, so none is invented.
7. Concurrency: `Mutex` chosen arbitrarily since banner-writer and TUI-reader may be different threads; not mandated by the EARS.
8. `ProjectedRows`/`PublishError` are stubs standing in for real sheets-view/kernel types.