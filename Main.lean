import CogitoCore
import CogitoCore.ARC.Definitions
import CogitoCore.ARC.Tasks
import CogitoCore.ARC.Programs

-- Basic CLI entry point that prints a greeting.
def main : IO Unit :=
  IO.println s!"Hello, world!"
