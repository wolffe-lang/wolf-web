# ww43: does lupin 0.1.53 (7896eddc) compile to wasm32? (kasumi; input re-check, wolf-interp#222)
# Two builds at the same pins, the interpreter checkout moved by hand (nothing committed):
# (1) with trunk's crates/lupin-wasm/wasm-portability.patch (ww40's, carried since), (2) with it absent.
L=~/lanes/ww43
export PATH="$L/bin:$HOME/.cargo/bin:$PATH" CARGO_BUILD_JOBS=4 CARGO_INCREMENTAL=0
cd $L/web || exit 1
test "$(git branch --show-current)" = ww43 || exit 1
git -C upstream/wolf-interp fetch -q --tags origin || exit 1
git -C upstream/wolf-interp checkout -q 7896eddc17fd9e3e015b025b354ccf62a766734b || exit 1
git -C upstream/wolf-interp submodule update --init --recursive || exit 1
echo "interp $(git -C upstream/wolf-interp rev-parse HEAD) $(grep -m1 '^version' upstream/wolf-interp/Cargo.toml)"
sha256sum crates/lupin-wasm/wasm-portability.patch
mkdir -p dist/play
./scripts/build-wasm.sh > $L/wasm-0153-patched.log 2>&1; echo "PATCHED-EXIT=$?"
test -s dist/play/lupin.wasm && sha256sum dist/play/lupin.wasm && cp dist/play/lupin.wasm $L/lupin-0.1.53-control.wasm
rm -f dist/play/lupin.wasm
mv crates/lupin-wasm/wasm-portability.patch $L/wasm-portability.patch.held || exit 1
./scripts/build-wasm.sh > $L/wasm-0153-unpatched.log 2>&1; echo "UNPATCHED-EXIT=$?"
mv $L/wasm-portability.patch.held crates/lupin-wasm/wasm-portability.patch || exit 1
git status --short
grep -m3 -E '^error' $L/wasm-0153-unpatched.log
git -C upstream/wolf-interp checkout -q 025428b725a35bfbc53745d4166817ff3053c0fd || exit 1
echo WASM-CONTROL-DONE
