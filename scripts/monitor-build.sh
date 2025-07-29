#!/usr/bin/env bash
# Monitor build progress

BUILD_LOG="build.log"

if [[ ! -f "$BUILD_LOG" ]]; then
    echo "❌ Build log not found: $BUILD_LOG"
    echo "💡 Start build with: ./dev/build-fast.sh 2>&1 | tee build.log"
    exit 1
fi

echo "📊 Monitoring build progress..."
echo "📁 Log file: $BUILD_LOG"
echo "🔄 Press Ctrl+C to stop monitoring"
echo ""

# Function to show build statistics
show_stats() {
    local total_lines=$(wc -l < "$BUILD_LOG" 2>/dev/null || echo "0")
    local errors=$(grep -c "error\|Error\|ERROR" "$BUILD_LOG" 2>/dev/null || echo "0")
    local warnings=$(grep -c "warn\|Warning\|WARNING" "$BUILD_LOG" 2>/dev/null || echo "0")
    
    echo "📈 Stats: Lines: $total_lines | Errors: $errors | Warnings: $warnings"
}

# Function to show current stage
show_stage() {
    local last_stage=""
    
    if tail -20 "$BUILD_LOG" | grep -q "Installing extensions"; then
        last_stage="🧩 Installing extensions"
    elif tail -20 "$BUILD_LOG" | grep -q "Copying locales"; then
        last_stage="🌍 Copying locales"
    elif tail -20 "$BUILD_LOG" | grep -q "minify-vscode"; then
        last_stage="📦 Minifying code"
    elif tail -20 "$BUILD_LOG" | grep -q "compile"; then
        last_stage="🔨 Compiling TypeScript"
    elif tail -20 "$BUILD_LOG" | grep -q "Installing dependencies"; then
        last_stage="📥 Installing dependencies"
    elif tail -20 "$BUILD_LOG" | grep -q "Restoring dependencies"; then
        last_stage="♻️  Restoring from cache"
    else
        last_stage="🔄 Building..."
    fi
    
    echo "🎯 Current stage: $last_stage"
}

# Monitor loop
while true; do
    clear
    echo "🚀 VSCodium/Neira Build Monitor"
    echo "================================"
    show_stats
    show_stage
    echo ""
    echo "📝 Last 10 lines:"
    echo "----------------"
    tail -10 "$BUILD_LOG" 2>/dev/null | sed 's/^/  /'
    echo ""
    echo "⏱️  $(date '+%H:%M:%S') - Refreshing in 5 seconds..."
    
    sleep 5
done
