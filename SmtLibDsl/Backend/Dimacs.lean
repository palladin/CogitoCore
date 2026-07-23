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

/-- Feed DIMACS through stdin and parse the standard solver result. -/
def run (solverName path : String) (artifact : CnfArtifact) :
    IO SatResult := do
  try
    let output ← IO.Process.output { cmd := path, args := #[] } (some artifact.dimacs)
    -- SAT solvers conventionally return 10 for SAT and 20 for UNSAT.
    if output.exitCode != 0 && output.exitCode != 10 && output.exitCode != 20 then
      return .error s!"{solverName} failed with exit code {output.exitCode}: {output.stderr}"
    return parseOutput solverName output.stdout output.stderr
  catch error =>
    return .error s!"failed to run {solverName}: {error}"

end SmtLibDsl.DimacsCli
