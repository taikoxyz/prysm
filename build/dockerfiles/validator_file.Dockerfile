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
RUN cd /prysm/cmd/validator && CGO_ENABLED=1 go build -v -o /usr/local/bin/validator

# Pull Geth into a second stage deploy container
FROM debian:latest

COPY --from=builder /usr/local/bin/validator /usr/local/bin/

ENTRYPOINT ["validator"]

