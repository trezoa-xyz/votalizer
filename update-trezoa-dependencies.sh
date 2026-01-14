#!/usr/bin/env bash
#
# Updates the trezoa version in all the SPL crates
#

here="$(dirname "$0")"

trezoa_ver=$1
if [[ -z $trezoa_ver ]]; then
  echo "Usage: $0 <new-trezoa-version>"
  exit 1
fi

if [[ $trezoa_ver =~ ^v ]]; then
  # Drop `v` from v1.2.3...
  trezoa_ver=${trezoa_ver:1}
fi

cd "$here"

echo "Updating Trezoa version to $trezoa_ver in $PWD"

if ! git diff --quiet && [[ -z $DIRTY_OK ]]; then
  echo "Error: dirty tree"
  exit 1
fi

declare tomls=()
while IFS='' read -r line; do tomls+=("$line"); done < <(find . -name Cargo.toml)

crates=(
  trezoa-account-decoder
  trezoa-banks-client
  trezoa-banks-server
  trezoa-bpf-loader-program
  trezoa-clap-utils
  trezoa-cli-config
  trezoa-cli-output
  trezoa-client
  trezoa-core
  trezoa-logger
  trezoa-notifier
  trezoa-program
  trezoa-program-test
  trezoa-remote-wallet
  trezoa-runtime
  trezoa-sdk
  trezoa-stake-program
  trezoa-transaction-status
  trezoa-validator
  trezoa-vote-program
)

set -x
for crate in "${crates[@]}"; do
  sed -i -e "s#\(${crate} = \"\).*\(\"\)#\1=$trezoa_ver\2#g" "${tomls[@]}"
done

