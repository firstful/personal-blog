#!/usr/bin/env python3
"""Test argument history functionality."""

import sys
import os
sys.path.insert(0, '/tmp/blogtest/content-agents')

from agents.models import Persona, RecentArgument

def test_argument_extraction():
    """Test that arguments are properly extracted from posts."""
    print("Testing argument extraction...")

    # Test post content
    content = """## Opening Post

    I've been watching AI hype cycles for years. Remember when blockchain was going to change everything?
    The demos were amazing but production deployments were disasters.

    Studies show that 80% of AI projects fail to reach production because teams focus on the shiny demo
    rather than solving real problems. The evidence is clear: we need to focus on production readiness.

    Like a house built on sand, AI without solid foundations will collapse.

    Therefore, we should demand proof of production deployment before getting excited."""

    # Create argument from post
    arg = RecentArgument.from_post("test topic", content)

    print(f"Extracted argument:")
    print(f"  Topic: {arg.topic}")
    print(f"  Angle: {arg.angle}")
    print(f"  Evidence: {arg.evidence}")
    print(f"  Metaphor: {arg.metaphor}")
    print(f"  Conclusion: {arg.conclusion}")

    # Verify we got meaningful content
    assert len(arg.angle) > 0, "Should extract an angle"
    assert len(arg.evidence) > 0, "Should extract evidence"
    assert len(arg.metaphor) > 0, "Should extract metaphor"
    assert len(arg.conclusion) > 0, "Should extract conclusion"

    print("✓ Argument extraction test passed")

def test_argument_history():
    """Test that argument history is properly maintained."""
    print("\nTesting argument history...")

    persona = Persona(
        name="test_persona",
        bio="test bio",
        style="test style",
        voice_anchor="test anchor",
        expertise=["testing"],
        quirks=["test quirk"]
    )

    # Add some arguments
    for i in range(5):
        arg = RecentArgument(
            topic=f"topic {i}",
            angle=f"angle {i}",
            evidence=f"evidence {i}",
            metaphor=f"metaphor {i}",
            conclusion=f"conclusion {i}"
        )
        persona.record_argument(arg)

    # Check history is maintained
    assert len(persona.argument_history) == 5, "Should have 5 arguments"

    # Add more than 20 to test trimming
    for i in range(5, 25):
        arg = RecentArgument(
            topic=f"topic {i}",
            angle=f"angle {i}",
            evidence=f"evidence {i}",
            metaphor=f"metaphor {i}",
            conclusion=f"conclusion {i}"
        )
        persona.record_argument(arg)

    # Should be trimmed to 20
    assert len(persona.argument_history) == 20, "Should be trimmed to 20 arguments"
    # Should contain the most recent ones
    assert persona.argument_history[-1].topic == "topic 24", "Should have most recent topic"

    print("✓ Argument history test passed")

def test_record_response():
    """Test that record_response properly records arguments."""
    print("\nTesting record_response...")

    persona = Persona(
        name="test_persona",
        bio="test bio",
        style="test style",
        voice_anchor="test anchor",
        expertise=["testing"],
        quirks=["test quirk"]
    )

    content = """This is a test post about AI safety.

    Studies show that AI alignment is crucial for preventing catastrophic outcomes.

    Like a car without brakes, unaligned AI could cause irreversible damage.

    Therefore, we should invest more in AI safety research."""

    # Record a response
    persona.record_response(
        qc_score=8.5,
        accepted=True,
        topic="AI Safety Concerns",
        content=content
    )

    # Check that stats were updated
    assert persona.total_posts == 1, "Should have 1 total post"
    assert persona.accepted_posts == 1, "Should have 1 accepted post"
    assert persona.avg_qc_score == 8.5, "Should have correct average score"

    # Check that argument was recorded
    assert len(persona.argument_history) == 1, "Should have 1 argument in history"
    arg = persona.argument_history[0]
    assert arg.topic == "AI Safety Concerns", "Should have correct topic"
    assert len(arg.angle) > 0, "Should have extracted angle"
    assert len(arg.evidence) > 0, "Should have extracted evidence"
    assert len(arg.metaphor) > 0, "Should have extracted metaphor"
    assert len(arg.conclusion) > 0, "Should have extracted conclusion"

    print("✓ record_response test passed")

def test_persona_context_includes_arguments():
    """Test that persona_context includes argument history."""
    print("\nTesting persona_context includes arguments...")

    from agents.orchestrator import persona_context

    persona = Persona(
        name="test_persona",
        voice_anchor="test anchor · testing is important",
        expertise=["testing", "validation"],
        quirks=["always asks for proof", "skeptical of claims"],
        tagline="Proof or it didn't happen",
        catchphrase="Show me the data",
        signature="test_persona · testing is important",
        bio="I believe in evidence-based decision making.",
        style="Analytical and data-driven"
    )

    # Add some arguments
    for i in range(3):
        arg = RecentArgument(
            topic=f"test topic {i}",
            angle=f"We need more evidence for claim {i}",
            evidence=f"Study {i} showed only 60% success rate",
            metaphor=f"Like building without a foundation",
            conclusion=f"More research is needed before proceeding"
        )
        persona.record_argument(arg)

    # Get persona context
    context = persona_context(persona)

    print("Persona context:")
    print(context)

    # Check that it includes voice anchor
    assert "Voice anchor: test anchor · testing is important" in context

    # Check that it includes argument history
    assert "Recently used arguments" in context
    assert "Angle:" in context
    assert "Evidence used:" in context
    assert "Metaphor:" in context
    assert "Conclusion:" in context

    print("✓ persona_context test passed")

if __name__ == "__main__":
    print("Running argument history tests...\n")

    test_argument_extraction()
    test_argument_history()
    test_record_response()
    test_persona_context_includes_arguments()

    print("\n✅ All tests passed!")