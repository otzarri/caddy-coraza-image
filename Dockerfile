# Ingress image for podchestra

ARG CADDY_VER

FROM docker.io/caddy:${CADDY_VER}-builder AS builder
ARG CADDY_VER
ARG CRS_VER

RUN mkdir -p /build && cd /build &&\
    go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest &&\
    xcaddy build v${CADDY_VER} --with github.com/corazawaf/coraza-caddy &&\
    wget https://raw.githubusercontent.com/corazawaf/coraza/v2/master/coraza.conf-recommended && \
    wget https://github.com/coreruleset/coreruleset/archive/refs/tags/v${CRS_VER}.tar.gz -O - | tar -xzvf - &&\
    mv coreruleset-${CRS_VER} crs


FROM docker.io/caddy:${CADDY_VER}

RUN sed -e 's,:80 {,:80 {\n        coraza_waf {\n                include /etc/coraza.conf\n                include /usr/local/share/coreruleset/crs-setup.conf\n                include /usr/local/share/coreruleset/rules/*.conf\n        }\n,g' /etc/caddy/Caddyfile
COPY --from=builder /build/caddy /usr/bin/
COPY --from=builder /build/coraza.conf-recommended /etc/coraza.conf
COPY --from=builder /build/crs/crs-setup.conf.example /usr/local/share/coreruleset/crs-setup.conf
COPY --from=builder /build/crs/rules /usr/local/share/coreruleset/

WORKDIR /srv
RUN rm -rf /tmp/*
CMD ["/usr/bin/caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile", "--watch"]
