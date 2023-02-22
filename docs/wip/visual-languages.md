---
search:
  exclude: true
#tags:
#    - Opinion
#    - Engineering
description: |
    A short overview about why attaching yourself to a programming language is marketable but bad for your code.
image: https://i.stack.imgur.com/686wZ.png
---

# Introduction

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
*Designer* : Hmm, our existing machinery has a forming bed that is limited to 4' in length, so it wouldn't be possible to form a ladder
*Business* : Okay, well lets just make it out of 4' segments then and we will combine the pieces after assembly
*Designer* : Another problem with the ladder is that 



[^tpp]: [Purchase 'The Phoenix Project'](https://itrevolution.com/product/the-phoenix-project/)
[^devops]: DevOps
[^formlabs]: [Read 'Introduction To Vacuum Forming'](https://formlabs.com/blog/introduction-to-vacuum-forming/)