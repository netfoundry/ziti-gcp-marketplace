FROM gcr.io/cloud-marketplace-tools/testrunner:0.1.2
ARG ZITI_VERSION=0.9.0-44

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    gettext \
    jq \
    uuid-runtime \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q -O /bin/kubectl \
    https://storage.googleapis.com/kubernetes-release/release/v1.12.0/bin/linux/amd64/kubectl \
      && chmod 755 /bin/kubectl
RUN curl -fLSs \
      -O "https://netfoundry.jfrog.io/netfoundry/ziti-release/ziti/amd64/linux/${ZITI_VERSION}/ziti.tar.gz" && \
  tar -C /bin -xzf "ziti.tar.gz" && \
  chmod +x /bin/ziti

COPY tests/basic-suite.yaml /tests/basic-suite.yaml
COPY tester.sh /tester.sh

WORKDIR /
ENTRYPOINT ["/tester.sh"]
