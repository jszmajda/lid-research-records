I'd call it overkill here — a table row is the right size for this one.

The decision-doc test isn't "was it a hard call" (you said you went back and forth), it's whether a cold reader of the *landed* choice would still find it non-obvious enough to re-litigate, and specifically whether other design nodes are being sized around the result. Neither holds:

- The certificates component's interface, result type, and behavior are identical under all three options — nothing downstream is sized around which backend won.
- Once landed, the choice reads as obviously consistent with an existing HLD tenet ("no runtime network access; kiosks have no network route during normal operation") — the HTTPS-directory and managed-service options were never really live against that constraint, even though they looked close to you in the moment.

That's exactly the case the skill calls out: contested while you worked, obvious once it lands, needs neither doc nor extra ceremony beyond the row. The table row I added already carries the context, criteria, and rejected alternatives, so a cold reader isn't missing anything a full doc would add.