# SmtLibDsl

A **language-indexed SMT-LIB DSL** for Lean 4 with generic solver backends,
including Z3, cvc5, Kissat, and CaDiCaL.

## What is SmtLibDsl?

SmtLibDsl is a domain-specific language embedded in Lean 4 for writing SMT-LIB2 constraint programs. It provides:

- **Type-safe expressions** — Bitvector widths and enabled SMT theories are tracked at compile time
- **Language-indexed free monad** — `Smt .bool`, `Smt .bv`, `Smt .abv`, and `Smt .all` compose only valid commands
- **SMT-LIB2 code generation** — Generates standards-compliant solver input
- **Typed expression CSE** — Repeated terms become deterministic `define-fun`
  bindings through a collision-safe, language-indexed memo
- **Generic SMT backends** — Use the same typed API with Z3, cvc5, or a custom backend
- **Checked SAT path** — Z3 bit-blasts QF_BV to CNF, Kissat solves DIMACS, and Lean validates every decoded SAT model

## Quick Example

```lean
import SmtLibDsl

open SmtLibDsl
open SmtLibDsl.SMT

-- Find x where x + 1 = 10 (8-bit bitvector)
def findX : Smt .bv Unit := do
  let x ← declareBV "x" 8
  assert (x +. bv 1 8 =. bv 10 8)

-- Compile to SMT-LIB2
#eval compile findX
/-
(set-logic QF_BV)
(declare-const x (_ BitVec 8))
(assert (= (bvadd x (_ bv1 8)) (_ bv10 8)))
(check-sat)
(get-model)
-/

-- One solve method; the first parameter is indexed by the query language.
#eval do
  let z3Result ← solve .z3 findX
  let cvc5Result ← solve .cvc5 findX
  let kissatResult ← solve .kissat findX
  let cadicalResult ← solve .cadical findX
  IO.println s!"Z3: {z3Result}"
  IO.println s!"cvc5: {cvc5Result}"
  IO.println s!"Kissat: {kissatResult}"
  IO.println s!"CaDiCaL: {cadicalResult}"

-- Compare two direct SMT backends, Lean-checking both decoded BV models.
#eval do
  let report ← compareCheckedBackends z3 cvc5 findX
  IO.println s!"{report.lhsName}: {report.lhsMs}ms"
  IO.println s!"{report.rhsName}: {report.rhsMs}ms"
  IO.println s!"agree: {report.agree}"
```

## Installation

### One-command setup

From the repository root:

```bash
./scripts/setup.sh
```

This checks for Z3, cvc5, Kissat, and CaDiCaL, installs any missing solver,
and runs the Lean integration tests. Installation is project-local under
`.tools/solvers`, so it needs neither `sudo` nor a shell-profile change.
Project-local binaries are discovered automatically by the Lean API.

The installer supports macOS and Linux on ARM64 and x86-64. It downloads the
latest stable official Z3 and cvc5 release binaries, and builds the latest
stable Kissat and CaDiCaL releases from their official source archives.

Required host tools are `curl`, `unzip`, `tar`, `make`, and a C/C++ compiler.
On macOS, the compiler and build tools come from:

```bash
xcode-select --install
```

On Ubuntu/Debian:

```bash
sudo apt-get update
sudo apt-get install -y build-essential curl unzip
```

Useful setup commands:

```bash
# Show exactly what is currently usable
./scripts/setup.sh --check

# Update all four project-local solvers to their latest stable releases
./scripts/setup.sh --force

# Install or update only one backend
./scripts/setup.sh --solver cvc5 --force --no-test

# Preview installation without changing files
./scripts/setup.sh --force --dry-run
```

