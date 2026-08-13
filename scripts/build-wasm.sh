#!/usr/bin/env bash
# ------------------------------------------------------------------
# Compile lupin, the reference interpreter, to WebAssembly.
#
# The playground runs the real interpreter. Not a subset of it, not a
# reimplementation of it in JavaScript: the pinned `upstream/wolf-interp`
# checkout, compiled for wasm32-unknown-unknown, answering through
# `crates/lupin-wasm`. Every verdict a visitor sees came out of the same code
# that answers `lupin run -` at a terminal.
#
# There is no wasm-bindgen and no npm here. `crates/lupin-wasm` is a plain
# cdylib with six exported functions over a byte-buffer ABI, and
# `site/play/lupin.js` is the hand-written glue. Two reasons: the toolchain
# stays cargo alone, which is what makes this script safe to run on the deploy
# box; and the page needs no `eval`, no blob workers and no inline scripts, so
# the nginx CSP stays at `'self' 'wasm-unsafe-eval'` with nothing added.
#
# THE PATCH. The pinned interpreter does not compile to wasm as it stands —
# see crates/lupin-wasm/wasm-portability.patch for the three reasons and the
# evidence. This script never touches the submodule. It stages a copy of the
# pinned tree under target/, patches the copy, and builds that. When the fix
# lands upstream the staged copy already carries the gates, this script says
# so and skips the patch, and the patch file can be deleted.
#
# Run from the repo root (build.sh does):  ./scripts/build-wasm.sh
# ------------------------------------------------------------------
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

TARGET=wasm32-unknown-unknown
DIST="$ROOT/dist"
STAGE="$ROOT/target/wasm-stage"
PATCH="$ROOT/crates/lupin-wasm/wasm-portability.patch"
INTERP="$ROOT/upstream/wolf-interp"

# The parser reserves 64 MiB of thread stack natively so the depth-256 nesting
# rail, and not a stack overflow, is what stops hostile input. wasm has one
# stack and the linker sizes it, so the equivalent reservation is a link
# argument. 32 MiB of a 4 GiB address space, committed a page at a time.
STACK_SIZE=$((32 * 1024 * 1024))

die() { printf 'build-wasm: %s\n' "$1" >&2; exit 1; }
note() { printf '  %s\n' "$1"; }

# -- the toolchain ---------------------------------------------------------

command -v cargo >/dev/null || die "cargo is not on PATH"
test -f "$INTERP/Cargo.toml" || \
  die "upstream/wolf-interp is empty — run: git submodule update --init --recursive"

# WOLF_WASM_SYSROOT is for a rust that has the wasm std somewhere rustc will
# not find on its own — a distro package extracted by hand, or a second
# toolchain. Unset on a rustup box, which is the normal case.
FLAGS="${RUSTFLAGS:-}"
if [[ -n "${WOLF_WASM_SYSROOT:-}" ]]; then
  FLAGS="$FLAGS --sysroot=$WOLF_WASM_SYSROOT"
  note "using WOLF_WASM_SYSROOT=$WOLF_WASM_SYSROOT"
fi

# -- stage the interpreter -------------------------------------------------

rm -rf "$STAGE"
mkdir -p "$STAGE/upstream" "$STAGE/crates"

# `git archive` rather than cp: tracked files only, so the staged tree gets
# neither the nested submodule nor a broken .git pointer, and the build is the
# same whatever is lying around in the checkout.
mkdir -p "$STAGE/upstream/wolf-interp"
git -C "$INTERP" archive HEAD | tar -x -C "$STAGE/upstream/wolf-interp"
test -f "$STAGE/upstream/wolf-interp/Cargo.toml" || die "staging the interpreter failed"

# crates/lupin-wasm goes to the same depth it sits at in the repo, so its
# `path = "../../upstream/wolf-interp"` resolves inside the staging tree with
# no manifest rewriting.
cp -R "$ROOT/crates/lupin-wasm" "$STAGE/crates/lupin-wasm"
rm -rf "$STAGE/crates/lupin-wasm/target"

# The interpreter pins its Rust version, and that pin governs this build too:
# lupin-wasm compiles the interpreter's own source. rustup reads the file from
# the build directory's ancestors, and the staged interpreter is a sibling of
# the crate we build, so the pin goes at the staging root where it covers both.
# Without this the build runs on whatever the box's default toolchain is, which
# is how almanta tried to compile a 1.97.1 tree with 1.89.0.
if [[ -f "$STAGE/upstream/wolf-interp/rust-toolchain.toml" ]]; then
  cp "$STAGE/upstream/wolf-interp/rust-toolchain.toml" "$STAGE/rust-toolchain.toml"
  note "staged the interpreter's toolchain pin: $(grep -oE '[0-9]+\.[0-9]+\.[0-9]+' "$STAGE/rust-toolchain.toml" | head -1)"
fi

# The probe runs from the staging root, after the pin is in place, so the
# target is added to the toolchain that will actually build.
cd "$STAGE"

