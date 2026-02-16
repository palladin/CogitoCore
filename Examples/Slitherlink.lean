import SmtLibDsl

open SmtLibDsl.SMT

namespace Slitherlink

/-- A clue cell: `none` means no clue, `some n` means exactly `n` surrounding edges are in the loop. -/
abbrev Clue := Option Nat

/-- Puzzle specification. -/
structure PuzzleSpec where
  id : String
  name : String
  clues : List (List Clue)

namespace PuzzleSpec

def rows (p : PuzzleSpec) : Nat := p.clues.length

def cols (p : PuzzleSpec) : Nat :=
  match p.clues.head? with
  | some row => row.length
  | none => 0

end PuzzleSpec

/-- User-provided 6×6 puzzle. -/
def onlinePuzzle6x6 : PuzzleSpec := {
  id := "online6"
  name := "Online 6x6"
  clues :=
    [ [none,   none,   none,   none,   some 0, none]
    , [some 3, some 3, none,   none,   some 1, none]
    , [none,   none,   some 1, some 2, none,   none]
    , [none,   none,   some 2, some 0, none,   none]
    , [none,   some 1, none,   none,   some 1, some 1]
    , [none,   some 2, none,   none,   none,   none]
    ]
}

/-- User-provided 8×8 puzzle. -/
def onlinePuzzle8x8 : PuzzleSpec := {
  id := "online8"
  name := "Online 8x8"
  clues :=
    [ [some 3, none,   none,   some 3, some 3, none,   some 3, none]
    , [none,   some 3, none,   none,   none,   none,   some 3, none]
    , [none,   none,   none,   some 3, some 3, none,   none,   none]
    , [none,   none,   none,   none,   none,   none,   some 3, none]
    , [none,   some 3, none,   some 3, none,   none,   none,   none]
    , [none,   some 3, none,   some 3, none,   none,   some 3, some 3]
    , [none,   none,   none,   none,   none,   none,   none,   none]
    , [some 3, none,   some 3, none,   some 3, some 3, some 3, none]
    ]
}

def puzzleCatalog : List PuzzleSpec := [onlinePuzzle6x6, onlinePuzzle8x8]

def getPuzzle? (id : String) : Option PuzzleSpec :=
  puzzleCatalog.find? (fun p => p.id == id)

def hName (r c : Nat) : String := s!"h_{r}_{c}"
def vName (r c : Nat) : String := s!"v_{r}_{c}"

def flatten2D (xss : List (List α)) : List α :=
  xss.foldr (· ++ ·) []

abbrev BV1 := Expr (Ty.bitVec 1)
abbrev BV4 := Expr (Ty.bitVec 4)
abbrev BV8 := Expr (Ty.bitVec 8)

structure EdgeVar where
  name : String
  expr : BV1
  p1 : Nat × Nat
  p2 : Nat × Nat

def edgeToBV4 (e : BV1) : BV4 := Expr.zeroExt 3 e
def edgeToBV8 (e : BV1) : BV8 := Expr.zeroExt 7 e

def sumEdges4 (es : List BV1) : BV4 :=
  es.foldl (fun acc e => acc +. edgeToBV4 e) (bv 0 4)

def sumEdges8 (es : List BV1) : BV8 :=
  es.foldl (fun acc e => acc +. edgeToBV8 e) (bv 0 8)

def declareHEdges (rows cols : Nat) : Smt (List (List EdgeVar)) := do
  let mut grid : List (List EdgeVar) := []
  for r in List.range (rows + 1) do
    let mut row : List EdgeVar := []
    for c in List.range cols do
      let name := hName r c
      let e ← declareBV name 1
      row := row ++ [{ name := name, expr := e, p1 := (r, c), p2 := (r, c + 1) }]
    grid := grid ++ [row]
  pure grid

def declareVEdges (rows cols : Nat) : Smt (List (List EdgeVar)) := do
  let mut grid : List (List EdgeVar) := []
  for r in List.range rows do
    let mut row : List EdgeVar := []
    for c in List.range (cols + 1) do
      let name := vName r c
      let e ← declareBV name 1
      row := row ++ [{ name := name, expr := e, p1 := (r, c), p2 := (r + 1, c) }]
    grid := grid ++ [row]
  pure grid

def getH? (h : List (List EdgeVar)) (r c : Nat) : Option EdgeVar :=
  h[r]? >>= fun row => row[c]?

def getV? (v : List (List EdgeVar)) (r c : Nat) : Option EdgeVar :=
  v[r]? >>= fun row => row[c]?

def incidentEdges (rows cols : Nat) (h : List (List EdgeVar)) (v : List (List EdgeVar)) (r c : Nat) : List BV1 :=
  let left := if c > 0 then (getH? h r (c - 1)).map (·.expr) else none
  let right := if c < cols then (getH? h r c).map (·.expr) else none
  let up := if r > 0 then (getV? v (r - 1) c).map (·.expr) else none
  let down := if r < rows then (getV? v r c).map (·.expr) else none
  [left, right, up, down].filterMap id