Install Lean 4 and Lake with [elan](https://github.com/leanprover/elan) if
`setup.sh` reports that `lake` is missing:

```bash
curl https://elan-init.lean-lang.org/ -sSf | sh
```

Then build or test directly:

```bash
lake build
lake exe smtlibdsl-test
```

### CI and custom installation directories

The same non-interactive command works in CI:

```bash
./scripts/setup.sh --force --no-test
lake exe smtlibdsl-test
```

For a cacheable directory outside the repository, install with `--prefix` and
point all backends at its `bin` directory:

```bash
./scripts/setup.sh --prefix /opt/smtlibdsl-solvers --force --no-test
SMTLIBDSL_SOLVER_DIR=/opt/smtlibdsl-solvers/bin lake exe smtlibdsl-test
```

### Solver discovery and manual overrides

Every backend uses the same discovery order:

1. `executable` supplied in its backend configuration;
2. its solver-specific environment variable;
3. `<SMTLIBDSL_SOLVER_DIR>/<solver>`;
4. `.tools/solvers/bin/<solver>` in the repository or an ancestor directory;
5. the solver name on `PATH`.

This means normal project-local setup requires no environment variable.
Overrides remain available for an existing system or manually downloaded
installation:

| Environment Variable | Description | Default |
|---------------------|-------------|---------|
| `SMTLIBDSL_SOLVER_DIR` | Directory containing all solver executables | project-local directory, then `PATH` |
| `SMTLIBDSL_Z3_PATH` | Z3 executable or command | shared discovery |
| `SMTLIBDSL_CVC5_PATH` | cvc5 executable or command | shared discovery |
| `SMTLIBDSL_KISSAT_PATH` | Kissat executable or command | shared discovery |
| `SMTLIBDSL_CADICAL_PATH` | CaDiCaL executable or command | shared discovery |

For example, a manually downloaded cvc5 no longer needs a temporary,
archive-specific path. Either copy it to `.tools/solvers/bin/cvc5`, put it on
`PATH`, or set:

```bash
SMTLIBDSL_CVC5_PATH=/absolute/path/to/cvc5 lake exe sokoban
```

## Language-indexed programs

Every expression and program names its allowed SMT language explicitly:

| Index | Allowed theories | SMT-LIB logic |
|------|-------------------|---------------|
| `.bool` | Booleans | `QF_UF` |
| `.bv` | Booleans and fixed-size bitvectors | `QF_BV` |
| `.abv` | Booleans, bitvectors, and arrays | `QF_ABV` |
| `.all` | Booleans, bitvectors, arrays, and datatypes | `ALL` |

For example, `declareArray` cannot elaborate inside `Smt .bv`. Reusable
fragments can be capability-polymorphic and safely compose into richer
languages:

```lean
def boundedNibble [Language.HasBV lang] : Smt lang Unit := do
  let x ← declareBV "x" 4
  assert (x <.ᵤ bv 10 4)

def withMemory : Smt .abv Unit := do
  boundedNibble
  let memory ← declareArray "memory" 4 (Ty.bitVec 4)
  assert (selectArr memory (bv 0 4) =. bv 3 4)
```

The mapped-CNF SAT pipeline deliberately accepts only `Smt .bv Unit`, so arrays
and datatypes cannot accidentally reach the bit-blasting pipeline.

## Type-indexed compiler CSE

Compilation fingerprints canonical expression nodes and shares repeated
subexpressions without introducing a second source-language AST. The memo value
type depends on the key's result sort:

```lean
abbrev ExpressionMemo (lang : Language) : Type :=
  Std.DHashMap (ExprKey lang) (fun key => Ref lang key.ty)
```

Consequently, looking up a Boolean key can only return `Ref lang .bool`, while
a bitvector key returns a reference of that exact bitvector sort. Hashes only
select a `DHashMap` bucket; lawful structural equality over the operator, sort,
parameters, and canonical children selects the entry, so a hash collision
cannot merge distinct expressions.

Both `compile` and the SMT→CNF bridge use this pass. The original `Smt` program
remains the source for model schemas and Lean model replay. Profiling data is
available without a second compilation:

```lean
let report := compileWithCSEReport query
IO.println report.text
IO.println s!"{report.stats.uniqueNodes} unique nodes"
IO.println s!"{report.stats.emittedDefinitions} shared definitions"
```

## Language-indexed solver API

There is one solving entry point:

```lean
solve (solver : Solver lang) (query : Smt lang Unit)
-- IO (Result query.schema)
```

The solver parameter and query must have the same `lang` index:

```lean
solve (.z3 : Solver .bool) boolQuery
solve (.z3 : Solver .bv) bvQuery
solve (.cvc5 : Solver .abv) arrayQuery
solve (.cvc5 : Solver .all) datatypeQuery
solve (.kissat : Solver .bv) bvQuery
solve (.cadical : Solver .bv) bvQuery
```

`Solver.kissat` and `Solver.cadical` have type `Solver .bv`, so they cannot be
passed to an `.abv` or `.all` query. Z3 and cvc5 provide values at all four
explicit indices. There is intentionally no unrestricted `.smt` index.

The façade remains open to new implementations:

```lean
-- Lift a direct backend at each language it explicitly supports.
Solver.ofSmtBackend myBackend

-- Or compose a mapped-CNF lowerer with any SAT backend.
def mySolver : Solver .bv :=
  Solver.ofCnf myLowerer mySatBackend

solve mySolver bvQuery
```

Underneath the façade, `SmtBackend`, `SupportsLanguage`, `ModelValidator`,
`CnfLowerer`, and `SatBackend` remain the extension interfaces.

### Checked CNF/SAT pipeline

`solve .kissat` and `solve .cadical` perform these steps:

1. Adds a named Boolean proxy for every source Boolean and every bitvector bit.
2. Runs the selected lowerer; `z3Cnf` uses Z3's `simplify`, `bit-blast`, and
   `tseitin-cnf` tactics.
3. Parses the propositional goal and emits DIMACS with a stable LSB-first model map.
4. Runs the selected SAT backend and decodes its signed DIMACS assignment.
5. Re-evaluates every original assertion in Lean before returning `.sat`.

## DSL Reference

### Types

| Type | Description |
|------|-------------|
| `Ty.bool` | Boolean |
| `Ty.bitVec n` | Bitvector of width `n` |
| `Ty.array idxWidth elem` | Array with bitvector index |
| `Ty.datatype decl` | User-defined datatype sort (carries full `DatatypeDecl`) |

### Declaring Variables

```lean
let x ← declareBV "x" 8           -- 8-bit bitvector
let b ← declareBool "b"           -- Boolean
let arr ← declareArray "a" 8 (Ty.bitVec 16)  -- Array
let grid ← declareBVTensor "cell" [9, 9] 4       -- 9×9 tensor of 4-bit values
```

### Datatypes

Define a datatype declaration once in Lean:

```lean
def PointDecl : DatatypeDecl := {
  name := "Point"
  constructor := "mkPoint"
  fields := [
    { name := "x", ty := Ty.bitVec 8 },
    { name := "y", ty := Ty.bitVec 8 }
  ]
}
```

Then choose one of two declaration styles:

```lean
-- Datatype declaration is inferred from PointDecl
let p ← declareDatatypeConstOf "p" PointDecl

-- Build a safe selector handle by static field name
let xField := PointDecl.fieldByName "x" (by simp [PointDecl, DatatypeDecl.fieldNames])
```

Notes:

- `declareDatatypeConstOf` carries the full `DatatypeDecl`, and `compile` automatically emits all required datatype declarations.
- Nested datatypes are inferred transitively from field types, so no dummy constants are needed for dependent datatype declarations.

## Migration (Breaking Changes)

If you're upgrading from older APIs, update code as follows:

1) Add an explicit language index to expressions and programs:

