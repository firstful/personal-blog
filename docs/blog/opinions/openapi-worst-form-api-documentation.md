---
title: OpenAPI Is the Worst Form of API Documentation Except All the Others
date: 2026-05-24
tags: [OpenAPI, API design, documentation, developer experience]
---

# OpenAPI Is the Worst Form of API Documentation Except All the Others

I have a love-hate relationship with OpenAPI. Actually, that's not quite right. It's more of a "tolerate-while-grumbling" relationship. OpenAPI specs are verbose, repetitive, and often wrong. They're written in YAML — a format that treats indentation as a personality disorder. They couple your documentation to a schema that's almost but not quite compatible with your actual implementation. And despite all of that, I keep writing them. So do you. So does everyone who ships a public API that anyone takes seriously.

There's a reason for that. OpenAPI is terrible, but everything else is worse.

## The Case Against OpenAPI (It's a Long List)

Let me count the ways.

**YAML.** I'll start with the obvious one. OpenAPI chose YAML as its primary representation, and YAML is a format that was designed by someone who thought Python's whitespace sensitivity was not nearly enough of a problem. A missing space in a multi-line string can change the entire structure of your document. The `|` vs `>` vs `|-` vs `>-` sigil game is a test of whether you've memorized the YAML spec or just given up and started escaping everything to be safe. If you use OpenAPI in JSON instead, you get all the verbosity of OpenAPI with none of the readability, plus the joy of manually balancing brackets.

**Repetition.** A well-designed REST API has consistent patterns. Your error responses all look the same. Your pagination follows the same format. Your authentication uses the same header. In OpenAPI, each of these patterns must be explicitly defined for every single endpoint — or you use `$ref` and components to extract them, which works great until you need to override one field in one response and suddenly you're deciding between `allOf` gymnastics and duplicating the entire schema.

**The drift problem.** The OpenAPI spec is a document. The API implementation is code. These two things live in different files, maintained by different people (or the same person at different levels of caffeine), and they inevitably diverge. The spec says the endpoint returns a 201 with a location header. The code returns a 200 with the resource in the body. Neither gets updated because the sprint deadline is tomorrow and "the tests pass." This is so endemic that an entire industry of spec-to-code and code-to-spec tooling exists just to paper over the gap.

**Versioning.** OpenAPI 2.0 (Swagger) was different from OpenAPI 3.0, which was different from OpenAPI 3.1, which is different from... wait, is everyone on 3.1 now? No, half the ecosystem still generates 3.0 because the 3.1 JSON Schema compatibility broke everything. Your carefully crafted spec file might be silently invalid depending on which version of which tool is trying to read it.

## But Consider the Alternatives

**No documentation.** I'm a professional. I understand code. Just read the source. This is the position of every senior engineer who has ever been burned by outdated docs, and it is absolutely correct for internal services where the team is small and the codebase is clean. But it does not scale. Your API consumers do not want to read your controller code to figure out what parameters to pass. They want a document, preferably one that works with their tools.

**Wiki-style prose docs.** This is what most projects do before they discover OpenAPI: a hand-written markdown page that describes the API in loose paragraphs. "The /users endpoint accepts a POST request with a JSON body containing the user's name and email." It's readable, it's flexible, and it is almost never complete. Did you document the error format? The rate limits? The pagination parameters? The deprecated fields? Of course not — you were in a hurry. And now there are three separate markdown files, each with different formatting, none of which tell the consumer whether the email field is required.

**Auto-generated docs.** Tools like Swagger UI and ReDoc take your OpenAPI spec and generate interactive documentation. This is genuinely useful. But it only works if your spec is accurate, which brings us back to the drift problem. And if you're generating the spec from code annotations (Javadoc-style), you've just swapped one maintenance burden for another — now your annotations are the spec, and they're sprinkled across your controllers like syntactic glitter.

**gRPC + protobuf.** Protobuf definitions are stricter, less ambiguous, and generate client code in every language. If you're building a new service from scratch, gRPC is genuinely better. But it requires protobuf tooling on every consumer, binary wire formats are harder to debug, and the ecosystem for browser clients is immature. For a public REST API — which is what most of us are building — gRPC is a non-starter because your consumers expect curl commands, not a `.proto` file.

**GraphQL.** GraphQL solves the over-fetching and under-fetching problems beautifully. But it introduces its own complexity: resolver architecture, N+1 query problems, and a learning curve that's steeper than "hit this URL, get JSON back." GraphQL is excellent for complex client-driven applications. For a simple CRUD API that has ten endpoints, it's a sledgehammer.

## Why OpenAPI Wins Anyway

Here's the thing. OpenAPI is terrible, but it's the only format that checks all of these boxes simultaneously:

**Machine-readable enough to generate code.** I can feed an OpenAPI spec into `openapi-generator` and get a working client library in Python, Go, TypeScript, or Java. I can generate a server stub, a mock server, or an API test suite. I can validate requests against the spec at the gateway layer. No other documentation format does this.

**Human-readable enough to review.** A well-written OpenAPI spec is readable. Not beautiful, but readable. I can scan the endpoints, understand the request/response shapes, and find the information I need without clicking through a UI. This is not true of protobuf (too verbose) or GraphQL schemas (too abstract).

**Industry standard.** Every API tool you've heard of supports OpenAPI: Postman, Insomnia, Kong, AWS API Gateway, Azure APIM, NGINX, Apache APISIX. If you ship an OpenAPI spec, your consumers can use whatever tool they prefer. If you ship a custom format, you're asking them to adopt your toolchain.

**Contract testing.** An OpenAPI spec is a contract between your service and its consumers. With tools like Dredd, Schemathesis, or `pact-js`, you can automatically verify that your implementation conforms to the spec. This doesn't solve the drift problem by magic, but it gives you a concrete way to catch it in CI.

## How to Make OpenAPI Suck Less

I've been working with OpenAPI long enough to develop some coping strategies. Share and enjoy.

**Put your spec in version control, next to your code.** The closer the spec is to the implementation, the less it will drift. Ideally, your spec should live in the same repository, and your CI should reject PRs where the spec and the code disagree.

**Use a code-first approach with linting.** Tools like `@nestjs/swagger` (TypeScript), `drf-spectacular` (Django), or `fastapi` (Python) generate the spec from your code. This guarantees accuracy at the cost of some control. Combine with `spectral` linting to enforce naming conventions, security schemes, and response standards.

**Write examples.** The single highest-leverage thing you can do in an OpenAPI spec is provide good examples. A consumer can figure out the schema from examples faster than they can parse a `type: object` with fourteen `$ref` chains. Every parameter, every request body, every response should have a realistic example.

**Version your spec independently.** Your API version and your spec version are different things. Bump the spec version when you fix a description, add an example, or clarify a constraint. Your consumers will thank you for the changelog.

**Accept the suck.** OpenAPI is not going to be replaced anytime soon. The network effects are too strong, the tooling ecosystem too deep, and the alternatives too compromised. Treat it like a tax on shipping a serious API — an annoying but necessary cost of doing business professionally.

Churchill said democracy is the worst form of government except for all the others. OpenAPI is the worst form of API documentation except for all the others. It's verbose, fragile, and frustrating. But it's also the only format that actually works at scale. So I'll keep writing YAML, muttering under my breath, and being grateful that at least I don't have to document everything in PDF.
