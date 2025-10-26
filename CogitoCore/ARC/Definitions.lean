namespace CogitoCore.ARC.Definitions

structure Grid (rows : Nat) (cols : Nat) where
  cells : Vector (Vector Nat cols) rows
  deriving Repr, BEq

structure Example (inRows : Nat) (inCols : Nat) (outRows : Nat) (outCols : Nat) where
  input : Grid inRows inCols
  output : Grid outRows outCols
  deriving Repr

structure Task (n : Nat) (inRows : Nat) (inCols : Nat) (outRows : Nat) (outCols : Nat) where
  name : String
  examples : Vector (Example inRows inCols outRows outCols) n
  deriving Repr

structure Transform (α : Type) (β : Type) where
  name : String
  apply : α → β

instance : Repr (Transform α β) where
  reprPrec t _ := t.name

inductive Program : Type → Type → Type _ where
  | last : Transform α ω → Program α ω
  | step : Transform α β → Program β ω → Program α ω


/-- Evaluate a program by composing its transforms. -/
def run {α ω : Type} : Program α ω → α → ω
  | .last t => t.apply
  | .step t rest =>
      fun input =>
        let mid := t.apply input
        run rest mid

def validateExample (prog : Program (Grid inRows inCols) (Grid outRows outCols)) (ex : Example inRows inCols outRows outCols) : Bool :=
  let output := run prog ex.input
  output == ex.output

def validateTask (prog : Program (Grid inRows inCols) (Grid outRows outCols)) (task : Task n inRows inCols outRows outCols) : Bool :=
  task.examples.all (validateExample prog)

end CogitoCore.ARC.Definitions
