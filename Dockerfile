# syntax=docker/dockerfile:1

# Comments are provided throughout this file to help you get started.
# If you need more help, visit the Dockerfile reference guide at
# https://docs.docker.com/go/dockerfile-reference/

# Want to help us make this template better? Share your feedback here: https://forms.gle/ybq9Krt8jtBL3iCk7
ARG RUST_VERSION=1.90.0
ARG RUST_TARGET=x86_64-unknown-linux-gnu
ARG APP_NAME=sla-fuzz

################################################################################
# Create a stage for building the application.

#FROM rust:${RUST_VERSION}-alpine AS build
FROM rust:${RUST_VERSION}-trixie AS build
ARG APP_NAME
ARG RUST_TARGET
WORKDIR /app

# Install host build dependencies.
# RUN apk add --no-cache clang20 lld musl-dev git libstdc++-dev
RUN apt-get update && apt-get install -y --no-install-recommends \
  lld \
  build-essential \
  git \
  clang \
  && rm -rf /var/lib/apt/lists/*

# Build the application.
# Leverage a cache mount to /usr/local/cargo/registry/
# for downloaded dependencies, a cache mount to /usr/local/cargo/git/db
# for git repository dependencies, and a cache mount to /app/target/ for
# compiled dependencies which will speed up subsequent builds.
# Leverage a bind mount to the src directory to avoid having to copy the
# source code into the container. Once built, copy the executable to an
# output directory before the cache mounted /app/target is unmounted.
#
#CC=clang CXX=clang++ RUSTFLAGS="-Zsanitizer=address -Ctarget-feature=-crt-static" cargo +nightly build --locked --release --target $RUST_TARGET && \
RUN --mount=type=bind,source=src,target=src \
    --mount=type=bind,source=.cargo,target=.cargo \
    --mount=type=bind,source=build.rs,target=build.rs \
    --mount=type=bind,source=Cargo.toml,target=Cargo.toml \
    --mount=type=bind,source=Cargo.lock,target=Cargo.lock \
    --mount=type=bind,source=libsla-sys,target=libsla-sys \
    --mount=type=cache,target=/app/target/ \
    --mount=type=cache,target=/usr/local/cargo/git/db \
    --mount=type=cache,target=/usr/local/cargo/registry/ \
RUSTFLAGS="-Zsanitizer=address" cargo +nightly build --locked --release --target $RUST_TARGET && \
cp ./target/$RUST_TARGET/release/$APP_NAME /bin/fuzzer

RUN --mount=type=bind,source=build-corpus.rs,target=build-corpus.rs \
./build-corpus.rs

################################################################################
# Create a new stage for running the application that contains the minimal
# runtime dependencies for the application. This often uses a different base
# image from the build stage where the necessary files are copied from the build
# stage.
#
# The example below uses the alpine image as the foundation for running the app.
# By specifying the "3.18" tag, it will use version 3.18 of alpine. If
# reproducibility is important, consider using a digest
# (e.g., alpine@sha256:664888ac9cfd28068e062c991ebcff4b4c7307dc8dd4df9e728bedde5c449d91).
#FROM alpine:3.18 AS final
FROM debian:trixie AS final
RUN apt-get update && apt-get install -y --no-install-recommends \
  adduser \
  && rm -rf /var/lib/apt/lists/*

# RUN mkdir -p /var/inputs

# Create a non-privileged user that the app will run under.
# See https://docs.docker.com/go/dockerfile-user-best-practices/
ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser

# TODO Figure out appropriate permissions so fuzzer can write files as user
#USER appuser

# Copy the executable from the "build" stage.
COPY --from=build /bin/fuzzer /bin/

# Expose the port that the application listens on.
# EXPOSE 12345

# Mount input volume
# VOLUME /var/inputs

# What the container should run when it is started.
ENTRYPOINT ["/bin/fuzzer", "/tmp/inputs"]
