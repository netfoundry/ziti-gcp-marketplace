ARG IMAGE_ZITI_TUNNEL
FROM $IMAGE_ZITI_TUNNEL as download
# This build stage grabs artifacts that are copied into the final image.
# It uses the same base as the final image to maximize docker cache hits.

ARG ZITI_VERSION="0.5.8-2554"

WORKDIR /tmp

RUN apt-get -q update && apt-get -q install -y --no-install-recommends curl ca-certificates
RUN curl -fLSs \
      -O "https://netfoundry.jfrog.io/netfoundry/ziti-release/ziti-controller/amd64/linux/${ZITI_VERSION}/ziti-controller.tar.gz" \
      -O "https://netfoundry.jfrog.io/netfoundry/ziti-release/ziti/amd64/linux/${ZITI_VERSION}/ziti.tar.gz" && \
  tar -xzf "ziti-controller.tar.gz" && \
  tar -xzf "ziti.tar.gz" && \
  chmod +x ziti-controller ziti
RUN curl -fLSs -O https://storage.googleapis.com/kubernetes-release/release/v1.17.0/bin/linux/amd64/kubectl && \
    chmod +x kubectl

################
#
#  Main Image
#
################

FROM $IMAGE_ZITI_TUNNEL

COPY --from=download /tmp/ziti-controller /usr/local/bin
COPY --from=download /tmp/ziti /usr/local/bin
COPY --from=download /tmp/kubectl /usr/local/bin
COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "run" ]