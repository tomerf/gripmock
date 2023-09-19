FROM golang:alpine

RUN mkdir /proto /stubs

# install tools (bash, git, protobuf, protoc-gen-go, protoc-grn-go-grpc, pkger)
RUN apk -U --no-cache add bash git protobuf &&\
    go install -v github.com/golang/protobuf/protoc-gen-go@latest &&\
    go install -v google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest &&\
    go install github.com/markbates/pkger/cmd/pkger@latest

# cloning well-known-types
RUN git clone https://github.com/google/protobuf.git /protobuf-repo &&\
    mkdir protobuf &&\
    mv /protobuf-repo/src/ /protobuf/ &&\
    rm -rf /protobuf-repo &&\
    mkdir -p /go/src/github.com/tokopedia/gripmock

COPY . /go/src/github.com/tokopedia/gripmock

WORKDIR /go/src/github.com/tokopedia/gripmock/protoc-gen-gripmock

RUN pkger

# install generator plugin
RUN go install -v

WORKDIR /go/src/github.com/tokopedia/gripmock

# install gripmock
RUN go install -v

RUN --mount=type=secret,id=github,dst=/root/.netrc GOPRIVATE=github.com/secful go get github.com/secful/go-protobuf/salt/protobuf

COPY proto /proto

# remove all .pb.go generated files
# since generating go file is part of the test
RUN find . -name "*.pb.go" -delete -type f

EXPOSE 4770 4771

ENTRYPOINT ["gripmock"]
