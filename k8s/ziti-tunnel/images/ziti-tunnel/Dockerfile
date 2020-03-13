ARG ZITI_VERSION
FROM netfoundry/ziti-tunnel:${ZITI_VERSION} AS download

WORKDIR /tmp
COPY ziti-LICENSE /tmp
RUN apt-get update && apt-get install -y wget
RUN wget https://raw.githubusercontent.com/netfoundry/ziti-cmd/master/LICENSE -O - >> /tmp/ziti-LICENSE

FROM netfoundry/ziti-tunnel:${ZITI_VERSION}

RUN mkdir /LICENSES
COPY --from=download /tmp/ziti-LICENSE /LICENSES