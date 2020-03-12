#!/bin/bash -xe

function alldone() {
    # slow down restarts if they're enabled
    sleep 1
}
trap alldone exit

ziti_root="${HOME}/.config/ziti"
pki_root="${ziti_root}/pki"
ca=ziti-tunnel-test

ziti pki create ca --pki-root="${pki_root}" --ca-file="${ca}"
ziti pki create key --pki-root="${pki_root}" --ca-name="${ca}" --key-file=test-controller
ziti pki create server --pki-root="${pki_root}" --ca-name="${ca}" \
     --key-file=test-controller --server-file=test-controller-server \
     --ip 127.0.0.1 --dns localhost --dns ziti-test-controller
ziti pki create client --pki-root="${pki_root}" --ca-name="${ca}" \
     --key-file=test-controller --client-file=test-controller-client

ctrl_root="${ziti_root}/controller"
mkdir -p "${ctrl_root}"
cat > "${ctrl_root}/ctrl.yaml" <<EOF
v: 3

db:                     ${ctrl_root}/db.db

identity:
  cert:                 ${pki_root}/${ca}/certs/test-controller-client.cert
  server_cert:          ${pki_root}/${ca}/certs/test-controller-server.cert
  key:                  ${pki_root}/${ca}/keys/test-controller.key
  ca:                   ${pki_root}/${ca}/certs/${ca}.cert

ctrl:
  listener:             tls:127.0.0.1:6262

mgmt:
  listener:             tls:127.0.0.1:10000

edge:
  api:
    listener: "0.0.0.0:1280"
    advertise: "ziti-test-controller:1280"

  enrollment:
    signingCert:
      cert: ${pki_root}/${ca}/certs/${ca}.cert
      key: ${pki_root}/${ca}/keys/${ca}.key
    edgeIdentity:
      durationMinutes: 5
    edgeRouter:
      durationMinutes: 5
EOF

ctrl_admin_user="admin"
ctrl_admin_pass="admin"
ziti-controller edge init "${ctrl_root}/ctrl.yaml" -u "${ctrl_admin_user}" -p "${ctrl_admin_pass}"

ziti-controller run "${ctrl_root}/ctrl.yaml"
