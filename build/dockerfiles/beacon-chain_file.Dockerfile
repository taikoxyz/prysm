# Support setting various labels on the final image
ARG COMMIT=""
ARG VERSION=""
ARG BUILDNUM=""

# Build Geth in a stock Go builder container
FROM golang:1.21-alpine as builder

RUN apk add --no-cache gcc g++ libstdc++ libc-dev musl-dev linux-headers git

# Get dependencies - will also be cached if we won't change go.mod/go.sum
COPY go.mod /prysm/
COPY go.sum /prysm/
RUN cd /prysm && go mod download

ADD . /prysm
RUN cd /prysm/cmd/beacon-chain && go build -v -o /usr/local/bin/

# Pull Geth into a second stage deploy alpine container
FROM alpine:latest

RUN apk add --no-cache ca-certificates gcc g++ libstdc++ libc-dev
COPY --from=builder /usr/local/bin/beacon-chain /usr/local/bin/

EXPOSE 4000 3500 8080 6060 9090
ENTRYPOINT ["beacon-chain"]