```rust
// @spec SHEET-PUB-003
// Module: sheets_view::republish
//
// Assumes: `CanonicalLog` is append-only and untouched by publish failures
// (write path already isolated upstream); this module only reacts to a
// failed republish attempt, it does not perform the republish itself.

use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;

/// Per-workbook view staleness state, shared between sync loop, in-tab
/// banner writer, and TUI.
#[derive(Clone)]
pub struct ViewStaleness {
    stale: Arc<AtomicBool>,
}

impl ViewStaleness {
    pub fn new() -> Self {
        Self { stale: Arc::new(AtomicBool::new(false)) }
    }

    pub fn is_stale(&self) -> bool {
        self.stale.load(Ordering::Acquire)
    }
}

/// Error from an attempted republish; distinct from log-write errors,
/// which are out of scope here (log is assumed already durable/committed
/// before any republish is attempted, so a republish failure cannot
/// roll it back or corrupt it).
#[derive(Debug)]
pub struct RepublishError(pub String);

/// Called by the sync driver after a republish attempt fails.
/// Does not retry inline — retry is deferred to the next scheduled sync
/// tick (assumption: "retry on the next sync" means no immediate/inline
/// retry loop here, avoiding hot-loop risk on persistent failures).
pub fn on_republish_failed(
    staleness: &ViewStaleness,
    err: &RepublishError,
    banner: &dyn InTabBanner,
    tui: &dyn TuiNotifier,
) {
    // Canonical log: untouched by construction — no write call in this path.
    staleness.stale.store(true, Ordering::Release);

    // Best-effort: banner write failure is swallowed, not propagated,
    // since banner surfacing is explicitly "best-effort" per spec.
    let _ = banner.show_stale(err);

    // TUI surfacing has no "best-effort" qualifier in the spec, so it's
    // treated as required-effort: assumed infallible (in-process channel
    // send) rather than a network call, so no error handling needed here.
    tui.notify_stale(err);
}

pub trait InTabBanner {
    fn show_stale(&self, err: &RepublishError) -> Result<(), String>;
}

pub trait TuiNotifier {
    fn notify_stale(&self, err: &RepublishError);
}
```

Assumptions:
1. Canonical log write already completes/commits before republish is attempted, so "unaffected" requires no rollback logic — just no write call in the failure path.
2. "Retry on the next sync" means deferred retry via the existing sync scheduler, not an inline retry loop — avoids unbounded retry storms; no backoff/max-attempts specified, so none added.
3. "Best-effort" qualifies only the in-tab banner, not the TUI — TUI notification is modeled as infallible (in-process), banner as fallible-but-swallowed (out-of-process Sheets API call).
4. Staleness is a simple boolean flag, not a counter/timestamp — spec doesn't require distinguishing repeated failures.
5. No specified behavior for a *second* consecutive failure while already stale — assumed idempotent (flag stays true, banner/TUI notified again).
6. `RepublishError` carries only a message; no error taxonomy given in the spec.