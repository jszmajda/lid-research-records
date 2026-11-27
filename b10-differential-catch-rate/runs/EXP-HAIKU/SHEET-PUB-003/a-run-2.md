```rust
use std::time::{Duration, SystemTime};
use std::sync::{Arc, Mutex};

/// Requirement SHEET-PUB-003 implementation sketch
/// Manages republish with exponential backoff, staleness tracking, and signaling

#[derive(Clone, Debug)]
pub struct ViewStaleness {
    is_stale: bool,
    failure_count: u32,
    last_failed_at: Option<SystemTime>,
}

pub struct PublishRetryPolicy {
    max_retries: u32,
    initial_backoff_ms: u64,
}

pub struct SheetsPublisher {
    /// Tracks staleness without modifying canonical log
    staleness: Arc<Mutex<ViewStaleness>>,
    policy: PublishRetryPolicy,
}

impl SheetsPublisher {
    pub fn publish_with_retry(
        &self,
        events: &[Event],
    ) -> Result<(), PublishError> {
        let mut staleness = self.staleness.lock().unwrap();

        for attempt in 0..self.policy.max_retries {
            // Attempt publish to sheets (transactional; fails cleanly)
            match self.attempt_sheets_publish(events) {
                Ok(_) => {
                    // Success: clear stale marker, reset retry counter
                    staleness.is_stale = false;
                    staleness.failure_count = 0;
                    self.signal_view_refreshed();
                    return Ok(());
                }
                Err(e) if attempt < self.policy.max_retries - 1 => {
                    // Retryable: mark stale, backoff, loop
                    staleness.is_stale = true;
                    staleness.failure_count = attempt + 1;
                    staleness.last_failed_at = Some(SystemTime::now());

                    self.signal_staleness_to_tui(&staleness);
                    drop(staleness); // Release lock before sleep

                    let backoff_ms =
                        self.policy.initial_backoff_ms * 2u64.pow(attempt);
                    std::thread::sleep(Duration::from_millis(backoff_ms));
                    
                    staleness = self.staleness.lock().unwrap(); // Re-acquire
                }
                Err(e) => {
                    // Final retry failed: mark stale, give up
                    staleness.is_stale = true;
                    staleness.last_failed_at = Some(SystemTime::now());
                    self.signal_staleness_to_tui(&staleness);
                    return Err(e);
                }
            }
        }
        unreachable!()
    }

    fn attempt_sheets_publish(&self, events: &[Event]) -> Result<(), PublishError> {
        // Transactional: writes projection + optional banner, or fails cleanly.
        // sheets-view crate owns this. Canonical log never touched.
        todo!()
    }

    fn signal_staleness_to_tui(&self, staleness: &ViewStaleness) {
        // Send staleness marker to TUI via channel/event bus
        // TUI renders "View stale; retrying..." in status line
        eprintln!("⚠ View stale (attempt {})", staleness.failure_count);
    }

    fn signal_view_refreshed(&self) {
        // Clear stale indicator from TUI
        eprintln!("✓ View refreshed");
    }

    pub fn is_stale(&self) -> bool {
        self.staleness.lock().unwrap().is_stale
    }
}

// In-tab banner managed separately by sheets-view crate
// Injects "[STALE — retrying]" row if staleness.is_stale, cleared on success
```

---

**Assumptions (explicit inventory):**

1. **Max retries**: 5 (unspecified; reasonable for transient failure patterns)
2. **Initial backoff**: 500 ms (unspecified; chosen to avoid hammering sheets API)
3. **Exponential base**: 2 (standard for backoff; doubles each attempt)
4. **Staleness storage**: Shared Arc<Mutex<>> in publisher; canonical log untouched (isolated storage)
5. **In-tab banner**: Best-effort means staleness flag is advisory; banner row injected by sheets-view crate when `is_stale == true`, removed on success
6. **Retry trigger**: Synchronous; caller blocks on `publish_with_retry()`; async variant deferred
7. **Retriable errors**: All `PublishError` variants retried up to max; terminal errors (auth) could be fast-failed (unimplemented)
8. **Canonical log**: Append-only, separate from view state; publish reads it, never modifies it
9. **TUI signaling**: Eprintln stub; real implementation uses event channel to TUI event loop

**Ambiguity resolved:**
- "Surface staleness via banner **and** TUI" interpreted as two independent channels (both always attempted; either can fail without blocking the other). In-tab banner is best-effort (may not render if sheets offline), while TUI is always reachable.