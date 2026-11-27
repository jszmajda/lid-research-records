```rust
/// Per-tab publish freshness, held by the sheets-view crate.
pub struct ViewStatus {
    pub stale: bool,
    pub last_error: Option<String>,
    pub last_attempt: DateTime<Utc>,
}

pub trait SheetsClient {
    fn publish_tab(&mut self, tab: &TabProjection) -> Result<(), PublishError>;
    fn write_banner(&mut self, tab_name: &str, msg: &str) -> Result<(), PublishError>;
    fn clear_banner(&mut self, tab_name: &str) -> Result<(), PublishError>;
}

pub trait TuiNotifier {
    fn surface_staleness(&mut self, tab_name: &str, err: &PublishError);
    fn clear_staleness(&mut self, tab_name: &str);
}

/// Republishes one view tab. Never touches the canonical event log —
/// no log handle is even in scope, so failure cannot corrupt it.
pub fn republish(
    sheets: &mut dyn SheetsClient,
    tui: &mut dyn TuiNotifier,
    status: &mut ViewStatus,
    tab: &TabProjection,
) {
    match sheets.publish_tab(tab) {
        Ok(()) => {
            status.stale = false;
            status.last_error = None;
            tui.clear_staleness(&tab.name);
            let _ = sheets.clear_banner(&tab.name); // best-effort
        }
        Err(e) => {
            status.stale = true;
            status.last_error = Some(e.to_string());
            status.last_attempt = Utc::now();
            tui.surface_staleness(&tab.name, &e);
            // best-effort banner: swallow failure, never propagate/panic
            let _ = sheets.write_banner(&tab.name, "View may be stale — last publish failed");
            // no retry scheduling here: status.stale=true persists and the
            // caller's normal sync loop re-invokes republish next tick
        }
    }
}
```

Assumptions:
1. "Republish fails" = `publish_tab` returns `Err`; no distinction drawn between transient/permanent failure since EARS doesn't classify.
2. "Leave canonical log unaffected" satisfied structurally: this function receives no log/ledger handle, so it has no path to mutate it, on success or failure.
3. Staleness is view-(tab)-level, matching "mark the view stale," not cell- or workbook-level.
4. "Retry on the next sync" = no dedicated retry queue/backoff; `stale` remains `true` and the pre-existing periodic sync loop calls `republish` again unconditionally next tick — the retry mechanism is reuse of ordinary scheduling, not new state. Unlimited retries assumed; no max-attempts/backoff specified.
5. "Best-effort ... banner": its write is fire-and-forget (`let _ =`) — a banner-write failure must not fail the stale-marking or block TUI surfacing, since only the banner is qualified "best-effort," not the TUI path.
6. TUI notification assumed to always succeed (infallible local UI update), since only the in-tab banner is explicitly hedged as best-effort.
7. On a subsequent successful republish, `stale` and banner are cleared and TUI is told to clear — not stated explicitly but the natural dual of "mark stale," needed so staleness isn't sticky forever.
8. `PublishError` type is a stand-in; concrete variants (network/auth/quota) are unspecified by the EARS and left abstract.
9. Function is synchronous/blocking for clarity; async runtime integration is an orthogonal implementation detail not addressed by the requirement.