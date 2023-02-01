
FROM golang:1.18-buster as builder

# Create and change to the app directory.
RUN mkdir /sampleapp
WORKDIR /sampleapp

# Get all application dependencies.
COPY go.* ./
RUN go mod download

# Copy code to the builder image.
COPY . /sampleapp/

# Build the binary.

RUN go build -v -o httpserver ./app

FROM debian:buster-slim
RUN set -x && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install \
    ca-certificates -y && \
    rm -rf /var/lib/apt/lists/*
COPY --from=builder /sampleapp/httpserver /sampleapp/httpserver

#Copy wallet files
#COPY --from=builder /sampleapp/ssl /sampleapp/ssl
EXPOSE 8080
ENV GO111MODULE=on
ENV GOFLAGS=-mod=vendor
WORKDIR /sampleapp
CMD ["/sampleapp/httpserver"]

#docker images --all
# docker build -t "sampleaapp01" .
# docker run -t -i --env-file ./db.env -p 8080:8080 sampleaapp01:latest 
# docker login sampleapp01.azurecr.io
# docker tag  sampleaapp01:latest sampleapp01.azurecr.io/httpapp
# docker push sampleapp01.azurecr.io/httpapp