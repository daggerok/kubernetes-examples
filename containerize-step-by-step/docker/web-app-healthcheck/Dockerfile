FROM openjdk:8u131-jre-alpine
MAINTAINER Maksim Kostromin <daggerok@gmail.com>
RUN apk --no-cache add busybox-suid bash curl \
 && addgroup app-group \
 && adduser -h /home/app -s /bin/bash -D -u 1025 app app-group
USER app
WORKDIR /home/app
VOLUME ["/home/app"]
ARG REDIS_HOST="redis"
ENV SPRING_REDIS_HOST ${REDIS_HOST}
ENTRYPOINT bash ./app.jar
EXPOSE 8080
HEALTHCHECK --interval=15s --timeout=15s --retries=15 CMD curl -f http://127.0.0.1:8080/health || exit 1
COPY ./web-app/build/libs/*.jar ./app.jar
