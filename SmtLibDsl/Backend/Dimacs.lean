/-
  SmtLibDsl - shared adapter for DIMACS command-line SAT solvers
-/
import SmtLibDsl.Backend.Core

namespace SmtLibDsl.DimacsCli

open SmtLibDsl

/-- Parse the standard SAT-competition status and signed model lines emitted
by command-line DIMACS solvers such as Kissat and CaDiCaL. -/
def parseOutput (solverName stdout stderr : String) : SatResult :=
  let lines := stdout.splitOn "\n" |>.map (·.trimAscii.toString)
  if lines.any (· == "s UNSATISFIABLE") then
    .unsat
  else if lines.any (· == "s SATISFIABLE") then
    let values := lines.filter (·.startsWith "v ")
      |>.flatMap (fun line => line.splitOn " ")
      |>.filterMap String.toInt?
    let assignment := values.foldl (fun result literal =>
      if literal == 0 then result
      else result.insert literal.natAbs (literal > 0)
    ) {}
    .sat assignment
  else
    .error s!"failed to parse {solverName} output:\n{stdout}\n{stderr}"

/-- Check a DIMACS solver executable using its version flag. -/
def checkExecutable (solverName path envName : String) :
    IO (Except String String) := do
  try
    let output ← IO.Process.output { cmd := path, args := #["--version"] }
    if output.exitCode == 0 then
      return .ok output.stdout.trimAscii.toString
    return .error s!"{solverName} returned an error: {output.stderr}"
  catch _ =>
    return .error s!"{solverName} not found at '{path}'. Run scripts/setup.sh or set {envName}."

private def waitWithTimeout {cfg : IO.Process.StdioConfig}
    (child : IO.Process.Child cfg) (milliseconds : Nat) :
    IO (Option UInt32) := do
  let delays :=
    List.replicate (milliseconds / 10) 10 ++
      if milliseconds % 10 == 0 then [] else [milliseconds % 10]
  let rec poll (remaining : List Nat) : IO (Option UInt32) := do
    match ← child.tryWait with
    | some exitCode => return some exitCode
    | none =>
      match remaining with
      | [] => return none
      | delay :: rest =>
        IO.sleep delay.toUInt32
        poll rest
  poll delays

private def outputWithTimeout (path : String) (args : Array String)
    (input : String) (timeout : Option Nat) :
    IO (Except Nat IO.Process.Output) := do
  let processArgs : IO.Process.SpawnArgs := {
    cmd := path
    args
    setsid := true
  }
  let (inputTask, child) ← do
    let (inputHandle, child) ← (← IO.Process.spawn {
      processArgs with
      stdin := .piped
      stdout := .piped
      stderr := .piped
    }).takeStdin
    let inputTask ← IO.asTask (do
      IO.FS.Handle.putStr inputHandle input
      IO.FS.Handle.flush inputHandle
    ) Task.Priority.dedicated
    pure (inputTask, child)
  let stdoutTask ← IO.asTask child.stdout.readToEnd Task.Priority.dedicated
  let stderrTask ← IO.asTask child.stderr.readToEnd Task.Priority.dedicated
  let exitCode : Except Nat UInt32 ←
    match timeout with
    | none => pure (.ok (← child.wait))
    | some milliseconds =>
      match ← waitWithTimeout child milliseconds with
      | some exitCode => pure (.ok exitCode)
      | none => pure (.error milliseconds)
  match exitCode with
  | .ok exitCode =>
    let _ ← IO.ofExcept inputTask.get
    let stdout ← IO.ofExcept stdoutTask.get
    let stderr ← IO.ofExcept stderrTask.get
    return .ok { exitCode, stdout, stderr }
  | .error milliseconds =>
    try
      child.kill
    catch _ =>
      pure ()
    let _ ← child.wait
    let _ := inputTask.get
    let _ := stdoutTask.get
    let _ := stderrTask.get
    return .error milliseconds

/-- Feed DIMACS through stdin, enforce a wall-clock timeout, and parse the
standard solver result. Extra arguments support DIMACS solvers that need
backend-specific command-line options. -/
def runWithArgs (solverName path : String) (args : Array String)
    (artifact : CnfArtifact) (config : SolveConfig := {}) :
    IO SatResult := do
  try
    match ← outputWithTimeout path args artifact.dimacs config.timeout with
    | .error milliseconds =>
      return .error s!"timeout ({milliseconds}ms)"
    | .ok output =>
    -- SAT solvers conventionally return 10 for SAT and 20 for UNSAT.
      if output.exitCode != 0 && output.exitCode != 10 && output.exitCode != 20 then
        return .error s!"{solverName} failed with exit code {output.exitCode}: {output.stderr}"
      return parseOutput solverName output.stdout output.stderr
  catch error =>
    return .error s!"failed to run {solverName}: {error}"

/-- Feed DIMACS through stdin and parse the standard solver result. -/
def run (solverName path : String) (artifact : CnfArtifact)
    (config : SolveConfig := {}) : IO SatResult :=
  runWithArgs solverName path #[] artifact config

end SmtLibDsl.DimacsCli
