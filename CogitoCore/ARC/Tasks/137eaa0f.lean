import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Transformations

open CogitoCore.ARC.Definitions
open CogitoCore.ARC.Transformations

namespace CogitoCore.ARC.Tasks

/-- Program for ARC task 137eaa0f.
This task finds all cells with color 5 (anchors), collects their 3×3 neighborhoods,
and overlays them into a single 3×3 output grid with 5 at the center. -/
def puzzle137eaa0fProgram : Program Grid Grid :=
  Program.last overlayAnchorNeighborhoodsTransform

/-- Registered solution entry for ARC task 137eaa0f. -/
def puzzle137eaa0fSolution : Solution :=
  { taskName := "137eaa0f"
  , program := puzzle137eaa0fProgram }

end CogitoCore.ARC.Tasks
