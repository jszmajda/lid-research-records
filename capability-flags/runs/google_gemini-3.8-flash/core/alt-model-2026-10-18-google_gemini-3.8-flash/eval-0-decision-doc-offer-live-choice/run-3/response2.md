I have created the decision document in `docs/decisions/change-delivery-mechanism.md` and linked it from the HLD's Key Design Decisions section.

### Summary of Artifacts

1. **`docs/decisions/change-delivery-mechanism.md`**:
   - **Context**: Frames the change-delivery problem around MarketBoard's 40 weekend markets, up to 800 concurrent staff browsers, and opening-time peaks of 20 edits per second.
   - **Decision Elements**: Evaluates Latency / Freshness (Major), Vendor Independence & Operating Cost (Major), Operational Complexity (Moderate), and Catch-up & Reconnect Recovery (Moderate).
   - **Options Analyzed**: Five-second HTTPS polling, self-hosted WebSockets, and hosted realtime service, evaluating concrete fit verdicts against each criterion.
   - **Selection**: Details why self-hosted WebSockets was chosen and documents the downstream obligations accepted (managing persistent sessions, heartbeats, and replay/snapshot recovery).

2. **`docs/high-level-design.md`**:
   - Linked the decision doc from the **Key Design Decisions** entry.

---

### Phase 1 Stop for User Review

Does the decision document and HLD update look good to proceed to Phase 2 (drafting the three downstream design nodes: `change-store`, `delivery`, and `browser-sync`), or would you like any adjustments to the rationale or framing?