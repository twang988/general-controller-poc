# Build the manager binary
FROM golang:1.18-alpine3.16 as builder

WORKDIR /workspace
# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum
# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
#RUN go mod download

RUN export https_proxy=http://147.11.252.42:9090 && apk add ca-certificates openssl git
ARG cert_location=/usr/local/share/ca-certificates
RUN openssl s_client -showcerts -connect goproxy.cn:443 </dev/null 2>/dev/null|openssl x509 -outform PEM >  ${cert_location}/goproxy.cn.crt
RUN update-ca-certificates
RUN unset https_proxy && export GOPROXY=https://goproxy.cn,direct && go mod download

# Copy the go source
COPY main.go main.go
COPY apis/ apis/
COPY controllers/ controllers/
COPY pkg/ pkg/

# Build
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -o manager main.go

# Use distroless as minimal base image to package the manager binary
# Refer to https://github.com/GoogleContainerTools/distroless for more details
FROM gcr.io/distroless/static:nonroot
WORKDIR /
COPY --from=builder /workspace/manager .
USER 65532:65532

ENTRYPOINT ["/manager"]
