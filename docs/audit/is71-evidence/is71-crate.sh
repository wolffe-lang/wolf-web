# is71: the crate's host gates on kasumi (fmt, clippy, its own cargo tests) at a commit.
#   usage: bash is71-crate.sh <commit>   (run after is71-leg.sh, which leaves the submodules in place)
set -u
L=~/lanes/is71; REV=$1
export PATH="$HOME/.cargo/bin:$PATH" CARGO_BUILD_JOBS=4
cd $L/web || exit 1
git checkout -q --detach "$REV" || exit 1
echo "HEAD $(git rev-parse HEAD)"
cd crates/lupin-wasm || exit 1
# the interpreter's toolchain pin, as build-wasm.sh stages it
TC=$(grep -oE '[0-9]+\.[0-9]+\.[0-9]+' ../../upstream/wolf-interp/rust-toolchain.toml | head -1); echo "toolchain $TC"
cargo +$TC fmt --check; echo "FMT-EXIT=$?"
cargo +$TC clippy --all-targets -- -D warnings > $L/clippy.log 2>&1; echo "CLIPPY-EXIT=$?"; tail -3 $L/clippy.log
cargo +$TC test > $L/crate-test.log 2>&1; echo "TEST-EXIT=$?"; grep -E "^test |test result" $L/crate-test.log
echo CRATE-DONE; touch $L/crate.done
