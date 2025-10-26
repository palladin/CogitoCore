namespace CogitoCore.ARC.Definitions

inductive Cell where
  | C0
  | C1
  | C2
  | C3
  | C4
  | C5
  | C6
  | C7
  | C8
  | C9
  deriving Repr, BEq


structure Grid (rows : Nat) (cols : Nat) where
  cells : Vector (Vector Cell cols) rows
  deriving Repr, BEq

structure InOutDim where
  inRows : Nat
  inCols : Nat
  outRows : Nat
  outCols : Nat

structure Example (dim : InOutDim) where
  input : Grid dim.inRows dim.inCols
  output : Grid dim.outRows dim.outCols
  deriving Repr

inductive Examples : List InOutDim → Type where
  | nil : Examples []
  | cons : Example d → Examples ds → Examples (d :: ds)

structure Task (dims : List InOutDim) where
  name : String
  examples : Examples dims

structure Transform (α : Type) (β : Type) where
  name : String
  apply : α → Option β

instance : Repr (Transform α β) where
  reprPrec t _ := t.name

inductive Program : Type → Type → Type _ where
  | last : Transform α ω → Program α ω
  | step : Transform α β → Program β ω → Program α ω

/-- Evaluate a program by composing its transforms. -/
def run {α ω : Type} : Program α ω → α → Option ω
  | .last t => t.apply
  | .step t rest =>
      fun input => do
        let mid ← t.apply input
        run rest mid

def validateExample {d : InOutDim} (prog : Program (Grid d.inRows d.inCols) (Grid d.outRows d.outCols)) (ex : Example d) : Option Bool :=
  do
    let output ← run prog ex.input
    output == ex.output

def validateTask (prog : (d : InOutDim) →  Program (Grid d.inRows d.inCols) (Grid d.outRows d.outCols)) (task : Task dims) : Option Bool :=
  all task.examples (fun d ex => validateExample (prog d) ex)
  where
    all {ds : List InOutDim} : Examples ds → ((d : InOutDim) → Example d → Option Bool) → Option Bool
      | .nil, _ => .some true
      | .cons (d := d) ex rest, p => do
          let b ← p d ex
          if b then all rest p else .some false

end CogitoCore.ARC.Definitions
