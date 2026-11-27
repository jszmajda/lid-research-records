**Concern: settle-pass handling of transient (non-numeric, not-yet-settled) price-cell readings during marks read-back (`sheets_view::read_marks`).**

**Ubiquitous**
- The system shall distinguish three price-cell reading states: `Numeric` (settled), `Transient` (`#N/A`/`Loading...`, not-yet-known), and `Permanent` (terminal non-numeric error) — Transient and Permanent are never conflated.
- The system shall read prices on a settle pass that polls `read_price_pass` separately from the tab write, never inline with it.
- A symbol absent entirely from a poll's returned pass shall be treated identically to an explicit `Transient` reading for settlement purposes.

**State-driven**
- WHILE any requested symbol's latest reading is `Transient` or absent, THE settle loop SHALL continue polling, up to `SettleConfig.max_polls` polls (default 8; each call site here uses explicit values 2/3/4/8).
- WHILE a symbol's reading is `Permanent`, THE system SHALL treat it as settled immediately (never retried, never counted toward the transient/absent condition), so a run of all-`Permanent` readings ends the loop before `max_polls` is reached.

**Event-driven**
- WHEN every requested symbol's latest reading is numeric-or-terminally-errored (i.e., none remain `Transient`/absent), THE settle loop SHALL terminate before reaching `max_polls`.
- WHEN the poll count reaches `max_polls` (`polls >= cfg.max_polls`) with symbols still `Transient`/absent, THE settle loop SHALL terminate — exactly `max_polls` calls to `read_price_pass`, no more, no fewer.
- WHEN, at loop termination, a symbol's latest reading is `Transient`/absent AND a prior cached `Mark` exists for it, THE system SHALL carry that prior `Mark` forward **unchanged** (identical `price_cents` and `quote_date`, not re-stamped) into `MarksProduced.marks`, and SHALL NOT record it in `degraded`.
- WHEN, at loop termination, a symbol's latest reading is `Transient`/absent AND no prior `Mark` exists, THE system SHALL record it in `degraded` with reason `TimedOut` and emit no mark.
- WHEN a symbol's latest reading is `Permanent`, THE system SHALL record it in `degraded` with reason `Permanent`, regardless of any prior mark (no carry-forward for terminal errors — carry-forward applies only to Transient/absent).

**Unwanted behavior**
- IF the settle window elapses while a symbol is still transient/absent, THEN the system SHALL NOT fabricate a mark and SHALL NOT value it at zero — only `TimedOut` degradation or prior-mark carry, never a synthesized value.
- IF `read_price_pass` itself errors (transport/offline), THEN `read_marks` SHALL propagate `Err` and produce no `MarksProduced` at all — never an empty/degraded-looking marks set — leaving carry-forward of prior marks to the caller.