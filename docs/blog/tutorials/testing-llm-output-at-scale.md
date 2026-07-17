---
tags:
    - Tutorial
    - LLM
    - Testing
    - Python
description: |
    A practical guide to systematically testing LLM outputs at scale — from simple
    assertion frameworks to semantic evaluation pipelines with regression tracking.

---

# Testing LLM Output at Scale

LLMs are squishy. You know this. The same prompt that produced a perfect SQL query yesterday may return a hallucinated table name today. Unlike traditional software where identical inputs always produce identical outputs, LLMs are inherently non-deterministic — and that makes testing them a fundamentally different problem.

Testing LLM outputs at scale means moving beyond "does it crash?" to "is the output correct, coherent, and safe?" across hundreds or thousands of variations. Here's a practical framework I've built while working with LLM-powered agents at opencode.

## Why Traditional Testing Falls Short

Unit tests assert exact equality. Integration tests check for expected side effects. Neither works when the output space is combinatorially large and the "correct" answer is a distribution, not a single value.

Consider an LLM that generates commit messages from diffs:

```python
# Traditional test — fragile and nearly useless
def test_commit_message():
    result = generate_commit_message("feat: add user login endpoint")
    assert result == "Add user login endpoint"  # Breaks on any phrasing change
```

This tests nothing meaningful. The LLM might return "Add login endpoint for users" or "Implement user authentication route" — both perfectly valid — and the test fails. Instead, we need to test *properties* of the output, not exact strings.

## Tier 1: Structural Assertions

Start with what LLMs do reliably: follow structural instructions. If your prompt asks for JSON, test that valid JSON is returned. If it asks for a list of three items, test that you got three items.

```python
import json
import jsonschema

def test_llm_output_is_valid_json(response_text):
    """Verify the LLM returns parseable JSON matching a schema."""
    try:
        data = json.loads(response_text)
    except json.JSONDecodeError:
        assert False, "Response is not valid JSON"
    
    schema = {
        "type": "object",
        "required": ["title", "description", "priority"],
        "properties": {
            "title": {"type": "string", "minLength": 1},
            "description": {"type": "string"},
            "priority": {"type": "string", "enum": ["low", "medium", "high", "critical"]}
        }
    }
    jsonschema.validate(instance=data, schema=schema)
```

These structural tests are cheap, deterministic, and catch the most common failure modes: malformed output, missing fields, and out-of-range values. Run them on every generation.

## Tier 2: Semantic Evaluation with LLM-as-Judge

For content quality, the best judge of LLM output is often another LLM. This pattern is called "LLM-as-Judge" — use a strong model (GPT-4, Claude 3.5 Sonnet, or a purpose-tuned evaluator) to rate the output of your target model.

```python
from openai import OpenAI

def evaluate_factual_accuracy(generated_text, source_material, client=None):
    """Use an LLM judge to rate factual accuracy on a 1-5 scale."""
    client = client or OpenAI()
    
    prompt = f"""You are an expert evaluator. Given source material and a generated response,
rate the factual accuracy from 1 (completely hallucinated) to 5 (perfectly faithful).

Source: {source_material}

Response: {generated_text}

Output only a JSON object: {{"score": int, "reasoning": "..."}}"""
    
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": prompt}],
        response_format={"type": "json_object"}
    )
    return json.loads(response.choices[0].message.content)
```

I use this approach extensively in opencode's evaluation pipeline. The key insight: you don't need a separate test suite for every prompt. A single evaluator prompt tuned for your quality dimensions (accuracy, completeness, conciseness, safety) covers your entire generation surface.

### Building a Test Suite

```python
import pytest
from dataclasses import dataclass, field

@dataclass
class LLMTestCase:
    name: str
    prompt: str
    expected_qualities: dict = field(default_factory=dict)
    min_score: float = 3.0
    structural_validators: list = field(default_factory=list)

TEST_CASES = [
    LLMTestCase(
        name="generate-release-notes",
        prompt="Generate release notes for v2.3.0 with features: user auth, API v2, dark mode",
        expected_qualities={"has_version_badge": True, "mentions_deprecations": False},
        min_score=4.0,
        structural_validators=[validate_semantic_versioning]
    ),
    LLMTestCase(
        name="summarize-incident",
        prompt="Summarize this P0 incident: DB connection pool exhausted at 14:23 UTC...",
        expected_qualities={"identifies_root_cause": True, "suggests_action_items": True},
        min_score=3.5
    ),
]

@pytest.mark.parametrize("case", TEST_CASES, ids=lambda c: c.name)
def test_llm_output_quality(case, llm_client, judge_client):
    response = llm_client.generate(case.prompt)
    
    # Run all structural validators
    for validator in case.structural_validators:
        validator(response)
    
    # Semantic evaluation
    result = evaluate_factual_accuracy(response, case.prompt, judge_client)
    assert result["score"] >= case.min_score, f"{case.name}: score {result['score']} < {case.min_score}"
```

