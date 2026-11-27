A row in the Decisions & Alternatives table is sufficient—a full decision doc would be overkill.

**Why:** The HLD's first tenet explicitly states "All serial-number lookup SHALL complete using files on the kiosk; no runtime network access is permitted." That constraint alone settles the choice. A cold reader looking at the registry LLD would immediately see why SQLite was chosen—it's the only option that satisfies that inherited constraint. The choice doesn't stay "live" for them; the HLD makes it obvious.

The skill's guidance is: don't offer a decision doc for choices that "an inherited constraint settles" or that "affect only their own node." Both apply here.

That said, your observation that you went back and forth more than expected is real, and it's worth noting in the row's rationale (which I did: "Offline-first design eliminates network dependency..."). The deliberation was genuine, but the result reads as inevitable once the constraints are in view—which is what matters for a cold read.

---

Ready to proceed to **Phase 3 (EARS spec draft)**, or would you like to close any of the edge-case gaps I surfaced before moving forward?