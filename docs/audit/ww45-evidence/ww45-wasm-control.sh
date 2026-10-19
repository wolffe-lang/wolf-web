# ww45: does lupin 0.1.54 (0e536e8f) still compile to wasm32 as ww44 left it? (kasumi; input re-check, wolf-interp#222)
# The interpreter pin does not move at ww45, so this is ww44's control re-run at the same pins:
# (1) with trunk's crates/lupin-wasm/wasm-portability.patch (ww40's, carried since), (2) with it absent.
# Prediction: (1) exit 0, imports 0, the module ww44 measured (04ce1322…); (2) exit 1, E0433.
L=~/lanes/ww45
export PATH="$L/bin:$HOME/.cargo/bin:$PATH" CARGO_BUILD_JOBS=4 CARGO_INCREMENTAL=0
cd $L/web || exit 1
test "$(git branch --show-current)" = ww45 || exit 1
echo "web $(git rev-parse HEAD)"
git -C upstream/wolf-interp fetch -q --tags origin || exit 1
git -C upstream/wolf-interp checkout -q 0e536e8fb4518eaa798ac426901ab81275db5c9f || exit 1
git -C upstream/wolf-interp submodule update --init --recursive || exit 1
echo "interp $(git -C upstream/wolf-interp rev-parse HEAD) $(grep -m1 '^version' upstream/wolf-interp/Cargo.toml); its spec $(git -C upstream/wolf-interp/upstream rev-parse HEAD)"
sha256sum crates/lupin-wasm/wasm-portability.patch
mkdir -p dist/play
./scripts/build-wasm.sh > $L/wasm-0154-patched.log 2>&1; echo "PATCHED-EXIT=$?"
test -s dist/play/lupin.wasm && sha256sum dist/play/lupin.wasm && cp dist/play/lupin.wasm $L/lupin-0.1.54-control.wasm
rm -f dist/play/lupin.wasm
mv crates/lupin-wasm/wasm-portability.patch $L/wasm-portability.patch.held || exit 1
./scripts/build-wasm.sh > $L/wasm-0154-unpatched.log 2>&1; echo "UNPATCHED-EXIT=$?"
mv $L/wasm-portability.patch.held crates/lupin-wasm/wasm-portability.patch || exit 1
git status --short
grep -m3 -E '^error' $L/wasm-0154-unpatched.log
grep -iE 'import' $L/wasm-0154-patched.log | head -3
echo WASM-CONTROL-DONE
