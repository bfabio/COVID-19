#
# Build image
#
from rust:1.41-slim as build

WORKDIR /app

ARG target=x86_64-unknown-linux-musl

RUN rustup target add $target

RUN apt-get update && apt-get install -y musl-tools \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY api/Cargo.lock api/Cargo.toml ./api/

RUN mkdir -p api/src && echo 'fn main(){}' > api/src/main.rs

RUN cd api && cargo build --release --target $target

COPY ./ ./
RUN touch api/src/main.rs

RUN cd api && cargo build --release --target $target
RUN strip /app/api/target/$target/release/api

#
# Final image
#
FROM scratch

COPY --from=build /app/api/target/x86_64-unknown-linux-musl/release/api /usr/local/bin/

USER 1000

EXPOSE 8000

CMD ["/usr/local/bin/api"]
