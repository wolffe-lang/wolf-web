# ww40: the control for the portability patch (kasumi). The same build-wasm.sh at the same pins with the
# patch file absent: lupin 0.1.49 as released must fail to compile for wasm32 (os_error_text -> eval::fs).
L=~/lanes/ww40
export PATH="$L/bin:$HOME/.cargo/bin:$PATH" CARGO_BUILD_JOBS=4
cd $L/web || exit 1
git -C upstream/wolf-interp rev-parse HEAD
test "$(git -C upstream/wolf-interp rev-parse HEAD)" = f516a5f4ea4341acd3a30f3e5cdd4327aede1912 || exit 1
mv crates/lupin-wasm/wasm-portability.patch $L/patch-aside || exit 1
./scripts/build-wasm.sh > $L/wasm-0149-unpatched.log 2>&1; echo "UNPATCHED-EXIT=$?"
mv $L/patch-aside crates/lupin-wasm/wasm-portability.patch || exit 1
grep -E 'error\[|could not compile|no portability patch|wasm build failed' $L/wasm-0149-unpatched.log
echo CONTROL-DONE
