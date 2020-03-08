ARG IMAGE_ZITI_TUNNEL
FROM $IMAGE_ZITI_TUNNEL

RUN apt update && apt-get install -y curl
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/v1.17.0/bin/linux/amd64/kubectl -o /bin/kubectl && \
    chmod +x /bin/kubectl
COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]
