```rust
// crates/sheets-view/src/publish.rs
// @spec SHEET-PUB-003

use std::time::Duration;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ViewFreshness { Fresh, Stale }

#[derive(Debug)]
pub struct PublishError { pub attempt: u32, pub detail: String, pub retryable: bool }

#[derive(Debug, Clone)]
pub struct BackoffPolicy { pub base: Duration, pub factor: u32, pub max_delay: Duration, pub max_attempts: u32 }

impl Default for BackoffPolicy {
    fn default() -> Self {
        Self { base: Duration::from_secs(1), factor: 2, max_delay: Duration::from_secs(300), max_attempts: 6 }
    }
}

impl BackoffPolicy {
    /// Attempt n (1-based) waits base * factor^(n-1), clamped to max_delay.
    pub fn delay_for(&self, attempt: u32) -> Duration {
        let mult = self.factor.saturating_pow(attempt.saturating_sub(1));
        self.base.saturating_mul(mult).min(self.max_delay)
    }
}

pub trait SheetsClient { fn republish(&self, view: &ViewSnapshot) -> Result<(), PublishError>; 
    /// Best-effort: banner failure is swallowed, never escalated.
    fn write_banner(&self, tab: &str, text: &str) -> Result<(), PublishError>; }
pub trait StaleSink { fn mark_stale(&self, view: &ViewId, reason: &str); fn mark_fresh(&self, view: &ViewId); }
pub trait Clock { fn sleep(&self, d: Duration); }

pub struct Publisher<C, S, K> { pub sheets: C, pub tui: S, pub clock: K, pub policy: BackoffPolicy }

impl<C: SheetsClient, S: StaleSink, K: Clock> Publisher<C, S, K> {
    /// Takes &ViewSnapshot only — no log handle in scope, so the canonical
    /// log is structurally unaffected by any failure path.
    pub fn republish(&self, id: &ViewId, snap: &ViewSnapshot) -> Result<(), PublishError> {
        let mut last: Option<PublishError> = None;
        for attempt in 1..=self.policy.max_attempts {
            match self.sheets.republish(snap) {
                Ok(()) => { self.tui.mark_fresh(id); return Ok(()); }
                Err(e) => {
                    let fatal = !e.retryable;
                    let reason = format!("republish attempt {attempt} failed: {}", e.detail);
                    self.tui.mark_stale(id, &reason);                       // TUI surface
                    let _ = self.sheets.write_banner(&snap.tab, &reason);    // best-effort banner
                    last = Some(e);
                    if fatal || attempt == self.policy.max_attempts { break; }
                    self.clock.sleep(self.policy.delay_for(attempt));
                }
            }
        }
        Err(last.expect("loop runs >= 1 attempt"))
    }
}
```

ASSUMPTIONS (all invented):
1. Types `ViewId`, `ViewSnapshot { tab: String, .. }` exist in kernel output; snapshot is precomputed, so retries republish identical bytes (idempotent, no kernel/Cents math here).
2. "Leave canonical log unaffected" implemented structurally: publisher never receives a writable log handle. No compensating write, no rollback.
3. Backoff defaults 1s base, ×2, cap 300s, 6 attempts; no jitter (single-user tool, no thundering herd).
4. Retries are in-process and synchronous via injected `Clock`; no persistence of the retry schedule across restarts. On restart, view is presumed stale until a successful publish.
5. `max_attempts` exhaustion leaves the view stale permanently and returns Err; the caller (scheduler) decides re-entry.
6. Non-retryable errors (auth, bad tab) break immediately but still mark stale + banner.
7. Banner is "best-effort": its own failure is discarded (`let _`), never retried, never masks the underlying error. It writes to the same tab that failed — accepted as likely-futile in a total-outage case.
8. Stale is marked on every failed attempt (idempotent set), not only at exhaustion, so the TUI shows staleness during the retry window rather than after it.
9. TUI surfacing = `StaleSink` observer; assumed non-blocking and infallible.
10. `mark_fresh` on success is inferred, not stated by the EARS.

AMBIGUITY: "retry with an exponential backoff schedule" does not say bounded or unbounded. Chose bounded with an explicit `max_attempts` + delay cap so a permanent failure cannot pin a thread forever; unbounded retry would make the returned `Result` meaningless.