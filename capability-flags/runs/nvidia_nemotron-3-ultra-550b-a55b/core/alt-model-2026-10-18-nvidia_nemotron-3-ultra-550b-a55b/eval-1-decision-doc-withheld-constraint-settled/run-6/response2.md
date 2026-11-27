Table row is sufficient — no decision doc needed.

**Why:** The choice is now settled in the LLD's Decisions & Alternatives table with a one-line rationale that names all three alternatives and the key criteria (offline, no network/service dependency, no recurring cost/credentials, index rebuild encapsulated, fits kiosk resources). A cold reader would see that row and not question it. No other design nodes are sized around this backend — the `findBySerial` interface is fixed regardless — so nothing downstream would re-litigate it.

The "earns-its-place" test (from `references/decision-doc-template.md`): *would a cold reader of the result find the choice non-obvious — question it, or be tempted to reverse it?* → No. The table row settles it.

---

Proceed to **Phase 3 — EARS spec update**? I'll add specs covering the SQLite-specific behaviors (index build, atomic swap, lookup semantics, latency).