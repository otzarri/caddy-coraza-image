#!/bin/bash

gh_rel_latest() {
    repo="${1}"
    echo $(curl -s https://api.github.com/repos/${repo}/releases/latest | jq -r .tag_name)
}

if [[ -z "${CADDY_VER}" ]]; then
    printf "Variable CADDY_VER unset."
    CADDY_VER=$(gh_rel_latest caddyserver/caddy | sed 's/^v//g')
    echo " Using latest version: ${CADDY_VER}."
fi

if [[ -z "${CRS_VER}" ]]; then
    printf "Variable CRS_VER unset."
    CRS_VER=$(gh_rel_latest coreruleset/coreruleset | sed 's/^v//g')
    echo " Using latest version: ${CRS_VER}."
fi

IMG_REG="localhost"
IMG_NAME="${IMG_REG}/otzarri/caddy-corazawaf"
IMG_TAG="${CADDY_VER}-crs-${CRS_VER}"

echo ""
echo "Building OCI image"
echo "Image name: ${IMG_NAME}"
echo "Image tag: ${IMG_TAG}"
echo ""

podman build \
    -t ${IMG_NAME}:${IMG_TAG} \
    --build-arg CADDY_VER=${CADDY_VER} \
    --build-arg CRS_VER=${CRS_VER} \
    .
