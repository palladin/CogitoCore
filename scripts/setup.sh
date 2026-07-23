#!/usr/bin/env bash
#
# Install and verify every external solver used by SmtLibDsl.
#
# The default installation is project-local:
#   .tools/solvers/bin/{z3,cvc5,kissat,cadical}
#
# No sudo access, Homebrew, shell-profile edit, or environment variable is
# required.  The Lean backends discover this directory automatically.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
INSTALL_ROOT="$REPO_ROOT/.tools/solvers"
BIN_DIR=""
CHECK_ONLY=false
FORCE=false
DRY_RUN=false
RUN_TESTS=true
SELECTED=()
WORK_ROOT=""

usage() {
  printf '%s\n' \
    "Usage: ./scripts/setup.sh [options]" \
    "" \
    "Install the latest stable Z3, cvc5, Kissat, and CaDiCaL releases." \
    "Existing working solvers are reused unless --force is supplied." \
    "" \
    "Options:" \
    "  --check              Only report installed solver versions" \
    "  --force              Install/update selected solvers project-locally" \
    "  --solver NAME        Select z3, cvc5, kissat, or cadical (repeatable)" \
    "  --prefix DIR         Install under DIR instead of .tools/solvers" \
    "  --no-test            Skip the Lean integration test suite" \
    "  --dry-run            Show which installations would be performed" \
    "  -h, --help           Show this help" \
    "" \
    "Examples:" \
    "  ./scripts/setup.sh" \
    "  ./scripts/setup.sh --check" \
    "  ./scripts/setup.sh --force" \
    "  ./scripts/setup.sh --solver cvc5 --force --no-test"
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

cleanup() {
  if [[ -n "$WORK_ROOT" && -d "$WORK_ROOT" ]]; then
    rm -rf -- "$WORK_ROOT"
  fi
}
trap cleanup EXIT

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check)
      CHECK_ONLY=true
      shift
      ;;
    --force)
      FORCE=true
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --no-test)
      RUN_TESTS=false
      shift
      ;;
    --solver)
      [[ $# -ge 2 ]] || die "--solver requires a name"
      SELECTED+=("$2")
      shift 2
      ;;
    --solver=*)
      SELECTED+=("${1#*=}")
      shift
      ;;
    --prefix)
      [[ $# -ge 2 ]] || die "--prefix requires a directory"
      INSTALL_ROOT="$2"
      shift 2
      ;;
    --prefix=*)
      INSTALL_ROOT="${1#*=}"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown option '$1' (run ./scripts/setup.sh --help)"
      ;;
  esac
done

if [[ ${#SELECTED[@]} -eq 0 ]]; then
  SELECTED=(z3 cvc5 kissat cadical)
fi

for solver in "${SELECTED[@]}"; do
  case "$solver" in
    z3|cvc5|kissat|cadical) ;;
    *) die "unknown solver '$solver'; expected z3, cvc5, kissat, or cadical" ;;
  esac
done

BIN_DIR="$INSTALL_ROOT/bin"

ensure_work_root() {
  if [[ -z "$WORK_ROOT" ]]; then
    WORK_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/smtlibdsl-solvers.XXXXXX")"
  fi
}

require_command() {
  command -v "$1" >/dev/null 2>&1 ||
    die "'$1' is required for this installation; install it and rerun setup"
}

resolve_candidate() {
  local candidate="$1"
  if [[ "$candidate" == */* ]]; then
    [[ -x "$candidate" ]] || return 1
    printf '%s\n' "$candidate"
  else
    command -v "$candidate" 2>/dev/null
  fi
}

solver_override() {
  case "$1" in
    z3) printf '%s\n' "${SMTLIBDSL_Z3_PATH:-}" ;;
    cvc5) printf '%s\n' "${SMTLIBDSL_CVC5_PATH:-}" ;;
    kissat) printf '%s\n' "${SMTLIBDSL_KISSAT_PATH:-}" ;;
    cadical) printf '%s\n' "${SMTLIBDSL_CADICAL_PATH:-}" ;;
  esac
}

resolve_solver() {
  local solver="$1"
  local override
  local candidate

  override="$(solver_override "$solver")"
  if [[ -n "$override" ]]; then
    resolve_candidate "$override"
    return
  fi

  if [[ -n "${SMTLIBDSL_SOLVER_DIR:-}" ]]; then
    candidate="$SMTLIBDSL_SOLVER_DIR/$solver"
    if [[ -x "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return
    fi
  fi

  candidate="$BIN_DIR/$solver"
  if [[ -x "$candidate" ]]; then
    printf '%s\n' "$candidate"
    return
  fi

  command -v "$solver" 2>/dev/null
}

check_solver() {
  local solver="$1"
  local path
  local version

  if ! path="$(resolve_solver "$solver")"; then
    printf 'missing  %-8s\n' "$solver"
    return 1
  fi

  if ! version="$("$path" --version 2>&1)"; then
    printf 'broken   %-8s %s\n' "$solver" "$path"
    return 1
  fi
  version="${version%%$'\n'*}"
  printf 'ready    %-8s %-45s %s\n' "$solver" "$path" "$version"
}

fetch_release() {
  local repository="$1"
  local destination="$2"
  require_command curl
  curl --fail --location --silent --show-error --retry 3 \
    -H "Accept: application/vnd.github+json" \
    -o "$destination" \
    "https://api.github.com/repos/$repository/releases/latest"
}

json_string() {
  local key="$1"
  local json="$2"
  awk -v wanted="\"$key\"" '
    index($0, wanted) {
      line = $0
      sub(/^[^:]*:[[:space:]]*"/, "", line)
      sub(/".*$/, "", line)
      print line
      exit
    }
  ' "$json"
}

release_asset() {
  local matcher="$1"
  local json="$2"
  awk -v matcher="$matcher" '
    index($0, "\"browser_download_url\"") {
      line = $0
      sub(/^[^:]*:[[:space:]]*"/, "", line)
      sub(/".*$/, "", line)
      if (line ~ matcher) {
        print line
        exit
      }
    }
  ' "$json"
}

download() {
  local url="$1"
  local destination="$2"
  require_command curl
  printf 'download %-8s %s\n' "" "$url"
  curl --fail --location --silent --show-error --retry 3 \
    -o "$destination" "$url"
}

install_prebuilt() {
  local solver="$1"
  local repository="$2"
  local asset_matcher="$3"
  local executable_name="$4"
  local work="$WORK_ROOT/$solver"
  local release_json="$work/release.json"
  local archive="$work/release.zip"
  local extracted="$work/extracted"
  local asset_url
  local release_tag
  local binary
  local relative_binary
  local package_dir="$INSTALL_ROOT/packages/$solver"
  local package_stage="$INSTALL_ROOT/packages/.$solver-stage-$$"

  require_command unzip
  require_command find
  mkdir -p "$work" "$extracted" "$INSTALL_ROOT/packages" "$BIN_DIR"
  fetch_release "$repository" "$release_json"
  release_tag="$(json_string tag_name "$release_json")"
  asset_url="$(release_asset "$asset_matcher" "$release_json")"
  [[ -n "$asset_url" ]] ||
    die "no compatible $solver binary in release '$release_tag' ($repository)"

  printf 'install  %-8s release %s\n' "$solver" "$release_tag"
  download "$asset_url" "$archive"
  unzip -q "$archive" -d "$extracted"

  binary="$(find "$extracted" -type f -name "$executable_name" \
    -path '*/bin/*' -print -quit)"
  [[ -n "$binary" ]] || die "$solver archive did not contain bin/$executable_name"
  relative_binary="${binary#"$extracted"/}"

  rm -rf -- "$package_stage"
  mkdir -p "$package_stage"
  cp -R "$extracted/." "$package_stage/"
  rm -rf -- "$package_dir"
  mv "$package_stage" "$package_dir"
  ln -sfn "$package_dir/$relative_binary" "$BIN_DIR/$solver"
}

install_source_solver() {
  local solver="$1"
  local repository="$2"
  local compiler="$3"
  local work="$WORK_ROOT/$solver"
  local release_json="$work/release.json"
  local archive="$work/source.tar.gz"
  local source="$work/source"
  local tarball_url
  local release_tag
  local jobs
  local binary

  require_command "$compiler"
  require_command make
  require_command tar
  require_command find
  mkdir -p "$work" "$source" "$BIN_DIR"
  fetch_release "$repository" "$release_json"
  release_tag="$(json_string tag_name "$release_json")"
  tarball_url="$(json_string tarball_url "$release_json")"
  [[ -n "$tarball_url" ]] ||
    die "release '$release_tag' did not expose a source archive"

  printf 'install  %-8s release %s (portable source build)\n' \
    "$solver" "$release_tag"
  download "$tarball_url" "$archive"
  tar -xzf "$archive" -C "$source" --strip-components=1

  jobs="$(getconf _NPROCESSORS_ONLN 2>/dev/null || printf '2')"
  (
    cd "$source"
    ./configure
    make -s -j "$jobs"
  )
  binary="$(find "$source/build" -type f -name "$solver" -print -quit)"
  [[ -n "$binary" ]] || die "$solver build completed without build/$solver"
  install -m 0755 "$binary" "$BIN_DIR/$solver"
}

platform_patterns() {
  local system
  local machine
  system="$(uname -s)"
  machine="$(uname -m)"

  case "$system:$machine" in
    Darwin:arm64|Darwin:aarch64)
      Z3_ASSET='arm64-osx-.*[.]zip$'
      CVC5_ASSET='cvc5-macOS-arm64-static[.]zip$'
      ;;
    Darwin:x86_64|Darwin:amd64)
      Z3_ASSET='x64-osx-.*[.]zip$'
      CVC5_ASSET='cvc5-macOS-x86_64-static[.]zip$'
      ;;
    Linux:arm64|Linux:aarch64)
      Z3_ASSET='arm64-glibc-.*[.]zip$'
      CVC5_ASSET='cvc5-Linux-arm64-static[.]zip$'
      ;;
    Linux:x86_64|Linux:amd64)
      Z3_ASSET='x64-glibc-.*[.]zip$'
      CVC5_ASSET='cvc5-Linux-x86_64-static[.]zip$'
      ;;
    *)
      die "unsupported platform $system/$machine; use the documented manual overrides"
      ;;
  esac
}

install_solver() {
  local solver="$1"
  case "$solver" in
    z3)
      install_prebuilt z3 Z3Prover/z3 "$Z3_ASSET" z3
      ;;
    cvc5)
      install_prebuilt cvc5 cvc5/cvc5 "$CVC5_ASSET" cvc5
      ;;
    kissat)
      install_source_solver kissat arminbiere/kissat cc
      ;;
    cadical)
      install_source_solver cadical arminbiere/cadical c++
      ;;
  esac
}

printf '%s\n' \
  "SmtLibDsl solver setup" \
  "install directory: $INSTALL_ROOT" \
  ""

if command -v lake >/dev/null 2>&1; then
  printf 'ready    %-8s %s\n' "lake" "$(lake --version 2>&1)"
else
  printf '%s\n' \
    "missing  lake" \
    "         Install elan: https://github.com/leanprover/elan"
fi

if [[ "$CHECK_ONLY" == true ]]; then
  status=0
  for solver in "${SELECTED[@]}"; do
    check_solver "$solver" || status=1
  done
  exit "$status"
fi

platform_patterns
ensure_work_root

for solver in "${SELECTED[@]}"; do
  if [[ "$FORCE" == false ]] && check_solver "$solver" >/dev/null 2>&1; then
    check_solver "$solver"
    continue
  fi
  if [[ "$DRY_RUN" == true ]]; then
    printf 'would install %-8s latest stable release\n' "$solver"
  else
    install_solver "$solver"
  fi
done

if [[ "$DRY_RUN" == true ]]; then
  printf '%s\n' "" "Dry run complete; no files were changed."
  exit 0
fi

printf '%s\n' "" "Solver verification:"
status=0
for solver in "${SELECTED[@]}"; do
  check_solver "$solver" || status=1
done
[[ "$status" -eq 0 ]] || die "one or more solver installations failed verification"

if [[ "$RUN_TESTS" == true ]]; then
  command -v lake >/dev/null 2>&1 ||
    die "Lake is required for integration tests; install elan or use --no-test"
  printf '%s\n' "" "Lean integration tests:"
  (
    cd "$REPO_ROOT"
    lake exe smtlibdsl-test
  )
fi

printf '%s\n' \
  "" \
  "Setup complete." \
  "The Lean API discovers project-local solvers automatically." \
  "Check at any time with: ./scripts/setup.sh --check"
