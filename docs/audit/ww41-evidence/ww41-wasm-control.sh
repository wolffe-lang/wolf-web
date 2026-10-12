# ww41: does lupin 0.1.51 (f72e78d7) compile to wasm32? (kasumi; input re-check, wolf-interp#222)
# Two builds at the same pins, the interpreter checkout moved by hand (nothing committed):
# (1) with trunk's crates/lupin-wasm/wasm-portability.patch (ww40's), (2) with it absent.
L=~/lanes/ww41
export PATH="$L/bin:$HOME/.cargo/bin:$PATH" CARGO_BUILD_JOBS=4 CARGO_INCREMENTAL=0
cd $L/web || exit 1
test "$(git branch --show-current)" = ww41 || exit 1
git -C upstream/wolf-interp fetch -q --tags origin || exit 1
git -C upstream/wolf-interp checkout -q f72e78d7a9d0ceb39d80380389ad6a2072991c63 || exit 1
git -C upstream/wolf-interp submodule update --init --recursive || exit 1
echo "interp $(git -C upstream/wolf-interp rev-parse HEAD) $(grep -m1 '^version' upstream/wolf-interp/Cargo.toml)"
sha256sum crates/lupin-wasm/wasm-portability.patch
mkdir -p dist/play
./scripts/build-wasm.sh > $L/wasm-0151-patched.log 2>&1; echo "PATCHED-EXIT=$?"
test -s dist/play/lupin.wasm && sha256sum dist/play/lupin.wasm && cp dist/play/lupin.wasm $L/lupin-0.1.51-control.wasm
rm -f dist/play/lupin.wasm
mv crates/lupin-wasm/wasm-portability.patch $L/wasm-portability.patch.held || exit 1
./scripts/build-wasm.sh > $L/wasm-0151-unpatched.log 2>&1; echo "UNPATCHED-EXIT=$?"
mv $L/wasm-portability.patch.held crates/lupin-wasm/wasm-portability.patch || exit 1
git status --short
grep -m3 -E '^error' $L/wasm-0151-unpatched.log
git -C upstream/wolf-interp checkout -q f516a5f4ea4341acd3a30f3e5cdd4327aede1912 || exit 1
echo WASM-CONTROL-DONE
