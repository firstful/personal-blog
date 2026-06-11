---
tags:
    - Tutorial
    - LLM
    - Libraries
    - Software Engineering
description: |
    A practical, step-by-step guide to generating custom utility libraries with LLMs —
    from spec design and iteration to packaging and ongoing maintenance.
image: https://blog.ffilt.us/assets/logo.png
---

# Using LLMs to Generate Bespoke Libraries

In my [last post](/blog/opinions/any-library-you-want-20-dollars/), I argued that the cost of creating a small, well-specified library has dropped from a week of engineering time to about $20 and a spec. The economics have inverted: it's now often cheaper to build than to import.

But *how* do you actually do this in practice? What does the workflow look like from idea to published library? This post is the concrete, step-by-step guide — prompts, templates, and all.

## The Workflow at a Glance

```
Idea → Spec → Generate → Validate → Package → Maintain
```

Each step takes minutes, not hours. Let me walk through each one with real examples.

## Step 1: Write the Spec

The spec is everything. A good spec is a complete type signature, a set of example inputs and outputs, and a sentence or two about constraints. That's it.

Here is the template I use:

```markdown
## Spec: [function name]

**Purpose:** One sentence about what this does.

**Signature:**
```
functionName(input: Type) => OutputType
```

**Behavior:**
- Rule 1 about how it behaves
- Rule 2 about edge cases
- Rule 3 about error handling

**Examples:**
```
input    → output
input2   → output2
input3   → Error / null / undefined
```

**Constraints:**
- No external dependencies
- Pure function (no side effects)
- Must handle [specific edge case]
```

Let's say I need a rate limiter with a specific backoff strategy — not quite the standard exponential backoff, but something in between. Here's the spec I'd write:

````markdown
## Spec: adaptive-rate-limiter

**Purpose:** A rate limiter that adjusts its throttle window based on observed error rates, for API clients that face variable rate limits.

**Signature:**
```typescript
function createAdaptiveLimiter(
  options: {
    initialWindowMs: number;    // Starting throttle window (e.g. 1000)
    maxWindowMs: number;        // Ceiling (e.g. 30000)
    backoffFactor: number;      // Multiply window by this on error (e.g. 1.5)
    recoveryFactor: number;     // Shrink window by this on success (e.g. 0.9)
    minSamplesBeforeRecovery: number; // Successful calls before we try shrinking
  }
): {
  acquire(): Promise<void>;     // Wait until allowed to proceed
  reportResult(success: boolean): void; // Feed back outcome
  getState(): { windowMs: number, lastError: number | null };
}
```

**Behavior:**
- `acquire()` resolves immediately if enough time has passed since last call
- Otherwise waits until the window has elapsed
- On `reportResult(false)`: multiply current window by backoffFactor
- On `reportResult(true)` after minSamplesBeforeRecovery consecutive successes: multiply by recoveryFactor
- Window is never less than initialWindowMs or more than maxWindowMs
- Multiple concurrent acquirers queue fairly

**Examples:**
```typescript
const limiter = createAdaptiveLimiter({
  initialWindowMs: 1000,
  maxWindowMs: 30000,
  backoffFactor: 1.5,
  recoveryFactor: 0.9,
  minSamplesBeforeRecovery: 3
});

// First call: resolves immediately
await limiter.acquire();
limiter.reportResult(false); // Error! Window → 1500

// Second call: waits ~1500ms
await limiter.acquire();
limiter.reportResult(true); // Only 1 success, need 3
```

**Constraints:**
- Zero external dependencies
- Browser and Node.js compatible
- No timers leak on garbage collection
```

## Step 2: Generate

Give the spec to an LLM with this prompt template:

> Generate a production-ready implementation of the library described below. Follow the spec exactly. Include full TypeScript type definitions, JSDoc comments on every exported function, and no external dependencies. If the spec is ambiguous, make a reasonable choice and note it in a comment.
>
> ```[paste spec here]```

I use GPT-4o or Claude 3.5 Sonnet for this. Cost: about $0.50–$2.00. Time: about 60 seconds.

The first pass is rarely perfect, and that is fine. I have never received a perfect first-pass library. The point is to get something *close* that I can iterate on.

## Step 3: Validate

Validation is not about reading every line of generated code — you will go mad if you try. Instead, I use three quick checks:

### Check 1: Does it compile / parse?

For TypeScript: `npx tsc --noEmit`. For Python: `python -c "import ast; ast.parse(open('lib.py').read())"`. If it doesn't pass basic syntax checking, regenerate or fix the one obvious issue.

### Check 2: Does it pass the spec's examples?

I wrap the examples from my spec into a quick test:

```typescript
import { describe, it, expect } from 'vitest';
import { createAdaptiveLimiter } from './adaptive-rate-limiter';

