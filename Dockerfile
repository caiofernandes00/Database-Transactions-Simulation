# Build stage
FROM golang:1.19.2-alpine3.16 AS builder
WORKDIR /app
COPY . .
RUN go build -o main src/main.go
RUN apk add curl tar
RUN curl -L https://github.com/golang-migrate/migrate/releases/download/v4.15.2/migrate.linux-amd64.tar.gz | tar xvz

# Run stage
FROM alpine:3.16
WORKDIR /app
COPY --from=builder /app/main .
COPY --from=builder /app/migrate ./migrate
COPY app.env .
COPY start.sh .
COPY wait-for.sh .
RUN chown 1000:1000 start.sh
COPY src/infrastructure/db/migrations ./migrations

EXPOSE 8080
ENTRYPOINT [ "/app/start.sh" ]
CMD ["/app/main"]