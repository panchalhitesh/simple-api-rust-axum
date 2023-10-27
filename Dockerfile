# Build stage

FROM rust:latest as T builder

COPY ./zscaler_ca.crt ./etc/ssl/certs/ca-certificates.crt

# 1. Create a new empty shell project

RUN USER=root cargo new --bin restapi WORKDIR /restapă

# 2. Copy our manifests

COPY./Cargo.lock ./Cargo.lock

COPY/Cargo.toml ./Cargo.toml

#3. Build only the dependencies to cache them

RUN cargo build --release

RUN rm src/*.rs

#4. Now that the dependency is built, copy your source code COPY./src./src

#

## 5. Build for release.

RUN rm/target/release/deps/restapi*

RUN cargo build --release

#

## our final base

FROM debian:bookworm-slim

RUN pwd && Ls -Ltr

## 6. Copy the build artifacts from the build stage

COPY --From-builder /restapi/target/release/restapi.

RUN pwd && ls -ltr

# Run the Binary


CMD ["./simple-api-rust-axum"]
