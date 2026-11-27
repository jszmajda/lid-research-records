**Ubiquitous:** The system shall represent every Sheets-side republish failure (a failed `batch_update_view`, a failed `read_price_pass`, a failed `write_stale_banner`, a failed `set_tab_order`) as the single error value `ViewError::PublishFailed`.

**Event-driven:** WHEN a view tab's `batch_update_view` call fails during republish, the system shall (a) leave that tab's previously-published header and rows completely unchanged (no partial/half-written data range), (b) add that tab's name to a *persistent* stale set, and (c) attempt a best-effort write of the banner text `"STALE — last sync {ts}"` (exact em-dash, `{ts}` = the caller-supplied `stale_banner_quote_ts`) to cell `AA1` of that tab.

**Unwanted behavior:** IF the best-effort banner write also fails, THEN the system shall swallow that error (no propagation, no second retry that cycle) and leave the tab stale, relying on the TUI as the fallback staleness surface.

**Event-driven:** WHEN republish processes multiple tabs in one call, each tab's write shall be attempted independently — a failure on one tab shall not skip or abort the write attempt for any other tab in the same batch.

**State-driven:** WHILE any tab's write failed OR the trailing `set_tab_order` call failed, the returned `RepublishOutcome.published` shall be `false` (logical AND across all per-tab results and the order reassert); a `set_tab_order` failure alone shall NOT add any tab to the stale set.

**Event-driven:** WHEN a previously-stale tab republishes successfully on a later call, its name shall be removed from the stale set (retry clears staleness); the returned `stale_tabs` always reflects the full accumulated set held across cycles, not only failures from the current call.

**Event-driven:** WHEN the advisory write-lock cannot be acquired before republish begins, the system shall write nothing to any tab, attempt no banner, and return immediately with `published: false` and the stale set unchanged — a full short-circuit before any mutation, distinguishing it from a partial per-tab failure.

**Unwanted behavior:** A failed republish shall never mutate or corrupt the canonical event log (store); failure is confined to the view layer and is retried on the next sync.

**Ubiquitous (boundary):** A tab absent entirely (fresh workbook) is not classified as a republish failure — the adapter creates the sheet, writes the frozen header once, then retries the data write, surfacing `PublishFailed` only if that bootstrap sequence itself errors.