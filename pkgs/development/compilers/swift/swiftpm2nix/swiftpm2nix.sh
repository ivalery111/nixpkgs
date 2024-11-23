#!/usr/bin/env bash

# Generates a Nix expression to fetch swiftpm dependencies, and a
# configurePhase snippet to prepare a working directory for swift-build.

set -eu -o pipefail
shopt -s lastpipe

stateFile=".build/workspace-state.json"
if [[ ! -f "$stateFile" ]]; then
  echo >&2 "Missing $stateFile. Run 'swift package resolve' first."
  exit 1
fi

stateVersion="$(jq .version $stateFile)"
if [[ $stateVersion -lt 5 || $stateVersion -gt 6 ]]; then
  echo >&2 "Unsupported $stateFile version"
  exit 1
fi

# Iterate dependencies and prefetch.
hashes=""
jq -r '.object.dependencies[] | "\(.subpath) \(.packageRef.location) \(.state.checkoutState.revision)"' $stateFile \
| while read -r name url rev; do
  echo >&2 "-- Fetching $name"
  hash="$(nurl "$url" "$rev" --json --submodules=true --fetcher=fetchgit | jq -r .args.hash)"
hashes+="
    \"$name\" = \"$hash\";"
  echo >&2
done
hashes+=$'\n'"  "

# Generate output.
mkdir -p nix
# Copy the workspace state, but clear 'artifacts'.
jq '.object.artifacts = []' < $stateFile > nix/workspace-state.json
# Build an expression for fetching sources, and preparing the working directory.
cat > nix/default.nix << EOF
# This file was generated by swiftpm2nix.
{
  workspaceStateFile = ./workspace-state.json;
  hashes = {$hashes};
}
EOF
echo >&2 "-- Generated ./nix"
