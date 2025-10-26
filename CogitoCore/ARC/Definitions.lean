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
  apply : α → β

instance : Repr (Transform α β) where
  reprPrec t _ := t.name

inductive Program : Type → Type → Type _ where
  | last : Transform α ω → Program α ω
  | step : Transform α β → Program β ω → Program α ω

inductive Programs : List InOutDim → Type _ where
  | nil : Programs []
  | cons : Program (Grid d.inRows d.inCols) (Grid d.outRows d.outCols) → Programs ds → Programs (d :: ds)

def run : Program α ω → α → ω
  | .last t => t.apply
  | .step t rest =>
      fun input =>
        let mid := t.apply input
        run rest mid

def validateExample {d : InOutDim} (prog : Program (Grid d.inRows d.inCols) (Grid d.outRows d.outCols)) (ex : Example d) : Bool :=
  let output := run prog ex.input
  output == ex.output

def validateTask (progs : Programs dims) (task : Task dims) : Bool :=
  all progs task.examples (fun prog ex => validateExample prog ex)
  where
    all {ds : List InOutDim} : Programs ds → Examples ds → ({d : InOutDim} → Program (Grid d.inRows d.inCols) (Grid d.outRows d.outCols) → Example d → Bool) → Bool
    | .nil, .nil, _ => true
    | .cons prog restProgs, .cons ex restExs, f =>
        f prog ex && all restProgs restExs f

end CogitoCore.ARC.Definitions
