---
search:
  exclude: true
#tags:
#    - Opinion
#    - UiPath
#    - C#
#    - Engineering
description: |
    A short overview about why attaching yourself to a programming language is marketable but bad for your code.
image: https://i.stack.imgur.com/686wZ.png

---

# Language agnosticism is not marketable, and that's a problem. 

## The Problem

When recruiters search LinkedIn, they search for terms like *"Java Developer"* or *"React Developer"*. Take a look at the requirements for a given job posting and you will find a list of programming languages and tools, with requirements listed in "Years of Experience". Many have written about this problem before[^1], and this phenomenon has been satirized by programmers, with some positions asking for YOE greater than the skill has existed!

<figure markdown>
  ![tweet](https://i.redd.it/lpo3jfzka9a51.jpg){width="400px"}
  <a href="https://twitter.com/tiangolo/status/1281946592459853830"><figcaption>YOE, in a nutshell.</figcaption></a>
</figure>

Many engineering "talent acquisition" roles could be more aptly named "risk management" when the main goal of interviewing is to find someone who has survived in a given sector for enough time to guarantee they are a 'good developer'. As with anything, a risk-averse strategy results in a compressed range of outcomes, but not ones that are 'better' on average[^2], and sometimes, even worse![^3]

!!! quote "Isaac Lyman[^4]"

    *Employers are constantly at risk of hiring developers with 20 years of job experience but no passion or drive, instead of developers with 4 years of job experience, 6 years of childhood hackery, 3 years of weekends on GitHub, and a lifetime of enthusiasm for cool software.*



## Frameworks, Languages, Standards, Platforms

For non-technical readers, and even tech-literate recruiters, it can be hard to understand the jargon and differentiate between different technologies. Let's imagine a situation where you are looking for a recruit with experience managing Swagger definitions. Quick quiz - of the following terms, which is the most relevant to this requirement?

??? hint "AsyncAPI"
    Related, but not what we are looking for!

??? hint "REST API"
    Nope!

??? hint "OpenAPI"
    Correct!

??? hint "FastAPI"
    Related, but not what we are looking for!






## Programming Lifecycle

As programming languages become increasingly high-level and PaaS[] becomes the standard for enterprises, the lifetime of a particular stack decreases. For those unfamiliar, lets take the example of the LAMP stack - Linux, Apache, MySQL, and PHP. This stack has been around for close to 30 years at this point, and the most common example of this is Wordpress, which powers over 40% of all websites on the internet[]. Similarly, Ruby on Rails was released in 2004 and has seen extensive use the 20 years since then. 

If you are hiring for these stacks, it could make sense to find developers who have significant experience on these stacks. If you need developers for a monolithic PHP application, it makes sense to write "5 years of experience with Laravel" on the requirements, because [no-one is coming out with hot new PHP frameworks in 2023](https://www.google.com/search?q=new+php+frameworks).

Lets assume you are not hiring for these roles. If you are, I would encourage you to close this article and go do a security audit, since there is a **86% chance that your app has a XSS or SQL injection bug.** [][]

<figure markdown>
  ![tweet](https://149351115.v2.pressablecdn.com/wp-content/uploads/2018/01/trends-minor.png){width="600px"}
  <figcaption><a href="https://stackoverflow.blog/2018/01/11/brutal-lifecycle-javascript-frameworks/">JS Frameworks</a></figcaption>
</figure>

## Programming is Learning

!!! quote "Jeff Atwood[^1]"

    *Somehow, they've forgetten [sic] that ***what software developers do best is learn***. Employers should be looking for passionate, driven, flexible self-educators who have a proven ability to code in whatever language -- and serving them up interesting projects they can engage with.* 

[^1]: [The YOE Myth](https://blog.codinghorror.com/the-years-of-experience-myth/)
[^2]: [Your Company Is Too Risk Averse](https://hbr.org/2020/03/your-company-is-too-risk-averse)
[^3]: [Loss Aversion](https://en.wikipedia.org/wiki/Loss_aversion)
[^4]: [YOE is a garbage metric](https://dev.to/isaacdlyman/years-of-experience-is-a-garbage-metric)
[^]: [Wordpress 43.2%](https://w3techs.com/technologies/details/cm-wordpress)
[^]: [The most hackable programming language is PHP](https://www.vice.com/en/article/ezp4ek/new-analysis-the-most-hackable-programming-language-is-php-by-a-mile)
[^]: I don't mean to hate on PHP too much. I have worked with it and can appreciate certain aspects of the language, but it's clear it has been superseded, especially when it comes to security.