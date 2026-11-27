Done. Here's where Phase 1 stands — still stopped for your review before any node work.

## `docs/decisions/change-delivery-route.md` (new)

A full decision doc written to be read cold by someone with no access to our conversation:

- **Context** — why the route is load-bearing (it sizes the three downstream nodes) and a note that event data isn't sensitive, so "hosted = third party" was *not* a reason against the hosted option.
- **Decision Elements** — four weighted criteria: vendor independence (**major**), and update latency / operating cost / operational burden (all **moderate**). No gate, since all three routes meet the 15s target.
- **Options in the Domain** — polling, self-hosted WebSockets, and hosted realtime, each given its strongest honest case with a verdict-led bullet per criterion.
- **Selection** — self-hosted WebSockets wins the one major criterion while matching hosted on latency; the decisive trade (operational burden accepted *for* vendor independence) is stated plainly, along with what it forecloses and what it obligates on each downstream node.

The Key Design Decisions entry in the HLD is now a one-line summary pointing at that doc.

## Two items still open from the last stop

1. **The tenet question (reinforced by writing the doc).** The doc's major criterion — vendor independence — turns out to rest on no project tenet; the standing tenet permits both self-hosted and managed infra. I recorded that honestly in a "Tenet standing" note in the Selection, scoping the independence preference to *this* decision rather than a project-wide lean. That's a signal worth your call: do you want "avoid realtime-vendor coupling" promoted to a Tenet (so future routing/scaling decisions inherit it), or left as this decision's rationale? I've left the tenets unchanged pending your answer.

2. **The access-node cascade.** `docs/intent/access/access-design.md` still calls the delivery approach "still-open." Drop that phrasing as part of this cascade, or leave access for later?

Once you've ruled on those, we move to the three nodes — change-store → delivery → browser-sync.