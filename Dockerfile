#####################################
# All rights reserved.              #
# started from Zero                 #
# Docker owned doob187              #
# Docker Maintainer MrDoob          #
#####################################
FROM alpine
LABEL maintainer=doob187
LABEL org.opencontainers.image.source https://github.com/doob187/docker-remote/

RUN \
  echo "**** install build packages ****" && \
  apk --quiet --no-cache --no-progress update && \
  apk --quiet --no-cache --no-progress upgrade

RUN \
  echo "**** install build packages ****" && \
  apk --quiet --no-cache --no-progress add bash shadow musl findutils coreutils && \
  apk del --quiet --clean-protected --no-progress && \
  rm -f /var/cache/apk/*

COPY root/ /
ENTRYPOINT [ "/bin/sh", "/start.sh" ]
