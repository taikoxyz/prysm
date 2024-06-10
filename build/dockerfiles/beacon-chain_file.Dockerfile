# Build Geth in a stock Go builder container
FROM golang:1.21 as builder

RUN apt-get update && apt-get install -y \
	gcc \
	g++ \
	libstdc++6 \
	libc-dev \
	musl-tools

# Get dependencies - will also be cached if we won't change go.mod/go.sum
COPY go.mod /prysm/
COPY go.sum /prysm/
RUN cd /prysm && go mod download

ADD . /prysm
RUN cd /prysm/cmd/beacon-chain && CGO_ENABLED=1 go build -v -o /usr/local/bin/beacon-chain

# Pull Geth into a second stage deploy container
FROM debian:buster-slim

RUN apt-get update && apt-get install -y \
	ca-certificates \
	libstdc++6 \
	libc-dev \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/bin/beacon-chain /usr/local/bin/

EXPOSE 4000 3500 8080 6060 9090
ENTRYPOINT ["beacon-chain"]

