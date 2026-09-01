# Model upgrade runbook

> A model version change is a migration, not a config change. It silently alters
> the behaviour of every prompt fitted to the previous version.

- **From:** provider/model/version
- **To:** provider/model/version
- **Driver:** deprecation deadline | cost | quality | capability
- **Deadline:** *(if provider-imposed, this is a dated commitment — treat it as one
  from the announcement, not from the month before)*
- **Owner:** …

## 1. Inventory

Which features call this model? Every one of them is in scope.

| Feature | Owner | Risk tier | Calls/day | Prompt count |
|---|---|---|---|---|
| | | | | |

> If this table is hard to fill in, that is the finding. Cost and usage
> attribution by feature is the prerequisite for ever doing this calmly.

## 2. Baseline

Record current performance on the old model **before** touching anything.
Without this you cannot tell a regression from a memory.

- Eval suite results, per feature, per segment: …
- Cost per resolution: …
- p95 latency: …
- Abstention rate: …

## 3. Offline evaluation

Run the full eval suite against the new version.

- [ ] Aggregate results recorded per feature
- [ ] **Per-segment results recorded** — the aggregate can improve while a
      specific category regresses badly, and the aggregate is what you will look
      at unless you have decided otherwise in advance
- [ ] Critical subset checked explicitly: safety refusals, top intents, previously
      fixed bugs
- [ ] Format and schema compliance verified — output-shape drift is common between
      versions and breaks parsers, not just quality
- [ ] Cost per resolution recalculated *(a "cheaper" model that is more verbose or
      needs more retries can be more expensive per resolution)*
- [ ] Latency measured, not assumed

**Regressions found:**

| Feature | Segment | Metric | Before | After | Decision |
|---|---|---|---|---|---|

## 4. Shadow run

- [ ] New version runs against a sample of live traffic, outputs compared and
      logged, **not served**
- [ ] Duration: at least one full weekly cycle, to cover traffic patterns
- [ ] Divergent cases sampled and reviewed by someone with domain knowledge
- [ ] Notable divergences added to the eval set permanently

## 5. Staged rollout

- [ ] Old version remains reachable and deployable throughout
- [ ] Rollout: 5% → 25% → 50% → 100%, with a defined soak at each step
- [ ] Quality metrics monitored per stage, segmented
- [ ] Cost monitored per stage
- [ ] User-reported error rate monitored
- [ ] **Rollback criteria written down before starting** — decide the abort
      threshold while it is still a neutral question

**Rollback trigger:** …

## 6. After

- [ ] Old version pinned in config removed only after a full stable soak
- [ ] **Prompts re-tuned now, not during the migration.** Changing two variables at
      once means learning nothing from either.
- [ ] Eval baselines updated to the new version
- [ ] Judge re-calibrated if the judge model also changed
- [ ] Inventory updated
- [ ] What surprised us, written down:

## Notes for next time

The migration-specific lessons. This section is the reason the runbook improves.
