Phase 1 — HLD check complete

Coherence pre-flight for segment PREVIEW
- HLD exists at docs/high-level-design.md and covers the preview worker domain. Architecture lists Previews with a private 12 GiB cache and notes the eviction policy remains open.
- LLD exists at docs/intent/previews/previews-design.md, prefix PREVIEW, parent high-level-design.
- EARS specs exist at docs/intent/previews/previews-specs.md with PREVIEW-001 … PREVIEW-005.
- LLD → EARS trace: PREVIEW-001/002/003 cover the GET /internal/previews contract and deduplication described in the LLD; PREVIEW-004 covers the 12 GiB admission bound; PREVIEW-005 covers render failure cleanup.
- EARS → tests trace: no test files found in the workspace. Tests are required before code in Phase 5.
- HLD → LLD trace: HLD tenets “Keep cache paths and replacement bookkeeping private to the preview worker” and “A cache miss is ordinary behavior, not an API failure” are reflected in the LLD private-cache and fixed-interface sections.

The change you requested — adopt 2Q eviction to protect comparison sheets during big screenings — is a leaf LLD decision. It does not alter the HLD architecture or the public preview interface, which remains fixed. The HLD statement “Its eviction policy remains open” will become stale once the LLD is finalized.

Approve proceeding to Phase 2 — LLD check/draft for PREVIEW with 2Q selection recorded in the Decisions & Alternatives table and the Private Cache section updated to describe the two-queue structure, size split, and bookkeeping?