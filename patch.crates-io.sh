#!/usr/bin/env bash
#
# Patches the TRZ crates for developing against a local trezoa monorepo
#

trezoa_dir=$1
if [[ -z $trezoa_dir ]]; then
  echo "Usage: $0 <path-to-trezoa-monorepo>"
  exit 1
fi

workspace_crates=(
  Cargo.toml
)

if [[ ! -r "$trezoa_dir"/scripts/read-cargo-variable.sh ]]; then
  echo "$trezoa_dir is not a path to the trezoa monorepo"
  exit 1
fi

set -e

trezoa_dir=$(cd "$trezoa_dir" && pwd)
cd "$(dirname "$0")"

source "$trezoa_dir"/scripts/read-cargo-variable.sh
trezoa_ver=$(readCargoVariable version "$trezoa_dir"/sdk/Cargo.toml)

echo "Patching in $trezoa_ver from $trezoa_dir"
echo
for crate in "${workspace_crates[@]}"; do
  if grep -q '\[patch.crates-io\]' "$crate"; then
    echo "$crate is already patched"
  else
    cat >> "$crate" <<PATCH
[patch.crates-io]
trezoa-account-decoder = {path = "$trezoa_dir/account-decoder" }
trezoa-banks-client = { path = "$trezoa_dir/banks-client"}
trezoa-banks-server = { path = "$trezoa_dir/banks-server"}
trezoa-bpf-loader-program = { path = "$trezoa_dir/programs/bpf_loader" }
trezoa-clap-utils = {path = "$trezoa_dir/clap-utils" }
trezoa-cli-config = {path = "$trezoa_dir/cli-config" }
trezoa-cli-output = {path = "$trezoa_dir/cli-output" }
trezoa-client = { path = "$trezoa_dir/client"}
trezoa-core = { path = "$trezoa_dir/core"}
trezoa-logger = {path = "$trezoa_dir/logger" }
trezoa-notifier = { path = "$trezoa_dir/notifier" }
trezoa-remote-wallet = {path = "$trezoa_dir/remote-wallet" }
trezoa-program = { path = "$trezoa_dir/sdk/program" }
trezoa-program-test = { path = "$trezoa_dir/program-test" }
trezoa-runtime = { path = "$trezoa_dir/runtime" }
trezoa-sdk = { path = "$trezoa_dir/sdk" }
trezoa-stake-program = { path = "$trezoa_dir/programs/stake" }
trezoa-transaction-status = { path = "$trezoa_dir/transaction-status" }
trezoa-validator = { path = "$trezoa_dir/validator" }
trezoa-vote-program = { path = "$trezoa_dir/programs/vote" }
PATCH
  fi
done

DIRTY_OK=1 ./update-trezoa-dependencies.sh "$trezoa_ver"
