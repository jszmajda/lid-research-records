```rust
// crate: sheets-view — republish + staleness handling for SHEET-PUB-003

use chrono::{DateTime, Utc};

/// Persistent-in-memory (or on-disk) staleness state for one workbook's
/// view. Kept entirely separate from the canonical log's storage.
pub struct ViewFreshness {
    pub stale: bool,
    pub last_failure: Option<PublishFailure>,
}

#[derive(Clone)]
pub struct PublishFailure {
    pub at: DateTime<Utc>,
    pub reason: String,
}

pub enum RepublishOutcome {
    Published,
    Failed(PublishFailure),
}

pub trait SheetsClient {
    fn push_tabs(&mut self, snapshot: &KernelSnapshot) -> Result<(), SheetsError>;
    fn write_banner(&mut self, state: BannerState) -> Result<(), SheetsError>;
}

pub trait TuiNotifier {
    fn notify_stale(&mut self, failure: &PublishFailure);
    fn notify_fresh(&mut self);
}

pub enum BannerState {
    Stale { since: DateTime<Utc> },
    Fresh,
}

/// Called by the sync scheduler each tick. On failure, this same tick
/// IS the "retry on next sync" — no separate retry/backoff subsystem.
/// Takes no reference to the canonical log, so it structurally cannot
/// mutate it: "log unaffected" is enforced by the type signature, not
/// by a runtime check.
pub fn republish(
    snapshot: &KernelSnapshot,
    sheets: &mut dyn SheetsClient,
    tui: &mut dyn TuiNotifier,
    freshness: &mut ViewFreshness,
) -> RepublishOutcome {
    match sheets.push_tabs(snapshot) {
        Ok(()) => {
            freshness.stale = false;
            freshness.last_failure = None;
            let _ = sheets.write_banner(BannerState::Fresh); // best-effort
            tui.notify_fresh();
            RepublishOutcome::Published
        }
        Err(e) => {
            let failure = PublishFailure { at: Utc::now(), reason: e.to_string() };
            freshness.stale = true;
            freshness.last_failure = Some(failure.clone());
            tui.notify_stale(&failure);
            // Banner write can itself fail; per spec this leg is
            // best-effort — swallow, don't escalate, don't retry separately.
            let _ = sheets.write_banner(BannerState::Stale { since: failure.at });
            RepublishOutcome::Failed(failure)
        }
    }
}
```

Assumptions:
1. "Log unaffected" enforced structurally (function takes no log handle) rather than via a runtime rollback/assertion — spec doesn't say how to prove it.
2. "Retry on the next sync" = the ordinary scheduled sync tick retries by simply re-running `republish`; no dedicated retry queue, counter, or backoff.
3. Any `Err` from `push_tabs` counts as "republish fails" — no distinction between transient/permanent failure classes.
4. Staleness modeled as one boolean + last-failure metadata per view (spec says "the view," singular), not per-tab.
5. "Best-effort" is read as applying specifically to the *banner write* (it's itself a Sheets call that can fail and whose failure is swallowed); TUI notification is assumed local/synchronous and reliable, so its failure isn't modeled.
6. On successful republish, staleness/banner are cleared and TUI is told "fresh" — not stated in this EARS but assumed as the natural inverse.
7. `SheetsError`/`KernelSnapshot` types assumed to exist elsewhere in the crate; left unspecified here.
8. No max-retry-count or give-up condition — spec implies indefinite per-sync retry until success.