# mistral-rs
Local inference engine


### Apple Silicon

```
git clone https://github.com/EricLBuehler/mistral.rs.git
cd mistral.rs
cargo build --release --features metal --target aarch64-apple-darwin
```

### Intel

```
git clone https://github.com/EricLBuehler/mistral.rs.git
cd mistral.rs
RUSTFLAGS="-C target-cpu=haswell" cargo build --release --features accelerate --target x86_64-apple-darwin
```

### Windows

download and install `clang+llvm-21.1.7-x86_64-pc-windows-msvc` from [`https://github.com/llvm/llvm-project/releases`](https://github.com/llvm/llvm-project/releases)

```
git clone https://github.com/EricLBuehler/mistral.rs.git
cd mistral.rs
LIBCLANG_PATH="..."
cargo build --release --target x86_64-pc-windows-msvc
```
