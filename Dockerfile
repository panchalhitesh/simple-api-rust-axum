# Build Stage
FROM rust:latest as builder

RUN USER=root cargo new --bin simple-api-rust-axum
WORKDIR ./axum-demo
COPY ./Cargo.toml ./Cargo.toml

# Build empty app with downloaded dependencies to produce a stable image layer for next build
RUN cargo build --release

# Build web app with own code
RUN rm src/*.rs
ADD . ./
RUN rm ./target/release/deps/simple-api-rust-axum*
RUN cargo build --release --no-cache


FROM debian:buster-slim
ARG APP=/usr/src/app

RUN apt-get update \
    && apt-get install -y ca-certificates tzdata \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 3000

ENV TZ=Etc/UTC \
    APP_USER=appuser

RUN groupadd $APP_USER \
    && useradd -g $APP_USER $APP_USER \
    && mkdir -p ${APP}

COPY --from=builder /axum-demo/target/release/simple-api-rust-axum ${APP}/axum-demo
COPY --from=builder /simple-api-rust-axum/static ${APP}/static

RUN chown -R $APP_USER:$APP_USER ${APP}

USER $APP_USER
WORKDIR ${APP}

CMD ["./simple-api-rust-axum"]
