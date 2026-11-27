## Phase 1 — HLD check

Updated `docs/high-level-design.md` to record the selected policy:

> Previews owns rendering, pending jobs, and a private 12 GiB cache using 2Q eviction to protect reused contact sheets from sequential screening scans.

The existing preview and review-api designs and specs otherwise remain coherent with the HLD. The 2Q decision belongs in the preview LLD; the public API and render queue do not need architectural changes.

Please approve this HLD update so I can proceed to Phase 2 and complete the preview LLD, including its 2Q queues, admission and promotion behavior, sizing, and edge-case probe.