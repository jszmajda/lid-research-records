REPUBLISH TIMING & MARK-REFRESH SERIALIZATION

**Event-Triggered Republish:** Republish runs on every cycle (headless `summary`, TUI connect/refresh, post-submit refresh). A confirmed durable ledger/tax append triggers a refresh (tui_app.rs L495–496, L496), which drives one cycle, which republishes. No ambient refresh loop independent of data changes or manual actions.

**Serialization Boundary (Lock-Guarded):** The publish phase acquires the runtime-owned advisory write-lock BEFORE mutating the workbook (sheets-view lib.rs L960–972) and releases it on scope exit. The settle read (mark refresh) happens ONLY AFTER the write returns, never inline with formula writes (sheets-view lib.rs L1022–1023; republish.rs L64–126 tests this strict ordering). A held lock (another Sheets-mutating primitive) causes republish to refuse: `published: false` returned, workbook untouched (republish.rs L240–254).

**Symbol Set for Pricing:** Only open-position symbols (qty != 0) are passed to settle; fully closed positions (qty = 0) are never priced—they draw no GOOGLEFINANCE read, avoid degradation, never pollute freshness stamps (cycle.rs L327–333, L418–424).

**Settle Pass Polling:** `read_marks` polls up to `cfg.max_polls` times (default 8, SettleConfig L788). Each poll reads the price-cell values; the loop exits early when all requested symbols are numeric OR terminally errored OR window elapses (sheets-view lib.rs L826–845). Polling count = `polls` incremented per iteration; settlement condition checked after each: no symbol remains `Transient` OR absent (L835–839). Still-transient symbols after the window **degrade** with `TimedOut` reason; prior good cached marks are carried forward so transient does not null a position (L870–879).

**Mark Carry-Forward (Prior Preservation):** On each poll, `latest.get(s)` reads the current pass; if absent or transient, the prior good mark from the last cycle survives injection into the next replay—never overwritten by a timeout/transient (L873–879). Terminal errors (`Permanent`, malformed ticker) degrade with no prior carry; sub-cent prices (round to ≤0 Cents) degrade `SubCent`, never a zero mark (sheets-view lib.rs L354–385, L349–351).

**One Cycle = Replay, Render, Republish→Settle, Repricing:** The publishing cycle (cycle.rs L378–456) replays once, renders all five bands, republishes atomically (per-tab `batchUpdate` with tail-truncate, no half-written window), settles in one serialized pass, then replays **again** with this cycle's cached marks to close the valuation loop—held outcome valued at sync time, not formula recalculation time.

Atomic Republish: Each tab is one `batchUpdate` from `DATA_START_ROW` onward; residual rows beyond the new count are truncated (republish.rs L142–152). Failed publish flags the tab stale, writes a best-effort in-tab banner (`"STALE — last sync {ts}"`), and retries next cycle (republish.rs L155–187).

**No Silent Offline Degrade:** If `read_marks` errors (workbook unreachable), the error **propagates** and produces **no** `MarksProduced`—never an empty degraded set. Runtime retains its prior cached marks and re-injects them next cycle (cycle.rs L304–306, sheets-view lib.rs L806–815).

<budget:token_budget>200000</budget:token_budget>

REPUBLISH-SETTLE SERIALIZATION & MARK REFRESH

**Republish runs on every cycle** (TUI refresh, post-submit, headless summary); a confirmed durable event append triggers a refresh (tui_app.rs L495–496), driving one cycle that republishes. Lock-guarded write phase acquires runtime-owned advisory write-lock BEFORE mutating workbook (sheets-view lib.rs L960–972), releasing on scope exit. Settle read (mark refresh) occurs ONLY AFTER write returns, never inline with formula publishes (sheets-view lib.rs L1022–1023; republish.rs L64–126 asserts strict order via call-log inspection). Held lock causes republish to refuse: `published: false`, workbook untouched (republish.rs L240–254).

**Price-Settle Window:** Symbol set = open-position symbols only (qty ≠ 0, cycle.rs L327–333). Read-marks polls up to `cfg.max_polls` (default 8) per cycle; exit early when all symbols numeric/errored/absent OR window elapses (sheets-view lib.rs L826–845). Still-transient symbols past the window degrade `TimedOut`; prior good marks carry forward so transient does not null holdings (L870–879). Terminal errors degrade `Permanent` (no prior carry); sub-cent prices degrade `SubCent`, never zero (L354–385). Offline read-back errors propagate—runtime retains prior marks, never silently degrades to empty (cycle.rs L304–306).

**One-Shot Cycle:** Replay → render five bands → republish atomically (per-tab `batchUpdate`, tail-truncate residuals, no half-written window) → settle in one serialized pass → replay again with this cycle's marks to close valuation loop. Failed publishes flag tabs stale, write best-effort in-tab banner (`STALE — last sync {ts}`), retry next cycle (republish.rs L155–187). Atomic per-tab writes preclude mid-rewrite reads.