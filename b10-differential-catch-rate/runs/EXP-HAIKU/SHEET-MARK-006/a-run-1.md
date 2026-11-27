```rust
use std::sync::{Arc, Mutex};

#[derive(Clone, Debug)]
struct Mark {
    symbol: String,
    price: f64,
}

#[derive(Debug)]
enum TransportError {
    Network(String),
    Timeout,
    Validation(String),
}

struct MarksRuntime {
    /// Last successful marks; retained when pass fails
    cached: Arc<Mutex<Vec<Mark>>>,
}

impl MarksRuntime {
    fn new() -> Self {
        MarksRuntime {
            cached: Arc::new(Mutex::new(Vec::new())),
        }
    }

    /// Marks read-back pass: all-or-nothing fetch and cache.
    /// On transport failure: error propagates, cache unchanged, no marks emitted.
    fn read_back_marks(
        &self,
        transport: &impl MarksTransport,
    ) -> Result<Vec<Mark>, TransportError> {
        // Attempt fetch; any transport error aborts entire pass (fail-fast).
        let marks = transport.fetch_marks()?;

        // Success: update cache atomically, then return marks.
        *self.cached.lock().unwrap() = marks.clone();
        Ok(marks)
    }

    /// Retrieve last cached marks after a failed pass.
    fn last_cached_marks(&self) -> Vec<Mark> {
        self.cached.lock().unwrap().clone()
    }
}

trait MarksTransport {
    fn fetch_marks(&self) -> Result<Vec<Mark>, TransportError>;
}

// Caller usage:
// match runtime.read_back_marks(&transport) {
//     Ok(marks) => { /* emit marks to sheets */ }
//     Err(e) => {
//         eprintln!("marks pass failed: {:?}", e);
//         // sheets remain on last_cached_marks; no partial update
//     }
// }
```

---

**ASSUMPTIONS (all invented):**

1. **Mark structure:** symbol (String) + price (f64); workspace uses Cents elsewhere but marks are prices
2. **TransportError variants:** Network, Timeout, Validation cover failure modes
3. **All-or-nothing scope:** "partial" means some marks fetched but fetch incomplete; single failure aborts entire batch (fail-fast via `?`)
4. **"Emit no marks":** function returns Err; caller decides display (show cached or UI cue); sheets *not updated* by failed pass
5. **Cache storage:** Arc<Mutex<Vec>> for thread-safe mutable cache; initial state empty Vec
6. **Clone cost:** cloning marks on success acceptable; could optimize with Arc<T> in Mark if data large
7. **Transport trait:** abstraction; real impl is sheets API layer or HTTP wrapper
8. **Error propagation:** Rust `?` operator propagates; caller must handle Result
9. **Cache lifetime:** owned by Runtime; initialized once, persists for process lifetime
10. **Concurrent access:** multiple callers of read_back_marks are serialized by Mutex

**Interpretation choice:** "emit no marks" = return Err and don't mutate cache, leaving caller to decide fallback behavior (display cached marks, retry, or stale-data UI cue). This honors "propagate error" without specifying sheets-layer behavior.