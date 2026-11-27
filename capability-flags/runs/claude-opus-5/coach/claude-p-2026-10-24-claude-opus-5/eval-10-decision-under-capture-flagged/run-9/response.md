**LID Coach — review of Field Notes**

*(Non-interactive run: no prompts were needed. The arrow-maintenance overlay isn't installed (`docs/arrows/` absent), so structural findings below are stated as patterns rather than enumerations, per the skill's default.)*

---

### Executive summary

**Posture:** *Bootstrapping — arrow is clean and well-linked at the top; design-layer rationale and the downstream phases are where the value is sitting.*

**Scorecard**
- ✓ **Configuration** — `## LID` block well-formed, Mode: Full, directive present and current-named
- ✓ **Linkage hygiene** — `prefix: SYNC`, `parent: high-level-design`, spec file names its LLD; IDs unique, zero-padded, grep-clean
- ✓ **Mutation hygiene** — no change-narration, no `[obsolete]` residue, no planning text; docs read cold
- ⚠ **Tenet cascade** — the conflict mechanism works against a stated goal under a condition the LLD itself describes
- ⚠ **Decision capture** — the load-bearing decision of the project is recorded as one word
- ✗ **Arrow completeness** — tests and code phases are absent while specs are marked done

**Headline:** For a two-document project the arrow is genuinely well-formed — frontmatter linkage, clean spec IDs, a real tenet, and docs with no accumulated residue, which is more discipline than most projects this young have. The single most valuable next step is the clock-skew conflict decision in `sync-design.md`: it conflicts with the HLD's convergence goal under conditions the LLD names two sections earlier, and nothing on the page records that trade.

---

### Findings (7 total · 3 high · 3 medium · 1 low)

- **F1 (high):** `sync-design.md:17` resolves conflicts by *device* wall-clock while `:9` states device clocks are routinely minutes wrong until reconnect — under that condition the genuinely later edit can lose and be discarded, working against the HLD goal *"Convergent state after reconnect"*; no Decisions row records the exception · *tenets capture forward-looking preference* + *coherence is adjacency* — design nodes lean the way the HLD says to lean, or record why not
- **F2 (high):** the `Conflict resolution` row's rationale is "Simpler." — a cold reader holding the clock-skew paragraph would still want to reverse this choice, and can't reconstruct what was weighed (server-receipt ordering? logical clocks? CRDT?) or that silent edit loss was the accepted cost · *docs carry current intent, written to be read cold* — the keep-side: live decisions need their reasoning on the page
- **F3 (high):** both specs carry `[x]` status yet the repo contains no code, no tests, and no `@spec` annotations — the arrow stops at EARS · *canonical arrow shape* (`HLD → LLDs → EARS → Tests → Code`) + *tests carry `@spec` annotations*
- **F4 (medium):** `sync-design.md:13` leaves merge edges open — note identity, what "pending edits" spans, ordering of a multi-edit batch, behavior on partial upload failure; two reasonable agents would land on incompatible implementations · *LLDs close enough of the solution space*
- **F5 (medium):** behaviors the LLD names have no spec — on-device SQLite storage, NTP resync on reconnect, upload failure/retry — so they're unnamed intent with nothing to test against · *effective intent-tree alignment*
- **F6 (medium):** the HLD carries no `## Key Design Decisions` and no success metrics, and `## Architecture` (`:13`) is a single clause — the architecture-level *why* that outlives any implementation isn't yet on the page · *HLD is architecture and rationale*
- **F7 (low):** one tenet (*Boring over clever*) — a real tie-breaker with a defensible opposite, so the one you have is sound — but it's the only pre-narrowed lean in a system whose sharp recurring question is how much edit loss is acceptable · *tenets capture forward-looking preference*

---

### What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md` — the project's entire file set (4 files)
- Enumerated: 1 LLD, 1 spec file, 2 EARS specs, 1 design-tree segment (`SYNC`), 1 tenet
- Arrow-path walked: the single segment end-to-end — HLD *Approach/Architecture* → `sync-design.md` → `SYNC-001/002` → (no tests) → (no code)
- Linkage metric: 0 `@spec` references found anywhere in the repo; 2 unique spec IDs declared
- Overlay: `docs/arrows/` not present — no `index.yaml` to consult, and no structural enumeration attempted from sampled reads
- Cold-read pass: performed over all three LID docs; no change-narration or obsolete-marker residue found, one clarity gap surfaced as F2

---

Want me to walk through any of these in detail, focus on a priority band, or work through the clock-skew decision (F1/F2) together — that one pair is where most of the leverage is? You can also pick a single finding to dig into.

If you have broader questions about using LID on this project — when `sync` would warrant splitting into a sub-HLD, where tests-first fits as you start implementing, whether to install the arrow-maintenance overlay this early — I can help with those too. Note that I don't edit files from a coach run: configuration changes go through `/update-lid`, and the doc edits above are yours to apply.