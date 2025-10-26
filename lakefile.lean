import Lake
open Lake DSL

package «CogitoCore» where
  -- All Lean modules are relative to the repository root.
  srcDir := "."

require batteries from git
  "https://github.com/leanprover-community/batteries" @ "main"

lean_lib «CogitoCore» where
  -- We expose the aggregated `CogitoCore` module as the library entry point.
  roots := #[`CogitoCore]

@[default_target]
lean_exe «cogito-core» where
  root := `Main
