#!/bin/bash
# SmtLibDsl Setup Script
# Checks, installs, and optionally upgrades required dependencies

set -e

UPGRADE_Z3=false

for arg in "$@"; do
  case "$arg" in
    --upgrade-z3)
      UPGRADE_Z3=true
      ;;
    -h|--help)
      echo "Usage: $0 [--upgrade-z3]"
      echo ""
      echo "Options:"
      echo "  --upgrade-z3   Upgrade Z3 if it is already installed"
      exit 0
      ;;
    *)
      echo "❌ Unknown option: $arg"
      echo "Run '$0 --help' for usage."
      exit 1
      ;;
  esac
done

echo "🔧 SmtLibDsl Setup"
echo "==================="
echo ""

# Check for Z3
check_z3() {
  if command -v z3 &> /dev/null; then
    echo "✓ Z3 found: $(z3 --version 2>&1 | head -1)"
    return 0
  else
    return 1
  fi
}

# Install Z3
install_z3() {
  echo "📦 Installing Z3..."

  if [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v brew &> /dev/null; then
      brew install z3
    else
      echo "❌ Homebrew not found. Install from: https://brew.sh"
      echo "   Then run: brew install z3"
      exit 1
    fi
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v apt-get &> /dev/null; then
      sudo apt-get update && sudo apt-get install -y z3
    elif command -v dnf &> /dev/null; then
      sudo dnf install -y z3
    elif command -v pacman &> /dev/null; then
      sudo pacman -S z3
    else
      echo "❌ Package manager not found. Install Z3 manually from:"
      echo "   https://github.com/Z3Prover/z3/releases"
      exit 1
    fi
  else
    echo "❌ Unsupported OS. Install Z3 manually from:"
    echo "   https://github.com/Z3Prover/z3/releases"
    exit 1
  fi
}

# Upgrade Z3
upgrade_z3() {
  echo "⬆️  Upgrading Z3..."

  if [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v brew &> /dev/null; then
      brew update
      brew upgrade z3
    else
      echo "❌ Homebrew not found. Install from: https://brew.sh"
      echo "   Then run: brew update && brew upgrade z3"
      exit 1
    fi
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v apt-get &> /dev/null; then
      sudo apt-get update && sudo apt-get install -y --only-upgrade z3
    elif command -v dnf &> /dev/null; then
      sudo dnf upgrade -y z3
    elif command -v pacman &> /dev/null; then
      sudo pacman -Syu z3
    else
      echo "❌ Package manager not found. Upgrade Z3 manually from:"
      echo "   https://github.com/Z3Prover/z3/releases"
      exit 1
    fi
  else
    echo "❌ Unsupported OS. Upgrade Z3 manually from:"
    echo "   https://github.com/Z3Prover/z3/releases"
    exit 1
  fi
}

# Check for Lean/Lake
check_lean() {
  if command -v lake &> /dev/null; then
    echo "✓ Lake found: $(lake --version 2>&1 | head -1)"
    return 0
  else
    echo "⚠️  Lake not found. Install elan from: https://github.com/leanprover/elan"
    return 1
  fi
}

# Main
echo "Checking dependencies..."
echo ""

check_lean || true

if [[ "$UPGRADE_Z3" == true ]]; then
  if check_z3; then
    echo ""
    upgrade_z3
    echo ""
    check_z3
  else
    echo ""
    echo "⚠️  Z3 is not installed yet. Installing instead of upgrading."
    install_z3
    echo ""
    check_z3
  fi
elif ! check_z3; then
  echo ""
  read -p "Z3 not found. Install now? [y/N] " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    install_z3
    echo ""
    check_z3
  else
    echo ""
    echo "⚠️  Z3 is required for SMT solving."
    echo "   Install manually or set SMTLIBDSL_Z3_PATH environment variable."
  fi
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "Build and run:"
echo "  lake build && lake exe smtlibdsl"
