---
tags:
    - Tutorial
    - LLM
    - Prompt Engineering
    - Software Engineering
description: |
    A practical guide to choosing between prompt chaining and tool use for
    multi-step LLM interactions — when to chain, when to tool, and how to
    combine both effectively.
image: https://blog.ffilt.us/assets/logo.png
---

# Prompt Chaining vs. Tool Use: When to Use What

Every LLM interaction starts with a single prompt, but serious applications rarely stay there. Once you move past one-shot generation and into multi-step workflows, you hit a fork in the road: **chain prompts** (feed the output of one call into the next) or **give the model tools** (let it decide when and how to call external functions). Both patterns work. Both have passionate advocates. And both are absolutely the wrong choice in some situations.

I've built both patterns over the last year — from simple article-generation pipelines to agentic coding workflows in opencode — and I've made every wrong choice at least once. Here's what I've learned about when to chain, when to tool, and how to combine them without creating a monstrosity.

## The Core Distinction

The difference is deceptively simple:

- **Prompt chaining** is a fixed pipeline. Step A runs, produces output, that output becomes input for Step B, which produces output for Step C, and so on. The model never decides what to do next — the code does.
- **Tool use** hands a menu of capabilities to the model and lets it decide which to invoke, in what order, and with what arguments. The model drives the control flow.

That distinction sounds academic until you hit production. The choice determines latency, cost, debuggability, error handling, and — most importantly — whether your application actually works when the model does something unexpected.

## When to Chain

Prompt chaining shines when your workflow has a fixed, known structure. The canonical example is content generation: retrieve a document, summarize it, format the summary, translate it. The steps are the same every time, the dependencies are linear, and there's no benefit to letting the model improvise the order.

**Good candidates for chaining:**

- **ETL pipelines** — Extract data, transform it, load it. Each step has a well-defined input and output schema.
- **Multi-stage generation** — Outline first, then write, then edit. The outline is a structural constraint for the writing step, and you want to enforce that ordering.
- **RAG with explicit sub-queries** — You know you need to retrieve from three different sources and then synthesize. The retrieval is fixed; only the synthesis needs generation.
- **Validation loops** — Generate content, validate it against a schema, regenerate if validation fails. The loop structure is fixed; only the regeneration is dynamic.

The rule of thumb: if you can draw the workflow as a DAG where the nodes are in a fixed order, use chaining.

**Chaining wins on:**
- **Determinism** — The flow never surprises you. You always know which step is running.
- **Debuggability** — Log the input and output of each step. You can replay any step in isolation.
- **Cost control** — You decide which model to use at each step. Expensive reasoning for synthesis, cheap model for formatting.
- **Latency predictability** — Total time is the sum of each step, no branching uncertainty.

The code smells like this:

```python
outline = generate(system="Create an outline", user=topic)
draft = generate(system="Write from this outline", user=outline)
edited = generate(system="Edit for clarity", user=draft)
```

Simple, obvious, boring. That's a feature.

## When to Use Tools

Tool use (or function calling) shines when the workflow is open-ended. You don't know in advance how many steps are needed, what order they'll happen in, or even whether a particular step is necessary at all. You want the model to navigate a space of possibilities — and you want it to use your systems to do it.

**Good candidates for tool use:**

- **Coding agents** — The model needs to read files, search for patterns, run tests, iterate on fixes. The order depends entirely on what it finds.
- **Research assistants** — Query a database, fetch a URL, check another source, cross-reference. The research path changes with every query.
- **Customer support** — Look up an account, check order status, initiate a refund, escalate. The flow depends on the customer's specific situation.
- **Data exploration** — Describe a dataset, run a query, pivot on results, visualize. The next step depends on what the last query revealed.

The rule of thumb: if you don't know the workflow structure when you write the code, use tools.

**Killer feature: multi-call atomicity.** When a tool call returns partial or unexpected results, the model can adjust its plan mid-flight without you writing special-case logic. The model's steering is a form of runtime adaptation that prompt chaining can only approximate with deeply nested conditionals.

The code smells like this:

```python
response = model.with_tools([
    search_files(".*\.py"),
    read_file(["path"]),
    run_tests()
]).generate("Fix the failing test", context=bug_report)
```

The model decides what to search, what to read, and when to run tests. You don't need to write a state machine for every possible debugging path.

## The Pitfall of Each Approach

Prompt chaining has a ceiling. When the workflow branches — "if the summary is too long, split it; if it's in a language I don't recognize, translate first" — you end up writing the control flow yourself. The chain becomes a tree, then a graph, and suddenly you're maintaining a state machine that rivals the complexity you were trying to avoid.

Tool use has a floor. It's only as good as the model's ability to choose the right tool at the right time. When the model calls the wrong function, calls the right function with wrong arguments, or loops forever calling the same function because it can't figure out that it's done, you're debugging an emergent behavior that's different every time. You can't reproduce it deterministically. You can't write a unit test that covers "the model decided to do something stupid." You can only add guardrails, rate limits, and pray your max-iterations threshold is high enough for success but low enough to limit damage.

## The Hybrid Pattern: Tools with a Chained Scaffold

The best systems I've built use both — but deliberately. The scaffold is a chain. The leaf operations are tools.

Here's the pattern:

```
Input → [Chain: Classify] → [Chain: Route] → [Tools: Execute] → [Chain: Format]
```

1. **Classify** (chain) — Determine the type of request. A simple, cheap classification model runs first.
2. **Route** (chain) — Based on classification, select a fixed workflow template. No model involvement — just code.
3. **Execute** (tools) — Within the workflow, the model has access to tools specific to that workflow. It can call them in any order.
4. **Format** (chain) — Take the accumulated results and produce a structured output. Fixed template, cheap model.

This keeps the control flow predictable (chaining) where it matters while giving the model flexibility (tools) where it helps. Crucially, each tool-calling segment is bounded: it has a fixed input, a fixed output schema, and a maximum number of iterations. If the model goes off the rails, the damage is contained to one segment.

## Decision Matrix

| You have... | Use... | Because... |
|---|---|---|
| Fixed, known workflow structure | Chain | Deterministic, debuggable, predictable cost |
| Open-ended task with unknown steps | Tools | Model adapts dynamically |
| Need deterministic repro of failures | Chain | Log each step, replay any step |
| Need to handle unexpected edge cases | Tools | Model can improvise around missing logic |
| Cost is the primary constraint | Chain | Use small models for simple steps |
| Latency is unpredictable | Chain | Bounded by sum of known step times |
| You want emergent behavior | Tools | Let the model surprise you (good or bad) |
| You want to sleep at night | Hybrid | Chain for structure, tools for flexibility, both bounded |

## The Real Lesson

The unhelpful truth is that you need experience with both to know which one fits. Every team I've watched fall into a trap has been dogmatic — "tools are the future, chains are legacy" or "chaining is reliable, tools are chaos." Both are right until they're catastrophically wrong.

Start simple. Chain first. If the workflow keeps branching in unpredictable ways, unlock a single tool at the branch point. If the tool calls are becoming a performance bottleneck or the model keeps making bad routing decisions, pull the routing back into a chain. The boundary between the two patterns isn't a wall — it's a slider. The art is tuning it for your specific use case, not pledging allegiance to one side.