def cellEdges? (h : List (List EdgeVar)) (v : List (List EdgeVar)) (r c : Nat) : Option (List BV1) := do
  let top ← (getH? h r c).map (·.expr)
  let bot ← (getH? h (r + 1) c).map (·.expr)
  let left ← (getV? v r c).map (·.expr)
  let right ← (getV? v r (c + 1)).map (·.expr)
  pure [top, bot, left, right]

/-- A subtour-elimination cut: these edge names cannot all be simultaneously active. -/
abbrev Cut := List String

def cutConstraint (allEdges : List EdgeVar) (cut : Cut) : Expr Ty.bool :=
  let edges := cut.filterMap (fun nm => (allEdges.find? (fun e => e.name == nm)).map (·.expr))
  if edges.isEmpty then Expr.btrue
  else
    let s := sumEdges8 edges
    s ≤.ᵤ bv (edges.length - 1) 8

def buildSlitherlink (spec : PuzzleSpec) (cuts : List Cut := []) : Smt (List EdgeVar) := do
  let rows := spec.rows
  let cols := spec.cols

  let hEdges ← declareHEdges rows cols
  let vEdges ← declareVEdges rows cols
  let allEdges := flatten2D hEdges ++ flatten2D vEdges

  -- Vertex degree constraints: each dot has degree 0 or 2.
  for r in List.range (rows + 1) do
    for c in List.range (cols + 1) do
      let deg := sumEdges4 (incidentEdges rows cols hEdges vEdges r c)
      assert ((deg =. bv 0 4) ∨. (deg =. bv 2 4))

  -- At least one active edge (prevents empty model).
  let total := sumEdges8 (allEdges.map (·.expr))
  assert (total >.ᵤ bv 0 8)

  -- Cell clue constraints.
  for r in List.range rows do
    for c in List.range cols do
      match (spec.clues[r]? >>= fun row => row[c]?), cellEdges? hEdges vEdges r c with
      | some (some n), some es =>
        assert (sumEdges4 es =. bv n 4)
      | _, _ => pure ()

  -- Subtour elimination cuts from previous iterations.
  for cut in cuts do
    assert (cutConstraint allEdges cut)

  pure allEdges

def slitherlink (spec : PuzzleSpec) (cuts : List Cut := []) : Smt Unit := do
  let _ ← buildSlitherlink spec cuts
  pure ()

def edgeIsActive (model : Model schema) (e : EdgeVar) : Bool :=
  match model.lookup e.name with
  | some raw =>
    match parseBitVec raw 1 with
    | some bvVal => bvVal.toNat == 1
    | none => false
  | none => false

def activeEdges (model : Model schema) (allEdges : List EdgeVar) : List EdgeVar :=
  allEdges.filter (edgeIsActive model)

def neighbors (vtx : Nat × Nat) (es : List EdgeVar) : List (Nat × Nat) :=
  es.foldl (fun out e =>
    if e.p1 == vtx then
      if out.contains e.p2 then out else e.p2 :: out
    else if e.p2 == vtx then
      if out.contains e.p1 then out else e.p1 :: out
    else out
  ) []

partial def bfs (es : List EdgeVar) (queue visited : List (Nat × Nat)) : List (Nat × Nat) :=
  match queue with
  | [] => visited
  | v :: rest =>
    if visited.contains v then
      bfs es rest visited
    else
      let ns := neighbors v es |>.filter (fun n => !(visited.contains n) && !(rest.contains n))
      bfs es (rest ++ ns) (v :: visited)

partial def componentsFromVertices (es : List EdgeVar) (remaining : List (Nat × Nat)) : List (List (Nat × Nat)) :=
  match remaining with
  | [] => []
  | v :: rest =>
    let comp := bfs es [v] []
    let rest' := rest.filter (fun x => !(comp.contains x))
    comp :: componentsFromVertices es rest'

def edgeComponents (es : List EdgeVar) : List (List EdgeVar) :=
  let vertices := flatten2D (es.map (fun e => [e.p1, e.p2])) |>.eraseDups
  let comps := componentsFromVertices es vertices
  comps.map (fun vs =>
    es.filter (fun e => vs.contains e.p1 && vs.contains e.p2))

def edgeVarsFromSchema (schema : VarSchema) : List EdgeVar :=
  schema.filterMap (fun (name, ty) =>
    match ty with
    | Ty.bitVec 1 =>
      if name.startsWith "h_" then
        let parts := name.splitOn "_"
        match parts with
        | [_, rs, cs] =>
          match rs.toNat?, cs.toNat? with
          | some r, some c =>
            some { name := name, expr := Expr.var name (Ty.bitVec 1), p1 := (r, c), p2 := (r, c + 1) }
          | _, _ => none
        | _ => none
      else if name.startsWith "v_" then
        let parts := name.splitOn "_"
        match parts with
        | [_, rs, cs] =>
          match rs.toNat?, cs.toNat? with
          | some r, some c =>
            some { name := name, expr := Expr.var name (Ty.bitVec 1), p1 := (r, c), p2 := (r + 1, c) }
          | _, _ => none
        | _ => none
      else none
    | _ => none)

