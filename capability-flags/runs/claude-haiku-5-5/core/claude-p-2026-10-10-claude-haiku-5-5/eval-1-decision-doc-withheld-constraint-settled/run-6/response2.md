It would be overkill. I'd keep the Decisions & Alternatives table in `registry-design.md` as the only record.

A decision doc is for a choice a cold reader would keep re-litigating, where the competing options trade off against several criteria and other nodes get sized around the result. This one doesn't meet that bar. The HLD's no-runtime-network tenet and the cloud-services non-goal rule out the HTTPS directory and the managed search service, so the choice is settled by a constraint you already recorded, not a judgment call. The certificates node is also unaffected, since it only sees `findBySerial`.

The table row already gives a future reader the answer and the reason: the two alternatives need network access at lookup time, which the HLD forbids.

A decision doc would become worth writing only if you wanted to revisit the network tenet. In that case the choice would be live again, and I'd offer one then. I haven't created any decision docs.