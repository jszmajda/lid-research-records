```rust
// sheets-view/src/republish.rs
// @spec SHEET-PUB-004

use crate::{SheetsClient, TabProjection, RepublishError};

/// Advisory write-lock owned by the runtime and shared by every
/// Sheets-mutating primitive (republish, settle-pass, etc.).
/// sheets-view does not construct or store this lock — it only
/// borrows a handle to acquire/release around its own mutation.
pub trait WorkbookLock: Send + Sync {
    /// Blocks until the lock is held; returns an RAII guard.
    /// Dropping the guard releases the lock unconditionally
    /// (success, early return, error, or panic unwind).
    fn acquire_write(&self) -> Box<dyn Drop + '_>;
}

pub fn republish(
    lock: &dyn WorkbookLock,
    client: &SheetsClient,
    tabs: &[TabProjection],
) -> Result<(), RepublishError> {
    let _guard = lock.acquire_write(); // held for the whole batch below

    for tab in tabs {
        client.write_tab(tab)?; // any Err propagates; guard still drops
    }

    Ok(())
    // _guard drops here on every exit path -> lock released after mutation
}
```

Assumptions (invented, none given by the EARS text):

1. "Runtime-owned" lock = sheets-view holds only a borrowed `&dyn WorkbookLock` handle; the lock's storage/identity lives in the runtime crate, not sheets-view. Modeled as a trait so sheets-view depends on the concept, not a concrete implementation.
2. "Advisory" = cooperative-only: nothing prevents a primitive that skips `acquire_write` from writing concurrently; the guarantee holds only because every Sheets-mutating primitive is assumed to call this same lock, per the "never writes concurrently with another Sheets-mutating primitive" clause.
3. Release mechanism = RAII guard (`Drop`), not a manual `unlock()` call, so "release after" holds even on error returns (`?`) or panics — chosen because manual unlock is easy to skip on early-return paths and the spec gives no exception for failure cases.
4. Lock scope = the entire `republish` call (all tabs in one batch), not re-acquired per-tab write — chosen because per-call granularity is what "republish never writes concurrently" most naturally scopes to; per-tab locking would still leave partial-batch interleaving.
5. Acquisition semantics = blocking, no timeout — EARS specifies no timeout/backoff/failure behavior for lock contention, so blocking-until-available was assumed as the minimal reading; a poisoned/unavailable lock is assumed to surface as a `RepublishError` variant rather than panic.
6. No read/shared-lock variant assumed — EARS mentions only a write-lock, so concurrent readers (if any) are out of scope for this function.
7. `TabProjection`/`SheetsClient`/`RepublishError` are pre-existing sheets-view types; only their existence, not shape, is assumed beyond what's needed to show the lock/mutation ordering.