```rust
// sheets-view crate: republish failure handling (SHEET-PUB-003)

/// Money already lives elsewhere as integer Cents; this module touches no accounting math.
pub struct ViewState {
    pub stale: bool,
    pub stale_reason: Option<String>,
}

pub enum RepublishOutcome {
    Ok,
    Failed(RepublishError),
}

pub struct RepublishError {
    pub message: String,
}

pub trait InTabBanner {
    /// Best-effort: failures here are logged, never propagated.
    fn set_banner(&self, text: &str) -> Result<(), BannerError>;
}
pub struct BannerError(pub String);

pub trait TuiNotifier {
    fn notify_stale(&self, reason: &str);
}

/// Called after an attempt to push a tab render to the workbook.
/// Canonical log (the append-only event source) is never passed in and never mutated here.
pub fn handle_republish_result(
    outcome: RepublishOutcome,
    state: &mut ViewState,
    banner: &dyn InTabBanner,
    tui: &dyn TuiNotifier,
) {
    match outcome {
        RepublishOutcome::Ok => {
            state.stale = false;
            state.stale_reason = None;
        }
        RepublishOutcome::Failed(err) => {
            // Canonical log: untouched by construction — this fn has no handle to it.
            state.stale = true;
            state.stale_reason = Some(err.message.clone());

            // Best-effort banner: swallow errors, don't fail the sync pass over UI cosmetics.
            if let Err(BannerError(e)) = banner.set_banner(&format!("View stale: {}", err.message)) {
                eprintln!("banner update failed (non-fatal): {e}");
            }

            // TUI surfacing is not best-effort — assumed reliable/local, so no error swallowing.
            tui.notify_stale(&err.message);

            // No retry scheduling here: "retry on the next sync" is interpreted as the
            // regular sync scheduler naturally re-attempting publish next cycle, driven
            // by `state.stale`, rather than this function scheduling its own retry/backoff.
        }
    }
}
```

Assumptions:
1. "Canonical log unaffected" is satisfied structurally — this function receives no reference/handle to the log, so it cannot mutate it; no explicit rollback logic is modeled.
2. "Retry on the next sync" means the existing periodic sync loop re-attempts publish because `stale == true`, not that this function spawns its own retry/backoff timer.
3. `RepublishError` carries only a `String` message — no distinction between transient (network) vs. permanent (auth/quota) failures, since the EARS doesn't require differentiated handling.
4. In-tab banner is explicitly "best-effort": its own write can fail (e.g., Sheets API also down) and that failure is logged and swallowed, not escalated or retried.
5. TUI surfacing is treated as reliable (no "best-effort" qualifier in the EARS), so its notifier is called unconditionally and not wrapped in error handling.
6. `ViewState` is per-tab; multi-tab fan-out/aggregation of staleness is out of scope for this requirement.
7. No distinction between "first failure" and "still failing" — each failed attempt simply re-marks stale and re-surfaces, idempotently.