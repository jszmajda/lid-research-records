```rust
// crates/sheets-view/src/publish.rs
// @spec SHEET-PUB-003

use std::time::Duration;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum ViewState { Fresh, Stale }

#[derive(Debug)]
pub struct ViewStatus {
    pub state: ViewState,
    pub last_good_rev: Option<LogRev>,   // revision the tabs currently show
    pub last_error: Option<String>,
    pub attempts: u32,
    pub next_retry_in: Option<Duration>,
}

pub struct BackoffPolicy { pub base: Duration, pub factor: u32, pub cap: Duration, pub max_attempts: u32 }
impl BackoffPolicy {
    fn delay(&self, attempt: u32) -> Duration {   // attempt is 1-based
        let d = self.base.saturating_mul(self.factor.saturating_pow(attempt.saturating_sub(1)));
        d.min(self.cap)
    }
}

pub trait SheetsClient {
    fn write_tabs(&self, snap: &ViewSnapshot) -> Result<(), PublishError>;
    fn write_banner(&self, text: &str) -> Result<(), PublishError>; // best-effort
}
pub trait Tui { fn set_view_status(&self, s: &ViewStatus); }
pub trait Clock { fn sleep(&self, d: Duration); }

/// Republish `snap`. Takes only `&ViewSnapshot` — no log handle exists in this
/// crate, so "leave the canonical log unaffected" holds structurally.
pub fn republish(
    snap: &ViewSnapshot,
    sheets: &dyn SheetsClient,
    tui: &dyn Tui,
    clock: &dyn Clock,
    policy: &BackoffPolicy,
    status: &mut ViewStatus,
) -> Result<(), PublishError> {
    let mut last: Option<PublishError> = None;
    for attempt in 1..=policy.max_attempts {
        match sheets.write_tabs(snap) {
            Ok(()) => {
                *status = ViewStatus { state: ViewState::Fresh, last_good_rev: Some(snap.rev),
                                       last_error: None, attempts: attempt, next_retry_in: None };
                let _ = sheets.write_banner("");           // clear banner, best-effort
                tui.set_view_status(status);
                return Ok(());
            }
            Err(e) => {
                status.state = ViewState::Stale;           // mark stale on FIRST failure
                status.attempts = attempt;
                status.last_error = Some(e.to_string());
                let more = attempt < policy.max_attempts;
                status.next_retry_in = more.then(|| policy.delay(attempt));
                let _ = sheets.write_banner(&format!(
                    "STALE — last good {:?}; publish failed ({e})",
                    status.last_good_rev));               // errors swallowed: best-effort
                tui.set_view_status(status);              // TUI surfacing is not best-effort
                last = Some(e);
                if more { clock.sleep(status.next_retry_in.unwrap()); }
            }
        }
    }
    status.next_retry_in = None;
    Err(last.expect("max_attempts >= 1"))
}
```

Assumptions invented: (1) `ViewSnapshot`/`LogRev`/`PublishError` types; snapshot is precomputed kernel output, so no accounting math here. (2) Log-safety is enforced by *not passing* a log handle rather than by a rollback — the log is append-only and publish is downstream. (3) Stale is set on the first failure, not after retries exhaust — "mark stale, retry" reads as concurrent, and a user watching mid-retry must see staleness. (4) Backoff: exponential `base * factor^(n-1)`, capped, bounded attempts (defaults 1s/2×/5min/8); no jitter (single-writer, one workbook). (5) Blocking `clock.sleep` retry loop rather than a scheduler; `Clock` injected for tests. (6) Banner write failures are ignored and never abort the loop — that is what "best-effort" means; TUI updates are assumed infallible/local. (7) Every `PublishError` is retried; no permanent/transient split (not stated). (8) `max_attempts == 0` is treated as invalid-by-construction; loop would return the `expect` panic, so callers must pass ≥1. (9) Banner text includes last-good revision so tabs are self-describing when stale. (10) Retries reuse the same snapshot — no re-fetch of live prices mid-retry, keeping the published view internally consistent. (11) Staleness persists in `ViewStatus` across calls; clearing happens only on success. (12) Single-threaded caller; `&mut ViewStatus` rather than a lock.