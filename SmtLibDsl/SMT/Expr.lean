/-
  SmtLibDsl - SMT-LIB BitVector Theory DSL
  Core types and type-indexed expressions
-/
namespace SmtLibDsl.SMT

/-- SMT-LIB sorts for QF_ABV theory (arrays + bitvectors) -/
inductive Ty where
  | bool
  | bitVec (n : Nat)
  | array (idxWidth : Nat) (elem : Ty)  -- Array (BitVec idxWidth) elem (supports nested arrays)
  | datatype (name : String)
deriving Repr, DecidableEq

/-- Generic SMT S-expression value for decoded model terms. -/
inductive SExpr where
  | atom (value : String)
  | list (items : List SExpr)
deriving Repr

namespace SExpr

private def dropWs : List Char → List Char
  | c :: cs => if c.isWhitespace then dropWs cs else c :: cs
  | [] => []

private def takeAtom : List Char → (String × List Char)
  | [] => ("", [])
  | c :: cs =>
    if c.isWhitespace || c == '(' || c == ')' then
      ("", c :: cs)
    else
      let (rest, tail) := takeAtom cs
      (String.singleton c ++ rest, tail)

private partial def takeBalanced (cs : List Char) : Option (String × List Char) :=
  let rec go (depth : Nat) (acc : List Char) : List Char → Option (String × List Char)
    | [] => none
    | c :: rest =>
      let depth' := if c == '(' then depth + 1 else if c == ')' then depth - 1 else depth
      let acc' := c :: acc
      if depth' == 0 then
        some (String.mk acc'.reverse, rest)
      else
        go depth' acc' rest
  match cs with
  | '(' :: _ => go 0 [] cs
  | _ => none

partial def parseFromChars : List Char → Option (SExpr × List Char)
  | cs =>
    let cs := dropWs cs
    match cs with
    | [] => none
    | '(' :: rest => parseList [] rest
    | ')' :: _ => none
    | _ =>
      let (a, tail) := takeAtom cs
      if a.isEmpty then none else some (.atom a, tail)
where
  parseList (acc : List SExpr) : List Char → Option (SExpr × List Char)
    | cs =>
      let cs := dropWs cs
      match cs with
      | [] => none
      | ')' :: rest => some (.list acc.reverse, rest)
      | _ =>
        match parseFromChars cs with
        | some (item, rest) => parseList (item :: acc) rest
        | none => none

/-- Parse a full SMT S-expression string. -/
def parse (s : String) : Option SExpr :=
  match parseFromChars s.toList with
  | some (sexpr, rest) =>
    if (dropWs rest).isEmpty then some sexpr else none
  | none => none

partial def toSmtLib : SExpr → String
  | .atom a => a
  | .list xs => s!"({String.intercalate " " (xs.map toSmtLib)})"

instance : ToString SExpr where
  toString := toSmtLib

end SExpr

/-- Field declaration for a datatype/record. -/
structure DatatypeField where
  name : String
  ty : Ty
deriving Repr, DecidableEq

/-- Datatype declaration with one constructor and named fields. -/
structure DatatypeDecl where
  name : String
  constructor : String
  fields : List DatatypeField
deriving Repr, DecidableEq

/-- A proof-carrying handle to a field that belongs to a specific datatype declaration. -/
structure DatatypeFieldRef (decl : DatatypeDecl) where
  field : DatatypeField
  inDecl : field ∈ decl.fields

/-- Get a field handle by index (safe by construction via `Fin`). -/
def DatatypeDecl.fieldAt (decl : DatatypeDecl) (idx : Fin decl.fields.length) : DatatypeFieldRef decl :=
  let field := decl.fields.get idx
  ⟨field, by
    dsimp [field]
    exact List.get_mem decl.fields idx⟩

/-- Convert Ty to SMT-LIB2 syntax string -/
def Ty.toSmtLib : Ty → String
  | Ty.bool => "Bool"
  | Ty.bitVec n => s!"(_ BitVec {n})"
  | Ty.array idxWidth elem => s!"(Array (_ BitVec {idxWidth}) {elem.toSmtLib})"
  | Ty.datatype name => name

instance : ToString Ty where
  toString := Ty.toSmtLib

/-- Map SMT types to corresponding Lean types -/
def Ty.LeanType : Ty → Type
  | Ty.bool => Bool
  | Ty.bitVec n => BitVec n
  | Ty.array _ _ => SExpr
  | Ty.datatype _ => SExpr

/-- Compile a datatype declaration to SMT-LIB2 syntax. -/
def DatatypeDecl.toSmtLib (decl : DatatypeDecl) : String :=
  let fieldStr := decl.fields
    |> List.map (fun f => s!"({f.name} {f.ty})")
    |> String.intercalate " "
  if fieldStr.isEmpty then
    s!"(declare-datatype {decl.name} (({decl.constructor})))"
  else
    s!"(declare-datatype {decl.name} (({decl.constructor} {fieldStr})))"

/-- Parse an SMT-LIB boolean value to Lean Bool -/
def parseBool (s : String) : Option Bool :=
  if s == "true" then some true
  else if s == "false" then some false
  else none

/-- Parse a hexadecimal character to its value -/
private def hexDigitToNat? (c : Char) : Option Nat :=
  if '0' ≤ c && c ≤ '9' then some (c.toNat - '0'.toNat)
  else if 'a' ≤ c && c ≤ 'f' then some (c.toNat - 'a'.toNat + 10)
  else if 'A' ≤ c && c ≤ 'F' then some (c.toNat - 'A'.toNat + 10)
  else none

/-- Parse a hexadecimal string to Nat -/
private def hexToNat? (s : String) : Option Nat :=
  s.foldl (fun acc c => do
    let a ← acc
    let d ← hexDigitToNat? c
    some (a * 16 + d)
  ) (some 0)

/-- Parse a binary string to Nat -/
private def binToNat? (s : String) : Option Nat :=
  s.foldl (fun acc c => do
    let a ← acc
    if c == '0' then some (a * 2)
    else if c == '1' then some (a * 2 + 1)
    else none
  ) (some 0)

/-- Parse an SMT-LIB bitvector value to Lean BitVec -/
def parseBitVec (s : String) (n : Nat) : Option (BitVec n) :=
  if s.startsWith "#x" then
    -- Hexadecimal: #x09
    let hexStr := s.drop 2
    hexToNat? hexStr |>.map (BitVec.ofNat n)
  else if s.startsWith "#b" then
    -- Binary: #b101
    let binStr := s.drop 2
    binToNat? binStr |>.map (BitVec.ofNat n)
  else
    -- Try decimal
    s.toNat? |>.map (BitVec.ofNat n)

/-- Parse an SMT-LIB value string to the corresponding Lean type -/
def Ty.parse (ty : Ty) (s : String) : Option ty.LeanType :=
  match ty with
  | Ty.bool => parseBool s
  | Ty.bitVec n => parseBitVec s n
  | Ty.array _ _ => SExpr.parse s
  | Ty.datatype _ => SExpr.parse s

/-- Parse only array/datatype values into generic S-expressions. -/
def Ty.parseAsSExpr? (ty : Ty) (s : String) : Option SExpr :=
  match ty with
  | Ty.array _ _ => SExpr.parse s
  | Ty.datatype _ => SExpr.parse s
  | _ => none

/-- Expressions indexed by sort, ensuring width-correctness at compile time -/
inductive Expr : Ty → Type where
  -- Variables
  | var     : String → (ty : Ty) → Expr ty

  -- Boolean literals
  | btrue   : Expr Ty.bool
  | bfalse  : Expr Ty.bool

  -- Boolean operations
  | and     : Expr Ty.bool → Expr Ty.bool → Expr Ty.bool
  | or      : Expr Ty.bool → Expr Ty.bool → Expr Ty.bool
  | not     : Expr Ty.bool → Expr Ty.bool
  | imp     : Expr Ty.bool → Expr Ty.bool → Expr Ty.bool
  | ite : Expr Ty.bool → Expr s → Expr s → Expr s

  -- BitVector literals
  | bvLit   : (val : Nat) → (n : Nat) → Expr (Ty.bitVec n)

  -- BitVector arithmetic (width-preserving)
  | bvAdd   : Expr (Ty.bitVec n) → Expr (Ty.bitVec n) → Expr (Ty.bitVec n)
  | bvSub   : Expr (Ty.bitVec n) → Expr (Ty.bitVec n) → Expr (Ty.bitVec n)
  | bvMul   : Expr (Ty.bitVec n) → Expr (Ty.bitVec n) → Expr (Ty.bitVec n)
  | bvUDiv  : Expr (Ty.bitVec n) → Expr (Ty.bitVec n) → Expr (Ty.bitVec n)
  | bvSDiv  : Expr (Ty.bitVec n) → Expr (Ty.bitVec n) → Expr (Ty.bitVec n)
  | bvURem  : Expr (Ty.bitVec n) → Expr (Ty.bitVec n) → Expr (Ty.bitVec n)
  | bvSMod  : Expr (Ty.bitVec n) → Expr (Ty.bitVec n) → Expr (Ty.bitVec n)
  | bvSRem  : Expr (Ty.bitVec n) → Expr (Ty.bitVec n) → Expr (Ty.bitVec n)
  | bvNeg   : Expr (Ty.bitVec n) → Expr (Ty.bitVec n)

  -- Bitwise operations
  | bvAnd   : Expr (Ty.bitVec n) → Expr (Ty.bitVec n) → Expr (Ty.bitVec n)
  | bvOr    : Expr (Ty.bitVec n) → Expr (Ty.bitVec n) → Expr (Ty.bitVec n)
  | bvXor   : Expr (Ty.bitVec n) → Expr (Ty.bitVec n) → Expr (Ty.bitVec n)
  | bvNot   : Expr (Ty.bitVec n) → Expr (Ty.bitVec n)
  | bvNand  : Expr (Ty.bitVec n) → Expr (Ty.bitVec n) → Expr (Ty.bitVec n)
  | bvNor   : Expr (Ty.bitVec n) → Expr (Ty.bitVec n) → Expr (Ty.bitVec n)
  | bvXnor  : Expr (Ty.bitVec n) → Expr (Ty.bitVec n) → Expr (Ty.bitVec n)

  -- Shifts
  | bvShl   : Expr (Ty.bitVec n) → Expr (Ty.bitVec n) → Expr (Ty.bitVec n)
  | bvLShr  : Expr (Ty.bitVec n) → Expr (Ty.bitVec n) → Expr (Ty.bitVec n)
  | bvAShr  : Expr (Ty.bitVec n) → Expr (Ty.bitVec n) → Expr (Ty.bitVec n)
  | rotateLeft  : (i : Nat) → Expr (Ty.bitVec n) → Expr (Ty.bitVec n)
  | rotateRight : (i : Nat) → Expr (Ty.bitVec n) → Expr (Ty.bitVec n)

  -- Comparisons (return Bool)
  | bvEq    : Expr (Ty.bitVec n) → Expr (Ty.bitVec n) → Expr Ty.bool
  | bvULt   : Expr (Ty.bitVec n) → Expr (Ty.bitVec n) → Expr Ty.bool
  | bvULe   : Expr (Ty.bitVec n) → Expr (Ty.bitVec n) → Expr Ty.bool
  | bvUGt   : Expr (Ty.bitVec n) → Expr (Ty.bitVec n) → Expr Ty.bool
  | bvUGe   : Expr (Ty.bitVec n) → Expr (Ty.bitVec n) → Expr Ty.bool
  | bvSLt   : Expr (Ty.bitVec n) → Expr (Ty.bitVec n) → Expr Ty.bool
  | bvSLe   : Expr (Ty.bitVec n) → Expr (Ty.bitVec n) → Expr Ty.bool
  | bvSGt   : Expr (Ty.bitVec n) → Expr (Ty.bitVec n) → Expr Ty.bool
  | bvSGe   : Expr (Ty.bitVec n) → Expr (Ty.bitVec n) → Expr Ty.bool
  | bvComp  : Expr (Ty.bitVec n) → Expr (Ty.bitVec n) → Expr (Ty.bitVec 1)

  -- Width-changing operations
  | concat  : Expr (Ty.bitVec m) → Expr (Ty.bitVec n) → Expr (Ty.bitVec (m + n))
  | extract : (hi lo : Nat) → Expr (Ty.bitVec n) → Expr (Ty.bitVec (hi - lo + 1))
  | zeroExt : (i : Nat) → Expr (Ty.bitVec n) → Expr (Ty.bitVec (n + i))
  | signExt : (i : Nat) → Expr (Ty.bitVec n) → Expr (Ty.bitVec (n + i))
  | repeat  : (i : Nat) → Expr (Ty.bitVec n) → Expr (Ty.bitVec (i * n))

  -- Overflow predicates (return Bool)
  | bvNegO  : Expr (Ty.bitVec n) → Expr Ty.bool
  | bvUAddO : Expr (Ty.bitVec n) → Expr (Ty.bitVec n) → Expr Ty.bool
  | bvSAddO : Expr (Ty.bitVec n) → Expr (Ty.bitVec n) → Expr Ty.bool
  | bvUMulO : Expr (Ty.bitVec n) → Expr (Ty.bitVec n) → Expr Ty.bool
  | bvSMulO : Expr (Ty.bitVec n) → Expr (Ty.bitVec n) → Expr Ty.bool

  -- Array operations
  | mkArray : (idxWidth : Nat) → (elem : Ty) → Expr elem → Expr (Ty.array idxWidth elem)
  | select  : Expr (Ty.array idxWidth elem) → Expr (Ty.bitVec idxWidth) → Expr elem
  | store   : Expr (Ty.array idxWidth elem) → Expr (Ty.bitVec idxWidth) → Expr elem → Expr (Ty.array idxWidth elem)
  | arrEq   : Expr (Ty.array idxWidth elem) → Expr (Ty.array idxWidth elem) → Expr Ty.bool

  -- Distinct constraint (names stored directly to avoid nested inductive issue)
  | distinctBV : (n : Nat) → (names : List String) → Expr Ty.bool

  -- Datatype field selector
  | dtSelect : (field : String) → (retTy : Ty) → Expr (Ty.datatype dtName) → Expr retTy

-- Smart constructors

/-- Create a bitvector literal with value `val` and width `n` -/
def bv (val n : Nat) : Expr (Ty.bitVec n) := Expr.bvLit val n

/-- Boolean true -/
def btrue : Expr Ty.bool := Expr.btrue

/-- Boolean false -/
def bfalse : Expr Ty.bool := Expr.bfalse

/-- Create a constant array where all indices map to the same value. -/
def constArray (idxWidth : Nat) (elem : Ty) (v : Expr elem) : Expr (Ty.array idxWidth elem) :=
  Expr.mkArray idxWidth elem v

/-- Read from an array at index -/
def selectArr (arr : Expr (Ty.array idxWidth elem)) (i : Expr (Ty.bitVec idxWidth)) : Expr elem :=
  Expr.select arr i

/-- Write to an array at index, returning new array -/
def storeArr (arr : Expr (Ty.array idxWidth elem)) (i : Expr (Ty.bitVec idxWidth)) (v : Expr elem) : Expr (Ty.array idxWidth elem) :=
  Expr.store arr i v

/-- Select a field from a datatype value (record selector syntax in SMT-LIB). -/
def selectField (field : String) (retTy : Ty) (rec : Expr (Ty.datatype dtName)) : Expr retTy :=
  Expr.dtSelect field retTy rec

/-- Type-safe field selection using a proof-carrying field handle.
    The return type is inferred from the selected field. -/
def selectFieldSafe {decl : DatatypeDecl} (fieldRef : DatatypeFieldRef decl)
    (rec : Expr (Ty.datatype decl.name)) : Expr fieldRef.field.ty :=
  Expr.dtSelect fieldRef.field.name fieldRef.field.ty rec

/-- Extract variable name from a variable expression -/
def Expr.varName : Expr ty → Option String
  | .var name _ => some name
  | _ => none

/-- Assert all bitvector expressions are pairwise distinct (List version).
    Only works on variable expressions - extracts their names for the distinct constraint. -/
def distinct (es : List (Expr (Ty.bitVec n))) : Expr Ty.bool :=
  let names := es.filterMap Expr.varName
  Expr.distinctBV n names

/-- Assert all bitvector expressions are pairwise distinct (Vector version) -/
def distinctV (es : Vector (Expr (Ty.bitVec n)) m) : Expr Ty.bool :=
  distinct es.toList

-- Notation (scoped to SMT namespace)

/-
  Notation conventions:
  - ALL SMT operators use `.` suffix to distinguish from Lean built-ins
  - Subscripts indicate variant when multiple exist:
    - `ᵤ` = unsigned (e.g., `<.ᵤ` unsigned less-than)
    - `ₛ` = signed (e.g., `<.ₛ` signed less-than)
    - `ₐ` = array (e.g., `=.ₐ` array equality)
  - No subscript = only one variant exists (e.g., `=.` bitvector equality)
-/

-- BitVector arithmetic
scoped infixl:70 " +. " => Expr.bvAdd
scoped infixl:70 " -. " => Expr.bvSub
scoped infixl:75 " *. " => Expr.bvMul

-- Bitwise operations
scoped infixl:65 " &. " => Expr.bvAnd
scoped infixl:60 " |. " => Expr.bvOr
scoped infixl:60 " ^. " => Expr.bvXor
scoped prefix:80 "~. " => Expr.bvNot

-- Shifts
scoped infixl:55 " <<. " => Expr.bvShl
scoped infixl:55 " >>. " => Expr.bvLShr
scoped infixl:55 " >>>.ₛ " => Expr.bvAShr

-- Equality
scoped infixl:50 " =. " => Expr.bvEq
scoped infixl:50 " =.ₐ " => Expr.arrEq

-- Unsigned comparisons
scoped infixl:50 " <.ᵤ " => Expr.bvULt
scoped infixl:50 " ≤.ᵤ " => Expr.bvULe
scoped infixl:50 " >.ᵤ " => Expr.bvUGt
scoped infixl:50 " ≥.ᵤ " => Expr.bvUGe

-- Signed comparisons
scoped infixl:50 " <.ₛ " => Expr.bvSLt
scoped infixl:50 " ≤.ₛ " => Expr.bvSLe
scoped infixl:50 " >.ₛ " => Expr.bvSGt
scoped infixl:50 " ≥.ₛ " => Expr.bvSGe

-- Boolean operations
scoped infixl:35 " ∧. " => Expr.and
scoped infixl:30 " ∨. " => Expr.or
scoped infixl:25 " →. " => Expr.imp
scoped prefix:40 "¬. " => Expr.not

end SmtLibDsl.SMT
