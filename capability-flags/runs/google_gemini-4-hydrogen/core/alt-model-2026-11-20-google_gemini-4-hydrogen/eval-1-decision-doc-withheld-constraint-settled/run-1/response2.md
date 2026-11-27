A standalone decision doc would be **overkill** here—the **Decisions & Alternatives** table row in `docs/intent/registry/registry-design.md` is the right level.

Under LID's earns-its-place test (judged from the landed state, not how close the deliberation felt), a full decision doc is only warranted when a choice stays genuinely live for a cold reader and other design nodes are sized around it. Here, two things settle it without a separate doc:

1. **Inherited constraints eliminate the alternatives:** The HLD tenets already require all serial-number lookups to use local files on the kiosk with no runtime network access, which rules out both the on-site HTTPS directory and the managed search service.
2. **Scope is local to `registry`:** `findBySerial(serial)` and its result types stay unchanged, and `certificates` is unaffected by the storage choice.

Whenever you're ready, let me know if you approve `registry-design.md` as written (and how you'd like to triage the Phase 2 edge-case probe items above) so we can move to **Phase 3 (EARS specs)**.