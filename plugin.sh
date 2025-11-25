#!/usr/bin/env bash

WORKDIR=$(mktemp -d)
cat <&0 > "${WORKDIR}/result.yaml"

echo "---" >> "${WORKDIR}/result.yaml"

if [ -z "${CI}" ]; then
  BRANCH=$(git rev-parse --abbrev-ref HEAD)
  SHA=$(git rev-parse --short HEAD)
  STATUS=$(test -z `git status --porcelain` && echo clean || echo dirty)
  kubectl create configmap --dry-run=client \
    "${1}-apply-log" -o yaml \
    --from-literal author="${USER}" \
    --from-literal branch="${BRANCH}" \
    --from-literal sha="${SHA}" \
    --from-literal status="${STATUS}" \
    | yq 'del(.metadata.creationTimestamp)' \
    >> "${WORKDIR}/result.yaml"
else
  kubectl create configmap --dry-run=client \
    "${1}-apply-log" -o yaml \
    --from-literal author="${USER}" \
    --from-literal ci="true" \
    | yq 'del(.metadata.creationTimestamp)' \
    >> "${WORKDIR}/result.yaml"
fi

cat "${WORKDIR}/result.yaml"
rm -rf "${WORKDIR}/result.yaml"
