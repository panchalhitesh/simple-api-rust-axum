# Build stage
FROM rust:latest as builder

# 1. Create a new empty shell project
RUN USER=root cargo new --bin simple-api-rust-axum

WORKDIR /simple-api-rust-axum

# 2. Copy our manifests
COPY ./Cargo.lock ./Cargo.lock
COPY ./Cargo.toml ./Cargo.toml

#3. Build only the dependencies to cache them
RUN cargo build --release
RUN rm src/*.rs

#4. Now that the dependency is built, copy your source code 
COPY ./src ./src
#
## 5. Build for release.
RUN pwd && ls -ltr
RUN rm ./simple-api-rust-axum/target/release/deps/simple-api-rust-axum*
RUN cargo build --release

#
## our final base
FROM debian:bookworm-slim
RUN pwd && ls -ltr

## 6. Copy the build artifacts from the build stage
COPY --from=builder /simple-api-rust-axum/target/release/simple-api-rust-axum .
RUN pwd && ls -ltr

# Run the Binary
CMD ["./simple-api-rust-axum"]
