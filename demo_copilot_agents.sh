#!/bin/bash

# Demo script for GitHub Copilot Agent Manager
# This script demonstrates the capabilities of the agent management system

echo "=== GitHub Copilot Agent Manager Demo ==="
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="/home/runner/work/Linux_projects/Linux_projects"
AGENT_MANAGER="$SCRIPT_DIR/copilot_agent_manager.sh"

# Function to run demo steps
run_demo() {
    echo -e "${BLUE}Step 1: Initialize the agent system${NC}"
    "$AGENT_MANAGER" init
    echo
    
    echo -e "${BLUE}Step 2: Show initial status${NC}"
    "$AGENT_MANAGER" status
    echo
    
    echo -e "${BLUE}Step 3: Create a sample task${NC}"
    # Create a sample task file for demonstration
    mkdir -p /home/runner/.copilot_agents/tasks
    
    # Create a sample task
    task_id="demo_$(date +%s)"
    task_file="/home/runner/.copilot_agents/tasks/${task_id}.task"
    
    cat > "$task_file" << EOF
TASK_ID=$task_id
TASK_NAME=Create Python Web Scraper
TASK_DESCRIPTION=Create a Python script to scrape product information from e-commerce websites
LANGUAGE=python
REPO_PATH=./web_scraper
PRIORITY=high
STATUS=pending
CREATED_AT=$(date '+%Y-%m-%d %H:%M:%S')
STARTED_AT=
COMPLETED_AT=
AGENT_ID=
EOF
    
    echo -e "${GREEN}Sample task created: $task_id${NC}"
    echo
    
    echo -e "${BLUE}Step 4: List all tasks${NC}"
    "$AGENT_MANAGER" list
    echo
    
    echo -e "${BLUE}Step 5: Start the task${NC}"
    "$AGENT_MANAGER" start "$task_id"
    echo
    
    echo -e "${BLUE}Step 6: Monitor task progress${NC}"
    echo "Waiting for task to complete..."
    sleep 2
    
    # Check task status multiple times
    for i in {1..5}; do
        echo -e "${YELLOW}Checking progress... ($i/5)${NC}"
        "$AGENT_MANAGER" status
        sleep 5
    done
    
    echo -e "${BLUE}Step 7: Final task monitoring${NC}"
    "$AGENT_MANAGER" monitor "$task_id"
    echo
    
    echo -e "${BLUE}Step 8: List all tasks (final)${NC}"
    "$AGENT_MANAGER" list
    echo
    
    echo -e "${GREEN}Demo completed successfully!${NC}"
    echo
    echo -e "${YELLOW}Key Features Demonstrated:${NC}"
    echo "✓ Agent system initialization"
    echo "✓ Task creation and management"
    echo "✓ Background agent processing"
    echo "✓ Progress monitoring"
    echo "✓ Task status tracking"
    echo "✓ Result/error reporting"
    echo
    echo -e "${BLUE}The GitHub Copilot Agent Manager is now ready for use!${NC}"
}

# Function to create additional example tasks
create_example_tasks() {
    echo -e "${BLUE}Creating additional example tasks...${NC}"
    
    # Task 1: JavaScript API
    task_id1="js_api_$(date +%s)"
    cat > "/home/runner/.copilot_agents/tasks/${task_id1}.task" << EOF
TASK_ID=$task_id1
TASK_NAME=RESTful API in Node.js
TASK_DESCRIPTION=Create a RESTful API using Node.js and Express for managing user accounts
LANGUAGE=javascript
REPO_PATH=./nodejs_api
PRIORITY=medium
STATUS=pending
CREATED_AT=$(date '+%Y-%m-%d %H:%M:%S')
STARTED_AT=
COMPLETED_AT=
AGENT_ID=
EOF
    
    # Task 2: Database Schema
    task_id2="db_schema_$(date +%s)"
    cat > "/home/runner/.copilot_agents/tasks/${task_id2}.task" << EOF
TASK_ID=$task_id2
TASK_NAME=Database Schema Design
TASK_DESCRIPTION=Design a normalized database schema for an e-commerce platform with products, orders, and customers
LANGUAGE=sql
REPO_PATH=./database_schema
PRIORITY=high
STATUS=pending
CREATED_AT=$(date '+%Y-%m-%d %H:%M:%S')
STARTED_AT=
COMPLETED_AT=
AGENT_ID=
EOF
    
    # Task 3: Bash Script
    task_id3="bash_backup_$(date +%s)"
    cat > "/home/runner/.copilot_agents/tasks/${task_id3}.task" << EOF
TASK_ID=$task_id3
TASK_NAME=Automated Backup Script
TASK_DESCRIPTION=Create a bash script for automated backup of important system files with compression and rotation
LANGUAGE=bash
REPO_PATH=./backup_scripts
PRIORITY=low
STATUS=pending
CREATED_AT=$(date '+%Y-%m-%d %H:%M:%S')
STARTED_AT=
COMPLETED_AT=
AGENT_ID=
EOF
    
    echo -e "${GREEN}Created 3 additional example tasks:${NC}"
    echo "- $task_id1 (JavaScript API)"
    echo "- $task_id2 (Database Schema)"
    echo "- $task_id3 (Bash Backup Script)"
    echo
}

# Main execution
if [ "$1" = "quick" ]; then
    echo -e "${YELLOW}Running quick demo...${NC}"
    create_example_tasks
    "$AGENT_MANAGER" list
elif [ "$1" = "full" ]; then
    echo -e "${YELLOW}Running full demo...${NC}"
    run_demo
    create_example_tasks
else
    echo "Usage: $0 [quick|full]"
    echo "  quick - Create example tasks and show list"
    echo "  full  - Run complete demonstration"
    echo
    echo "To run the agent manager interactively:"
    echo "  $AGENT_MANAGER"
    echo
    echo "To see all available commands:"
    echo "  $AGENT_MANAGER help"
fi