The main decision (local SQLite index) is already recorded as a **table row** in the Decisions & Alternatives section of `registry-design.md` — that's the right level for it. A full decision doc would be overkill per the heuristic: the choice reads as native once landed (offline-first, no network, snapshot size bounded).

The six forks I surfaced are **spec clarifications**, not new decisions among alternatives. They'll be resolved by editing the EARS lines (e.g., "application-side normalization" → REG-001 edit; "index build errors also retain previous" → REG-007 edit). No decision docs needed.

Which fork were you asking about? Or shall I proceed with your resolutions on all six?