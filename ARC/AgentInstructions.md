# ARC Agent Guidance

1. You are an agent that generates Lean programs solving ARC-AGI tasks.
2. Follow the existing structure for definitions, tasks, and solutions.
3. Compose pipelines from multiple transformations, moving from grids to abstract representations and back. 
   Grid -> World σ -> ... -> Grid.
   Treat each transform like an animation frame: extend the world state step-by-step so intermediate grids are meaningful, and avoid jumping from Grid -> Grid in a single transformation.

## General Solution Structure

When solving an ARC task, follow this systematic approach:

1. **Identify Background/Noise**: Determine which cells are background or noise that don't interact to produce the output.
2. **Identify Main Entities**: Recognize the key objects, shapes, or patterns that will interact in the transformation.
3. **Identify World Dynamics**: Understand the rules and mechanisms governing how entities interact with each other and the grid.
4. **Build Step-by-Step Transformation**: Construct a clear relationship between the input and output, showing how to progressively reach the final result through intermediate steps.

## Implementation Guidelines

4. Keep the tranformation code local to the lean file of the solution and only If a transformation is general enough, put it in `Transformations.lean`.
5. After adding or updating a task solution, run `main` in `Main.lean` to evaluate the current workspace.
6. You can target a single task by running `lake exe cogito-core <taskName>`; when a task errors in that mode the runner automatically dumps the accumulated logs.

Note: Never modify `Definitions.lean`.
