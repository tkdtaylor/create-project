---
description: Audit the project for doc/spec/diagram/fitness drift and apply fixes
---
Invoke the **create-project** skill with arguments `mode=fix-drift`.

This runs the project drift audit: dispatches parallel sub-agents across inventory, hook wiring, spec drift, fitness rows, and README freshness, aggregates a prioritized punch list, and offers to apply the must-fix and should-fix items. Skips the project interview.
