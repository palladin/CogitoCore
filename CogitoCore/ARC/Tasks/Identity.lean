import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Transformations

open CogitoCore.ARC.Definitions
open CogitoCore.ARC.Transformations

namespace CogitoCore.ARC.Tasks

def identityExample : Example :=
  { input := { cells := #[#[.C5]] }
  , output := { cells := #[#[.C5]] } }

/-- Simple identity ARC task mirroring its input. -/
def identityTask : Task :=
  { name := "identity"
  , examples := [identityExample] }

def identityProgram : Program Grid Grid :=
  .last gridIdentityTransform

def identitySolution : Solution :=
  { task := identityTask
  , program := identityProgram
  , isValid := by rfl }

end CogitoCore.ARC.Tasks
