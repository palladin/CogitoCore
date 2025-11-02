import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Parsing
import CogitoCore.ARC.Pretty
import CogitoCore.ARC.EvalStats

namespace CogitoCore.ARC.Evaluator

open CogitoCore.ARC
open CogitoCore.ARC.Definitions
open CogitoCore.ARC.Pretty
open CogitoCore.ARC.Parsing

/-- Pretty-print collected pipeline logs with indentation. -/
private def printLogs (logs : List String) : IO Unit := do
  IO.println "    logs:"
  let rec loop : List String → Nat → IO Unit
    | [], _ => pure ()
    | msg :: rest, idx => do
        IO.println s!"      {idx}. {msg}"
        loop rest (idx + 1)
  loop logs 1

/-- Evaluate a collection of examples for a program, reporting pass/fail details and returning stats. -/
def evaluateExamples (label : String) (solution : Solution) (examples : List Example)
    (dumpLogs : Bool) : IO EvalStats := do
  if examples.isEmpty then
    IO.println s!"  No {label} examples."
    pure EvalStats.zero
  else
    let rec loop (idx : Nat) (stats : EvalStats) (remaining : List Example) : IO EvalStats :=
      match remaining with
      | [] => pure stats
      | ex :: rest =>
          match runSolution (fuel := 1000) solution ex.input with
          | (Except.error err, logs) => do
              IO.println s!"  {label} {idx + 1}: runtime error {err}"
              if dumpLogs ∧ ¬ logs.isEmpty then
                printLogs logs
              let stats := EvalStats.record stats false
              loop (idx + 1) stats rest
          | (Except.ok actual, logs) => do
              if actual == ex.output then
                IO.println s!"  {label} {idx + 1}: passed"
                if dumpLogs ∧ ¬ logs.isEmpty then
                  printLogs logs
                let stats := EvalStats.record stats true
                loop (idx + 1) stats rest
              else
                IO.println s!"  {label} {idx + 1}: FAILED"
                dumpGrid "    expected:" ex.output
                dumpGrid "    actual:  " actual
                let diffs := gridDiffs ex.output actual
                printDiffs diffs
                if dumpLogs ∧ ¬ logs.isEmpty then
                  printLogs logs
                let stats := EvalStats.record stats false
                loop (idx + 1) stats rest
    loop 0 EvalStats.zero examples

/-- Evaluate a solution across its training and test sets, printing per-split summaries. -/
def evaluateSolution (sol : Solution) (dumpLogs : Bool := false) : IO EvalStats := do
  IO.println s!"Evaluating task {sol.taskName}"
  match ← loadTask sol.taskName with
  | .error err => do
      IO.eprintln s!"  Error loading task: {err}"
      pure EvalStats.zero
  | .ok task => do
      let trainingStats ← evaluateExamples "Training" sol task.trainExamples dumpLogs
      let testStats ← evaluateExamples "Test" sol task.testExamples dumpLogs
      IO.println s!"  Training summary: {trainingStats.passed}/{trainingStats.total} passed"
      IO.println s!"  Test summary: {testStats.passed}/{testStats.total} passed"
      pure <| EvalStats.add trainingStats testStats

end CogitoCore.ARC.Evaluator
