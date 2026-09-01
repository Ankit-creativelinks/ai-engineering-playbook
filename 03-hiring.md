# Hiring

The loop I run for AI engineering roles, the rubrics behind it, and what I have
stopped doing.

---

## What I am selecting for

In roughly this priority order:

1. **Evaluation instinct.** Does this person reflexively ask how we would know if
   it got better? This is the strongest single predictor I have found.
2. **Failure-mode reasoning.** Given a system, can they enumerate how it goes
   wrong — and distinguish the loud failures from the silent ones?
3. **Systems judgment.** Latency budgets, cost, caching, graceful degradation.
   Ordinary senior engineering, applied to a stochastic component.
4. **Calibrated uncertainty.** Can they say "I do not know, and here is how I
   would find out"? This field rewards it and punishes bluffing, and candidates
   who bluff in an interview will bluff in a design review.
5. **Model literacy.** Real but genuinely fourth. It is the most teachable item
   on this list and the one most interviews over-weight.

Note what is absent: familiarity with a specific framework, and the ability to
explain transformer internals. Both correlate with having read the same material
I have, not with shipping something that works.

## The loop

Five stages, no more. Every additional stage costs you strong candidates who have
other offers, and buys you less signal than the stage before it.

| Stage | Duration | Signal | Who runs it |
|---|---|---|---|
| 1. Screen | 30 min | Genuine ownership of something real | Hiring manager |
| 2. **Eval design** | 60 min | Evaluation instinct, failure reasoning | Senior AI engineer |
| 3. Practical build | 90 min | Working code against a real API, with judgment | Two engineers |
| 4. System design | 60 min | Architecture, cost, scale, degradation | Staff+ engineer |
| 5. Leadership + values | 45 min | Collaboration, disagreement, growth | Cross-functional |

**No take-homes above mid-level.** Senior candidates have jobs and families; a
take-home selects for free time, not skill. I would rather spend 90 minutes of my
own engineers' time than eight unpaid hours of a candidate's.

## The eval design interview

<a name="the-eval-design-interview"></a>

This is the highest-signal hour in my loop, and it is the one I would keep if I
could only keep one.

**The setup.** I describe a real, deployed AI feature in enough detail to reason
about — a support assistant, a document extractor, a search experience. Then:

> "This shipped last quarter. Leadership is asking whether it is working. You have
> two weeks and one engineer. What do you build, and what do you tell them?"

**What I am listening for**, roughly in order of how much it moves my decision:

- Do they ask what "working" means *before* proposing a metric? Weak candidates
  propose accuracy in the first minute. Strong ones ask what decision the answer
  will inform, and what happens to the feature if the answer is bad.
- Do they separate **retrieval quality from generation quality**? This single
  distinction separates people who have debugged a RAG system in production from
  people who have read about one.
- Where does the labelled data come from? Strong candidates go straight to
  production logs and existing human decisions. Weak ones propose that the team
  hand-writes a few hundred examples, without noticing that this samples the
  distribution they imagine rather than the one they have.
- Do they propose an **LLM judge**, and if so, do they raise calibrating it
  against human labels unprompted? Proposing a judge is table stakes. Knowing the
  judge itself needs validating is the senior signal.
- Do they distinguish **offline** evaluation from **online** measurement, and know
  which question each one answers?
- Do they mention cost — of the feature, and of the eval harness itself?

**The follow-up that separates senior from staff:**

> "Your eval says quality went up. Support ticket volume also went up. Both are
> real. What do you do?"

I am watching for whether they treat the metric as authoritative or as evidence.
Staff-level candidates immediately question whether the eval set represents the
traffic that generates tickets — and usually land on the answer I am hoping for:
the tickets *are* the missing eval data.

## Levelling

What actually distinguishes levels in AI engineering, stripped of the usual
prose:

| Level | The distinguishing behaviour |
|---|---|
| **Mid** | Ships a working feature against a spec. Uses the eval harness someone else built. |
| **Senior** | Owns quality for a feature end to end. Builds its eval set. Knows its cost and its failure distribution. |
| **Staff** | Owns quality across features. Sets the bar others are held to. Chooses which problems do *not* need a model. |
| **Principal** | Changes what the organization believes. The architectural positions others cite in their own design docs. |

The most common levelling error I see is promoting on **demo impressiveness**
rather than **operational ownership**. Building the impressive prototype is
mid-level work. Keeping it correct for eighteen months, through two model
deprecations and a tenfold traffic increase, is senior work — and it is much
less visible in a promo packet, which is a problem the levelling system has to
actively correct for.

## Rubric: the practical build

Candidates build a small retrieval-backed feature against a real API, with
internet access and any tooling they like. I score four dimensions, 1–4 each. I
hire at 12+, with no dimension below 2.

**1. Problem framing.** Did they clarify ambiguity before coding? Did they notice
the part of the spec that does not need a model at all? *(A candidate who solves
half the problem with a database index and tells me why scores a 4.)*

**2. Working software.** Does it run, handle the obvious failure cases, and
degrade sensibly when the API misbehaves? Retries, timeouts, and a fallback path
are what I am looking for — not test coverage theatre.

**3. Quality reasoning.** How do they know it works? Even a handful of test cases
with a stated rationale beats a polished implementation with none.

**4. Communication.** Can they walk through their trade-offs and name what they
would do with another day? I explicitly reward "I chose the worse option here
because of the time limit, and here is what I would change."

## What I have stopped doing

- **Whiteboard algorithms.** Never predicted performance in this role. Selected
  for recent interview practice.
- **Asking people to explain attention.** Selects for the same reading list.
- **Multi-day take-homes** above mid-level. See above.
- **The "AI ethics" question asked as a values checkbox.** It produced rehearsed
  answers and no signal. Replaced with a concrete scenario in stage 5: *"Your
  model is measurably better for one user segment than another. Ship or hold?"*
  That one produces real conversation, because there is no safe answer.
- **Requiring published research** for engineering roles. It filtered out several
  of the best applied engineers I have worked with.

## A note on the market

AI engineering candidates are, at the time of writing, evaluating you at least as
hard as you evaluate them. Two things move offer acceptance more than
compensation, in my experience:

- **Access to real traffic.** Engineers in this field want their work in front of
  users, because that is the only place the interesting problems live.
- **An honest account of where you are.** Candidates have heard "AI is core to
  our strategy" from everyone. Telling them plainly that you have one shipped
  feature, a messy eval story, and a real need for someone to own it is more
  attractive than it sounds — to exactly the people you want.

<!-- FILL: add your own offer-acceptance observations here if you have them. Concrete recruiting anecdotes are memorable in interviews. -->
