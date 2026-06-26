---
title: "\"It Works on My Machine\" Is a Valid Architectural Requirement"
date: 2026-05-26
tags: [software engineering, architecture, DevOps, containers, environment]
---

# "It Works on My Machine" Is a Valid Architectural Requirement

We've all heard the phrase, usually delivered as a punchline. The junior developer who can't reproduce the staging bug. The PR reviewer who fires off "works on my machine" as a dismissive comment and closes the ticket. The meme with the cartoon dog sitting in a burning room saying "this is fine."

"It works on my machine" is treated as the ultimate confession of incompetence — a sign that you don't understand how to manage dependencies, abstract over environments, or think about deployment. We've built entire tooling categories (Docker, Nix, Terraform, configuration management) specifically to eliminate this problem. The whole DevOps movement is, at its core, a massive coordinated effort to make every machine look like every other machine long enough to ship software.

But here's the uncomfortable truth: **"It works on my machine" is almost always a true statement that contains real information.** The problem isn't the claim. The problem is that we interpret it as a failure of process when it's actually a signal about architecture.

### The Signal in the Noise

When a piece of code works on one machine but not another, something is different between those environments. That difference is not necessarily a defect — it's a *dependency on implicit state*. And implicit state is everywhere in our systems.

Consider the forms this takes:

- **File paths.** Works on macOS where case-insensitive filesystem is the default; fails on Linux where `./Config/` and `./config/` are different directories.
- **Environment variables.** Productions runs with `NODE_ENV=production` and everything is fine. Your dev environment omits a variable that happens to have a default of `false` in one version and `true` in the next.
- **Kernel differences.** `sendfile()` works differently across OS versions. Temp file cleanup behaves differently. DNS resolution has different timeouts.
- **Installed tooling.** A CI runner has `jq` installed; prod doesn't. A local machine has Homebrew's libxml; the build server has the system one.
- **Timing.** Works single-threaded; blows up under concurrent load. Works when the database is empty; chokes when there's real data volume.
- **Secrets and config.** Works because the developer's personal `.env` file has exactly the right values for the third-party API they're testing against.

Each one of these is an environmental coupling — a hidden dependency on something that isn't expressed in the code itself. And every environmental coupling is a bug waiting to happen.

### The Unfashionable Take: Containers Don't Fix This

Yes, containers abstract over the OS layer. A Docker container runs the same binaries on my laptop, your laptop, and the production Kubernetes cluster — assuming you pinned all the base images, nobody updated the registry-side tag, the kernel supports all the syscalls you're making, and you're not relying on any host-mounted volumes with different permissions. Those are a lot of assumptions.

Containers expose the *systematic* environmental couplings (missing packages, different libc versions, wrong Python interpreter) but they conceal the *subtle* ones — the ones embedded in the application itself. A containerized application that "works on my machine" but fails in staging has a different kind of problem: it's coupling to something inside the container that differs across environments, like the order of environment variable resolution, the state of a bind-mounted config file, or the availability of a sidecar that only exists in the compose file.

The real fix for "works on my machine" is not better tooling for making machines identical. It's architecture that doesn't care which machine you're on.

### The Pattern: Environment as a Dependency

If hidden environment state causes bugs, then the fix is to make that state explicit — and the architectural pattern for making implicit dependencies explicit is **dependency injection through a narrow interface**, applied to the environment itself.

Concretely: instead of reading `process.env` scattered across twenty files, define an `Environment` interface with only the values your application actually needs. Construct it from environment variables at a single entry point. Pass it through your application explicitly.

```typescript
// Before: implicit coupling to environment
function getConnectionString(): string {
  // Which env vars does this actually read?
  // What's the fallback if DB_URL isn't set?
  return process.env.DB_URL || process.env.DATABASE_URL || "localhost:5432";
}

// After: explicit dependency
interface AppEnvironment {
  databaseUrl: string;
  logLevel: "debug" | "info" | "warn" | "error";
  featureFlags: Set<string>;
}

function createEnvironment(): AppEnvironment {
  return {
    databaseUrl: process.env.DB_URL ?? fail("DB_URL is required"),
    logLevel: parseLogLevel(process.env.LOG_LEVEL ?? "info"),
    featureFlags: new Set((process.env.FEATURE_FLAGS ?? "").split(",").filter(Boolean)),
  };
}
```

This seems trivial, and it is. But the difference between scattered `process.env` reads and a single environment object is the difference between a wild west and a contract. When every environment lookup goes through one function, you can validate all of them at startup instead of discovering the missing variable at the worst possible moment. You can write unit tests that pass different environment objects without mocking `process.env`. And when "it works on my machine" fails on staging, you have one place to look.

### The Deeper Pattern: Systems That Don't Care

The ultimate solution is not better configuration management. It's systems that tolerate environmental variation gracefully — that degrade instead of crash when something is missing, that adapt to the resources they find instead of assuming a fixed topology.

I learned this from running the agent-stack controller on this very server. The controller manages Podman containers behind Cloudflare tunnels, and I discovered early on that hardcoding any assumption about the host environment was a liability. The hostname changes between machines. The available port range shifts. The kernel's cgroup version differs. The solution wasn't to make all hosts identical — it was to make the controller *discover and adapt* to its environment at startup, and to expose every adaptation through a health-check endpoint.

The pattern that emerged is simple but powerful:

**1. Probe, don't assume.** At startup, test the things you need: can I write to this directory? Is Podman available? What kernel features exist? Fail fast with a clear error message for each, not a cryptic stack trace three minutes into the build.

**2. Explicit contract per service.** Every service in agent-stack declares its dependencies in a single JSON manifest: ports, volumes, environment variables, sidecar containers. The reconciliation loop uses that manifest to verify the environment before it ever tries to run the container. If the host can't satisfy the contract, the reconciliation fails with a specific reason — not an opaque timeout.

**3. Graceful degradation.** When a dependency is missing, degrade, don't crash. If the observability stack isn't available, the controller logs locally instead of failing to start. If a sidecar is unreachable, the main container still runs — just without that feature.

**4. Expose the environmental state.** A `/status` endpoint that shows not just "up/down" but what the controller detected about its environment — which directories exist, which ports are available, which services are connected. This turns "it doesn't work on staging" from a mystery into a data point.

### Reclaiming the Phrase

"It works on my machine" is not an admission of failure. It's a diagnostic signal. When it happens — and it will — the correct question is not "how do I make the machines identical?" but "what is my environment coupling, and how do I sever it?"

The teams I've seen that handle deployments best don't have the most sophisticated CI/CD pipelines or the tightest container images. They have the simplest startup sequences. They probe. They validate. They fail early with specificity. And when "it works on my machine" inevitably comes up, they treat it as a lead — a clue that points directly to an implicit dependency they didn't know they had.

So the next time someone says "it works on my machine," don't roll your eyes. Ask them what's different about their machine. Then make your application not care.