## Tier 3: Regression Testing at Scale

The hard part isn't running a single test — it's knowing when your model's behavior has drifted. LLM outputs change silently when you update the model, tweak system prompts, or even when the provider adjusts their serving infrastructure.

### Snapshot Testing with Embeddings

Store a semantic fingerprint of each generation and compare against baselines:

```python
from sentence_transformers import SentenceTransformer
import numpy as np

class LLMRegressionTracker:
    def __init__(self):
        self.encoder = SentenceTransformer("all-MiniLM-L6-v2")
        self.baselines = {}
    
    def record_baseline(self, test_name, output):
        self.baselines[test_name] = self.encoder.encode(output)
    
    def check_regression(self, test_name, new_output, threshold=0.85):
        new_embedding = self.encoder.encode(new_output)
        similarity = np.dot(self.baselines[test_name], new_embedding)
        assert similarity >= threshold, (
            f"Semantic drift detected in {test_name}: "
            f"cosine similarity {similarity:.3f} < {threshold}"
        )
```

When a regression test fails, the cause is often subtle: a system prompt change, a temperature adjustment, or a model update. Tag each test run with the prompt hash, model version, and temperature so you can pinpoint what changed.

## Tier 4: Continuous Evaluation in CI

These tests are pointless if they only run locally. Integrate them into your CI pipeline with a dedicated evaluation step:

```yaml
# .github/workflows/llm-eval.yml (example for opencode's CI)
eval-suite:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - name: Run LLM evaluation suite
      run: pytest tests/llm_eval/ -v --junitxml=llm-results.xml
      env:
        LLM_API_KEY: ${{ secrets.LLM_API_KEY }}
        JUDGE_API_KEY: ${{ secrets.JUDGE_API_KEY }}
    - name: Upload regression report
      if: always()
      uses: actions/upload-artifact@v4
      with:
        name: llm-regression-report
        path: llm-results.xml
```

### Cost Management

Running LLM-as-Judge for every test case gets expensive. Optimize with:

1. **Stratified sampling** — Run the full semantic suite on every PR merge, but only a 20% random sample on each commit.
2. **Caching** — If the prompt and model version haven't changed, reuse the last evaluation score.
3. **Cheap proxies first** — Run structural tests (free) before semantic tests (paid). Fail fast.
4. **Graduated evaluation** — Lightweight judge (GPT-4o-mini) for routine checks, heavyweight (Claude 3.5 Sonnet) for flagged cases.

## The Testing Pyramid for LLMs

```
         ╱  Continuous   ╲        ← Production monitoring, user feedback
        ╱     Eval in CI   ╲      ← Full regression suite on merge
       ╱  Semantic Eval     ╲    ← LLM-as-Judge, embedding comparison
      ╱   Structural Tests   ╲   ← JSON schema, type checks, range validation
     ╱   Unit / Integration   ╲  ← Business logic, tool call verification
```

Traditional testing inverts this — most tests are cheap unit tests and few are expensive integration tests. For LLMs, the pyramid is weighted toward the middle: structural tests are cheap and high-value, semantic tests are expensive but essential, and CI-level regression ensures you catch drift before it reaches users.

## Conclusion

Testing LLM outputs at scale isn't about eliminating non-determinism — it's about bounding it. Structural assertions catch format errors fast. LLM-as-Judge catches quality degradation. Embedding-based regression catches semantic drift over time. Together, they form a pipeline that lets you ship LLM-powered features with confidence, knowing that when your model starts misbehaving, you'll know before your users do.

The tools exist today. The framework is straightforward. The only thing standing between you and reliable LLM output is the discipline to actually run the tests.
