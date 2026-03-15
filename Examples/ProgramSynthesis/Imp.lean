import SmtLibDsl
import Examples.ProgramSynthesis.Imp.Parser
import Examples.ProgramSynthesis.Imp.Compiler

namespace ProgramSynthesis.Imp

def usage : String :=
  "Usage: lake exe imp Examples/ProgramSynthesis/Imp/Examples/<program>.imp [--dump-smt] [--profile]"

def positionalArgs (args : List String) : List String :=
  args.filter fun arg =>
    arg != "--dump-smt" && arg != "-d" && arg != "--profile" && arg != "-p"

def run (args : List String) : IO UInt32 := do
  let dumpSmt := args.contains "--dump-smt" || args.contains "-d"
  let profile := args.contains "--profile" || args.contains "-p"
  let programArgs := positionalArgs args
  match programArgs with
  | [programPath] =>
    let sourceResult ←
      try
        let source ← IO.FS.readFile programPath
        pure (.ok source : Except String String)
      catch e =>
        pure (.error s!"Failed to read IMP program '{programPath}': {e}" : Except String String)

    match sourceResult with
    | .error err =>
      IO.eprintln err
      return 1
    | .ok source =>
      IO.println "=== IMP SMT Compiler ==="
      IO.println ""
      IO.println s!"Program file: {programPath}"
      IO.println "Source:"
      IO.println source
      IO.println ""

      match parseProgram source with
      | .error err =>
        IO.eprintln s!"Parse error: {err}"
        return 1
      | .ok program =>
        let vars := varsStmt program
        let initialBindings : Env String := vars.map (fun name => (name, name))
        let finalBindings := (finalSsaEnv vars initialBindings 0 program).fst
        IO.println s!"Parsed AST: {program}"
        IO.println ""
        IO.println "Compiling IMP program to SSA-based SMT..."
        let result <- SmtLibDsl.SMT.solve (compiledProgram program) {
          dumpSmt := dumpSmt
          profile := profile
        }
        match result with
        | .sat model =>
          match envFromBindings initialBindings model with
          | .error err =>
            IO.eprintln s!"Failed to reconstruct model inputs: {err}"
            return 1
          | .ok inputEnv =>
            let interpretedEnv := evalStmt inputEnv program
            match envFromBindings finalBindings model with
            | .error err =>
              IO.eprintln s!"Failed to reconstruct final SSA values: {err}"
              return 1
            | .ok finalEnv =>
              match validateEnvEquality vars finalEnv interpretedEnv with
              | .error err =>
                IO.eprintln s!"Interpreter validation failed: {err}"
                IO.eprintln s!"Model inputs: {showEnv vars inputEnv}"
                IO.eprintln s!"Final SSA state: {showEnv vars finalEnv}"
                IO.eprintln s!"Interpreter final state: {showEnv vars interpretedEnv}"
                return 1
              | .ok _ =>
                IO.println "SAT - generated SSA SMT constraints are satisfiable"
                IO.println s!"Model inputs: {showEnv vars inputEnv}"
                IO.println s!"Final SSA state: {showEnv vars finalEnv}"
                IO.println s!"Final SSA bindings: {showBindings finalBindings model}"
                IO.println s!"Interpreter final state: {showEnv vars interpretedEnv}"
                IO.println "Interpreter validation: OK"
                return 0
        | .unsat =>
          IO.eprintln "UNSAT - generated SSA SMT constraints are inconsistent"
          return 1
        | .unknown reason =>
          IO.eprintln s!"Unknown: {reason}"
          return 1
  | [] =>
    IO.eprintln usage
    IO.eprintln "Example: lake exe imp Examples/ProgramSynthesis/Imp/Examples/increment_then_branch.imp"
    return 1
  | _ =>
    IO.eprintln "Expected exactly one IMP source file path."
    IO.eprintln usage
    return 1

end ProgramSynthesis.Imp

def main (args : List String) : IO UInt32 :=
  ProgramSynthesis.Imp.run args