```lean
-- Before
def query : Smt Unit := ...
def predicate : Expr Ty.bool := ...

-- After
def query : Smt .bv Unit := ...
def predicate : Expr .bv Ty.bool := ...
```

2) Datatype sort payload now uses declarations, not names:

```lean
-- Before
Ty.datatype "Point"

-- After
Ty.datatype PointDecl
```

3) Field references now use index-based handles:

```lean
-- Before
let xField : DatatypeFieldRef PointDecl := {
  field := { name := "x", ty := Ty.bitVec 8 }
  inDecl := by simp [PointDecl]
}

-- After (static by-name)
let xField : DatatypeFieldRef PointDecl :=
  PointDecl.fieldByName "x" (by simp [PointDecl, DatatypeDecl.fieldNames])
```

4) `declareDatatype` and `declareDatatypeConst` were removed from the public DSL API. Use:

```lean
let p ← declareDatatypeConstOf "p" PointDecl
```

5) Model lookup/get APIs now return `Except String ...` (with error messages), and no longer require membership proof arguments:

```lean
match model.get "p" (Ty.datatype PointDecl) with
| .ok pVal => ...
| .error err => ...
```

`Model.lookup?` / `Model.get?` are available as Option-style compatibility helpers.

6) Datatype field extraction now returns `Except String ...`:

```lean
match pVal.getField xField with
| .ok x => ...
| .error err => ...
```

### Operators

**Arithmetic** (width-preserving):
```lean
x +. y    -- addition
x -. y    -- subtraction
x *. y    -- multiplication
```

**Bitwise**:
```lean
x &. y    -- and
x |. y    -- or
x ^. y    -- xor
~. x      -- not
x <<. y   -- left shift
x >>. y   -- logical right shift
```

**Comparisons** (return `Expr lang Ty.bool`):
```lean
x =. y     -- equality
x <.ᵤ y    -- unsigned less-than
x ≤.ᵤ y    -- unsigned less-or-equal
x <.ₛ y    -- signed less-than
x ≤.ₛ y    -- signed less-or-equal
```

**Boolean**:
```lean
a =. b    -- equality
a ∧. b    -- and
a ∨. b    -- or
¬. a      -- not
a →. b    -- implication
```

**Arrays**:
```lean
selectArr arr idx        -- read
storeArr arr idx val     -- write (returns new array)
arr1 =.ₐ arr2           -- array equality
```

**Constraints**:
```lean
distinct [x, y, z]       -- all values are different
```

## Project Structure

