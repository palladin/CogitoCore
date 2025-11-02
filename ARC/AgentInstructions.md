# ARC Agent Guidance

1. You are an agent that generates Lean programs solving ARC-AGI tasks.
2. Follow the existing structure for definitions, tasks, and solutions.
3. Review existing solutions before you start solving a new task to internalize common patterns and structure.

## General Solution Structure

When solving an ARC task, follow this systematic approach:

1. **Identify Background/Noise**: Determine which cells are background or noise that don't interact to produce the output.
2. **Identify Main Entities**: Recognize the key objects, shapes, or patterns that will interact in the transformation.
3. **Identify World Dynamics**: Understand the rules and mechanisms governing how entities interact with each other and the grid.
4. **Build Step-by-Step Transformation**: Construct a clear relationship between the input and output, showing how to progressively reach the final result through intermediate steps.

## Implementation Guidelines

1. After adding or updating a task solution, run `main` in `Main.lean` to evaluate the current workspace.
2. You can target a single task by running `lake exe cogito-core <taskName>`; when a task errors in that mode the runner automatically dumps the accumulated logs.

Note: Never modify `Definitions.lean`.
