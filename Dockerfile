FROM golang:1.7.3 as builder

WORKDIR /app/src/bloodwing
COPY bloodwing.go .
RUN CGO_ENABLED=0 go build -o bin/bloodwing -ldflags '-w'


FROM golang:1.7.3

ENV PATH="/app/bin:${PATH}"
RUN apt-get update \
    && apt-get install -y ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/src/bloodwing/bin /app/bin
COPY start.sh ./bin
RUN chmod +x ./bin/start.sh

EXPOSE 8080

WORKDIR /app/

CMD ["/app/bin/bloodwing"]
