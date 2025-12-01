FROM golang:1.23-alpine AS builder
RUN apk add --no-cache git
WORKDIR /app
RUN cat <<EOF > main.go
package main
import "net/http"
func main() {
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        w.Write([]byte("<h1 style='font-family:Arial;text-align:center;margin-top:100px'>Hello World from Fargate!</h1>"))
    })
    http.ListenAndServe(":8080", nil)
}
EOF
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o hello-server main.go

FROM scratch
COPY --from=builder /app/hello-server /hello-server
EXPOSE 8080
ENTRYPOINT ["/hello-server"]
