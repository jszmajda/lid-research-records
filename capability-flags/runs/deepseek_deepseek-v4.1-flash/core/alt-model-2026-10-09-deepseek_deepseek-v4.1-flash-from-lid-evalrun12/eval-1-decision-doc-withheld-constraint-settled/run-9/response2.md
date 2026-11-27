Overkill — a Decisions & Alternatives row is the right record. Two reasons from the doc test:

- The choice is **settled by an inherited constraint**: the HLD tenet "no runtime network access" already eliminates both network-backed options, so a cold reader isn't facing live alternatives — they're facing the consequence of a tenet.
- It **affects only its own node**: the certificates interface and behavior are unchanged, so nothing downstream is sized around it.

A full decision doc earns its place when the options stay genuinely live for a cold reader and the tradeoffs need re-running. Here the row's rationale settles it. (If the network tenet is ever relaxed, that's when the three options become a real live decision worth a doc — not before.)

Still awaiting your triage on the eight probe gaps and your approval of the LLD before I move to Phase 3.