/-- Render solution as ASCII with clues and loop segments. -/
def renderSolution (spec : PuzzleSpec) (active : List EdgeVar) : IO Unit := do
  let rows := spec.rows
  let cols := spec.cols

  let activeNames := active.map (·.name)
  let hasH := fun r c => activeNames.contains (hName r c)
  let hasV := fun r c => activeNames.contains (vName r c)

  IO.println "Solution:"
  for r in List.range (rows + 1) do
    let mut top := ""
    for c in List.range cols do
      top := top ++ "•"
      top := top ++ (if hasH r c then "──" else "  ")
    top := top ++ "•"
    IO.println top

    if r < rows then
      let mut mid := ""
      for c in List.range cols do
        mid := mid ++ (if hasV r c then "│" else " ")
        let clueChar := match spec.clues[r]? >>= fun row => row[c]? with
          | some (some n) => toString n
          | _ => " "
        mid := mid ++ clueChar ++ " "
      mid := mid ++ (if hasV r cols then "│" else " ")
      IO.println mid

/-- Solve with iterative subtour elimination until one connected loop remains. -/
partial def solveSingleLoop
    (spec : PuzzleSpec)
    (cuts : List Cut)
    (iteration : Nat)
    (maxIterations : Nat)
    (config : SolveConfig)
    : IO (Option (List EdgeVar)) := do
  if iteration > maxIterations then
    IO.println s!"Reached iteration limit ({maxIterations}) without a single-loop model."
    return none

  let query := slitherlink spec cuts
  let result ← solve query config
  match result with
  | .unsat =>
    IO.println "UNSAT: no solution satisfies current constraints."
    return none
  | .unknown reason =>
    IO.println s!"Solver returned unknown: {reason}"
    return none
  | .sat model =>
    let withVars := buildSlitherlink spec cuts
    let allEdges := edgeVarsFromSchema withVars.schema

    let active := activeEdges model allEdges
    let comps := edgeComponents active |>.filter (fun es => !es.isEmpty)

    IO.println s!"Iteration {iteration}: active edges = {active.length}, loop components = {comps.length}"

    if comps.length == 1 then
      return some active
    else
      -- Only add subtour elimination cuts for NON-LARGEST components.
      -- The largest component is the main loop candidate; cutting it
      -- could eliminate valid single-loop solutions (unlike TSP, Slitherlink
      -- loops don't visit all vertices).
      let sorted := comps.toArray.qsort (fun a b => a.length > b.length)
      let subtours := (sorted.toList.drop 1).filter (fun es => !es.isEmpty)
      let newCuts : List Cut := subtours.map (fun comp => comp.map (·.name))
      solveSingleLoop spec (cuts ++ newCuts) (iteration + 1) maxIterations config

def findArgValue (args : List String) (longOpt shortOpt : String) : Option String :=
  match args with
  | [] => none
  | [_] => none
  | a :: b :: rest =>
    if a == longOpt || a == shortOpt then some b
    else findArgValue (b :: rest) longOpt shortOpt

def printPuzzleList : IO Unit := do
  IO.println "Available puzzles:"
  for p in puzzleCatalog do
    IO.println s!"  {p.id} - {p.name} ({p.rows}x{p.cols})"

end Slitherlink

open Slitherlink in
def main (args : List String) : IO UInt32 := do
  let dumpSmt := args.contains "--dump-smt" || args.contains "-d"
  let profile := args.contains "--profile" || args.contains "-p"
  let listOnly := args.contains "--list" || args.contains "-l"

  if listOnly then
    printPuzzleList
    return 0

  let runOne (spec : PuzzleSpec) : IO Bool := do
    IO.println "=== Slitherlink SMT Solver ==="
    IO.println "Rules: each clue equals surrounding active edges; vertices have degree 0 or 2; result is a single loop."
    IO.println s!"Puzzle: {spec.name} ({spec.rows}x{spec.cols})"
    IO.println ""

    IO.println "Puzzle (· = no clue):"
    for row in spec.clues do
      let line := row.map (fun c => match c with | some n => toString n | none => "·") |> String.intercalate " "
      IO.println line
    IO.println ""

    match ← solveSingleLoop spec [] 1 60 { dumpSmt := dumpSmt, profile := profile } with
    | some active =>
      IO.println ""
      IO.println "SAT - single loop found."
      renderSolution spec active
      pure true
    | none =>
      IO.println "No single-loop solution found."
      pure false

  let requestedId := findArgValue args "--puzzle" "-P"
  match requestedId with
  | some pid =>
    let some spec := getPuzzle? pid | do
      IO.eprintln s!"Unknown puzzle id: {pid}"
      printPuzzleList
      return 1
    let ok ← runOne spec
    return if ok then 0 else 1
  | none =>
    let mut solved := 0
    let mut failed := 0
    let total := puzzleCatalog.length
    for idx in List.range total do
      let some spec := puzzleCatalog[idx]? | pure ()
      IO.println s!"\n--- Puzzle {idx + 1}/{total}: {spec.id} ---"
      let ok ← runOne spec
      if ok then
        solved := solved + 1
      else
        failed := failed + 1
      IO.println ""
    IO.println s!"Summary: solved {solved} / {puzzleCatalog.length}, failed {failed}."
    return 0
