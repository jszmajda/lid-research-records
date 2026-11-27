---

## LID Coach — Visit Planner

**Posture:** Solid foundation — design phases done well, two coherence gaps to address before extending the arrow into tests and code.

---

### Scorecard

- ✓ **HLD discipline** — clean architecture and rationale, no implementation detail bleeding upstream
- ✓ **Tenet quality** — four real tie-breakers; all pass the defensible-opposite and lean-not-trigger tests
- ✓ **LLD granularity** — one LLD per declared component, scopes don't overlap
- ✓ **Mutation hygiene** — no accumulation residue, no obsolete markers anywhere in the docs
- ⚠ **Tenet cascade** — urgent-path design silently trades the *first asked, first served* tenet without a recorded exception
- ⚠ **Arrow completeness** — design phases are solid; tests and code not yet begun

**Headline:** The HLD, both LLDs, and specs are clean and internally consistent across the full design layer; the most valuable next step before extending into tests and code is recording the urgent-path tenet exception.

---

### Findings (4 total · 0 high · 3 medium · 1 low)

- **F1 (medium):** Urgent-path open portal window can bypass *first asked, first served* — the fulfillment design allows any eligible signed-in account to claim a short-notice opening during the 20-minute window regardless of interest order, with no Decisions row naming the tenet traded and why · *tenet cascade — designs that work against a project's own tenets without a recorded exception leave intent ambiguous for future sessions; decision capture — the reasoning behind the tradeoff is lost*

- **F2 (medium):** Arrow stops at specs — tests and code phases not yet started · *canonical arrow shape — the arrow is HLD → LLDs → EARS → Tests → Code; without tests, specs have no verified coverage and the arrow can't be walked end-to-end*

- **F3 (medium):** "Checkout" used without definition in `fulfillment-design.md` and FILL-004 — a cold reader hits "claim it through checkout" and "complete checkout" with no prior introduction of what checkout is · *docs carry current intent, written to be read cold — implicit terminology is a context dependency that only resolves for someone who was present when the design was named*

- **F4 (low):** `notBefore` field reference in `fulfillment-design.md` ("schedules a registry scan with `notBefore` set 20 minutes later") is an implementation detail — the scheduling mechanism's internal field name doesn't belong at the intent level · *LLDs close enough of the solution space — the LLD should name the intent (a minimum delay before the scan), not the implementation field that encodes it*

---

### What was audited

- **Read fully:** `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/intake/intake-design.md`, `docs/intent/intake/intake-specs.md`, `docs/intent/fulfillment/fulfillment-design.md`, `docs/intent/fulfillment/fulfillment-specs.md`
- **Enumerated:** 2 LLDs, 2 spec files, 15 specs total (INTAKE-001–007, FILL-001–008)
- **Code and test sampling:** no code or test files exist; tests and code phases not yet started
- **Arrow-maintenance overlay (`docs/arrows/`):** not present

---

Want me to walk through any finding in more detail, focus on a specific theme, or work through next steps together? You can also name a specific finding to dig into.

If you have broader questions about using LID — how to structure the tests phase, when to split an LLD into a sub-HLD, what to do when a tenet needs an exception — I can help with those too.