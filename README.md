# deploy_agent_Dri-m
# Project Factory - Student Attendance Tracker

A shell script that automates the creation of a complete workspace for parents to be able to track the
students attendance, including directory structure,
configuration, and environment validation.

## What it does

Running the script creates a new project directory named
`attendance_tracker_<input>`, containing: 
attendance_tracker_<input>/

├── attendance_checker.py

├── Helpers/

│   ├── assets.csv

│   └── config.json

└── reports/

└── reports.log

It also:
- Lets you interactively update the attendance warning/failure
- Gracefully handles interruptions (Ctrl+C) by archiving the in-progress work
- Performs a health check to confirm the environment is okay

## How to run the script

```bash
./factory.sh <input>
```

`<input>` is any string you choose to identify the project (e.g. a version
number or project name). It will be used to name the generated directory.

### Example

```bash
./factory.sh v1
```

This creates a directory named `attendance_tracker_v1/` with the full
project structure inside.

