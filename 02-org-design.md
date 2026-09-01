# Organization design

How I structure engineering organizations that ship AI products, and the failure
modes I am structuring against.

---

## The two failure modes

Almost every AI org problem I have seen is one of two shapes.

**The bottleneck.** A central AI team owns the AI features. Every product team
that wants an AI capability files a request. The AI team becomes a queue, its
roadmap becomes a negotiation between VPs, and its engineers — hired to do
interesting work — spend their time on other teams' backlogs. Product teams learn
to route around it, usually by quietly hiring their own AI engineer.

**The sprawl.** Every product team owns its AI stack end to end. Six months later
you have four prompt-management approaches, three eval runners, two vector
stores, no cost attribution, and nobody who can answer "are we getting better?"
across the company. The first serious model deprecation costs you a quarter,
because four teams must each independently discover the same regressions.

Both are the same mistake made in opposite directions: drawing the line between
central and embedded in the wrong place, or not drawing it at all.

## The line

<a name="the-line"></a>

The division that has held up for me:

| The platform owns | Product teams own |
|---|---|
| Inference gateway, routing, fallback | Prompts and context construction |
| Caching and rate limiting | Retrieval strategy for their domain |
| Tracing, token accounting, cost attribution | The eval *contents* — what "good" means here |
| Eval *infrastructure* — runner, harness, dashboards | The quality bar and the launch decision |
| The safety and policy layer | Domain-specific tools and function definitions |
| Model lifecycle: onboarding, deprecation, upgrades | Their latency and cost budget, within platform limits |

The principle underneath it: **the platform owns what is identical across
features; product teams own what encodes domain judgment.** Nobody on a central
team can tell you whether a legal-summarization answer is good. That knowledge
lives with the team that talks to the customers, and it cannot be centralized
without being destroyed.

The corollary people resist: **the platform team must not own a user-facing AI
feature.** The moment it does, it acquires a roadmap that competes with its
service obligations, and service always loses to features.

## When to form a platform team

Not on day one. A platform team with one customer is an abstraction exercise.

My trigger conditions — I want **two of three** before funding the team:

1. **Three or more product teams** are shipping LLM features independently.
2. **Duplication is visible and costly.** I can point at two teams that built the
   same eval runner, or two implementations of prompt versioning.
3. **A company-level question has become unanswerable.** "What do we spend on
   inference, by feature?" or "which features break if this model is deprecated?"
   should be answerable in an afternoon. When they are not, and the reason is
   structural rather than clerical, that is the signal.

Before those conditions hold, the right structure is a **guild**: the two or
three people doing AI work across teams meet weekly, share what broke, and
maintain a shared utilities repo that nobody is formally on the hook to support.
It costs almost nothing, and it produces the design knowledge you will need to
build the platform properly later.

Starting the platform team too early is the more expensive error, because you
will centralize the wrong things. The eval runner belonged in the platform. The
retrieval strategy looked like it did too — right up until the second domain
needed something completely different.

## Sizing, and what I fund first

For an organization of roughly 100–150 engineers, with AI a significant but not
exclusive part of the product:

- **AI platform: 5–8 engineers.** Below five it cannot both build and support.
  Above eight at this scale, it starts inventing work.
- **Applied AI, embedded: 1–3 per product team** with real AI surface area,
  reporting into the product team, with a dotted line to the platform's technical
  standards.
- **Research: zero** — unless model quality is genuinely your moat. It usually is
  not. Most companies describing themselves as AI companies are engineering
  companies applying models, and staffing research is a way of buying prestige
  instead of progress. If you do need it, fund it as a separate org with its own
  time horizon and success criteria, never inside a delivery team, where the
  roadmap will consume it within two quarters.
- **Data engineering: fund it before you think you need it.** The most common
  reason an AI roadmap stalls has nothing to do with models. It is that the data
  the feature needs is not accessible, not clean, or not legally usable.

<!-- FILL: replace these numbers with org sizes you have actually run. Specific figures you can defend from experience are far stronger than my defaults, and an interviewer will ask. -->

## The roles people conflate

Titles in this space are close to meaningless, which makes hiring unpredictable
and levelling unfair. The distinctions I insist on:

| Role | Question they answer | Fails when |
|---|---|---|
| **Research scientist** | Can we make the model itself better? | Given a delivery date |
| **ML engineer** | Can we train, serve, and monitor models at scale? | Treated as an API integrator |
| **AI engineer** | Can we build a reliable product on someone else's model? | Expected to have publications |
| **Data engineer** | Can the right data get to the right place, correctly and legally? | Treated as the least prestigious of these |

The most expensive hiring mistake I see is hiring a **research scientist for an
AI engineering problem.** The job is systems work — latency budgets, failure
modes, retrieval quality, cost control, graceful degradation. A strong researcher
in that seat is bored, mis-levelled, and gone within a year. The company then
concludes that AI talent is hard to retain, when what actually happened is a role
mismatch it created itself.

The second most expensive is the mirror image: hiring a strong application
developer, then being surprised when the system is confidently wrong in
production, because nobody in the room had the instinct to ask what the failure
distribution looked like.

## Conway's law applies with unusual force

Service boundaries in AI systems calcify around team boundaries faster than in
ordinary software, because the interfaces are so cheap to create. A prompt is a
contract that anyone can write and nobody reviews.

Two practical consequences:

- **If retrieval and generation live in different teams, quality will stall.**
  They are tightly coupled and must be tuned together. I keep them in one team
  even when it makes the org chart less tidy.
- **A shared prompt library across teams becomes shared mutable state.** Prompts
  read like content and behave like code. Version them, review them, and give
  each one a single owning team — or accept that a change made for one feature
  will silently regress three others.

## Reporting lines

The AI platform team reports where the rest of platform engineering reports. Not
into product, where it becomes a feature team. Not into a separate "AI org"
reporting to the CEO — which sounds strategic and functions as a moat around a
budget.

The structure I push back on hardest is an AI organization sitting outside
engineering entirely. It reliably produces demos that cannot be operated, and it
makes every launch a negotiation between two organizations with incompatible
definitions of done.
