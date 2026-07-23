/-
  SmtLibDsl - Portable solver models and SMT-LIB result parsing
-/
import SmtLibDsl.SMT.Compile

namespace SmtLibDsl.SMT

/-- Model holding variable assignments, indexed by schema. -/
structure Model (vars : VarSchema) where
  raw : List (String × String)

/-- Lookup a variable value by name (runtime check, raw string). -/
def Model.lookup (m : Model vars) (name : String) : Except String String :=
  match m.raw.lookup name with
  | some value => .ok value
  | none => .error s!"variable '{name}' not found in model"

/-- Option-style lookup compatibility helper. -/
def Model.lookup? (m : Model vars) (name : String) : Option String :=
  m.raw.lookup name

/-- Get a variable value parsed to the requested Lean type. -/
def Model.get (m : Model vars) (name : String) (ty : Ty) :
    Except String ty.LeanType := do
  let raw ← m.lookup name
  match ty.parse raw with
  | some value => .ok value
  | none => .error s!"failed to decode '{name}' as {ty} from '{raw}'"

/-- Option-style parse compatibility helper. -/
def Model.get? (m : Model vars) (name : String) (ty : Ty) :
    Option ty.LeanType :=
  m.raw.lookup name >>= ty.parse

instance : ToString (Model vars) where
  toString model := toString model.raw

/-- Portable result returned by every SMT and SAT pipeline backend. -/
inductive Result (vars : VarSchema) where
  | sat (model : Model vars)
  | unsat
  | unknown (reason : String)

instance : ToString (Result vars) where
  toString
  | .sat model => s!"sat\n{model}"
  | .unsat => "unsat"
  | .unknown reason => s!"unknown ({reason})"

/-- Parse standard SMT-LIB `sat`/`unsat`/`unknown` output and zero-argument
`define-fun` model entries.  This intentionally does not depend on a specific
solver's outer `(model ...)` wrapper. -/
def parseSmtLibResult (output : String) : (List (String × String)) ⊕ String :=
  let lines := output.splitOn "\n" |>.filter (fun line => !line.isEmpty)
  match lines with
  | "sat" :: rest => .inl (parseModel (String.intercalate " " rest))
  | "unsat" :: _ => .inr "unsat"
  -- Output after `unknown` is not a valid model. Some solvers still emit text
  -- in response to the unconditional `(get-model)`, so do not treat it as the
  -- unknown reason.
  | "unknown" :: _ => .inr "unknown"
  | _ => .inr s!"failed to parse SMT-LIB solver output: {output}"
where
  parseModel (modelString : String) : List (String × String) :=
    let chunks := (modelString.replace "\n" " ").splitOn "(define-fun "
    match chunks with
    | [] => []
    | _ :: rest =>
      rest.filterMap fun part =>
        let candidate := "(define-fun " ++ part
        match takeBalanced candidate.toList with
        | some (block, _) => parseDefineFunBlock block
        | none => none

  dropWs : List Char → List Char
    | char :: rest => if char.isWhitespace then dropWs rest else char :: rest
    | [] => []

  takeAtom : List Char → String × List Char
    | [] => ("", [])
    | char :: rest =>
      if char.isWhitespace || char == '(' || char == ')' then
        ("", char :: rest)
      else
        let (suffix, tail) := takeAtom rest
        (String.singleton char ++ suffix, tail)

  takeBalanced : List Char → Option (String × List Char)
    | [] => none
    | chars@('(' :: _) =>
      let rec go (depth : Nat) (acc : List Char) :
          List Char → Option (String × List Char)
        | [] => none
        | char :: rest =>
          let nextDepth :=
            if char == '(' then depth + 1
            else if char == ')' then depth - 1
            else depth
          let nextAcc := char :: acc
          if nextDepth == 0 then
            some (String.ofList nextAcc.reverse, rest)
          else
            go nextDepth nextAcc rest
      go 0 [] chars
    | _ => none

  parseTokenOrSexp (chars : List Char) : Option (String × List Char) :=
    let chars := dropWs chars
    match chars with
    | [] => none
    | '(' :: _ => takeBalanced chars
    | _ =>
      let (token, rest) := takeAtom chars
      if token.isEmpty then none else some (token, rest)

  parseDefineFunBlock (block : String) : Option (String × String) :=
    if !block.startsWith "(define-fun" then none
    else
      let rest := (block.drop "(define-fun".length).toString.toList
      let (name, rest) := takeAtom (dropWs rest)
      if name.isEmpty then none
      else
        match parseTokenOrSexp rest with
        | none => none
        | some (_, rest) =>
          match parseTokenOrSexp rest with
          | none => none
          | some (_, rest) =>
            match parseTokenOrSexp rest with
            | none => none
            | some (value, _) => some (name, value.trimAscii.toString)

end SmtLibDsl.SMT
