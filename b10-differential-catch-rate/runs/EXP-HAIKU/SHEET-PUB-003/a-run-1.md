```rust
use std::sync::{Arc, RwLock};
use std::time::{Duration, Instant};

/// Manages republish failures per SHEET-PUB-003:
/// - Retries with exponential backoff
/// - Marks view stale on error
/// - Leaves canonical log unmodified
/// - Surfaces staleness best-effort via banner and TUI
pub struct ViewPublisher {
    state: Arc<RwLock<PublishState>>,
    initial_backoff: Duration,  // e.g., 1 second
    max_backoff: Duration,      // e.g., 5 minutes
}

struct PublishState {
    is_stale: bool,
    retry_count: u32,
    next_retry_at: Option<Instant>,
    last_error: Option<String>,
}

impl ViewPublisher {
    pub fn new(initial_backoff: Duration, max_backoff: Duration) -> Self {
        Self {
            state: Arc::new(RwLock::new(PublishState {
                is_stale: false,
                retry_count: 0,
                next_retry_at: None,
                last_error: None,
            })),
            initial_backoff,
            max_backoff,
        }
    }

    /// Attempt publish to Sheets. On failure: mark stale, schedule exponential retry,
    /// leave canonical_log untouched (read-only, never committed on error).
    pub fn attempt_publish(
        &self,
        canonical_log: &CanonicalLog,
        publish_fn: impl Fn(&CanonicalLog) -> Result<()>,
    ) {
        match publish_fn(canonical_log) {
            Ok(()) => {
                let mut s = self.state.write().unwrap();
                s.is_stale = false;
                s.retry_count = 0;
                s.next_retry_at = None;
                s.last_error = None;
            }
            Err(e) => {
                let mut s = self.state.write().unwrap();
                s.is_stale = true;
                s.retry_count = s.retry_count.saturating_add(1);
                s.last_error = Some(e.to_string());

                // Exponential backoff: initial * 2^(retry_count-1), capped at max
                let exp = 2_u32.saturating_pow(s.retry_count.saturating_sub(1));
                let backoff = self.initial_backoff.mul_f32(exp as f32).min(self.max_backoff);
                s.next_retry_at = Some(Instant::now() + backoff);
            }
        }
    }

    /// Query for in-tab banner (best-effort: if lock unavailable, return None silently).
    pub fn get_staleness_banner(&self) -> Option<String> {
        self.state
            .read()
            .ok()?
            .is_stale
            .then(|| format!("View stale; retrying... (attempt #{})", self.state.read().ok()?.retry_count))
    }

    /// Query for TUI display (best-effort: silently degraded if unavailable).
    pub fn get_tui_staleness_indicator(&self) -> Option<StalenessIndicator> {
        self.state.read().ok().and_then(|s| {
            s.is_stale.then(|| StalenessIndicator {
                is_stale: true,
                retry_count: s.retry_count,
                next_retry_in: s.next_retry_at.map(|t| t - Instant::now()),
            })
        })
    }

    pub fn should_retry_now(&self) -> bool {
        self.state
            .read()
            .ok()
            .and_then(|s| s.next_retry_at.map(|t| Instant::now() >= t))
            .unwrap_or(false)
    }
}

pub struct StalenessIndicator {
    pub is_stale: bool,
    pub retry_count: u32,
    pub next_retry_in: Option<Duration>,
}
```

**ASSUMPTIONS (explicit list):**

1. **Type shapes**: `CanonicalLog` is a reference type; `publish_fn` closure borrows immutably (never modifies log).
2. **Backoff formula**: exponential = `initial * 2^(attempt-1)`, capped at `max_backoff`; no jitter (could add).
3. **Max retries**: unbounded retry-count field; caller decides when to give up (e.g., after 12 attempts).
4. **Staleness scope**: marks only the *view*, not the log; log remains authoritative.
5. **Best-effort degradation**: `RwLock::read().ok()` silently eats poisoned locks; banner/TUI failures don't escalate.
6. **State repr**: single atomic `PublishState` struct; no separate retry queue (retries are pull-based from a loop).
7. **Timing**: uses `Instant` (monotonic, not wall-clock); suitable for local retry scheduling.
8. **Error capture**: stores last error string for debugging; doesn't replay it.
9. **Ambiguity resolved**: "mark the view stale" → boolean flag, not a variant type; allows cheap queries.
10. **Retry initiation**: caller polls `should_retry_now()` or runs a separate timer task to re-invoke `attempt_publish()`.

**Interpretation notes**: The requirement is silent on retry limits, concurrency model (async vs. sync), and who drives the retry loop—assumed synchronous, caller-driven polling, unbounded retries at the logic level (operational limits external).