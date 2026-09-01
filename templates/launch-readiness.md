# Launch readiness review: [Feature name]

> The gate an AI feature passes before it meets users. Scaled to risk tier —
> a review that treats internal tooling like a medical device gets routed around,
> and then nothing is reviewed.

- **Feature:** …
- **Owner:** …
- **Risk tier:** Low | Medium | High
- **Launch date:** …
- **Reviewers:** …

## The three questions

Every tier answers these in writing. If they cannot be answered, the feature is
not ready regardless of its metrics.

**1. What is the worst realistic output, and what happens to the user then?**

Not the worst imaginable — the worst realistic. Then: what does it cost the user,
and how do they recover?

**2. How does the user know they are talking to an AI, and how do they reach a
human?**

**3. What data goes to the provider, under what terms, with what retention?**

This is where I see the most unmanaged risk. Confirm the data processing terms
have been read, and that they are consistent with the commitments in your own
privacy policy. An engineering decision that creates a legal exposure is still a
legal exposure.

## Quality

- [ ] Eval spec exists and is linked: …
- [ ] Current rung on the [maturity ladder](../04-evaluation.md#the-maturity-ladder): …
- [ ] Metrics meet stated targets — **including per segment**, not only aggregate
- [ ] Abstention behaviour verified: the system declines when it should
- [ ] Holdout set results reported *(not just the tuned set)*
- [ ] Retrieval measured separately from generation
- [ ] Someone with domain knowledge has read a real sample of outputs

## Operations

- [ ] Model version **pinned**, never floating to "latest"
- [ ] Cost per resolution known: …
- [ ] Cost ceiling configured, with an alert — degrades, never fails silently open
- [ ] p95 latency measured against a written budget
- [ ] Tracing in place: inputs, retrieved context, outputs, tokens, cost, latency
- [ ] Cost attributed by feature and tenant
- [ ] Production output sampling scheduled, with a named reviewer

## Failure and degradation

- [ ] **Kill switch exists and has been tested** — the feature can be disabled and
      the pre-AI experience served
- [ ] Prompts versioned and independently rollback-able
- [ ] Behaviour on empty retrieval verified: **abstains, never generates from no
      context**
- [ ] Behaviour on provider timeout and provider outage defined and tested
- [ ] Quality-based severity criteria written *(a confidently wrong answer pages
      nobody by default — decide in advance what makes it an incident)*
- [ ] On-call knows this feature exists and what to do about it

## Users

- [ ] AI involvement disclosed clearly
- [ ] Path to a human exists and is discoverable
- [ ] One-click "this was wrong" feedback wired into the eval pipeline
- [ ] Errors are honest — the failure message does not imply certainty the system
      does not have

## High tier only

- [ ] Domain expert sign-off: …
- [ ] Documented human appeal path for adverse outcomes
- [ ] Fairness checked across affected user segments
- [ ] Legal/compliance review complete
- [ ] Communications plan for a public quality failure

## Decision

- **Outcome:** Approved | Approved with conditions | Not ready
- **Conditions:** …
- **Follow-up date:** …

## Accepted risks

What we are knowingly shipping without, and why. Signed by the owner — an
undocumented accepted risk becomes a surprise in a postmortem.
