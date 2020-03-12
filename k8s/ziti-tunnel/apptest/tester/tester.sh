#!/bin/bash
#
# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -xeo pipefail
shopt -s nullglob

#for test in /tests/*; do
#  testrunner -logtostderr "--test_spec=${test}"
#done

ctrl_admin_user=$(cat /run/secrets/netfoundry.io/controller-credentials/username)
ctrl_admin_pass=$(cat /run/secrets/netfoundry.io/controller-credentials/password)
ctrl_cas=/tmp/ctrl-cas.pem
timeout 60 sh -c "while ! curl -skL https://ziti-test-controller:1280/.well-known/est/cacerts; do sleep 1; done"
curl -skL https://ziti-test-controller:1280/.well-known/est/cacerts | base64 -d | openssl pkcs7 -inform DER -print_certs > "${ctrl_cas}"
ziti edge controller login https://ziti-test-controller:1280 -u "${ctrl_admin_user}" -p "${ctrl_admin_pass}" -c "${ctrl_cas}"

#nodes=$(kubectl get nodes -o json | jq '.items | length')
ziti edge controller list api-sessions
