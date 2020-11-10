#!/bin/bash
set -euo pipefail

#
# Commands
#

GCLOUD="${GCLOUD:-gcloud}"
JQ="${JQ:-jq}"
NI="${NI:-ni}"
RM_F="${RM_F:-rm -f}"

#
# Variables
#

WORKDIR="${WORKDIR:-/workspace}"

log() {
  echo "[$( date -Iseconds )] $*"
}

err() {
  log "error: $*" >&2
  exit 2
}

usage() {
  echo "usage: $*" >&2
  exit 1
}

#
# Setup
#

# This reads google.serviceAccountInfo and creates /workspace/creds/credentials.json
$NI gcp config -d "${WORKDIR}/creds"

[ -f "${WORKDIR}/creds/credentials.json" ] || usage "spec: specify a gcp connection as \`google: \!Connection ...\` in your spec"

PROJECT="$( $NI get -p '{ .project }' )"
[ -z "${PROJECT}" ] && PROJECT="$(jq -r .project_id "${WORKDIR}/creds/credentials.json")"
$GCLOUD config set project "${PROJECT}"

ACCOUNT="$( $NI get -p '{ .account }' )"
[ -n "${ACCOUNT}" ] && $GCLOUD config set account "${ACCOUNT}"

$GCLOUD config set core/disable_usage_reporting true
$GCLOUD config set component_manager/disable_update_check true

$GCLOUD auth activate-service-account --key-file="${WORKDIR}/creds/credentials.json"

$RM_F "${WORKDIR}/creds/credentials.json"

#
# Main
#

declare -a SERVICES
SERVICES=( $( $NI get | $JQ -r 'try .services // empty | @sh' ) )
[[ ${#SERVICES[@]} -eq 0 ]] && usage "spec: specify \`services\`, the list of services to enable"

$GCLOUD services enable "${SERVICES[@]}"

