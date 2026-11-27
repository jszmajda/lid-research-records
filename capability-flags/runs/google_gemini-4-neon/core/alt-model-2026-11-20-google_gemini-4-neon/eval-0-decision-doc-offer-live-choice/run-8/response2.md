Created `docs/decisions/change-delivery.md` and linked it from `## Key Design Decisions` in `docs/high-level-design.md`.

### `docs/decisions/change-delivery.md`

- **Frontmatter:** `node: high-level-design`
- **Context:** Frames the 40-market / 800-browser / 20 edits-per-second problem, the three coupled downstream nodes (`change-store`, `delivery`, `browser-sync`), and why all three options satisfy the existing HLD goals and tenets.
- **Decision Elements:** Four weighted criteria — **update latency (major)**, **vendor independence and recurring cost (major)**, **operational simplicity for connections and recovery (moderate)**, and **steady-state read and publication efficiency (minor)**. No binary gates (all three options pass the goals and tenets).
- **Options in the Domain:** Full descriptions, per-criterion fit verdicts (`strong` / `partial` / `weak`), and neutral summaries for **Five-second HTTPS polling**, **Self-hosted WebSockets**, and **Hosted realtime service**.
- **Selection:** Records **Self-hosted WebSockets** as winning on both major criteria while explicitly accepting the `weak` fit on operational simplicity, closes the loop against the HLD tenets, and lists what the choice forecloses and obligates in `change-store`, `delivery`, and `browser-sync`.

### `docs/high-level-design.md` (`## Key Design Decisions`)

```markdown
- **Self-hosted WebSockets for change delivery.** Committed revisions are pushed over self-hosted WebSockets rather than five-second HTTPS polling or a hosted realtime service — trading self-hosted connection capacity and reconnect/catch-up operations for low-latency updates without recurring realtime vendor fees or provider coupling. See [Change Delivery decision](decisions/change-delivery.md).
```

Please review `docs/decisions/change-delivery.md` and the HLD update. Once approved, let me know:
1. Whether to also update the stale "still-open change-delivery approach" wording in `docs/intent/access/access-design.md`.
2. Which of the three downstream nodes (`change-store`, `delivery`, or `browser-sync`) you want to draft first in Phase 2.