```
SmtLibDsl.lean             -- Library entry point & version
Main.lean                  -- CLI entry point (lists examples)
lakefile.lean              -- Build configuration
SmtLibDsl/
├── Backend.lean           -- Generic backend aggregator
├── Backend/
│   ├── Core.lean          -- SMT/CNF/SAT interfaces and comparison API
│   ├── Z3.lean            -- Z3 direct SMT backend
│   ├── Cvc5.lean          -- cvc5 direct SMT backend
│   ├── Dimacs.lean        -- Shared SAT-competition CLI adapter
│   ├── Kissat.lean        -- Kissat SAT backend
│   ├── Cadical.lean       -- CaDiCaL SAT backend
│   ├── CNF.lean           -- Z3 lowerer and Lean BV validation/pipeline
│   └── Solver.lean        -- One language-indexed solve entry point
├── SMT.lean               -- Compatibility/module aggregator
└── SMT/
    ├── Expr.lean          -- Type-indexed SMT expressions
    ├── Cmd.lean           -- SMT commands & Smt monad
    ├── CSE.lean           -- Typed structural memo and DAG-shaped emission
    ├── Compile.lean       -- Compile to SMT-LIB2
    ├── Model.lean         -- Portable models and SMT-LIB result parser
    ├── Solver.lean        -- Re-export of the indexed Solver API
    ├── CNF.lean           -- Compatibility facade for mapped-CNF API
    └── Tensor.lean        -- Multi-dimensional tensor support
Examples/
├── Sudoku.lean            -- 9×9 Sudoku solver
├── NQueens.lean           -- N-Queens puzzle
├── MagicSquare.lean       -- Magic square solver
├── Countdown.lean         -- Countdown numbers game
├── Minesweeper.lean       -- Minesweeper auto-solver
├── ProgramSynthesis/
│   ├── Imp.lean           -- IMP CLI entry point
│   └── Imp/
│       ├── Syntax.lean    -- IMP AST, environment helpers, interpreter
│       ├── Parser.lean    -- Tokenizer and recursive-descent parser
│       ├── Compiler.lean  -- SSA-based SMT compiler
│       └── Examples/
│           ├── increment_then_branch.imp
│           ├── reassignment.imp
│           ├── branch.imp
│           └── state_flow.imp
├── Sokoban.lean           -- Sokoban puzzle solver
├── SokobanLevels.lean     -- Original 90 Sokoban levels
├── Slitherlink.lean       -- Slitherlink loop puzzle solver
├── Life.lean              -- Conway's Game of Life
└── Eternity2.lean         -- Edge-matching puzzle
Tests/
└── SMT.lean               -- Test suite
```

## Examples

### Sudoku Solver
```bash
lake exe sudoku
```
Uses 4-bit bitvectors for digits 1-9, with row/column/box distinctness constraints.

### N-Queens
```bash
lake exe nqueens
```
Places 8 queens on a chessboard with diagonal constraints using absolute difference.

### Magic Square
```bash
lake exe magicsquare
```
Finds an n×n grid where all rows, columns, and diagonals sum to the magic constant.

### Countdown Numbers Game
```bash
lake exe countdown
```
Synthesizes arithmetic expressions using RPN stack-based evaluation.

### IMP Program Example
```bash
lake exe imp Examples/ProgramSynthesis/Imp/Examples/increment_then_branch.imp
```
Parses a small IMP program from a `.imp` file and compiles it to SSA-style SMT-LIB2 with explicit `ssa_*` temporaries and branch merges via `ite`.

### Minesweeper
```bash
lake exe minesweeper
```
Iteratively deduces safe cells and mines using UNSAT queries.

### Sokoban
```bash
lake exe sokoban --list    # List available levels
lake exe sokoban 2         # Benchmark installed backends while solving level 2
lake exe sokoban 2 30      # Benchmark with a maximum of 30 moves
lake exe sokoban 3 --bound=33 --profile --timeout=1000  # One hard query
```
At every move bound, the example sends the same `.bv` query through Z3, cvc5,
Kissat, and CaDiCaL, reports wall-clock and cumulative times, checks that all
conclusive backend answers agree, and only then replays the decoded solution.
Missing solver executables are reported and skipped. `--timeout=<ms>` bounds
each direct SMT call; a timeout is inconclusive, while contradictory SAT and
UNSAT answers remain a hard error. The CNF/SAT pipelines continue and every
decoded SAT model is still checked in Lean.

`--bound=<steps>` benchmarks one fixed query instead of paying for every
smaller search bound. Microban 1 has a 33-move solution, so `--bound=33` is the
useful all-backend benchmark for level 3.

### Slitherlink
```bash
lake exe slitherlink                  # Run all configured puzzles
lake exe slitherlink --list            # List available puzzles
lake exe slitherlink -P online6        # Solve a specific puzzle
```
Draws a single closed loop satisfying clue counts using degree constraints and iterative subtour elimination.

## License

MIT License. See [LICENSE](LICENSE).
