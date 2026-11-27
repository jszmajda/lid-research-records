The decision doc is written at `docs/decisions/change-delivery.md` and linked from the HLD's Key Design Decisions entry. Nothing is committed.

It follows the standard shape: why the choice matters, the criteria, each option described as its advocate would with a fit verdict per criterion, then the selection and what it obligates.

## Please check these in the doc

- **The weights are my reading of what you said.** I marked update latency and vendor independence as major, operational burden and visibility of connectivity failure as moderate, and read load as minor. The selection rests on those weights, so correct any that are off.
- **I added one criterion you didn't name.** The tenet "Connectivity failures must be visible" cuts slightly against sockets: a connection that dies without closing looks the same as a quiet board. I scored sockets as a partial fit there and recorded an obligation for browser sync to check liveness explicitly.
- **The latency rationale is mine.** I justified "major" by saying a board that lags will leave staff keeping the group chat open alongside it. Replace it if your actual reason is different.
- **I named two conditions for revisiting.** The doc says to re-run the judgment if the operations work outgrows the team during event hours, or if latency stops mattering to staff.

## Still open from last time

2. **Freshness goal.** The doc now calls latency a major criterion, but the HLD goal is still "within 15 seconds", which polling meets. Do you want a tighter figure, and what is it?
3. **Vendor-independence tenet.** I wrote the selection as a weighing of criteria, with the tenet still permitting both self-hosted and managed infrastructure. Should that stay this decision only, become a lean for the board's live path, or become a lean against managed services in general?
4. **Socket authorization.** Is opening a socket checked by access or by delivery, and what happens to an open socket on session expiry or revocation? You can decide it now or leave it to the delivery node.
5. **Access design wording.** May I fix the line in `docs/intent/access/access-design.md` that still says "the still-open change-delivery approach"?

Once you approve the HLD and the decision doc, the next step is the first of the three nodes. I'd start with the change store, since delivery and browser sync both depend on its revision history.