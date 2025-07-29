#!/usr/bin/env bash
# Preload dependencies for faster builds

set -e

echo "🚀 Preloading dependencies for faster builds..."

# Check if vscode directory exists
if [[ ! -d "vscode" ]]; then
    echo "📥 VSCode source not found, preparing..."
    . prepare_vscode.sh
fi

cd vscode

echo "📦 Installing main dependencies..."
npm ci --prefer-offline --no-audit --no-fund

echo "🧩 Installing extension dependencies..."
npm run postinstall

echo "🔧 Precompiling TypeScript..."
npm run compile

echo "✅ Dependencies preloaded successfully!"
echo "💡 Next builds will be much faster!"

cd ..
