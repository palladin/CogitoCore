import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Tasks

open CogitoCore.ARC.Definitions
open CogitoCore.ARC.Tasks
open Program

namespace CogitoCore.ARC.Programs

private def gridIdentityTransform (rows cols : Nat) : Transform (Grid rows cols) (Grid rows cols) :=
  { name := s!"grid-id-{rows}x{cols}"
  , apply := fun g => .some g }

private def failureTransform : Transform α β :=
  { name := "failure-transform"
  , apply := fun _ => .none }

/-- ------------------------------------------------------------------
    Identity program dispatcher using trivial transforms or failure.
    ------------------------------------------------------------------ -/
def identityProgram (d : InOutDim) : Program (Grid d.inRows d.inCols) (Grid d.outRows d.outCols) :=
  match d with
  | { inRows := inRows, inCols := inCols, outRows := outRows, outCols := outCols } =>
      if hRows : inRows = outRows then
        if hCols : inCols = outCols then
          by
            cases hRows
            cases hCols
            exact Program.last (gridIdentityTransform inRows inCols)
        else
          Program.last failureTransform
      else
        Program.last failureTransform

def identityValidation : Option Bool :=
  validateTask identityProgram identityTask

def identityWitness : { p : (d : InOutDim) → Program (Grid d.inRows d.inCols) (Grid d.outRows d.outCols) // validateTask p identityTask = .some true } :=
  ⟨identityProgram, by rfl⟩

end CogitoCore.ARC.Programs
