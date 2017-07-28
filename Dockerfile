FROM hashicorp/consul-template:apline-0.19.0

ADD start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

VOLUME /consul-template/output

ENTRYPOINT ["start.sh"]
