**Reconstructed EARS requirements — Est. Tax Rate cell (Positions tab, column H)**

**Ubiquitous — encoding format.**
The system shall render the Est. Tax Rate value as a signed percent string of the form `[-]<whole>.<frac4>%`, where `whole = |ppm| / 10_000` and `frac4 = |ppm| % 10_000` zero-padded to exactly 4 digits (e.g. `Ppm(150_000)` → `"15.0000%"`). No independent rounding is applied — the decomposition is an exact base-10 split of the ppm integer, since 1 ppm equals exactly 0.0001 percentage points.

**Ubiquitous — value/formula typing.**
The Est. Tax Rate cell shall always be emitted as `Cell::Value` (an engine-written value), never `Cell::Formula`. Per the `batch_update_view` contract, a `Cell::Value` MUST be written as Sheets `userEnteredValue` (never a forced/string value), so `"20.0000%"` is parsed exactly as a human-typed percent literal: the numeric fraction `0.20` under a percent number format — coercible into arithmetic, not inert text.

**State-driven — presence of a computed rate.**
WHILE a symbol has a computed effective unrealized tax rate in `effective_rates`, the system shall render that cell as the `fmt_ppm`-formatted percent string. WHILE a symbol is absent from `effective_rates` (a degraded estimate), the system shall render the cell as the empty string `""`.

**Event-driven — consumption by post-tax formulas.**
WHEN the Positions tab is rendered, the system shall emit, on the same row `r` as the rate cell `H{r}`:
- `Est. Unrealized Tax (est)` (I) as `=G{r}*H{r}`
- `Net Unrealized (est)` (J) as `=G{r}*(1-H{r})`

Both formulas shall reference only their own row's `G` and `H` cells (row-anchored; a row shift must never mis-pair cells across rows).

**Unwanted behavior — degraded/absent rate.**
IF the Est. Tax Rate cell is empty (degraded/absent), THEN the dependent formulas shall still evaluate arithmetically rather than error: Sheets treats the blank cell as `0` in arithmetic context, so `Est. Unrealized Tax` degrades to `0` and `Net Unrealized` degrades to the pre-tax `Unrealized P&L` figure (`G{r}`).

**Invariant (pinned by test on the encoding pipeline).**
The percent string shall always end in `%`; its numeric body, divided by 100, shall be a finite fraction in `[0.0, 1.0]`; and the identity `G*H + G*(1-H) == G` shall hold for any valid rate — i.e. the two post-tax formulas must partition the pre-tax figure exactly, with no loss/duplication.