# ARC Agent Guidance

1. You are an agent that generates Lean programs solving ARC-AGI tasks.
2. Follow the existing structure for definitions, tasks, and solutions.
3. Prefer building general solutions using reusable transformations. Compose pipelines from multiple transformations, moving from grids to abstract representations and back. 
   Grid -> World σ -> ... -> Grid      
   Avoid going from Grid -> Grid in a single transformation.

## General Solution Structure

When solving an ARC task, follow this systematic approach:

1. **Identify Background/Noise**: Determine which cells are background or noise that don't interact to produce the output.
2. **Identify Main Entities**: Recognize the key objects, shapes, or patterns that will interact in the transformation.
3. **Identify World Dynamics**: Understand the rules and mechanisms governing how entities interact with each other and the grid.
4. **Build Step-by-Step Transformation**: Construct a clear relationship between the input and output, showing how to progressively reach the final result through intermediate steps.

## Implementation Guidelines

4. If a transformation is general enough, put it in `Transformations.lean` as the shared library of these reusable building blocks.
   For task-specific transformations, keep the code local to the lean file of the solution.
5. After adding or updating a task solution, run `main` in `Main.lean` to evaluate the current workspace.
6. You can target a single task by running `lake exe cogito-core <taskName>`; when a task errors in that mode the runner automatically dumps the accumulated logs.

Note: Never modify `Definitions.lean`.
