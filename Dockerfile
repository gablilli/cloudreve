FROM golang:1.25-alpine AS builder
ARG VERSION=4.0.0
ARG COMMIT_SHA=unknown
RUN apk add --no-cache git bash
WORKDIR /app
COPY . .
RUN go build -a -o cloudreve \
      -ldflags "-s -w \
        -X 'github.com/cloudreve/Cloudreve/v4/application/constants.BackendVersion=${VERSION}' \
        -X 'github.com/cloudreve/Cloudreve/v4/application/constants.LastCommit=${COMMIT_SHA}'"

FROM alpine:latest
WORKDIR /cloudreve
RUN apk update \
    && apk add --no-cache tzdata vips-tools ffmpeg libreoffice aria2 supervisor font-noto font-noto-cjk libheif libraw-tools ca-certificates \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && mkdir -p ./data/temp/aria2 \
    && chmod -R 766 ./data/temp/aria2
ENV CR_ENABLE_ARIA2=1 \
    CR_SETTING_DEFAULT_thumb_ffmpeg_enabled=1 \
    CR_SETTING_DEFAULT_thumb_vips_enabled=1 \
    CR_SETTING_DEFAULT_thumb_libreoffice_enabled=1 \
    CR_SETTING_DEFAULT_media_meta_ffprobe=1 \
    CR_SETTING_DEFAULT_thumb_libraw_enabled=1
COPY .build/aria2.supervisor.conf .build/entrypoint.sh ./
COPY --from=builder /app/cloudreve ./cloudreve
RUN chmod +x ./cloudreve \
    && chmod +x ./entrypoint.sh \
    && sed -i 's/\r//' ./entrypoint.sh
EXPOSE 5212 443 6888 6888/udp
VOLUME ["/cloudreve/data"]
ENTRYPOINT ["sh", "./entrypoint.sh"]
