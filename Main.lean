import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Tasks.Solutions
import CogitoCore.ARC.EvalStats
import CogitoCore.ARC.Evaluator

open CogitoCore.ARC
open CogitoCore.ARC.Definitions
open CogitoCore.ARC.Evaluator

def main : IO Unit := do
  let totalTasks := solutions.length
  let rec loop (remaining : List Solution) (stats : EvalStats) (tasksPassed : Nat) : IO (EvalStats × Nat) :=
    match remaining with
    | [] => pure (stats, tasksPassed)
    | sol :: rest => do
        let result ← evaluateSolution sol
        let stats := EvalStats.add stats result
        let tasksPassed := if result.passed == result.total then tasksPassed + 1 else tasksPassed
        loop rest stats tasksPassed
  let (overall, passedTasks) ← loop solutions EvalStats.zero 0
  IO.println s!"Tasks summary: {passedTasks}/{totalTasks} passed"
  IO.println s!"Overall summary: {overall.passed}/{overall.total} examples passed"
  pure ()
