#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Bootstrap Flux (see https://docs.fluxcd.io/en/1.18.0/tutorials/get-started-helm.html).
kubectl apply --filename https://raw.githubusercontent.com/fluxcd/helm-operator/master/deploy/crds.yaml
kubectl create namespace flux
helm install --namespace flux --repo https://charts.fluxcd.io --set git.url=https://github.com/joshuaspence/helm-operator-demo.git --set git.branch=v1.0.2 --set git.readonly=true --set git.path=deployments --wait flux flux >/dev/null
helm install --namespace flux --repo https://charts.fluxcd.io --set helm.versions=v3 --version 1.0.2 --wait helm-operator helm-operator >/dev/null

# Force a sync.
fluxctl --k8s-fwd-ns flux sync

# Check results.
kubectl -n flux describe helmrelease/helm-operator
