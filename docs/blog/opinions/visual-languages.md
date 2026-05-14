---
tags:
    - Opinion
    - Engineering
description: |
    How programming languages shape the software we build, and why that matters.
image: https://i.stack.imgur.com/686wZ.png
---

# Visual Languages: How Our Tools Shape Our Products

## Introduction

One of the most popular books for those working in IT is 'The Phoenix Project'[^tpp], and for good reason. It provides justification and explanation for principles that undergird the DevOps[^devops] movement and does so while remaining relatable and even humorous at times.

One of the most repeated elements is the comparison of IT to a manufacturing plant, where the only difference is that instead of producing automotive parts, IT produces software. This analogy is used repeatedly to shoot down the idea that software development is a special industry that must be treated like a bespoke artisan furniture business.

## Vacuum Forming

I would like to extend this analogy further to talk about how programming languages impact the product in the same way the tools of a manufacturing plant impact their products. Lets take for example, a vacuum forming machine, as seen below:

<figure markdown>
  ![vacuum](https://thumbs.gfycat.com/EnlightenedGleefulBernesemountaindog-size_restricted.gif){width="400px" style="border-radius: 20px;"}
  <figcaption>Vacuum Forming Luggage</figcaption>
</figure>

Vacuum forming machines simultaneously provide huge value while imposing non-trivial constraints on the products they produce. FormLabs[^formlabs] provides a succinct explanation of these constraints:

!!! quote "FormLabs[^formlabs]"

    Vacuum forming is only viable for parts with relatively **thin walls** and **simple geometries**. The finished parts may not have a **consistent wall thickness**, and **concave parts** with a deep draw are difficult to produce using vacuum forming.

If you are a product designer, and the main tool at your disposal is a vacuum forming machine, your parts will inevitably be designed around these constraints. If you were limited to just this machine, it would be impossible to produce certain parts. For example:

*Business* : We need you to design us a ladder.

*Designer* : Hmm, our existing machinery has a forming bed that is limited to 4' in length, so it would not be possible to form a ladder in one piece.

*Business* : Okay, well lets just make it out of 4' segments and then we will combine the pieces after assembly.

*Designer* : That could work, but another problem is that a ladder has complex geometry. The rungs need to be round and the rails need to be flat. Vacuum forming cannot produce parts with varying wall thickness and sharp corners without secondary operations.

The result is a product that works but is heavier, has more joints, and costs more to produce than if it had been designed for the right manufacturing process from the start.

## Programming Languages as Constraints

Replace "vacuum forming machine" with "JavaScript" or "Java" and the analogy holds. Every programming language comes with its own set of constraints:

- **JavaScript** makes concurrency easy but single-threaded computation hard
- **Java** provides robust typing and tooling but requires significant ceremony
- **Python** offers rapid iteration but struggles with CPU-bound parallelism
- **Rust** guarantees memory safety but demands explicit lifetime management

None of these are inherently bad. They are trade-offs. The problem arises when an organization standardizes on one language and then tries to solve every problem with it. The result is software that works, but carries the weight of the wrong tool.

## No-Code and Visual Programming

This is where the analogy becomes particularly relevant today. The rise of no-code and low-code platforms (UiPath, Power Apps, Retool) represents a bet that visual, domain-specific tools can produce software faster than general-purpose programming languages.

The vacuum forming analogy suggests a cautionary note: these platforms will be excellent for a specific range of problems — thin walls and simple geometries — but will struggle with anything that requires deep customization or non-standard behavior. When your application inevitably needs to do something outside the platform's design, you will face the same choice as our ladder designer: work around it, accept the inefficiency, or rebuild with different tools.

## Choosing the Right Tool

The lesson is not that vacuum forming is bad, or that visual languages are inferior. It is that every tool imposes constraints, and the best engineers understand the constraints of their tools well enough to know when a different tool is needed. Language agnosticism is not just about career flexibility; it is about building better products by choosing the right constraints for the problem at hand.

[^tpp]: [Purchase 'The Phoenix Project'](https://itrevolution.com/product/the-phoenix-project/)
[^devops]: DevOps
[^formlabs]: [Read 'Introduction To Vacuum Forming'](https://formlabs.com/blog/introduction-to-vacuum-forming/)
