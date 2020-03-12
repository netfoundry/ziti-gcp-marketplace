ARG IMAGE_ZITI_TUNNEL
FROM $IMAGE_ZITI_TUNNEL

ARG ZITI_VERSION

RUN apt update && apt-get install -y curl
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/v1.17.0/bin/linux/amd64/kubectl -o /bin/kubectl && \
    chmod +x /bin/kubectl
RUN curl -fLSs \
      -O "https://netfoundry.jfrog.io/netfoundry/ziti-release/ziti/amd64/linux/${ZITI_VERSION}/ziti.tar.gz" && \
  tar -C /bin -xzf "ziti.tar.gz" && \
  chmod +x /bin/ziti

COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]
