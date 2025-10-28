namespace CogitoCore.ARC

structure EvalStats where
  passed : Nat
  total : Nat
  deriving Inhabited

namespace EvalStats

def zero : EvalStats :=
  { passed := 0, total := 0 }

def add (a b : EvalStats) : EvalStats :=
  { passed := a.passed + b.passed, total := a.total + b.total }

def record (stats : EvalStats) (success : Bool) : EvalStats :=
  let passedInc := if success then 1 else 0
  { passed := stats.passed + passedInc, total := stats.total + 1 }

end EvalStats

end CogitoCore.ARC
