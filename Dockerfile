#####################################
# All rights reserved.              #
# started from Zero                 #
# Docker owned from sudobox.io      #
# Docker Maintainer MrDoob          #
#####################################
FROM alpine
LABEL maintainer=sudobox.io
LABEL org.opencontainers.image.source https://github.com/doob187/docker-remote/

RUN \
  echo "**** install build packages ****" && \
  apk --quiet --no-cache --no-progress update && \
  apk --quiet --no-cache --no-progress upgrade

RUN \
  echo "**** install build packages ****" && \
  apk --quiet --no-cache --no-progress add bash shadow musl findutils coreutils && \
  rm -f /var/cache/apk/*

RUN \
  echo "**** purge build packages cache ****" && \
  apk --quiet --no-cache --no-progress cache clean && \
  apk --quiet --clean-protected --no-progress del

#COPY root/ /
COPY start.sh /
#RUN chmod 777 start.sh
#RUN chown -R 1000:1000 start.sh
ENTRYPOINT [ "/bin/sh", "/start.sh" ]
