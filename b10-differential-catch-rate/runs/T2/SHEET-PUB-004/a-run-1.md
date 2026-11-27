```rust
/// Advisory write-lock shared by every Sheets-mutating primitive in the
/// process; owned by the runtime, not by any single primitive.
pub struct Runtime {
    workbook_lock: std::sync::Arc<tokio::sync::Mutex<()>>,
}

impl Runtime {
    pub fn workbook_lock(&self) -> std::sync::Arc<tokio::sync::Mutex<()>> {
        self.workbook_lock.clone()
    }
}

pub struct RepublishError(pub String);

/// sheets-view::republish
/// @spec SHEET-PUB-004
pub async fn republish(
    runtime: &Runtime,
    sheets: &mut dyn SheetsClient,
    view: ProjectedView,
) -> Result<(), RepublishError> {
    // Acquire before any mutation. `.lock().await` blocks the task (not the
    // OS thread) until the lock is free; MutexGuard is held across all the
    // writes below and released automatically on drop, including on early
    // return via `?` or panic-unwind, satisfying "release it after."
    let _guard = runtime.workbook_lock().lock_owned().await;

    for tab in view.tabs {
        sheets
            .write_tab(&tab.name, &tab.rows)
            .await
            .map_err(|e| RepublishError(format!("write {}: {e}", tab.name)))?;
    }

    Ok(())
    // _guard drops here -> lock released.
}

pub trait SheetsClient {
    async fn write_tab(&mut self, name: &str, rows: &[Row]) -> Result<(), String>;
}
pub struct Row;
pub struct ProjectedView {
    pub tabs: Vec<Tab>,
}
pub struct Tab {
    pub name: String,
    pub rows: Vec<Row>,
}
```

Assumptions:
1. "Runtime-owned" = a single `Runtime` value, constructed once per process, holds the lock `Arc`; all Sheets-mutating primitives (republish, settle pass, etc.) are given a reference to the same `Runtime` so the lock is truly shared, not per-primitive.
2. "Advisory" = cooperative only — nothing prevents a primitive from writing to Sheets without acquiring the lock; correctness depends on every mutating primitive opting in. No OS-level or Sheets-API-level enforcement is implied.
3. Lock is async (`tokio::sync::Mutex`) rather than a blocking `std::sync::Mutex`, since Sheets writes are network I/O and republish is assumed to run inside an async runtime; if the codebase is sync, substitute `std::sync::Mutex` and `.lock().unwrap()`.
4. Acquisition has no timeout — the EARS states no fallback/timeout behavior, so republish waits indefinitely for the lock rather than failing fast or erroring on contention.
5. "Release after" is interpreted as release-on-completion-of-the-whole-mutation-sequence, including error paths — implemented via RAII guard drop, not an explicit unlock call, so a mid-loop write failure still releases the lock.
6. Scope of "mutating the workbook" = the entire multi-tab write sequence per republish call, not per individual API request — the lock is held across all tab writes in one republish invocation, not re-acquired per tab.
7. No re-entrancy: republish is assumed not to call itself or another lock-acquiring primitive while holding the guard, since `tokio::sync::Mutex` is not reentrant and would deadlock.
8. Lock poisoning/failure is out of scope for this sketch — `lock_owned().await` here cannot fail short of the runtime shutting down.