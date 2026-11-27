```rust
/// Integer minor-unit currency; kernel is the sole source of Cents arithmetic.
pub type Cents = i64;

/// Monotonic settle-pass watermark. Advances only when a marks read-back
/// settle completes — never on a live/formula read.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub struct SyncId(pub u64);

/// Kernel-computed, stacked (cumulative across all prior tax lots/events for
/// a symbol, not a per-event delta) tax-adjusted figure, valid as of one
/// completed sync.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct KernelTaxFigure {
    pub symbol: String,
    pub cost_basis: Cents,
    pub realized_gain: Cents,
    pub unrealized_gain: Cents,
    pub tax_adjusted_value: Cents,
    pub as_of_sync: SyncId,
}

/// One row published to the Tax tab. Carries its own source label so it
/// cannot be visually confused with the Positions tab's live estimate.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct TaxTabRow {
    pub symbol: String,
    pub tax_adjusted_value: Cents,
    pub realized_gain: Cents,
    pub unrealized_gain: Cents,
    pub as_of_sync: SyncId,
    pub source_label: &'static str,
}

/// Pure projection kernel figures -> Tax tab rows. No accounting/tax math,
/// no price lookup, no GOOGLEFINANCE formula: values are copied verbatim
/// ("kernel-exact") from the last completed settle pass.
pub fn project_tax_tab(figures: &[KernelTaxFigure]) -> Vec<TaxTabRow> {
    figures
        .iter()
        .map(|f| TaxTabRow {
            symbol: f.symbol.clone(),
            tax_adjusted_value: f.tax_adjusted_value,
            realized_gain: f.realized_gain,
            unrealized_gain: f.unrealized_gain,
            as_of_sync: f.as_of_sync,
            source_label: "kernel (as of last sync)",
        })
        .collect()
}
```

Assumptions invented:

1. "Stacked" = each figure is a cumulative aggregate across all prior tax lots/events for a symbol, not a per-transaction delta — no other stacking semantics (e.g. chart-stacking) are implied by this text-only spec.
2. "Kernel-exact" = a byte-for-byte copy of kernel `Cents` output with zero reformatting/rounding in sheets-view, enforcing the "no accounting math here" boundary.
3. "As-of-last-sync" = each figure already carries the `SyncId` of the last completed settle pass; `project_tax_tab` does not recompute or advance it — publish is a pure, timestamp-preserving copy.
4. "Distinct from Positions" is satisfied structurally: a separate `TaxTabRow` type plus a `source_label` field, rather than any shared formula/live-price column — this tab has no GOOGLEFINANCE input at all.
5. Empty input slice is a valid degenerate case, producing an empty row vec, not an error (no tax activity yet is a legitimate ledger state).
6. All figures passed in are assumed to already share a consistent `as_of_sync` (i.e., upstream guarantees a single settle-pass snapshot); per-row watermark is retained defensively but this function performs no cross-row consistency check — validation, if needed, is kernel/caller responsibility, not sheets-view's.
7. Row ordering is whatever the kernel slice provides; no sorting/dedup is performed here.
8. Negative or zero `Cents` values are passed through unexamined — bounds/sign validation is out of scope for a projection-only crate.