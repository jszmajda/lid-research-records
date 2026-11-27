**Ambiguity resolved:** "runtime-owned advisory write-lock" is read as a single process-wide lock instance held on a shared `Runtime` handle (not a per-call or per-workbook lock), since the requirement says lock contention must span *any* Sheets-mutating primitive, not just other `republish` calls. Advisory ⇒ cooperative (nothing stops a primitive that forgets to take it), so correctness rests entirely on every mutating primitive going through this same acquire/release path — enforced here via an RAII guard so release happens on all exit paths, including error returns.

```rust
// sheets-view/src/republish.rs
use std::sync::Arc;
use tokio::sync::Mutex;

/// Runtime-owned advisory write-lock shared by every Sheets-mutating
/// primitive (republish, marks settle pass, etc).
pub type SheetsWriteLock = Arc<Mutex<()>>;

pub struct Runtime {
    pub sheets_write_lock: SheetsWriteLock,
    // ...other runtime-owned handles
}

pub struct ProjectedView; // kernel-projected tab data, opaque here
pub struct Workbook;      // Sheets API client/spreadsheet handle

#[derive(Debug, thiserror::Error)]
pub enum RepublishError {
    #[error("workbook mutation failed: {0}")]
    Mutation(#[from] WorkbookError),
}

#[derive(Debug, thiserror::Error)]
#[error("workbook error")]
pub struct WorkbookError;

impl Workbook {
    async fn write_tabs(&mut self, _view: &ProjectedView) -> Result<(), WorkbookError> {
        Ok(()) // batchUpdate / values.update calls
    }
}

/// @spec SHEET-PUB-004
pub async fn republish(
    runtime: &Runtime,
    workbook: &mut Workbook,
    view: &ProjectedView,
) -> Result<(), RepublishError> {
    // Acquire before mutating; guard's Drop releases on every exit path,
    // including the `?` early return below.
    let _guard = runtime.sheets_write_lock.lock().await;

    workbook.write_tabs(view).await?;

    Ok(()) // _guard drops here -> lock released
}
```

**Assumptions:**
1. Lock type: `tokio::sync::Mutex<()>` wrapped in `Arc`, chosen over `std::sync::Mutex` to avoid poisoning semantics and to support async holders across `.await` points during network I/O.
2. Lock lives on a `Runtime` struct passed by reference; `republish` does not construct it, matching "runtime-owned."
3. Acquisition is unconditionally blocking (`.lock().await`) — no timeout — since the spec states no fallback/backoff behavior; a timeout would be an invented policy beyond the text.
4. No explicit "unlock" call exists; release is structural (guard drop at scope end), which trivially satisfies "release it after" on both success and error, since Rust drops the guard during unwind-free early returns.
5. Failure of `write_tabs` does not require the lock to stay held or be retried — it's dropped and the error propagates via `RepublishError::Mutation`.
6. Nothing else in the workbook is touched outside the guarded region, so the guard's scope equals "the mutation" — no partial-lock or read-then-lock ordering is implied by the spec.
7. Other Sheets-mutating primitives (e.g., marks settle) are assumed to take the identical `runtime.sheets_write_lock` — out of scope for this function but required for the spec's mutual-exclusion guarantee to actually hold.