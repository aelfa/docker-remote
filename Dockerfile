#####################################
# All rights reserved.              #
# started from Zero                 #
# Docker owned from sudobox.io      #
# Docker Maintainer MrDoob          #
#####################################

FROM lsiobase/alpine:3.13
LABEL maintainer=sudobox.io
LABEL org.opencontainers.image.source https://github.com/doob187/docker-remote/

RUN \
  echo "**** install build packages ****" && \
  apk --quiet --no-cache --no-progress update && \
  apk --quiet --no-cache --no-progress upgrade

RUN \
  echo "**** install build packages ****" && \
  apk --quiet --no-cache --no-progress add shadow musl \
  bash bc rsync rclone findutils coreutils && \
  rm -rf /var/cache/apk/*

COPY ./start.sh /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/start.sh"]
