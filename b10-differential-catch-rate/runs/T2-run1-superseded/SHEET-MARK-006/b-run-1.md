**Requirements enforced — marks read-back transport-failure handling (`sheets_view::read_marks`, `SheetsViewClient::read_price_pass`)**

**[Event-driven]** WHEN `client.read_price_pass()` returns `Err` during a settle-pass poll, `read_marks` SHALL immediately return `Err` (the same error) and SHALL NOT return `Ok` with any `MarksProduced` — partial or empty.

**[Unwanted-behavior]** `read_marks` SHALL NEVER substitute an empty or partial marks set for a transport failure. An `Ok` result with no marks is indistinguishable from "every symbol degraded," which would incorrectly null out live positions; a transport failure MUST be surfaced as `Err`, not silently absorbed.

**[Event-driven]** WHEN `read_price_pass` fails, the poll loop SHALL abort on that first failing call — the failure is NOT retried within the bounded `max_polls` window and is NOT treated as a per-symbol transient reading. (Bounding by `max_polls` applies only to the "still transient/absent" retry path, not to transport errors, which short-circuit via `?` before any poll-count or settled-check logic runs.)

**[Ubiquitous]** On a transport failure, `read_marks` itself SHALL NOT carry the `prior` marks map forward and SHALL NOT touch it — carrying forward previously cached marks (with their quote-date stamps) into the next replay is exclusively the caller's (`runtime`'s) responsibility, performed after observing the propagated `Err`.

**[State-driven]** WHILE the Positions view tab does not yet exist (fresh/cold-start workbook), `read_price_pass` SHALL return `Ok` with an empty `PricePass` rather than `Err` — a missing tab is classified as "no marks yet," never as a transport/unreachable failure. (This boundary is enforced one layer below `read_marks`, at the `SheetsViewClient` implementation, but pins that transport-failure semantics must not be conflated with the cold-start/missing-tab case.)

**Supporting/contrasting behavior pinned by the same tests, for completeness of the boundary:**
- A terminal non-numeric reading (`PriceReading::Permanent`) is a distinct, non-transport failure mode: it degrades that single symbol immediately (`DegradeReason::Permanent`, no prior carry, loop settles without exhausting `max_polls`) and does NOT abort the whole `read_marks` call.
- A still-transient reading past `max_polls` is also non-transport: it degrades per-symbol (`TimedOut`) or carries the prior mark, and does NOT produce an `Err`.
- Only an actual `Err` from `read_price_pass` triggers the all-or-nothing propagation described above; all other per-symbol states resolve within a successful `Ok(MarksProduced)`.