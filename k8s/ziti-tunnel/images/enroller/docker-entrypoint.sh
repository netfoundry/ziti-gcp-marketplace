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

if [ -d /run/secrets/netfoundry.io/controller-credentials ]; then
  # we are running with the test configuration, and so we create the identity (and JWT) here.
  ctrl_admin_user=$(cat /run/secrets/netfoundry.io/controller-credentials/username)
  ctrl_admin_pass=$(cat /run/secrets/netfoundry.io/controller-credentials/password)
  ctrl_cas=/tmp/ctrl-cas.pem
  timeout 60 sh -c "while ! curl -skL https://ziti-test-controller:1280/.well-known/est/cacerts; do sleep 1; done"
  curl -skL https://ziti-test-controller:1280/.well-known/est/cacerts | base64 -d | openssl pkcs7 -inform DER -print_certs > "${ctrl_cas}"
  ziti edge controller login https://ziti-test-controller:1280 -u "${ctrl_admin_user}" -p "${ctrl_admin_pass}" -c "${ctrl_cas}"
  ziti edge controller create identity device "${NF_REG_NAME}" -o generated.jwt
  ZITI_ENROLLMENT_TOKEN=$(cat generated.jwt)
fi

echo "Enrolling ${NF_REG_NAME}"
# ZITI_ENROLLMENT_TOKEN is intentionally not quoted here so the shell will trim any leading/trailing whitespace
echo -n ${ZITI_ENROLLMENT_TOKEN} > "/tmp/${NF_REG_NAME}.jwt"
ziti-enroller -j "/tmp/${NF_REG_NAME}.jwt"

json=$(cat "/tmp/${NF_REG_NAME}.json")
kubectl create -n "${NAMESPACE}" secret generic "${SECRET_NAME}" --from-file="/tmp/${NF_REG_NAME}.json"
kubectl label secret "${SECRET_NAME}" "app.kubernetes.io/name=${NF_REG_NAME}"
