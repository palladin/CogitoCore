import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Tasks

open CogitoCore.ARC.Definitions
open CogitoCore.ARC.Tasks
open Program

namespace CogitoCore.ARC.Programs

def gridIdentityTransform : Transform (Grid 1 1) (Grid 1 1) :=
  { name := "grid-id"
  , apply := id }

def identityProgram : Program (Grid 1 1) (Grid 1 1) :=
  Program.last gridIdentityTransform

def identityValidation : Bool :=
  validateTask identityProgram identityTask

def identityWitness : { p : Program (Grid 1 1) (Grid 1 1) // validateTask p identityTask = true } :=
  ⟨identityProgram, by rfl⟩

end CogitoCore.ARC.Programs
