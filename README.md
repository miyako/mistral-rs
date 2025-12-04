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

```
git clone https://github.com/EricLBuehler/mistral.rs.git
cd mistral.rs
cargo build --release
```
