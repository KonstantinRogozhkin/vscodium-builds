#!/usr/bin/env bash
# Script to cache and restore dependencies for faster builds

set -e

CACHE_DIR="$HOME/.vscodium-build-cache"
PROJECT_ROOT="$(pwd)"
VSCODE_DIR="$PROJECT_ROOT/vscode"

# Create cache directory
mkdir -p "$CACHE_DIR"

cache_dependencies() {
    echo "🔄 Caching dependencies..."
    
    if [[ -d "$VSCODE_DIR/node_modules" ]]; then
        echo "📦 Caching main node_modules..."
        rsync -a --delete "$VSCODE_DIR/node_modules/" "$CACHE_DIR/node_modules/"
    fi
    
    if [[ -d "$VSCODE_DIR/extensions" ]]; then
        echo "🧩 Caching extension dependencies..."
        find "$VSCODE_DIR/extensions" -name "node_modules" -type d | while read -r ext_modules; do
            relative_path="${ext_modules#$VSCODE_DIR/}"
            cache_path="$CACHE_DIR/$relative_path"
            mkdir -p "$(dirname "$cache_path")"
            rsync -a --delete "$ext_modules/" "$cache_path/"
        done
    fi
    
    echo "✅ Dependencies cached successfully!"
}

restore_dependencies() {
    echo "🔄 Restoring dependencies from cache..."
    
    if [[ -d "$CACHE_DIR/node_modules" ]]; then
        echo "📦 Restoring main node_modules..."
        mkdir -p "$VSCODE_DIR"
        rsync -a "$CACHE_DIR/node_modules/" "$VSCODE_DIR/node_modules/"
    fi
    
    if [[ -d "$CACHE_DIR/extensions" ]]; then
        echo "🧩 Restoring extension dependencies..."
        find "$CACHE_DIR/extensions" -name "node_modules" -type d | while read -r cached_modules; do
            relative_path="${cached_modules#$CACHE_DIR/}"
            target_path="$VSCODE_DIR/$relative_path"
            mkdir -p "$(dirname "$target_path")"
            rsync -a "$cached_modules/" "$target_path/"
        done
    fi
    
    echo "✅ Dependencies restored successfully!"
}

clean_cache() {
    echo "🧹 Cleaning build cache..."
    rm -rf "$CACHE_DIR"
    echo "✅ Cache cleaned!"
}

case "${1:-}" in
    "cache")
        cache_dependencies
        ;;
    "restore")
        restore_dependencies
        ;;
    "clean")
        clean_cache
        ;;
    *)
        echo "Usage: $0 {cache|restore|clean}"
        echo "  cache   - Cache current dependencies"
        echo "  restore - Restore dependencies from cache"
        echo "  clean   - Clean the cache"
        exit 1
        ;;
esac
