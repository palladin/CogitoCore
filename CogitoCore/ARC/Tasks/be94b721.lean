import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Transformations

open CogitoCore.ARC.Definitions
open CogitoCore.ARC.Transformations

namespace CogitoCore.ARC.Tasks

/-- Program for ARC task be94b721.
This task extracts the bounding box of the most frequently occurring color. -/
def puzzlebe94b721Program : Program Grid Grid :=
  Program.last extractMostFrequentColorBoundingBoxTransform

/-- Registered solution entry for ARC task be94b721. -/
def puzzlebe94b721Solution : Solution :=
  { taskName := "be94b721"
  , program := puzzlebe94b721Program }

end CogitoCore.ARC.Tasks
