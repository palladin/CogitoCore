import CogitoCore.ARC.Definitions

open CogitoCore.ARC.Definitions

namespace CogitoCore.ARC.Tasks


private def singletonVector {α : Type} (a : α) : Vector α 1 :=
  ⟨#[a], by rfl⟩

private def oneByOneGrid (value : Nat) : Grid 1 1 :=
  { cells := ⟨#[singletonVector value], by rfl⟩ }

def identityExample : Example 1 1 1 1 :=
  { input := oneByOneGrid 5
  , output := oneByOneGrid 5 }

def identityExamples : Vector (Example 1 1 1 1) 1 :=
  ⟨#[identityExample], by rfl⟩

def identityTask : Task 1 1 1 1 1 :=
  { name := "identity"
  , examples := identityExamples }


end CogitoCore.ARC.Tasks
