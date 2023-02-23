FROM alpine:latest AS build

RUN apk add --no-cache go gcc g++ git make build-base

WORKDIR /app
#ENV GOPATH /app
COPY . /app

RUN go mod download

RUN CGO_ENABLED=1 GOOS=linux go build


FROM alpine:latest
RUN apk --update add ca-certificates \
                     mailcap \
                     curl libc6-compat g++ libstdc++ libgcc

HEALTHCHECK --start-period=2s --interval=5s --timeout=3s \
  CMD curl -f http://localhost/health || exit 1

VOLUME /srv

COPY --from=build /app/filebrowser /filebrowser

COPY docker_config.json /.filebrowser.json
#COPY filebrowser /filebrowser

ENTRYPOINT [ "/filebrowser" ]