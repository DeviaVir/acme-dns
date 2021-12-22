FROM golang:1-alpine AS builder

RUN apk add --update gcc musl-dev git

ENV GOPATH      /tmp/buildcache
ENV CGO_ENABLED 1
COPY . /tmp/acme-dns
WORKDIR /tmp/acme-dns
RUN go build -ldflags="-extldflags=-static"

# assemble the release ready to copy to the image.
RUN mkdir -p /tmp/release/bin
RUN mkdir -p /tmp/release/etc/acme-dns
RUN mkdir -p /tmp/release/var/lib/acme-dns
RUN cp /tmp/acme-dns/acme-dns /tmp/release/bin/acme-dns

FROM gcr.io/distroless/static

WORKDIR /
COPY --from=builder /tmp/release .

VOLUME ["/etc/acme-dns", "/var/lib/acme-dns"]
ENTRYPOINT ["/bin/acme-dns"]
EXPOSE 53 80 443
EXPOSE 53/udp
