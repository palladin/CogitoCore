import CogitoCore
import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Tasks.Solutions
import CogitoCore.ARC.EvalStats
import CogitoCore.ARC.Evaluator

open CogitoCore.ARC
open CogitoCore.ARC.Definitions
open CogitoCore.ARC.Evaluator

def main (args : List String) : IO UInt32 := do
  IO.println s!"CogitoCore {CogitoCore.version} ARC Evaluation"
  let (solutionsToRun, dumpLogs, missing?) :=
    match args with
    | [] => (solutions, false, (none : Option String))
    | name :: _ =>
        match solutions.find? (fun (sol : Solution) => sol.taskName = name) with
        | some sol => ([sol], true, none)
        | none => ([], true, some name)
  match missing? with
  | some name => do
      IO.eprintln s!"No solution registered with task name '{name}'."
      let known := solutions.map (fun (sol : Solution) => sol.taskName)
      if ¬ known.isEmpty then
        IO.println "Available task names:"
        for n in known do
          IO.println s!"  - {n}"
      else
        IO.println "No solutions are currently registered."
      pure 1
  | none => do
      let totalTasks := solutionsToRun.length
      let rec loop (remaining : List Solution) (stats : EvalStats) (tasksPassed : Nat) : IO (EvalStats × Nat) :=
        match remaining with
        | [] => pure (stats, tasksPassed)
        | sol :: rest => do
            let result ← evaluateSolution sol dumpLogs
            let stats := EvalStats.add stats result
            let tasksPassed := if result.passed == result.total then tasksPassed + 1 else tasksPassed
            loop rest stats tasksPassed
      let (overall, passedTasks) ← loop solutionsToRun EvalStats.zero 0
      IO.println s!"Tasks summary: {passedTasks}/{totalTasks} passed"
      IO.println s!"Overall summary: {overall.passed}/{overall.total} examples passed"
      pure 0
