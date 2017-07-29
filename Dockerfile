FROM hashicorp/consul-template:0.19.0-alpine

RUN apk --update --no-cache add ca-certificates openssl tar

ADD start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

RUN mkdir -p /consul-template/output && \
    chown -R consul-template:consul-template /consul-template

VOLUME /consul-template/output

ENTRYPOINT ["start.sh"]
