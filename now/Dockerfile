FROM node:9-alpine

MAINTAINER Dhruv Dang <hi@dhruv.io>

RUN npm install -g now --unsafe-perm=true \
 && apk update \
 && apk add bash \
 && rm -rf /var/cache/apk/*

WORKDIR /data 
VOLUME /data

CMD ["now"]
