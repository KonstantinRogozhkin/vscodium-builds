#!/usr/bin/env bash
# Fast build script with dependency caching
# shellcheck disable=SC1091,SC2129

### Windows
# to run with Bash: "C:\Program Files\Git\bin\bash.exe" ./dev/build-fast.sh
###

export APP_NAME="Neira"
export ASSETS_REPOSITORY="Neira/neira"
export BINARY_NAME="neira"
export CI_BUILD="no"
export GH_REPO_PATH="Neira/neira"
export ORG_NAME="Neira"
export SHOULD_BUILD="yes"
export SKIP_ASSETS="yes"
export SKIP_BUILD="no"
export SKIP_SOURCE="no"
export VSCODE_LATEST="no"
export VSCODE_QUALITY="stable"
export VSCODE_SKIP_NODE_VERSION_CHECK="yes"
# Path to Neira Agent extension VSIX file
export NEIRA_AGENT_EXTENSION_PATH="/Users/konstantin/Projects/continue/extensions/vscode/neira-agent-1.1.67.vsix"

# Fast build options
export USE_CACHE="yes"
export SKIP_DEPENDENCY_INSTALL="no"

while getopts ":ilopscf" opt; do
  case "$opt" in
    i)
      export ASSETS_REPOSITORY="VSCodium/vscodium-insiders"
      export BINARY_NAME="codium-insiders"
      export VSCODE_QUALITY="insider"
      ;;
    l)
      export VSCODE_LATEST="yes"
      ;;
    o)
      export SKIP_BUILD="yes"
      ;;
    p)
      export SKIP_ASSETS="no"
      ;;
    s)
      export SKIP_SOURCE="yes"
      ;;
    c)
      export USE_CACHE="no"
      ;;
    f)
      export SKIP_DEPENDENCY_INSTALL="yes"
      ;;
    *)
      ;;
  esac
done

case "${OSTYPE}" in
  darwin*)
    export OS_NAME="osx"
    ;;
  linux*)
    export OS_NAME="linux"
    ;;
  msys)
    export OS_NAME="windows"
    ;;
  *)
    echo "Unknown OS"
    exit 1
    ;;
esac

# Determine architecture
if [[ "${OS_NAME}" == "osx" ]]; then
  ARCH=$(uname -m)
  if [[ "${ARCH}" == "arm64" ]]; then
    export VSCODE_ARCH="arm64"
  else
    export VSCODE_ARCH="x64"
  fi
elif [[ "${OS_NAME}" == "linux" ]]; then
  ARCH=$(uname -m)
  if [[ "${ARCH}" == "x86_64" ]]; then
    export VSCODE_ARCH="x64"
  elif [[ "${ARCH}" == "aarch64" ]] || [[ "${ARCH}" == "arm64" ]]; then
    export VSCODE_ARCH="arm64"
  elif [[ "${ARCH}" == "armv7l" ]]; then
    export VSCODE_ARCH="armhf"
  else
    export VSCODE_ARCH="x64"
  fi
elif [[ "${OS_NAME}" == "windows" ]]; then
  export VSCODE_ARCH="x64"
fi

echo "🚀 Starting fast build for ${APP_NAME} (${OS_NAME}-${VSCODE_ARCH})"
echo "📋 Build options:"
echo "   USE_CACHE: ${USE_CACHE}"
echo "   SKIP_DEPENDENCY_INSTALL: ${SKIP_DEPENDENCY_INSTALL}"

# Restore dependencies from cache if available
if [[ "${USE_CACHE}" == "yes" && "${SKIP_DEPENDENCY_INSTALL}" == "no" ]]; then
  echo "🔄 Attempting to restore dependencies from cache..."
  ./scripts/cache-dependencies.sh restore || echo "⚠️  Cache restore failed, will install fresh dependencies"
fi

# Run the main build
echo "🔨 Running main build process..."
. build.sh

# Cache dependencies after successful build
if [[ "${USE_CACHE}" == "yes" && "${SHOULD_BUILD}" == "yes" ]]; then
  echo "💾 Caching dependencies for future builds..."
  ./scripts/cache-dependencies.sh cache || echo "⚠️  Failed to cache dependencies"
fi

echo "✅ Fast build completed!"
