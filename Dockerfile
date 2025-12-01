FROM public.ecr.aws/docker/library/golang:1.23-alpine AS builder

RUN apk add --no-cache git ca-certificates

WORKDIR /app

RUN cat <<'EOF' > main.go
package main

import (
    "fmt"
    "net/http"
)

func main() {
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintf(w, `
<!DOCTYPE html>
<html>
<head><title>Hello World</title></head>
<body style="font-family: system-ui, sans-serif; text-align: center; margin-top: 15vh;">
  <h1 style="font-size: 3rem; color: #0d6efd;">Hello World from Fargate!</h1>
  <p>Built with Go + public.ecr.aws + CodeBuild</p>
  <p>Port: 8080</p>
</body>
</html>`)
    })

    fmt.Println("Server starting on :8080...")
    http.ListenAndServe(":8080", nil)
}
EOF

RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o hello-server main.go

FROM public.ecr.aws/docker/library/alpine:3.20

RUN apk add --no-cache ca-certificates

COPY --from=builder /app/hello-server /hello-server

EXPOSE 8080

USER 10001

ENTRYPOINT ["/hello-server"]
