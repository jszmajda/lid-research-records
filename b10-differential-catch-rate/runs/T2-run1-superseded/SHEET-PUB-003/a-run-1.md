```rust
//! sheets-view: republish failure handling (EARS SHEET-PUB-003)
//! Canonical log is never touched here — this module only holds a
//! `&Ledger` (read-only) view, never a handle capable of mutating it.

pub struct ViewState {
    pub stale: bool,
    pub stale_reason: Option<String>,
    pub stale_since: Option<std::time::SystemTime>,
}

pub trait ViewStateStore {
    fn load(&self) -> ViewState;
    fn save(&self, state: &ViewState);
}

pub trait TuiNotifier {
    fn notify_stale(&self, reason: &str);
}

pub trait BannerWriter {
    fn write_banner(&self, reason: &str) -> Result<(), BannerError>;
}

#[derive(Debug)]
pub struct BannerError(pub String);

#[derive(Debug)]
pub struct PublishError(pub String);

/// Runs one sync attempt. On failure: log untouched, view marked stale,
/// staleness surfaced (banner best-effort, TUI notified), and the
/// existing stale flag guarantees the *next* scheduled sync() call
/// retries — no separate retry loop is introduced here.
pub fn sync(
    republish: impl FnOnce() -> Result<(), PublishError>,
    state_store: &impl ViewStateStore,
    banner: &impl BannerWriter,
    tui: &impl TuiNotifier,
) {
    match republish() {
        Ok(()) => {
            state_store.save(&ViewState { stale: false, stale_reason: None, stale_since: None });
        }
        Err(PublishError(msg)) => {
            let state = ViewState {
                stale: true,
                stale_reason: Some(msg.clone()),
                stale_since: Some(std::time::SystemTime::now()),
            };
            state_store.save(&state); // persists so the next scheduled sync retries

            // Best-effort: banner failure is swallowed, never propagated.
            if let Err(BannerError(e)) = banner.write_banner(&msg) {
                eprintln!("banner write failed (ignored, best-effort): {e}");
            }
            tui.notify_stale(&msg);
        }
    }
}
```

Assumptions:
1. `republish()` is an existing upstream operation returning `Result<(), PublishError>`; any `Err` — including partial-tab failure — is treated as a whole-view failure (spec says "mark the view stale," singular, not per-tab).
2. "Leave canonical log unaffected" is enforced architecturally: `sync` never receives a mutable ledger/log handle, only the fallible republish closure — a write-capability boundary, not a runtime check.
3. Staleness is tracked in a separate small state store (not the event log), with `stale`, `reason`, `since`; success resets it. Reset-on-success isn't stated in this EARS but is assumed necessary to make "stale" meaningful and "retry on next sync" observable.
4. "Retry on the next sync" is interpreted as: no internal retry/backoff loop is added; an external scheduler already calls `sync()` periodically, and persisting `stale=true` is sufficient since the same code path re-attempts naturally next call.
5. "Best-effort" is read as scoped to the banner specifically per the phrase "best-effort in-tab banner" — its failure is caught and logged, never propagated/panicking. TUI notification is not explicitly called best-effort in the text but is still called after the banner unconditionally, so a banner failure can't suppress TUI surfacing.
6. `BannerWriter`/`TuiNotifier` are assumed trait boundaries for testability; concrete impls (Sheets API cell write, TUI event channel) are out of scope for this sketch.
7. Idempotency on repeated consecutive failures: re-saving `stale=true` with an updated reason/timestamp is acceptable — no de-duplication logic required by the text.
8. Money/Cents type and accounting logic are irrelevant here per the sheets-view crate's stated boundary (no accounting/tax math), so omitted entirely.