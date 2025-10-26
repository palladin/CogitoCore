namespace CogitoCore.ARC

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



end CogitoCore.ARC
