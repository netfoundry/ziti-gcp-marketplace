#!/bin/bash -xeu

if kubectl get secret "${SECRET_NAME}" > /dev/null 2> kubectl-stderr; then
  echo "secret ${SECRET_NAME} already exists - not enrolling"
  exit 0
else
  code=$(sed -e 's/^.*(\(.*\)).*$/\1/' kubectl-stderr)
  case "${code}" in
  NotFound)
    # go on to create secret
    ;;
  Forbidden)
    echo "ERROR: please run this image with a service account that can 'get' the \"${SECRET_NAME}\" secret"
    exit 1
    ;;
  *)
    echo "ERROR: unable to test for secret."
    cat kubectl-stderr
    exit 1
    ;;
  esac
fi

echo "Enrolling ${NF_REG_NAME}"
# ZITI_ENROLLMENT_TOKEN is intentionally not quoted here so the shell will trim any leading/trailing whitespace
echo -n ${ZITI_ENROLLMENT_TOKEN} > "/tmp/${NF_REG_NAME}.jwt"
ziti-enroller -j "/tmp/${NF_REG_NAME}.jwt"
kubectl create -n "${NAMESPACE}" secret generic "${SECRET_NAME}" --from-file="/tmp/${NF_REG_NAME}.json"
kubectl patch secret "${SECRET_NAME}" -p '{"metadata":{"labels":{"app.kubernetes.io/name":"'${NF_REG_NAME}'"}}}'