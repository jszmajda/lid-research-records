```rust
// sheets-view/src/republish.rs
// @spec SHEET-PUB-004

use std::sync::Arc;
use tokio::sync::Mutex;

/// Runtime-owned advisory write-lock. One instance lives on the shared
/// runtime handle and is acquired by every Sheets-mutating primitive
/// (republish, settle pass, etc.) before touching the workbook.
#[derive(Clone)]
pub struct SheetsWriteLock(Arc<Mutex<()>>);

impl SheetsWriteLock {
    pub fn new() -> Self {
        Self(Arc::new(Mutex::new(())))
    }
}

pub struct Runtime {
    pub sheets_write_lock: SheetsWriteLock,
    // ...other runtime-owned handles
}

pub struct Workbook {
    // opaque Sheets API client/session
}

#[derive(Debug, thiserror::Error)]
pub enum RepublishError {
    #[error("workbook mutation failed: {0}")]
    Mutation(String),
}

/// Republishes kernel-projected view tabs to the workbook.
/// Acquires the runtime's advisory write-lock for the full mutation
/// window and releases it unconditionally (guard-drop) on return or error.
pub async fn republish(
    runtime: &Runtime,
    workbook: &mut Workbook,
    tabs: &[ViewTab],
) -> Result<(), RepublishError> {
    let _guard = runtime.sheets_write_lock.0.lock().await; // acquire

    for tab in tabs {
        write_tab(workbook, tab)
            .await
            .map_err(|e| RepublishError::Mutation(e.to_string()))?;
    }

    Ok(())
    // _guard drops here (success or `?` early-return) -> release
}

pub struct ViewTab {
    pub name: String,
    // ...projected rows
}

async fn write_tab(_workbook: &mut Workbook, _tab: &ViewTab) -> Result<(), String> {
    Ok(())
}
```

Assumptions (invented, not in the EARS text):

1. **Lock scope/identity**: "runtime-owned" = a single in-process `Arc<Mutex<()>>` held on a shared `Runtime` struct, not a cross-process/distributed lock — chosen because "another Sheets-mutating primitive" reads as a sibling component in the same runtime, and nothing in the spec implies multi-process coordination.
2. **Lock type**: async `tokio::sync::Mutex` rather than a std mutex, since Sheets mutation is I/O-bound; EARS doesn't specify sync vs async.
3. **Release-on-error guarantee**: EARS says "release it after" without addressing failure paths; I chose RAII (guard dropped on any return, including `?` early-exit) as the only interpretation that satisfies "never writes concurrently" under error conditions too.
4. **No timeout/backoff**: spec gives no failure-to-acquire behavior, so acquisition blocks indefinitely (`await`) rather than timing out — deadlock/starvation handling is left unspecified and unimplemented.
5. **Granularity**: lock is held for the *entire* multi-tab republish call, not per-tab, since the requirement says "before mutating the workbook" (singular action) not "before each mutation."
6. **No poisoning/recovery logic**: `tokio::Mutex` can't be poisoned, so no error variant for lock-acquisition failure exists — assumed acceptable since EARS doesn't require one.
7. **Workbook/ViewTab shapes**: invented as opaque placeholders; the requirement doesn't constrain their structure.