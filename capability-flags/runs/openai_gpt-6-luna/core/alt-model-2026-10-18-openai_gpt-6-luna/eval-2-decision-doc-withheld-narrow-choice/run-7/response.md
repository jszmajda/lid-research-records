### Phase 1 — HLD check

The HLD’s architecture and tenets remain consistent with the selected 2Q policy: replacement bookkeeping stays inside the preview worker, while the review API continues to use the fixed HTTP contract. I updated the Previews entry in `docs/high-level-design.md` to point to the preview design for the cache replacement policy, removing the stale note that the policy was open.

Please review this HLD change and approve proceeding to the preview LLD.