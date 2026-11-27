A separate decision doc would be overkill here. The row in the Decisions & Alternatives table is the right level for two reasons:

1. **Inherited constraints eliminate the alternatives:** The HLD tenets strictly mandate that kiosks operate with no runtime network access and perform all lookups using local files. Both the on-site HTTPS directory and the managed search service violate those standing constraints.
2. **The choice is fully contained within the component:** The interface to `certificates` (`findBySerial`) remains identical regardless of the backend, so no neighboring nodes are sized around this decision.

To a cold reader of the landed system, a local embedded index is the natural shape for an offline kiosk. A future reader wondering why remote alternatives weren't chosen is completely answered by the rationale row in the table.