describe('adaptive-rate-limiter', () => {
  it('resolves immediately on first call', async () => {
    const limiter = createAdaptiveLimiter({
      initialWindowMs: 1000,
      maxWindowMs: 30000,
      backoffFactor: 1.5,
      recoveryFactor: 0.9,
      minSamplesBeforeRecovery: 3
    });
    const start = Date.now();
    await limiter.acquire();
    expect(Date.now() - start).toBeLessThan(50); // Should be nearly instant
  });

  it('backs off on error', async () => {
    const limiter = createAdaptiveLimiter({ /* same config */ });
    await limiter.acquire();
    limiter.reportResult(false);
    expect(limiter.getState().windowMs).toBe(1500);
  });

  it('never exceeds maxWindowMs', async () => {
    const limiter = createAdaptiveLimiter({
      initialWindowMs: 1000,
      maxWindowMs: 5000,
      backoffFactor: 10, // Aggressive backoff
      recoveryFactor: 0.9,
      minSamplesBeforeRecovery: 3
    });
    // Simulate many errors
    for (let i = 0; i < 10; i++) {
      await limiter.acquire();
      limiter.reportResult(false);
    }
    expect(limiter.getState().windowMs).toBeLessThanOrEqual(5000);
  });
});
```

If any test fails, I do not debug the code. **I debug the spec.** I add more detail, clarify the ambiguous edge case, and regenerate. This is the key insight: you are not debugging generated code. You are refining a specification.

### Check 3: Property-based tests for edge cases

For non-trivial libraries, I add a few [fast-check](https://github.com/dubzzz/fast-check) property tests to catch off-by-one and boundary issues:

```typescript
import fc from 'fast-check';

it('window never drops below initial', () => {
  fc.assert(
    fc.property(fc.integer({ min: 1, max: 100 }), (errorCount) => {
      const limiter = createAdaptiveLimiter({ /* config */ });
      for (let i = 0; i < errorCount; i++) {
        limiter.reportResult(false);
      }
      return limiter.getState().windowMs >= 1000;
    })
  );
});
```

## Step 4: Package

Once validated, I package the library as a focused module. The structure is minimal:

```
adaptive-rate-limiter/
├── src/
│   └── index.ts         # The generated code + any manual fixes
├── test/
│   └── index.test.ts    # Spec-derived tests
├── package.json         # name, version, main, types, exports
├── tsconfig.json
└── README.md            # One paragraph + API reference
```

I do not publish to npm for most of these libraries. They live in a `vendor/` directory inside my project, imported by relative path:

```json
{
  "name": "my-project",
  "dependencies": {
    "adaptive-rate-limiter": "file:./vendor/adaptive-rate-limiter"
  }
}
```

This gives me first-class imports without the overhead of publishing, versioning, and maintaining a public package. If the library proves useful across multiple projects, *then* I consider publishing it. Most never reach that point — and that is fine. They served their purpose.

## Step 5: Maintain (Minimally)

The maintenance burden of these libraries is near zero because:

- **They have no dependencies.** No transitive vulnerabilities. No version conflicts. No deprecation warnings from upstream.
- **They have a narrow API.** Three to five exported functions, each with a clear spec. If the interface needs to change, I change the spec, regenerate, and fix the two call sites.
- **They are disposable.** If a library becomes more trouble than it is worth, I inline the two call sites and delete the file. There is no deprecation process, no migration guide, no semver negotiation.

The only maintenance task is updating the spec-driven tests when requirements change. And because the spec is the source of truth, that is a matter of editing a few lines in a test file and regenerating.

## Concrete Example: A Currency Formatting Library

Here is a real example. I needed a library that formats currency values with automatic unit scaling — show `$1.2K` instead of `$1,200`, `$3.4M` instead of `$3,400,000`, and so on. Standard libraries handle locale-aware formatting but not auto-scaling.

**Spec (5 minutes):**

> `formatCompactCurrency(value: number, currency: string, locale?: string): string`
> - For values >= 1e12: show "T" suffix, 2 decimal places
> - For values >= 1e9: show "B" suffix, 2 decimal places
> - For values >= 1e6: show "M" suffix, 2 decimal places
> - For values >= 1e3: show "K" suffix, 1 decimal place
> - For values < 1e3: show full value with currency symbol
> - Uses Intl.NumberFormat for the base formatting
> - Examples: 1_234_567 → "$1.23M", 999 → "$999.00", 2_500_000_000 → "$2.50B"

**Generation (60 seconds):** Claude 3.5 Sonnet produced a clean implementation in one pass. Total: 42 lines of TypeScript.

**Validation (10 minutes):** Three tests, all passed on first run.

**Result:** A library that fit exactly what I needed, with no dependencies, in under 20 minutes.

## When to Use This Workflow

This approach excels for the long tail of small, focused utilities:

- Formatting and parsing functions
- Custom data structures not covered by standard libraries
- API wrappers with specific retry and caching semantics
- Validation logic that is too specific for a general-purpose validator
- Mathematical or statistical helpers with niche requirements

It is not for:

- Protocol implementations (HTTP, WebSocket, crypto)
- Large frameworks with ecosystem dependencies
- Anything requiring expert security review

## The Bottom Line

This workflow — spec, generate, validate by spec test, package local, maintain minimally — turns library creation from a week-long commitment into a 20-minute task. The $20 price point from my last post is not theoretical. I have done this dozens of times now, and the pattern holds.

The skill to cultivate is not prompt engineering. It is **spec design**. Learning to write clear, complete, unambiguous specs is what separates a generated mess from a production-ready library. The LLM is a compiler for specs. Treat it like one.
