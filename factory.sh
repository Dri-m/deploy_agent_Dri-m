#!/bin/bash
#
# Project Factory - Student Attendance Tracker
#
# Part 1 : Directory Architecture
# Part 2 : Dynamic Configuration (Stream Editing)
#
# Usage : ./factory.sh <input>
# Example : ./factory.sh v1
#   => creates attendance_tracker_v1/

set -euo pipefail

# --- Check argument ---
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <input>"
    echo "Example: $0 v1"
    exit 1
fi

INPUT="$1"
PROJECT_DIR="attendance_tracker_${INPUT}"
ARCHIVE_NAME="attendance_tracker_${INPUT}_archive.tar.gz"

# --- Part 3: Process Management (The Trap) ---
# Signal handler: triggered when the user presses Ctrl+C (SIGINT)
cleanup_on_interrupt() {
    echo ""
    echo "Signal caught: SIGINT (Ctrl+C) received."

    if [[ -d "$PROJECT_DIR" ]]; then
        echo "Archiving current (incomplete) state to '${ARCHIVE_NAME}'..."
        tar -czf "$ARCHIVE_NAME" "$PROJECT_DIR"

        echo "Removing incomplete directory '${PROJECT_DIR}'..."
        rm -rf "$PROJECT_DIR"

        echo "Cleanup complete. Archive saved as '${ARCHIVE_NAME}'."
    else
        echo "No partial directory found to archive."
    fi

    echo "Exiting script."
    exit 130
}

# Register the trap
trap cleanup_on_interrupt SIGINT

# --- Prevent overwriting an existing project ---
if [[ -d "$PROJECT_DIR" ]]; then
    echo "Error: directory '$PROJECT_DIR' already exists."
    exit 1
fi

echo "Creating directory structure for '$PROJECT_DIR'..."

# --- Create directory structure ---
mkdir -p "$PROJECT_DIR/Helpers"
mkdir -p "$PROJECT_DIR/reports"

# --- Create attendance_checker.py with real source code ---
cat > "$PROJECT_DIR/attendance_checker.py" << 'PYEOF'
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    # 1. Load Config
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)
    
    # 2. Archive old reports.log if it exists
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    # 3. Process Data
    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
        
        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])
            
            # Simple Math: (Attended / Total) * 100
            attendance_pct = (attended / total_sessions) * 100
            
            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."
            
            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
PYEOF

# --- Create assets.csv with real student data ---
cat > "$PROJECT_DIR/Helpers/assets.csv" << 'CSVEOF'
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
CSVEOF

# --- Create empty reports.log (the Python script generates/archives it on each run) ---
touch "$PROJECT_DIR/reports/reports.log"

# --- Initialize config.json with the real (nested) default structure ---
cat > "$PROJECT_DIR/Helpers/config.json" << 'JSONEOF'
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
JSONEOF

echo "Directory structure created successfully:"
echo ""

# --- Part 2: Dynamic Configuration (Stream Editing) ---
echo "--- Dynamic Configuration ---"
read -p "Do you want to update the attendance thresholds? (y/n): " UPDATE_CONFIG

if [[ "$UPDATE_CONFIG" == "y" || "$UPDATE_CONFIG" == "Y" ]]; then
    read -p "Enter new Warning threshold (default 75): " WARNING_VALUE
    read -p "Enter new Failure threshold (default 50): " FAILURE_VALUE

    # Use default values if user enters nothing
    WARNING_VALUE="${WARNING_VALUE:-75}"
    FAILURE_VALUE="${FAILURE_VALUE:-50}"

    # In-place edit of config.json using sed (matches the nested "thresholds" keys)
    sed -i "s/\"warning\": [0-9]*/\"warning\": ${WARNING_VALUE}/" "$PROJECT_DIR/Helpers/config.json"
    sed -i "s/\"failure\": [0-9]*/\"failure\": ${FAILURE_VALUE}/" "$PROJECT_DIR/Helpers/config.json"

    echo "Thresholds updated: Warning=${WARNING_VALUE}%, Failure=${FAILURE_VALUE}%"
else
    echo "Keeping default thresholds: Warning=75%, Failure=50%"
fi

echo ""
echo "Final config.json:"
cat "$PROJECT_DIR/Helpers/config.json"
echo ""

# --- Display the created structure ---
if command -v tree &> /dev/null; then
    tree "$PROJECT_DIR"
else
    find "$PROJECT_DIR" | sed -e "s|[^/]*/|  |g"
fi
