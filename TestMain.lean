import CogitoCore

def main : IO Unit := do
  IO.println s!"CogitoCore {CogitoCore.version} Test"
  IO.println "Hello from minimal main!"
