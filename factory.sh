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

# --- Prevent overwriting an existing project ---
if [[ -d "$PROJECT_DIR" ]]; then
    echo "Error: directory '$PROJECT_DIR' already exists."
    exit 1
fi

echo "Creating directory structure for '$PROJECT_DIR'..."

# --- Create directory structure ---
mkdir -p "$PROJECT_DIR/Helpers"
mkdir -p "$PROJECT_DIR/reports"

# --- Create files ---
touch "$PROJECT_DIR/attendance_checker.py"
touch "$PROJECT_DIR/Helpers/assets.csv"
touch "$PROJECT_DIR/reports/reports.log"

# --- Initialize config.json with default threshold values ---
cat > "$PROJECT_DIR/Helpers/config.json" << JSONEOF
{
    "warning_threshold": 75,
    "failure_threshold": 50
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

    # In-place edit of config.json using sed
    sed -i "s/\"warning_threshold\": [0-9]*/\"warning_threshold\": ${WARNING_VALUE}/" "$PROJECT_DIR/Helpers/config.json"
    sed -i "s/\"failure_threshold\": [0-9]*/\"failure_threshold\": ${FAILURE_VALUE}/" "$PROJECT_DIR/Helpers/config.json"

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
