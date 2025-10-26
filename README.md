# CogitoCore

CogitoCore is a Lean 4 research playground for program-synthesis strategies inspired by the ARC-AGI benchmark. The initial scaffold focuses on a tiny handcrafted task so that synthesis ideas can be prototyped quickly in Lean.

## Prerequisites

- Install [elan](https://leanprover-community.github.io/get_started.html) so the pinned Lean toolchain can be fetched automatically.
- Ensure the `lake` build tool (ships with Lean 4) is available on your `$PATH`.

## Quickstart

```
lake build              # Compile the library
lake exe cogito-core    # Run the demo synthesis pipeline
```

The demo prints the result of running a naïve search over a few handcrafted programs against the bundled ARC-style task.

## Project Layout

- `lean-toolchain`: pins Lean 4 version `leanprover/lean4:4.8.0`.
- `lakefile.toml`, `lakefile.lean`: Lake package configuration and executable target.
- `CogitoCore/`: library source code.
	- `ARC/`: ARC grid/task representations and sample data.
	- `Synthesis/`: DSL primitives and a naïve synthesis engine.
- `Main.lean`: entry point that runs the demo search.
- `Test/Smoke.lean`: simple regression check using `#eval`.

## Next Steps

- Extend `CogitoCore.Synthesis.Engine` with richer search strategies (enumerative, constraint solving, etc.).
- Encode additional ARC tasks inside `CogitoCore.ARC.Task` for broader coverage.
- Integrate Lean automation (e.g., metaprogramming tactics) to guide synthesis.
