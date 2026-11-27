```rust
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;
use std::time::Duration;
use tokio::time::sleep;

// Shared staleness marker (arc-wrapped for multi-thread access)
pub type StalenessMarker = Arc<AtomicBool>;

/// Republish with failure recovery: exponential backoff + staleness signaling
pub async fn republish_with_recovery<Fut, E>(
    mut publish_fn: impl FnMut() -> Fut,
    staleness: StalenessMarker,
    config: RetryConfig,
) -> Result<(), E>
where
    Fut: std::future::Future<Output = Result<(), E>>,
    E: std::fmt::Display,
{
    let mut delay = config.initial_delay_ms;
    let mut attempt = 0;

    loop {
        match publish_fn().await {
            Ok(()) => {
                // Republish succeeded: mark view fresh
                staleness.store(false, Ordering::Release);
                return Ok(());
            }
            Err(e) => {
                // Failure: mark stale (TUI and banner read this)
                staleness.store(true, Ordering::Release);
                
                attempt += 1;
                if config.max_retries.map_or(false, |m| attempt > m) {
                    return Err(e);
                }

                // Exponential backoff
                delay = (delay as f64 * config.backoff_multiplier) as u64;
                delay = delay.min(config.max_delay_ms);
                
                sleep(Duration::from_millis(delay)).await;
            }
        }
    }
}

pub struct RetryConfig {
    pub initial_delay_ms: u64,
    pub max_delay_ms: u64,
    pub backoff_multiplier: f64,
    pub max_retries: Option<usize>,
}

impl Default for RetryConfig {
    fn default() -> Self {
        Self {
            initial_delay_ms: 1000,
            max_delay_ms: 300_000,
            backoff_multiplier: 2.0,
            max_retries: None, // Infinite retries
        }
    }
}

// TUI/banner layer (separate concern)
pub fn is_view_stale(marker: &StalenessMarker) -> bool {
    marker.load(Ordering::Acquire)
}
```

**ASSUMPTIONS (Explicit Inventory):**

1. **Canonical log unchanged**: Handled by `publish_fn`'s contract—only publishes, never mutates the log. Recovery logic never touches the log.
2. **Staleness type**: Boolean flag (not enum); `Arc<AtomicBool>` for lock-free thread-safe access (TUI reads concurrently).
3. **Exponential backoff**: Milliseconds; initial 1s, max 5m, multiplier 2.0—tuned for sheets API rate limits.
4. **Max retries**: Unbounded by default (None = infinite)—assume operator eventually succeeds or circuit-breaker external.
5. **Backoff overflow**: Capped at `max_delay_ms` to prevent duration explosion.
6. **"Best-effort" surface**: Staleness is a volatile boolean; TUI/banner read it without blocking. Failures to display the banner (UI crash, etc.) don't propagate back into retry logic.
7. **In-tab banner**: Assumed orthogonal—separate layer owns rendering; this module only sets `stale=true`.
8. **Generic error type**: `E: Display` allows any error; no attempt to discriminate transient vs. permanent failures (assumed safe to retry all).
9. **No callback on failure**: Staleness setter is atomic-store, not async. Notifications are synchronous or offloaded to caller.
10. **Republish is total**: `publish_fn` is a black box; we do not retry partial publishes or checkpoint intermediate sheets.

**Interpretation choice:** "Retry with exponential backoff" → retry *indefinitely* (unless capped by config), because the requirement says "leave canonical log unaffected" (safe to retry forever) and does not mention max attempts. If intent is finite retry, set `max_retries` in config.