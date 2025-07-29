#!/usr/bin/env bash
# shellcheck disable=SC1091

set -ex

. version.sh

# Function to install extensions from configuration file
install_extensions() {
  local extensions_config="../extensions.config"
  local binary_path="../VSCode-darwin-${VSCODE_ARCH}/${APP_NAME}.app/Contents/Resources/app/bin/${BINARY_NAME}"
  
  if [[ ! -f "${extensions_config}" ]]; then
    echo "Warning: Extensions configuration file not found at ${extensions_config}"
    return 0
  fi
  
  echo "Installing extensions from configuration..."
  
  while IFS='|' read -r extension_id vsix_path description || [[ -n "$extension_id" ]]; do
    # Skip comments and empty lines
    if [[ "$extension_id" =~ ^#.*$ ]] || [[ -z "$extension_id" ]]; then
      continue
    fi
    
    echo "Installing: $description ($extension_id)"
    
    if [[ -n "$vsix_path" && -f "$vsix_path" ]]; then
      # Install from local VSIX file
      echo "  Installing from VSIX: $vsix_path"
      "$binary_path" --install-extension "$vsix_path" || echo "  Failed to install $extension_id from VSIX"
    else
      # Install from marketplace
      echo "  Installing from marketplace: $extension_id"
      "$binary_path" --install-extension "$extension_id" || echo "  Failed to install $extension_id from marketplace"
    fi
  done < "$extensions_config"
  
  echo "Extension installation completed."
}

if [[ "${SHOULD_BUILD}" == "yes" ]]; then
  echo "MS_COMMIT=\"${MS_COMMIT}\""

  . prepare_vscode.sh

  cd vscode || { echo "'vscode' dir not found"; exit 1; }

  export NODE_OPTIONS="--max-old-space-size=8192"

  npm run monaco-compile-check
  npm run valid-layers-check

  npm run gulp compile-build-without-mangling
  npm run gulp compile-extension-media
  npm run gulp compile-extensions-build
  npm run gulp minify-vscode

  if [[ "${OS_NAME}" == "osx" ]]; then
    # generate Group Policy definitions
    node build/lib/policies darwin

    npm run gulp "vscode-darwin-${VSCODE_ARCH}-min-ci"

    find "../VSCode-darwin-${VSCODE_ARCH}" -print0 | xargs -0 touch -c

    # Copy locales for internationalization
    echo "Copying locales..."
    cp -r ../locales "../VSCode-darwin-${VSCODE_ARCH}/${APP_NAME}.app/Contents/Resources/"
    
    # Install extensions from configuration file
    install_extensions

    . ../build_cli.sh

    VSCODE_PLATFORM="darwin"
  elif [[ "${OS_NAME}" == "windows" ]]; then
    # generate Group Policy definitions
    node build/lib/policies win32

    # in CI, packaging will be done by a different job
    if [[ "${CI_BUILD}" == "no" ]]; then
      . ../build/windows/rtf/make.sh

      npm run gulp "vscode-win32-${VSCODE_ARCH}-min-ci"

      if [[ "${VSCODE_ARCH}" != "x64" ]]; then
        SHOULD_BUILD_REH="no"
        SHOULD_BUILD_REH_WEB="no"
      fi

      . ../build_cli.sh
    fi

    VSCODE_PLATFORM="win32"
  else # linux
    # in CI, packaging will be done by a different job
    if [[ "${CI_BUILD}" == "no" ]]; then
      npm run gulp "vscode-linux-${VSCODE_ARCH}-min-ci"

      find "../VSCode-linux-${VSCODE_ARCH}" -print0 | xargs -0 touch -c

      . ../build_cli.sh
    fi

    VSCODE_PLATFORM="linux"
  fi

  if [[ "${SHOULD_BUILD_REH}" != "no" ]]; then
    npm run gulp minify-vscode-reh
    npm run gulp "vscode-reh-${VSCODE_PLATFORM}-${VSCODE_ARCH}-min-ci"
  fi

  if [[ "${SHOULD_BUILD_REH_WEB}" != "no" ]]; then
    npm run gulp minify-vscode-reh-web
    npm run gulp "vscode-reh-web-${VSCODE_PLATFORM}-${VSCODE_ARCH}-min-ci"
  fi

  cd ..
fi
