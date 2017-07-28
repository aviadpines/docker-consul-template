FROM hashicorp/consul-template:0.19.0-alpine

RUN apk --update --no-cache add ca-certificates openssl

ADD start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

VOLUME /consul-template/output

ENTRYPOINT ["start.sh"]
