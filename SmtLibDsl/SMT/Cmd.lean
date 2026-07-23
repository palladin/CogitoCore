/-
  SmtLibDsl - SMT-LIB BitVector Theory DSL
  Commands and Smt monad (free monad pattern)
-/
import SmtLibDsl.SMT.Expr
import SmtLibDsl.SMT.Tensor

namespace SmtLibDsl.SMT

/-- Variable schema: list of (name, type) pairs tracking declared variables -/
abbrev VarSchema := List (String × Ty)

/-- SMT-LIB commands indexed by the language they are allowed to use. -/
inductive Cmd (lang : Language) : Type → Type _ where
  | declareConst : String → (ty : Ty) → [Ty.Supported lang ty] →
      Cmd lang (Expr lang ty)
  | declareDatatypeConstOf : String → (decl : DatatypeDecl) →
      [Language.HasDatatype lang] → Cmd lang (Expr lang (Ty.datatype decl))
  | assert       : Expr lang Ty.bool → Cmd lang Unit

/-- Free monad for sequencing commands in one explicit SMT language. -/
inductive Smt (lang : Language) : Type → Type _ where
  | pure : α → Smt lang α
  | bind : Cmd lang α → (α → Smt lang β) → Smt lang β

/-- Bind operation for Smt monad -/
def Smt.flatMap (ma : Smt lang α) (f : α → Smt lang β) : Smt lang β :=
  match ma with
  | .pure a => f a
  | .bind cmd g => .bind cmd (fun x => flatMap (g x) f)

instance : Monad (Smt lang) where
  pure := Smt.pure
  bind := Smt.flatMap

/-- Extract the variable schema from an Smt program -/
def Smt.schema : Smt lang α → VarSchema
  | .pure _ => []
  | .bind (@Cmd.declareConst _ name ty _) f =>
    (name, ty) :: schema (f (.var name ty))
  | .bind (@Cmd.declareDatatypeConstOf _ name decl _) f =>
    (name, Ty.datatype decl) :: schema (f (.var name (Ty.datatype decl)))
  | .bind (.assert _) f => schema (f ())

-- Command API

/-- Declare a bitvector constant of width n -/
def declareBV (name : String) (n : Nat) [Language.HasBV lang] :
    Smt lang (Expr lang (Ty.bitVec n)) :=
  Smt.bind (Cmd.declareConst name (Ty.bitVec n)) Smt.pure

/-- Declare a boolean constant -/
def declareBool (name : String) : Smt lang (Expr lang Ty.bool) :=
  Smt.bind (Cmd.declareConst name Ty.bool) Smt.pure

/-- Assert a boolean constraint -/
def assert (e : Expr lang Ty.bool) : Smt lang Unit :=
  Smt.bind (Cmd.assert e) Smt.pure

-- Tensor declaration API

/-- Build variable name with indices appended -/
def indexedName (base : String) (indices : List Nat) : String :=
  base ++ String.join (indices.map (fun i => s!"_{i}"))

/-- Declare a single variable -/
def declareVar (name : String) (ty : Ty) [Ty.Supported lang ty] :
    Smt lang (Expr lang ty) :=
  Smt.bind (Cmd.declareConst name ty) Smt.pure

/-- Declare a constant of the exact datatype declaration provided. -/
def declareDatatypeConstOf (name : String) (decl : DatatypeDecl)
    [Language.HasDatatype lang] : Smt lang (Expr lang (Ty.datatype decl)) :=
  Smt.bind (Cmd.declareDatatypeConstOf name decl) Smt.pure

/-- Declare a tensor of variables, building the nested Vector structure -/
def declareTensorAux (name : String) (ty : Ty) [Ty.Supported lang ty]
    (prefix_ : List Nat) :
    (dims : List Nat) → Smt lang (Tensor dims (Expr lang ty))
  | [] => do
    let varName := indexedName name prefix_
    declareVar varName ty
  | d :: ds => do
    Vector.tabulateM d (fun ⟨i, _⟩ => declareTensorAux name ty (prefix_ ++ [i]) ds)

/-- Declare a tensor of variables with given shape, returning Tensor dims (Expr ty) -/
def declareTensor (name : String) (dims : List Nat) (ty : Ty) [Ty.Supported lang ty] :
    Smt lang (Tensor dims (Expr lang ty)) :=
  declareTensorAux name ty [] dims

/-- Declare a bitvector tensor -/
def declareBVTensor (name : String) (dims : List Nat) (n : Nat)
    [Language.HasBV lang] : Smt lang (Tensor dims (Expr lang (Ty.bitVec n))) :=
  declareTensor name dims (Ty.bitVec n)

/-- Declare a boolean tensor -/
def declareBoolTensor (name : String) (dims : List Nat) :
    Smt lang (Tensor dims (Expr lang Ty.bool)) :=
  declareTensor name dims Ty.bool

/-- Declare an array variable with BitVec index and element type. -/
def declareArray (name : String) (idxWidth : Nat) (elem : Ty)
    [Language.HasArray lang] [Ty.Supported lang elem] :
    Smt lang (Expr lang (Ty.array idxWidth elem)) :=
  Smt.bind (Cmd.declareConst name (Ty.array idxWidth elem)) Smt.pure

end SmtLibDsl.SMT
