# ww46 note (added when the evidence landed): copied unchanged below this note. Its comment lines were carried from
# ww45's and are wrong for ww46: the interpreter pin moves to e642f26 (lupin 0.1.55), which the script checks out, and
# the module it predicts (04ce1322…) is ww44's; the measured module is 1fc52ce9… (wasm-control.txt), equal to the
# build's dist/play/lupin.wasm at the head (build-summary.txt).
# ww46: does lupin 0.1.55 (0e536e8f) still compile to wasm32 as ww44 left it? (kasumi; input re-check, wolf-interp#222)
# The interpreter pin does not move at ww46, so this is ww44's control re-run at the same pins:
# (1) with trunk's crates/lupin-wasm/wasm-portability.patch (ww40's, carried since), (2) with it absent.
# Prediction: (1) exit 0, imports 0, the module ww44 measured (04ce1322…); (2) exit 1, E0433.
L=~/lanes/ww46
export PATH="$L/bin:$HOME/.cargo/bin:$PATH" CARGO_BUILD_JOBS=4 CARGO_INCREMENTAL=0
cd $L/web || exit 1
test "$(git branch --show-current)" = ww46 || exit 1
echo "web $(git rev-parse HEAD)"
git -C upstream/wolf-interp fetch -q --tags origin || exit 1
git -C upstream/wolf-interp checkout -q e642f2630ad4c7f53740428d5cca705f2e0d295b || exit 1
git -C upstream/wolf-interp submodule update --init --recursive || exit 1
echo "interp $(git -C upstream/wolf-interp rev-parse HEAD) $(grep -m1 '^version' upstream/wolf-interp/Cargo.toml); its spec $(git -C upstream/wolf-interp/upstream rev-parse HEAD)"
sha256sum crates/lupin-wasm/wasm-portability.patch
mkdir -p dist/play
./scripts/build-wasm.sh > $L/wasm-0155-patched.log 2>&1; echo "PATCHED-EXIT=$?"
test -s dist/play/lupin.wasm && sha256sum dist/play/lupin.wasm && cp dist/play/lupin.wasm $L/lupin-0.1.55-control.wasm
rm -f dist/play/lupin.wasm
mv crates/lupin-wasm/wasm-portability.patch $L/wasm-portability.patch.held || exit 1
./scripts/build-wasm.sh > $L/wasm-0155-unpatched.log 2>&1; echo "UNPATCHED-EXIT=$?"
mv $L/wasm-portability.patch.held crates/lupin-wasm/wasm-portability.patch || exit 1
git status --short
grep -m3 -E '^error' $L/wasm-0155-unpatched.log
grep -iE 'import' $L/wasm-0155-patched.log | head -3
echo WASM-CONTROL-DONE
