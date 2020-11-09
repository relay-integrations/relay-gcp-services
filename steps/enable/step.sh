#!/bin/bash
set -euo pipefail

#
# Commands
#

GCLOUD="${GCLOUD:-gcloud}"
JQ="${JQ:-jq}"
NI="${NI:-ni}"

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

# This reads google.serviceAccountInfo and creates /workspace/creds/credentials.json
$NI gcp config -d "${WORKDIR}/creds"

[ -f "${WORKDIR}/creds/credentials.json" ] || usage "spec: Unable to find credentials"

declare -a AUTH_ARGS

ACCOUNT="$( $NI get -p '{ .account }' )"
[ -n "${ACCOUNT}" ] && AUTH_ARGS+=( "${ACCOUNT}" )

AUTH_ARGS+=( "--key-file=${WORKDIR}/creds/credentials.json" )

PROJECT="$( $NI get -p '{ .account }' )"
[ -z "${PROJECT}" ] && usage "spec: specify \`project\`"

AUTH_ARGS+=( "--project=${PROJECT}" )
$GCLOUD auth activate-service-account "${AUTH_ARGS[*]}"

declare -a SERVICES
SERVICES=( $( $NI get | $JQ -r 'try .services // empty | @sh' ) )
[[ ${#SERVICES[@]} -eq 0 ]] && usage "spec: specify \`services\`"

$GCLOUD services enable "${SERVICES[*]}"
