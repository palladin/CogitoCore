# CogitoCore

CogitoCore probes how large language models cope with program generation when immersed in Lean 4's rich abstractions and compositional tooling. The project invites an LLM to assemble higher-order transformations and compose reusable modules while staying within a precise type system. ARC-AGI tasks supply the reasoning benchmark, so success means leveraging Lean's ARC specific structures to help the LLM complete each task efficiently.

## In a Nutshell

- Lean provides the typed playground: ARC grids, tasks, and reusable transformations are encoded directly in Lean.
- The LLM proposes programs: candidate pipelines are stitched together from the provided abstractions and must pass Lean's type checker.
- ARC-AGI measures success: tasks from the benchmark validate whether the Lean-guided synthesis flow solves real ARC missions end to end.

## Prerequisites

- Install [elan](https://leanprover-community.github.io/get_started.html) so the pinned Lean toolchain can be fetched automatically.
- Ensure the `lake` build tool (ships with Lean 4) is available on your `$PATH`.


## Project Layout

- `lean-toolchain`: pins Lean 4 version `leanprover/lean4:4.8.0`.
- `lakefile.toml`, `lakefile.lean`: Lake package configuration and executable target.
- `CogitoCore/ARC/Definitions.lean`: core cell, grid, and task abstractions with rich typing hooks.
- `CogitoCore/ARC/Transformations.lean`: reusable building blocks that LLMs can compose into larger programs.
- `CogitoCore/ARC/Tasks/`: curated ARC-AGI missions expressed both as Lean examples and raw JSON metadata.
- `data/training/`: original ARC JSON payloads mirrored from the benchmark.
- `Main.lean`: current CLI stub; will soon drive the ARC evaluation harness.