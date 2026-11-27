Resuming the registry work — this is the Phase 2 stop. (Phase 1 HLD check is clean: the architecture is unchanged; last session stopped at the option sketch, so we resume at Phase 2.)

**Coherence pre-flight.** Specs REG-001…004 trace to the LLD, the LLD matches the HLD, and there is no test drift (no tests exist yet — all four specs are active `[ ]` gaps). One finding: the HLD tenets ("no runtime network access," "no network route," USB-only updates) and the "cloud services" non-goal already eliminate the on-site HTTPS directory and managed-search options. The choice is settled by an inherited constraint, and all three options kept `findBySerial` and the certificate interface unchanged, so its effect stays inside the registry segment.

**Decision recording — no question to you.** Judging the landed state, not how close the options looked in deliberation: an inherited constraint settles this choice and it affects only the registry segment, so I neither offered nor wrote a decision doc. I recorded it as one Decisions & Alternatives row in the registry LLD, without asking.

**Phase 2 output — `docs/intent/registry/registry-design.md` finalized** (summarized; full text in the file). Written as a fresh author: all "not selected yet / candidates / remain open / pending your choice / no certificate change" residue removed; rejected alternatives live only in the Decisions table.
- Interface: `findBySerial(serial)` → `Found(record, snapshotDate)` | `NotFound(snapshotDate)`; fixed result types; certificates uses only this interface and never reads registry storage.
- Backend: active snapshot backed by a local embedded SQLite index built from its records; lookups read only kiosk files, no service, no network.
- Import: verify signature, reject unsupported schema, validate serial uniqueness, build the index, activate snapshot+index together; failure leaves the previous snapshot+index active.
- Lookup: normalize surrounding whitespace + uppercase ASCII (punctuation significant), query the index, return snapshot date even on NotFound.
- `docs/high-level-design.md`: dropped the stale "Its private lookup backend remains open." clause — a coherence fix, no architectural change, no new tenets, no Key Design Decisions section, because the decision's substance lives in the registry leaf.
- No cascade into certificates: interface unchanged, so that segment's LLD/specs are untouched. EARS specs REG-001…004 are unchanged so far.

**LLD edge-case probe** (delegated to a blind reader; summarized, most load-bearing first). These are gaps, not answers — I have resolved none:
1. No active snapshot / cold start: `NotFound` needs a date but no initial-state or error variant is defined.
2. Is serial uniqueness over raw or normalized serials (two raw serials can collapse under trim+uppercase)?
3. Are index keys normalized like the lookup input, or is only lookup normalized?
4. "Activate snapshot and index together": no staged/switching state or recovery if interrupted.
5. Failure during activation (post-validation) is undefined; "import failure" covers only pre-activation.
6. Lookup during an in-flight import / at the switch: no visibility or ordering rule.
7. "Reports a useful error": no error shape, and `findBySerial`'s fixed results carry no error variant.
8. Missing/corrupt/unreadable SQLite index at lookup: no storage-error shape.
9. Snapshot older than the active one: no freshness/monotonicity rule.
10. Ordering/precedence when signature, schema, and uniqueness validation all fail together.
11. Empty / all-whitespace / embedded-whitespace / non-ASCII serials: normalized value and exact-match semantics unstated.

**Stop — I need your ruling before Phase 3.** No tests or code were written; those come at Phases 5–6 after their own stops.
1. Numbered triage: which of gaps 1–11 should be fixed in the LLD now, and which deferred as open questions?
2. Approve the finalized registry LLD + HLD fix (or give numbered edits) so I can proceed to Phase 3 — the EARS spec draft and consistency report.