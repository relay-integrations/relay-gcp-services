FROM google/cloud-sdk:alpine
RUN apk --no-cache add bash ca-certificates curl git jq openssh && update-ca-certificates
COPY "./step.sh" "/entrypoint.sh"
ENTRYPOINT []
CMD ["/bin/bash", "/entrypoint.sh"]

LABEL "org.opencontainers.image.title"="Enables a GCP service"
LABEL "org.opencontainers.image.description"="This step enables a GCP service via the Google Cloud cli."
LABEL "com.puppet.nebula.sdk.version"="v1"
