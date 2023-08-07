#!/bin/bash

set -e

# Run install command
if [[ -n "${INSTALL_COMMAND}" ]]
then
  ${INSTALL_COMMAND}
elif [[ -f yarn.lock ]]
then
  yarn
else
  npm i
fi

# Run build command
if [[ -n "${BUILD_COMMAND}" ]]
then
  ${BUILD_COMMAND}
else
  npm run build
fi

# Deploy to Netlify
export NETLIFY_SITE_ID="${NETLIFY_SITE_ID}"
export NETLIFY_AUTH_TOKEN="${NETLIFY_AUTH_TOKEN}"

COMMAND="netlify deploy --dir=${BUILD_DIRECTORY} --functions=${FUNCTIONS_DIRECTORY} --message=\"${NETLIFY_DEPLOY_MESSAGE}\""

if [[ "${NETLIFY_DEPLOY_TO_PROD}" == "true" ]]
then
  COMMAND+=" --prod"
elif [[ -n "${DEPLOY_ALIAS}" ]]
then
  COMMAND+=" --alias ${DEPLOY_ALIAS}"
fi

OUTPUT=$(sh -c "$COMMAND")
URL_REGEX='(http|https)://[a-zA-Z0-9./?=_-]*'

# Set outputs
function getRandomString () {
  echo $(dd if=/dev/urandom bs=15 count=1 status=none | base64)
}

function setOutput () {
  local key=$1
  local value=$2
  local EOF="$(getRandomString)"

  echo "${key}<<$EOF" >> "$GITHUB_OUTPUT"
  echo "${value}" >> "$GITHUB_OUTPUT"
  echo "$EOF" >> "$GITHUB_OUTPUT"
}

NETLIFY_OUTPUT=$(echo "$OUTPUT")
NETLIFY_PREVIEW_URL=$(echo "$OUTPUT" | grep -Eo "Unique (draft|deploy) URL: +$URL_REGEX" | grep -Eo $URL_REGEX)
NETLIFY_LOGS_URL=$(echo "$OUTPUT" | grep -Eo "Build logs: +$URL_REGEX" | grep -Eo $URL_REGEX)
NETLIFY_LIVE_URL=$(echo "$OUTPUT" | grep -Eo "Website URL: +$URL_REGEX" | grep -Eo $URL_REGEX)

setOutput "NETLIFY_OUTPUT" "$OUTPUT"
setOutput "NETLIFY_PREVIEW_URL" "$NETLIFY_PREVIEW_URL"
setOutput "NETLIFY_LOGS_URL" "$NETLIFY_LOGS_URL"
setOutput "NETLIFY_LIVE_URL" "$NETLIFY_LIVE_URL"
