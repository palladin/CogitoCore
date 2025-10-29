import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Parsing
import CogitoCore.ARC.Pretty
import CogitoCore.ARC.EvalStats

namespace CogitoCore.ARC.Evaluator

open CogitoCore.ARC
open CogitoCore.ARC.Definitions
open CogitoCore.ARC.Pretty
open CogitoCore.ARC.Parsing

/-- Evaluate a collection of examples for a program, reporting pass/fail details and returning stats. -/
def evaluateExamples (label : String) (program : Program Grid Grid) (examples : List Example) : IO EvalStats := do
  if examples.isEmpty then
    IO.println s!"  No {label} examples."
    pure EvalStats.zero
  else
    let rec loop (idx : Nat) (stats : EvalStats) (remaining : List Example) : IO EvalStats :=
      match remaining with
      | [] => pure stats
      | ex :: rest =>
          match run program ex.input with
          | (Except.error err, _) => do
              IO.println s!"  {label} {idx + 1}: runtime error {err}"
              let stats := EvalStats.record stats false
              loop (idx + 1) stats rest
          | (Except.ok actual, _) => do
              if actual == ex.output then
                IO.println s!"  {label} {idx + 1}: passed"
                let stats := EvalStats.record stats true
                loop (idx + 1) stats rest
              else
                IO.println s!"  {label} {idx + 1}: FAILED"
                dumpGrid "    expected:" ex.output
                dumpGrid "    actual:  " actual
                let diffs := gridDiffs ex.output actual
                printDiffs diffs
                let stats := EvalStats.record stats false
                loop (idx + 1) stats rest
    loop 0 EvalStats.zero examples

/-- Evaluate a solution across its training and test sets, printing per-split summaries. -/
def evaluateSolution (sol : Solution) : IO EvalStats := do
  IO.println s!"Evaluating task {sol.taskName}"
  match ← loadTask sol.taskName with
  | .error err => do
      IO.eprintln s!"  Error loading task: {err}"
      pure EvalStats.zero
  | .ok task => do
      let trainingStats ← evaluateExamples "Training" sol.program task.trainExamples
      let testStats ← evaluateExamples "Test" sol.program task.testExamples
      IO.println s!"  Training summary: {trainingStats.passed}/{trainingStats.total} passed"
      IO.println s!"  Test summary: {testStats.passed}/{testStats.total} passed"
      pure <| EvalStats.add trainingStats testStats

end CogitoCore.ARC.Evaluator
