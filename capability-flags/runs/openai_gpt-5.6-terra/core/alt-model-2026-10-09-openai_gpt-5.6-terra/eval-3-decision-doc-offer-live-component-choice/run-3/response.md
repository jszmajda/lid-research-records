**Phase 1: HLD Check**

Updated `docs/high-level-design.md` to reflect that the record-store concurrency policy is now selected and that tablet sync and review/export remain out of scope until the record-store contract is complete.

```markdown
| record-store | Accept visit submissions and define how concurrent edits become a current record | docs/intent/record-store/record-store-design.md | Drafted; whole-visit revisions selected |
```

```markdown
The concurrency mechanism belongs to record-store, not this HLD. Tablet-sync and review-export depend on that node's contract: it determines submission metadata, the shape of review work, and which record states can enter an export. Those two designs remain out of scope until the record-store contract is complete.
```

The HLD remains coherent: it preserves submitted edits, keeps exports inspectable, and assigns the concurrency mechanism to the record-store node. The selected policy does not require an HLD-level decision record because it affects only that node.

Approve the HLD update so I can draft the completed record-store design in Phase 2?