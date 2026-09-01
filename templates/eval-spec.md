# Evaluation spec: [Feature name]

> Written **before** anyone tunes anything. The purpose is to define "better"
> while it is still a neutral question, rather than after someone has a change
> they want to ship.

- **Feature:** …
- **Owner:** …
- **Date:** YYYY-MM-DD
- **Current rung:** 0–5 *(see the [maturity ladder](../04-evaluation.md#the-maturity-ladder))*
- **Target rung:** …

## The decision this informs

What will we *do* differently depending on the result? An eval that cannot change
a decision is a dashboard, and dashboards are optional.

## What "good" means here

Plain language, before any metric. What does a satisfied user get? What is the
worst acceptable output?

## Metrics

### Retrieval *(if applicable — measure this separately, always)*

| Metric | Definition | Current | Target | Blocks release? |
|---|---|---|---|---|
| Recall@k | Was the needed context retrieved at all? | | | |
| Precision@k | How much irrelevant context came with it? | | | |
| Rank of first relevant | Did it survive the context budget? | | | |

### Generation *(scored given correct context)*

| Metric | Definition | Current | Target | Blocks release? |
|---|---|---|---|---|
| Faithfulness | Is the answer supported by the context? | | | |
| Completeness | Did it use what it was given? | | | |
| Format compliance | Valid schema / required fields | | | |
| **Abstention rate** | How often it correctly declines | | | |

Abstention is not optional. A system that never declines is uncalibrated, and the
rate dropping is a regression even when every other number improves.

### End to end

| Metric | Definition | Current | Target | Blocks release? |
|---|---|---|---|---|
| Task success | User got what they came for | | | |
| Cost per resolution | See [unit economics](../06-operations.md#unit-economics) | | | |
| p95 latency | | | | |

## The dataset

- **Size:** N cases
- **Sources:** production logs (%), reported failures (%), existing human
  decisions (%), adversarial (%), synthetic (%)
- **Sampling:** how the distribution was chosen, and how the long tail is
  represented
- **Holdout:** N cases never tuned against
- **Segments:** the slices reported separately — language, user type, query
  category, tenant. Averages hide the failures that matter.
- **Refresh cadence:** when new cases get added, and by whom

> If more than a small fraction is hand-written by the team, say so here and treat
> the results as optimistic. Hand-written cases sample the distribution you
> imagine, not the one you have.

## Judge configuration *(if using an LLM judge)*

- **Judge model and version:** *(must differ from the model being evaluated)*
- **Human calibration set:** N cases labelled by humans
- **Measured agreement:** __% *(below ~80% on this task, the judge is not
  measuring what we think — fix it before trusting any number above)*
- **Re-calibration trigger:** any judge model change

## Release gates

- **Hard block:** any regression in [critical subset — safety refusals, top intents
  by volume, previously-fixed bugs]
- **Hard block:** aggregate regression beyond [tolerance] on [metric]
- **Warn:** everything else

Gating too tightly on a noisy metric trains the team to bypass the gate, which is
worse than having no gate.

## Known gaps

What this eval does *not* cover, stated honestly, so nobody mistakes a green run
for a guarantee.
