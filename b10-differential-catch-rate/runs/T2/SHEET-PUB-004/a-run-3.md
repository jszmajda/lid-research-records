```rust
use std::sync::Arc;
use tokio::sync::Mutex;

/// Runtime-owned advisory lock shared by every Sheets-mutating primitive
/// (republish, marks-settle, etc.). Exclusive only — no reader tier.
#[derive(Clone)]
pub struct SheetsRuntime {
    write_lock: Arc<Mutex<()>>,
}

/// RAII guard: dropping it releases the lock, on every exit path
/// (success, error return, or panic unwind).
pub struct WriteLockGuard<'a>(tokio::sync::MutexGuard<'a, ()>);

impl SheetsRuntime {
    pub async fn acquire_write_lock(&self) -> WriteLockGuard<'_> {
        WriteLockGuard(self.write_lock.lock().await)
    }
}

#[derive(Debug, thiserror::Error)]
pub enum RepublishError {
    #[error("workbook mutation failed: {0}")]
    Mutation(String),
}

/// @spec SHEET-PUB-004
pub async fn republish(
    runtime: &SheetsRuntime,
    workbook: &WorkbookClient,
    projection: &ProjectedTabs,
) -> Result<(), RepublishError> {
    let _guard = runtime.acquire_write_lock().await; // acquire before any mutation

    let result = workbook
        .write_tabs(projection)
        .await
        .map_err(|e| RepublishError::Mutation(e.to_string()));

    result // _guard drops here on every path, releasing the lock
}

// Placeholders — shapes not specified by this EARS
pub struct WorkbookClient;
pub struct ProjectedTabs;
impl WorkbookClient {
    pub async fn write_tabs(&self, _p: &ProjectedTabs) -> Result<(), String> { Ok(()) }
}
```

Assumptions (invented, not given by the EARS text):

1. **Async, tokio-based runtime.** Sheets mutation is network I/O, so the lock is `tokio::sync::Mutex<()>` acquired via `.lock().await`, not a std blocking mutex.
2. **Indefinite wait, no timeout.** Spec gives no failure/timeout semantics for acquisition, so `acquire_write_lock` is treated as infallible — it awaits as long as needed and cannot itself error.
3. **RAII (drop-based) release**, not an explicit `unlock()` call. Chosen because "release it after" doesn't state failure behavior; a guard is the only interpretation that releases the lock on *every* exit path, including an `Err` return or a panic during `write_tabs`.
4. **Exclusive-only lock**, no separate reader tier, despite the "write-lock" name implying a possible sibling read-lock elsewhere in the runtime (out of scope here).
5. **Not re-entrant.** Calling `republish` from a task that already holds the lock is assumed out of scope (would deadlock); the spec doesn't ask for reentrancy.
6. **`WorkbookClient` / `ProjectedTabs` are placeholders** for the kernel-projected view and Sheets API client; their real shapes belong to other specs, not SHEET-PUB-004.
7. **Errors from the mutation itself don't affect lock release** — the guard drop is unconditional, decoupled from the `Result` returned by `write_tabs`.
8. **No starvation/fairness guarantee assumed** beyond whatever `tokio::sync::Mutex` provides natively (FIFO-ish).