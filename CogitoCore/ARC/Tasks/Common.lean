import CogitoCore.ARC.Definitions

namespace CogitoCore.ARC.Tasks

/-- Helper to build a `Vector` of length 3 from individual cells. -/
def row3 (a b c : Cell) : Vector Cell 3 :=
  ⟨#[a, b, c], by rfl⟩

/-- Helper to build a `Vector` of length 4 from individual cells. -/
def row4 (a₀ a₁ a₂ a₃ : Cell) : Vector Cell 4 :=
  ⟨#[a₀, a₁, a₂, a₃], by rfl⟩

/-- Helper to build a `Vector` of length 5 from individual cells. -/
def row5 (a₀ a₁ a₂ a₃ a₄ : Cell) : Vector Cell 5 :=
  ⟨#[a₀, a₁, a₂, a₃, a₄], by rfl⟩

/-- Helper to build a `Vector` of length 6 from individual cells. -/
def row6 (a₀ a₁ a₂ a₃ a₄ a₅ : Cell) : Vector Cell 6 :=
  ⟨#[a₀, a₁, a₂, a₃, a₄, a₅], by rfl⟩

/-- Helper to build a `Vector` of length 8 from individual cells. -/
def row8 (a₀ a₁ a₂ a₃ a₄ a₅ a₆ a₇ : Cell) : Vector Cell 8 :=
  ⟨#[a₀, a₁, a₂, a₃, a₄, a₅, a₆, a₇], by rfl⟩

/-- Helper to build a `Vector` of length 9 from individual cells. -/
def row9 (a₀ a₁ a₂ a₃ a₄ a₅ a₆ a₇ a₈ : Cell) : Vector Cell 9 :=
  ⟨#[a₀, a₁, a₂, a₃, a₄, a₅, a₆, a₇, a₈], by rfl⟩

/-- Helper to build a `Vector` of length 10 from individual cells. -/
def row10 (a₀ a₁ a₂ a₃ a₄ a₅ a₆ a₇ a₈ a₉ : Cell) : Vector Cell 10 :=
  ⟨#[a₀, a₁, a₂, a₃, a₄, a₅, a₆, a₇, a₈, a₉], by rfl⟩

end CogitoCore.ARC.Tasks
