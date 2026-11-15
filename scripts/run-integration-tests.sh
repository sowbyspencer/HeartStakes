#!/usr/bin/env bash
set -euo pipefail

MC_VERSION="${1:-1.21.7}"
TEST_NAME="${2:-}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVER_DIR="${ROOT_DIR}/ci-server-${MC_VERSION}"
FABRIC_API_VERSION="0.129.0+1.21.7"
[[ "${MC_VERSION}" == "1.21.8" ]] && FABRIC_API_VERSION="0.136.1+1.21.8"
PACKTEST_VERSION="2.2.0"

command -v curl >/dev/null || { echo "curl is required" >&2; exit 1; }
command -v jq >/dev/null || { echo "jq is required" >&2; exit 1; }
java -version >/dev/null 2>&1 || { echo "Java 21 is required" >&2; exit 1; }

mkdir -p "${SERVER_DIR}/mods" "${SERVER_DIR}/world/datapacks"

loader_version="$(curl --fail --silent --show-error \
  "https://meta.fabricmc.net/v2/versions/loader/${MC_VERSION}" \
  | jq -r 'map(select(.loader.stable == true))[0].loader.version')"
installer_version="$(curl --fail --silent --show-error \
  'https://meta.fabricmc.net/v2/versions/installer' \
  | jq -r 'map(select(.stable == true))[0].version')"

server_url="https://meta.fabricmc.net/v2/versions/loader/${MC_VERSION}/${loader_version}/${installer_version}/server/jar"
curl --fail --location --silent --show-error "${server_url}" -o "${SERVER_DIR}/server.jar"

fabric_api_url="$(curl --fail --silent --show-error \
  'https://api.modrinth.com/v2/project/P7dR8mSH/version' \
  | jq -r --arg version "${FABRIC_API_VERSION}" \
    'map(select(.version_number == $version))[0].files | map(select(.primary == true))[0].url')"
packtest_url="$(curl --fail --silent --show-error \
  'https://api.modrinth.com/v2/project/XsKUhp45/version' \
  | jq -r --arg version "${PACKTEST_VERSION}" \
    'map(select(.version_number == $version))[0].files | map(select(.primary == true))[0].url')"

curl --fail --location --silent --show-error "${fabric_api_url}" -o "${SERVER_DIR}/mods/fabric-api.jar"
curl --fail --location --silent --show-error "${packtest_url}" -o "${SERVER_DIR}/mods/packtest.jar"

rm -rf "${SERVER_DIR}/world/datapacks/HeartStakes" "${SERVER_DIR}/world/datapacks/heartstakes-tests"
cp -r "${ROOT_DIR}/HeartStakes" "${SERVER_DIR}/world/datapacks/HeartStakes"
cp -r "${ROOT_DIR}/tests/heartstakes-testpack" "${SERVER_DIR}/world/datapacks/heartstakes-tests"
if [[ -n "${TEST_NAME}" ]]; then
  find "${SERVER_DIR}/world/datapacks/heartstakes-tests/data/heartstakes/test" -name '*.mcfunction' ! -name "${TEST_NAME}.mcfunction" -delete
fi

cd "${SERVER_DIR}"
timeout --foreground --signal=TERM 90s java -Xmx2G \
  -Dpacktest.auto \
  -Dpacktest.auto.annotations \
  -jar server.jar nogui
