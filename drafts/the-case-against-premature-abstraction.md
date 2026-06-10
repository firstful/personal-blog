---
title: The Case Against Premature Abstraction
date: 2026-06-10
tags: [software engineering, architecture, DX]
---

A junior engineer looks at duplicated code and sees a mess. A senior engineer looks at it and sees a pattern waiting to crystallize. A staff engineer looks at it and counts to three.

The Rule of Three — the heuristic that you should not extract a shared abstraction until you've seen the pattern appear at least three times — is one of the oldest pieces of wisdom in software engineering. It predates Agile, microservices, AI-assisted development, and most of the frameworks we use today. It has survived every trend because it encodes something fundamental about the nature of software: *premature abstraction is more expensive than duplication.*

And yet, in the age of LLMs that can generate abstractions on demand, the pressure to extract early has never been greater. It's also never been more dangerous.

### The Cost of Being Wrong

The standard argument against duplication is that it creates maintenance burden: a bug in the duplicated logic must be fixed in N places instead of one. This is true. But it is also the best-case scenario for abstraction — the scenario where the abstraction was correct.

Consider what happens when the abstraction was wrong:

- **You extracted the wrong boundary.** The two uses you unified turn out to have different future trajectories. One needs a new parameter. Then another. Then a flag to disable a feature the other doesn't need. Six months later, the shared function has five optional parameters, two of which are mutually exclusive, and a comment that reads "this is a mess but I'm afraid to untangle it."

- **You optimized the wrong dimension.** The abstraction that made the first two call sites cleaner made the third one — the one you didn't know about when you extracted — considerably harder. Now you have a choice: force the third caller into your abstraction's shape, or add a leaky escape hatch that defeats the purpose.

- **You created coupling where none existed.** Before the abstraction, the two pieces of code could evolve independently. After extraction, a change intended for one caller must be evaluated for impact on the other. You have introduced a dependency between unrelated features.

These costs are invisible at extraction time. They compound slowly, like interest on bad debt. And by the time they are obvious, the abstraction is too entrenched to remove without a dedicated refactoring ticket that nobody will prioritize.

### Why Three?

The Rule of Three is not a magical number. It is a heuristic calibrated to the distribution of actual code evolution patterns. Three instances give you:

1. **Signal over noise.** Two instances could be coincidence. Three instances strongly suggests a genuine pattern — enough samples to distinguish the essential properties (what stays the same across all three) from the accidental ones (what varies).

2. **A decision boundary.** With three examples, you can see the axes of variation clearly. What changes? What stays the same? This directly informs the abstraction's interface. With two examples, you have one data point of difference — not enough to know which axis is the real one.

3. **Enough data to regret it safely.** If you extract after three and it's wrong, you've wasted a bounded amount of effort. The refactoring is still manageable. If you extract after twenty, the cleanup cost is prohibitive.

The rule surfaces an uncomfortable truth: *good abstractions are empirical, not theoretical.* You cannot design them in advance. You must discover them by watching real code evolve.

### The AI Amplification Trap

LLMs make premature abstraction dramatically more tempting. The reasoning goes: if extracting an abstraction costs $0.50 and 30 seconds, why not extract early? You can always throw it away.

This reasoning is seductive and wrong. The cost of extraction is not the extraction itself. The cost is the *commitment to a design decision* — the coupling, the interface contract, the assumption that this shape will generalize. That cost is unchanged by the speed of generation.

What LLMs *do* change is the viability of the alternative: rather than abstracting, you can keep code duplicated and use the LLM to apply coordinated edits across all copies. When a bug is found in the duplicated logic, you prompt the LLM to fix all instances simultaneously. The maintenance cost of duplication drops dramatically.

This inverts the traditional calculus. In the pre-LLM world, duplicating code meant multiplying maintenance effort. In the LLM world, coordinated editing across duplicates is nearly as cheap as editing a single function. The Rule of Three not only still applies — it applies with *more* force, because the downside of premature abstraction is unchanged while the cost of waiting has decreased.

| Approach | Pre-LLM Maintenance Cost | With LLM Maintenance Cost |
|---|---|---|
| Abstract early (correct) | Low (one place to fix) | Low (one place to fix) |
| Abstract early (wrong) | High (refactor cost + coupling) | High (refactor cost + coupling) |
| Duplicate, then abstract at 3 | Medium (fix N places until refactor) | Low (LLM fixes all copies) |

The asymmetry is striking: LLMs remove the main argument for early abstraction (maintenance burden of duplication) without reducing the cost of a wrong abstraction.

### When Abstraction Is Cheaper Than Duplication

Not all duplication is worth keeping. Some patterns are so stable that abstraction is trivially safe:

- **Language idioms.** A for-loop over an array of objects is not an abstraction worth extracting; it is a language pattern. Write it inline.

- **Standard library wrappers.** If you're wrapping `fetch()` with the same headers on every call, that is not a pattern you are discovering — it is a configuration you are repeating. Extract it.

- **Well-defined transformations.** A function that converts one data format to another, where both formats are specified by an external standard (not something your team controls), is safe to abstract from the first instance. The boundary is defined externally.

The dangerous abstractions are the ones you *imagine* will generalize. The ones based on a hunch about what future code will look like. The ones that feel elegant but have no empirical support.

### A Practical Heuristic

When you find yourself reaching for an abstraction, ask:

1. **How many instances do you have right now?** If it's fewer than three, wait. Write the third one. If it never comes, the abstraction was wrong.

2. **Are the instances actually the same, or just similar?** Duplication of identical logic is the best candidate. Superficially similar logic that happens to converge on the same implementation is the worst — the divergence is coming.

3. **What is the cost of extracting now versus extracting later?** With LLMs, the cost of extracting later is lower than it has ever been. There is almost no scenario where waiting is the expensive choice.

4. **Could this abstraction be a library instead?** If the abstraction is context-free — no dependency on your app's internal types, database schema, or auth model — it's safer to extract. Library abstractions have naturally bounded interfaces. Application abstractions leak.

### The Third Instance Is a Gift

There is a specific pleasure in reaching the third instance of a pattern and realizing the abstraction is finally clear. The interface reveals itself. The parameters snap into focus. The implementation writes itself. That moment is not available at instance two. You cannot shortcut it with cleverness or experience or AI assistance.

The third instance is not a delay. It is the *data point* that makes the abstraction correct. Treat it as such.

And if the third instance never comes? Then you have two copies of something, and an LLM can fix both of them for pocket change. That is not a failure of discipline. It is the cost of being right about what matters.
