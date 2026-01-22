#!/bin/bash

LOG="/tmp/opencode.log"
echo "=== Starting opencode script at $(date) ===" > "$LOG"
echo "PATH: $PATH" >> "$LOG"
echo "USER: $(whoami)" >> "$LOG"
echo "PWD: $(pwd)" >> "$LOG"

# Find opencode binary - check common locations
OPENCODE_BIN=""
for loc in /usr/local/bin/opencode /home/vscode/.local/bin/opencode /home/vscode/go/bin/opencode $(which opencode 2>/dev/null); do
    if [ -x "$loc" ]; then
        OPENCODE_BIN="$loc"
        break
    fi
done

# If not found, try to find it
if [ -z "$OPENCODE_BIN" ]; then
    OPENCODE_BIN=$(find /home /usr -name "opencode" -type f -executable 2>/dev/null | head -1)
fi

echo "Found opencode at: $OPENCODE_BIN" >> "$LOG"

if [ -z "$OPENCODE_BIN" ] || [ ! -x "$OPENCODE_BIN" ]; then
    echo "ERROR: opencode binary not found!" >> "$LOG"
else
    # Start opencode web in background with full path
    echo "Starting opencode web..." >> "$LOG"
    nohup "$OPENCODE_BIN" web >> "$LOG" 2>&1 &
    PID=$!
    echo "Started with PID: $PID" >> "$LOG"
    
    # Give it a moment to start and verify
    sleep 2
    if ps -p $PID > /dev/null 2>&1; then
        echo "Process $PID is running" >> "$LOG"
    else
        echo "Process $PID died immediately" >> "$LOG"
    fi
fi

# Find and start ttyd
TTYD_BIN=""
for loc in /usr/local/bin/ttyd /usr/bin/ttyd /home/vscode/.local/bin/ttyd $(which ttyd 2>/dev/null); do
    if [ -x "$loc" ]; then
        TTYD_BIN="$loc"
        break
    fi
done

if [ -z "$TTYD_BIN" ]; then
    TTYD_BIN=$(find /home /usr -name "ttyd" -type f -executable 2>/dev/null | head -1)
fi

echo "Found ttyd at: $TTYD_BIN" >> "$LOG"

if [ -z "$TTYD_BIN" ] || [ ! -x "$TTYD_BIN" ]; then
    echo "ERROR: ttyd binary not found!" >> "$LOG"
else
    # Start ttyd in background
    echo "Starting ttyd..." >> "$LOG"
    nohup "$TTYD_BIN" -W -p 7681 bash >> "$LOG" 2>&1 &
    PID=$!
    echo "Started ttyd with PID: $PID" >> "$LOG"
    
    # Give it a moment to start and verify
    sleep 1
    if ps -p $PID > /dev/null 2>&1; then
        echo "ttyd process $PID is running" >> "$LOG"
    else
        echo "ttyd process $PID died immediately" >> "$LOG"
    fi
fi

exit 0
