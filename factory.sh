#!/bin/bash
#
# Project Factory - Student Attendance Tracker
# Part 1 : Directory Architecture
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
touch "$PROJECT_DIR/Helpers/config.json"
touch "$PROJECT_DIR/reports/reports.log"

echo "Directory structure created successfully:"
echo ""

# --- Display the created structure ---
if command -v tree &> /dev/null; then
    tree "$PROJECT_DIR"
else
    find "$PROJECT_DIR" | sed -e "s|[^/]*/|  |g"
fi
