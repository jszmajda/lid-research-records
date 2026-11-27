Now I'll work through the LID workflow to finish the preview design with the 2Q cache eviction strategy.

## Phase 1 — HLD Check

The HLD currently states that the eviction policy "remains open." With the 2Q decision made, I'll update the HLD to reflect this choice while keeping implementation details in the previews LLD.

**Proposed HLD change** to the Architecture section's Previews bullet:

```markdown
- Previews: `docs/intent/previews/previews-design.md`, with `docs/intent/previews/previews-specs.md`. Owns rendering, pending jobs, and a private 12 GiB cache using a 2Q eviction policy.
```

The brief mention of 2Q belongs in the HLD because it affects the system's behavior under load (how well comparison sheets survive sequential screenings), which is architectural context. The mechanism details — queue sizes, promotion rules — belong in the LLD.

Does this HLD update correctly capture the decision at the appropriate level?