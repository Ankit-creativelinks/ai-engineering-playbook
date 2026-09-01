# ADR-NNN: [Short decision title]

> An ADR format adapted for AI systems. The difference from a standard ADR is the
> last two sections: AI systems have dependencies that change underneath you, so
> a decision record that does not state its expiry conditions is incomplete.

- **Status:** Proposed | Accepted | Superseded by ADR-NNN | Reversed
- **Date:** YYYY-MM-DD
- **Deciders:** names
- **Consulted:** who was asked
- **Risk tier:** Low | Medium | High *(see [governance](../06-operations.md#governance-proportionate-to-risk))*

## Context

What is true right now that forces a decision? Constraints, requirements,
volumes, deadlines. Written so someone with no memory of this quarter can follow
it.

State the **problem**, not the solution you already have in mind. If this section
only makes sense given the decision below, it is written wrong.

## Options considered

For each: what it is, and why it is or is not the answer. Include the option you
rejected quickly — future readers will ask, and "we considered and rejected it
for reason X" is a real contribution.

### Option A: [name]

- **How it works:** …
- **Cost:** build time, per-query cost, operational burden
- **Failure mode:** what does it do when it is wrong?
- **Reversibility:** how hard is it to undo in six months?

### Option B: [name]

*(as above)*

## Decision

What we are doing, in one paragraph, in the active voice.

## Why

The reasoning that actually drove it — including the non-technical parts. "Option
B was better on latency but nobody on the team had operated one" is a legitimate
and useful reason. Sanitized rationale makes for a useless record.

## Consequences

**Accepted costs.** What gets worse. Every real decision has some; an ADR listing
only benefits is advocacy, not a record.

**What this constrains.** Which future options are now harder or foreclosed.

**What we must now maintain.** New operational obligations — a cache to refresh, a
pipeline to re-run, a vendor relationship to manage.

## AI-specific: dependency exposure

*Delete this section if the decision involves no model dependency.*

- **Models depended on:** provider and pinned version
- **If this model is deprecated:** what breaks, and what the migration costs
- **If the provider changes pricing:** what our cost sensitivity is
- **Data leaving our boundary:** what, to whom, under what terms, retained how long
- **Prompt coupling:** how much of our tuning is fitted to this specific model?

## Revisit conditions

**The section that makes this document useful in a year.** Under what specific,
observable conditions should someone reopen this decision?

Write triggers, not dates. Good ones are falsifiable:

- Query volume exceeds N/day
- Cost per resolution exceeds $X
- The deterministic path's fall-through rate exceeds N%
- A second team needs this capability
- The pinned model is deprecated

## Revisited: YYYY-MM-DD

> Add this section when a revisit condition fires, or at any point the decision
> is re-examined. **Do not edit the sections above** — the value of this record is
> that it preserves what was believed at the time.

- **What triggered the review:** …
- **What we got right:** …
- **What we got wrong:** the honest part. What did reality do that we did not
  predict?
- **Outcome:** Confirmed | Amended | Superseded by ADR-NNN
