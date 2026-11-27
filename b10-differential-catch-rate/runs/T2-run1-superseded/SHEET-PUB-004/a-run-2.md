```rust
// sheets-view::republish — SHEET-PUB-004
//
// Assumption: the "runtime-owned advisory write-lock" is a single process-wide
// (or cross-primitive) mutex exposed by the runtime crate, handed to this
// module via a shared handle rather than owned by sheets-view itself.
// Modeled as `Arc<tokio::sync::Mutex<()>>` — advisory: it only guards
// Sheets-mutating primitives that opt in to acquiring it, not raw API access.

use std::sync::Arc;
use tokio::sync::Mutex;

/// Handle type supplied by the runtime; sheets-view only borrows it.
pub type WriteLock = Arc<Mutex<()>>;

pub struct RepublishError(pub String);

pub async fn republish(
    lock: &WriteLock,
    workbook: &mut WorkbookHandle,
    tabs: &[TabProjection],
) -> Result<(), RepublishError> {
    // Acquire before any mutation. Assumption: acquisition blocks (no timeout)
    // rather than try-lock-and-fail — EARS says "shall acquire", not "attempt
    // to acquire," so a busy lock means republish waits its turn rather than
    // erroring. Tokio's Mutex is not poisonable, so no poison-recovery path
    // is needed (unlike std::sync::Mutex).
    let _guard = lock.lock().await;

    // Guard held for the full mutation; released on drop at function exit —
    // including on early return or panic-unwind — so "release after" holds
    // even on the error path. This is the RAII interpretation of "release
    // after mutating"; an alternative (explicit unlock call before each
    // return) was rejected as more error-prone.
    let result = do_mutate(workbook, tabs).await;

    // _guard drops here regardless of result, releasing the lock.
    result
}

async fn do_mutate(
    workbook: &mut WorkbookHandle,
    tabs: &[TabProjection],
) -> Result<(), RepublishError> {
    for tab in tabs {
        workbook
            .write_tab(tab)
            .await
            .map_err(|e| RepublishError(e.to_string()))?;
    }
    Ok(())
}

// Stand-ins for types owned elsewhere in the workspace.
pub struct WorkbookHandle;
impl WorkbookHandle {
    async fn write_tab(&mut self, _tab: &TabProjection) -> Result<(), String> {
        Ok(())
    }
}
pub struct TabProjection;
```

Assumptions (explicit, all invented — not stated by the EARS):
1. Lock is `Arc<tokio::sync::Mutex<()>>`, owned/constructed by the runtime crate, passed by reference — "runtime-owned" read as supplied-not-constructed-here.
2. Acquisition blocks indefinitely (no timeout/try-lock); "shall acquire" implies waiting, not failing fast on contention.
3. Release-on-drop (RAII guard) satisfies "release after," including on error or panic, since the EARS doesn't distinguish success/failure release paths.
4. Empty `tabs` slice is a valid no-op republish — lock is still acquired/released (the requirement doesn't gate locking on there being work to do).
5. No re-entrancy handling: if `republish` is called while already holding the lock on the same task, it deadlocks — EARS doesn't specify reentrant semantics, and tokio's Mutex isn't reentrant.
6. Tokio's Mutex chosen over `std::sync::Mutex` since "mutating the workbook" is assumed to be an async I/O operation (network call to Sheets API); no poison-recovery logic needed since tokio's Mutex can't poison.
7. "Another Sheets-mutating primitive" is out of scope for this sketch — assumed to be a sibling function that takes the same `WriteLock` handle; not shown.