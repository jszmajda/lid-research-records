SHEET-VIEW-U1 (Ubiquitous): The header row (row 1) of a view tab shall be written exactly once, at tab creation, and shall never be rewritten by any subsequent republish call.

SHEET-VIEW-U2 (Ubiquitous): The data range for a view tab shall always begin at the fixed anchored row `DATA_START_ROW = 2` (1-based), directly beneath the frozen header, through column Z.

SHEET-VIEW-U3 (Ubiquitous): A `Cell::Value` shall be written as a native Sheets `userEnteredValue` (never a forced/string value), so a bare number parses as numeric and a percent-suffixed string (e.g. `"20.0000%"`) parses as the numeric fraction with percent formatting; a `Cell::Formula` shall be written as a `userEnteredValue` formula string including its leading `=`, so it recomputes live.

SHEET-VIEW-E1 (Event-driven): WHEN a view tab is republished, the system shall rewrite the tab's entire current data range (`DATA_START_ROW` through the last row) in one atomic `update_range`/`batchUpdate` call.

SHEET-VIEW-E2 (Event-driven): WHEN a republish presents fewer rows than the tab's previous publish, the system shall replace the data rows wholesale, truncating the residual tail to exactly the new row count — no leftover stale rows, no half-written window.

SHEET-VIEW-E3 (Event-driven): WHEN the target tab does not yet exist, the system shall create the sheet, write the tab's typed header to row 1 exactly once, then write the data range — a "missing tab" write failure is treated as create-then-retry-once, not a terminal error.

SHEET-VIEW-E4 (Event-driven): WHEN a tab write fails for any reason other than "tab missing," the system shall return `Err(PublishFailed)`, leave that tab's existing published content unmodified, add the tab to the stale set, and attempt (best-effort) a single-cell write of `"STALE — last sync {ts}"` to cell `AA1` of that tab; failure of the banner write shall not change the outcome.

SHEET-VIEW-E5 (Event-driven): WHEN republish spans multiple tabs, each tab's write shall be attempted independently in sequence; one tab's failure shall not prevent remaining tabs from being attempted; each tab's stale flag is cleared on that tab's success and set on that tab's failure.

SHEET-VIEW-E6 (Event-driven): WHEN republish is invoked, the advisory write-lock shall be acquired before any tab mutation and released only after all tab writes and the tab-order reassert complete.

SHEET-VIEW-S1 (State-driven): WHILE the advisory write-lock is held by another holder, republish shall write nothing to any tab, report `published=false`, and leave the existing stale-tab set unchanged.

SHEET-VIEW-N1 (Unwanted behavior): IF a republish call presents a header for a tab different from that tab's previously-published header, THEN this is a contract violation — every republish call's header for a given tab must be byte-identical to the one written at creation.