I’d keep this as a **Decisions & Alternatives row**. The length of the debate isn’t what makes a decision doc useful; it’s whether a future reader needs a fuller analysis to understand or reconsider the choice.

Here, the rationale is compact: **protect comparison sheets from sequential scans, accepting extra bookkeeping and queue tuning**. The choice lives entirely inside the preview worker; other components aren’t being designed around its eviction mechanics. The existing row preserves the meaningful alternatives and why 2Q wins.

The promotion rule and queue allocation still need decisions, but they belong in the preview design. A standalone decision doc would mostly duplicate that material rather than add reasoning a future maintainer needs.