# rustup owns targets, but a distro rust with a wasm package has the std
# without rustup ever being installed. Probe for the std, then fall back to
# rustup only if the probe fails.
# Ask rustc where the target's libraries would live and look for std there.
# Cheaper than a probe compile, and it answers the only question that matters.
have_target() {
  local libdir
  # shellcheck disable=SC2086 -- FLAGS is a flag list and must word-split
  libdir=$(rustc $FLAGS --target "$TARGET" --print target-libdir 2>/dev/null) || return 1
  [[ -n "$libdir" ]] && compgen -G "$libdir/libstd-*.rlib" >/dev/null
}

if ! have_target; then
  command -v rustup >/dev/null || die \
    "the $TARGET std is not installed and rustup is not on PATH.
    With rustup:     rustup target add $TARGET
    Distro rust:     install the wasm std for rust $(rustc --version | cut -d' ' -f2)
                     (Arch: rust-wasm; Fedora: rust-std-static-$TARGET)
    Neither:         point WOLF_WASM_SYSROOT at a sysroot that has it"
  note "adding the $TARGET target via rustup"
  rustup target add "$TARGET" || die "rustup could not add $TARGET"
  have_target || die "rustup reported success but $TARGET still does not build"
fi


# -- patch the copy --------------------------------------------------------

cd "$STAGE/upstream/wolf-interp"
if [[ ! -f "$PATCH" ]]; then
  note "no portability patch present; building the pin as it stands"
elif patch -p1 --dry-run --silent --forward < "$PATCH" >/dev/null 2>&1; then
  patch -p1 --silent --forward < "$PATCH" >/dev/null
  note "applied wasm-portability.patch to the staged copy (submodule untouched)"
elif patch -p1 -R --dry-run --silent < "$PATCH" >/dev/null 2>&1; then
  note "the pin already carries the wasm portability gates; patch not needed"
  note "  -> crates/lupin-wasm/wasm-portability.patch can be deleted"
else
  die "crates/lupin-wasm/wasm-portability.patch does not apply to the pinned
    interpreter and is not already applied. The pin moved under the patch.
    Rebase the patch against $(git -C "$INTERP" rev-parse --short HEAD), or
    land it upstream and move the pin past it. Refusing to guess."
fi

# -- build -----------------------------------------------------------------

cd "$STAGE/crates/lupin-wasm"

# The interpreter's build.rs stamps WOLF_INTERP_COMMIT by running `git rev-parse
# HEAD`, and every observation record carries the answer so a record can say
# which interpreter produced it. The staged tree has no .git of its own, so git
# would walk up and answer with *this* repository's commit: a record claiming
# the interpreter was built from a wolf-web revision, which is the exact
# dishonesty the interpreter's build.rs was written to prevent. Point GIT_DIR at
# the submodule's real gitdir so the stamp is the interpreter's own pin.
GIT_DIR=$(git -C "$INTERP" rev-parse --absolute-git-dir 2>/dev/null) || GIT_DIR=""
if [[ -n "$GIT_DIR" ]]; then
  export GIT_DIR
  note "stamping the interpreter commit as $(git rev-parse --short=7 HEAD)"
else
  note "the interpreter has no gitdir here; records will report commit 'unknown'"
fi

export RUSTFLAGS="$FLAGS -C link-arg=-zstack-size=$STACK_SIZE"
cargo build --release --target "$TARGET" --quiet \
  || die "the wasm build failed; the output above is cargo's"

WASM="$STAGE/crates/lupin-wasm/target/$TARGET/release/lupin_wasm.wasm"
test -f "$WASM" || die "cargo reported success but $WASM is missing"

# The module must import nothing. An import means something reached for a host
# function this design does not have, the page has no shim to satisfy it, and
# instantiation would fail in the visitor's browser instead of here.
if command -v python3 >/dev/null; then
  python3 - "$WASM" <<'PY' || die "the wasm module declares imports; see above"
import sys, struct

data = open(sys.argv[1], "rb").read()
assert data[:8] == b"\x00asm\x01\x00\x00\x00", "not a wasm module"

def uleb(buf, i):
    out = shift = 0
    while True:
        b = buf[i]; i += 1
        out |= (b & 0x7F) << shift
        if not b & 0x80:
            return out, i
        shift += 7

i, imports = 8, None
while i < len(data):
    sec = data[i]; i += 1
    size, i = uleb(data, i)
    if sec == 2:  # the import section
        imports, _ = uleb(data, i)
    i += size

if imports:
    print(f"  wasm: {imports} import(s) declared — the page has no shim for them",
          file=sys.stderr)
    sys.exit(1)
print("  wasm: imports 0 (the module is self-contained)")
PY
fi

# -- publish ---------------------------------------------------------------

mkdir -p "$DIST/play"
cp "$WASM" "$DIST/play/lupin.wasm"

RAW=$(wc -c < "$DIST/play/lupin.wasm")
GZ=$(gzip -9 -c "$DIST/play/lupin.wasm" | wc -c)
note "wasm: $((RAW / 1024)) KiB raw, $((GZ / 1024)) KiB gzipped"
