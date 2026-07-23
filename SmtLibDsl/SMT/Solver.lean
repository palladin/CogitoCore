/-
  Compatibility facade for the portable model API and default Z3 backend.
-/
import SmtLibDsl.SMT.Model
import SmtLibDsl.Backend.Z3
import SmtLibDsl.Backend.Solver

namespace SmtLibDsl.SMT

/-- Compatibility alias for the historical namespace. -/
abbrev SolveConfig := SmtLibDsl.SolveConfig

end SmtLibDsl.SMT
