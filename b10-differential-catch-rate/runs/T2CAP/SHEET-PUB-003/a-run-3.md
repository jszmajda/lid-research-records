```rust
//! sheets-view :: republish failure handling. @spec SHEET-PUB-003
use std::time::Duration;

pub struct ViewId(pub String);

#[derive(Clone, Copy, PartialEq)]
pub enum ViewState { Fresh, Stale { attempts: u32 } }

pub struct PublishError(pub String);

pub trait SheetsClient {
    fn republish(&self, view: &ViewId) -> Result<(), PublishError>;
    /// Best-effort: writes a banner row into the tab. Failure is swallowed.
    fn write_banner(&self, view: &ViewId, text: &str) -> Result<(), PublishError>;
}

pub trait TuiSink { fn set_staleness(&self, view: &ViewId, msg: Option<String>); }

pub struct BackoffPolicy { pub base: Duration, pub factor: u32, pub cap: Duration, pub max_attempts: Option<u32> }

impl BackoffPolicy {
    pub fn default_policy() -> Self {
        Self { base: Duration::from_secs(1), factor: 2, cap: Duration::from_secs(300), max_attempts: None }
    }
    /// attempt is 1-based; saturating so no overflow/panic at large attempt counts.
    pub fn delay(&self, attempt: u32) -> Duration {
        let mult = self.factor.saturating_pow(attempt.saturating_sub(1).min(32));
        self.base.saturating_mul(mult).min(self.cap)
    }
}

pub struct Republisher<C: SheetsClient, T: TuiSink> {
    pub client: C, pub tui: T, pub policy: BackoffPolicy,
}

impl<C: SheetsClient, T: TuiSink> Republisher<C, T> {
    /// Pure decision step: no log/ledger handle is taken here, so the canonical
    /// log is structurally unaffected by any failure path.
    pub fn attempt(&self, view: &ViewId, state: ViewState) -> (ViewState, Option<Duration>) {
        match self.client.republish(view) {
            Ok(()) => { self.tui.set_staleness(view, None); (ViewState::Fresh, None) }
            Err(e) => {
                let attempts = match state { ViewState::Stale { attempts } => attempts.saturating_add(1), _ => 1 };
                let msg = format!("STALE: last republish failed ({}) — attempt {}", e.0, attempts);
                let _ = self.client.write_banner(view, &msg); // best-effort
                self.tui.set_staleness(view, Some(msg));
                let next = match self.policy.max_attempts {
                    Some(m) if attempts >= m => None,
                    _ => Some(self.policy.delay(attempts)),
                };
                (ViewState::Stale { attempts }, next)
            }
        }
    }
}
```

Assumptions invented:
1. "Canonical log unaffected" is satisfied structurally — the publisher is given no write handle to the event log — rather than by a rollback/compensation step. Chose this because the log is append-only and publishing is downstream projection.
2. Failure is any `Err` from the Sheets API; no distinction between transient (429/5xx) and permanent (auth/404) errors. Permanent errors still retry under the same schedule.
3. Backoff defaults: 1s base, factor 2, 300s cap, unbounded attempts (never gives up; staleness persists). No jitter.
4. Retry is scheduled, not slept-in-place — `attempt` returns the delay so the caller's scheduler owns timing (testable, non-blocking).
5. Staleness is per-view (per-tab), not workbook-global; `attempts` counter lives in view state and resets on success.
6. Banner is "best-effort": banner write failure is swallowed and does not itself trigger retry or alter state. Banner is a text row in the tab; no cell-range detail specified.
7. TUI surfacing is a synchronous sink call assumed infallible (in-process).
8. Ambiguity: whether the banner/TUI update happens on every failed attempt or only on the first transition to stale. Chose every attempt, so the surfaced message carries the current attempt count.
9. Overflow edge: exponent clamped at 32 and saturating arithmetic, so long outage streaks cannot panic or wrap.
10. No concurrency control; caller serializes attempts per view.