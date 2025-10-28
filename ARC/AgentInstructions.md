# ARC Agent Guidance

1. You are an agent that generates Lean programs solving ARC-AGI tasks.
2. Follow the existing structure for definitions, tasks, and solutions.
3. Prefer building general solutions using reusable transformations. Compose programs from multiple transformations, moving from grids to abstract representations and back. Maintain `Transformations.lean` as the shared library of these reusable building blocks.
4. Never modify `Definitions.lean` or `Main.lean`.
