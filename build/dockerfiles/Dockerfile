# Build Geth in a stock Go builder container
FROM --platform=${BUILDPLATFORM} golang:1.21 AS builder

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

FROM builder AS build-beacon-chain
ARG TARGETOS
ARG TARGETARCH
RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    cd /prysm/cmd/beacon-chain && CGO_ENABLED=1 go build -v -o /usr/local/bin/beacon-chain

FROM builder AS build-validator
ARG TARGETOS
ARG TARGETARCH
RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    cd /prysm/cmd/validator && CGO_ENABLED=1 go build -v -o /usr/local/bin/validator

FROM builder AS build-prysmctl
ARG TARGETOS
ARG TARGETARCH
RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    cd /prysm/cmd/prysmctl && CGO_ENABLED=1 go build -v -o /usr/local/bin/prysmctl

# Pull Geth into a second stage deploy container
FROM debian:latest AS beacon-chain
COPY --from=build-beacon-chain /usr/local/bin/beacon-chain /usr/local/bin/
EXPOSE 4000 3500 8080 6060 9090
ENTRYPOINT ["beacon-chain"]

FROM debian:latest AS validator
COPY --from=build-validator /usr/local/bin/validator /usr/local/bin/
ENTRYPOINT ["validator"]

FROM debian:latest AS prysmctl
COPY --from=build-prysmctl /usr/local/bin/prysmctl /usr/local/bin/
ENTRYPOINT ["prysmctl"]
