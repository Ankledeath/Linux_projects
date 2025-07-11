#!/bin/bash

# GitHub Copilot Agent Manager
# A tool to delegate tasks to GitHub Copilot coding agents and monitor their progress

# Configuration
AGENTS_DIR="$HOME/.copilot_agents"
TASKS_DIR="$AGENTS_DIR/tasks"
LOGS_DIR="$AGENTS_DIR/logs"
CONFIG_FILE="$AGENTS_DIR/config.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Initialize the agent system
init_agent_system() {
    echo -e "${BLUE}Initializing GitHub Copilot Agent System...${NC}"
    
    # Create necessary directories
    mkdir -p "$AGENTS_DIR" "$TASKS_DIR" "$LOGS_DIR"
    
    # Create default configuration if it doesn't exist
    if [ ! -f "$CONFIG_FILE" ]; then
        cat > "$CONFIG_FILE" << EOF
{
    "max_concurrent_agents": 3,
    "default_timeout": 3600,
    "github_token": "",
    "copilot_model": "gpt-4",
    "log_level": "INFO"
}
EOF
    fi
    
    echo -e "${GREEN}Agent system initialized successfully!${NC}"
    echo -e "${YELLOW}Please configure your GitHub token in: $CONFIG_FILE${NC}"
}

# Display current agent status
show_agent_status() {
    echo -e "${BLUE}=== GitHub Copilot Agent Status ===${NC}"
    echo
    
    # Count active tasks
    active_tasks=$(find "$TASKS_DIR" -name "*.task" -type f 2>/dev/null | wc -l)
    completed_tasks=$(find "$TASKS_DIR" -name "*.completed" -type f 2>/dev/null | wc -l)
    failed_tasks=$(find "$TASKS_DIR" -name "*.failed" -type f 2>/dev/null | wc -l)
    
    echo -e "Active Tasks: ${YELLOW}$active_tasks${NC}"
    echo -e "Completed Tasks: ${GREEN}$completed_tasks${NC}"
    echo -e "Failed Tasks: ${RED}$failed_tasks${NC}"
    echo
    
    # Show active tasks
    if [ "$active_tasks" -gt 0 ]; then
        echo -e "${BLUE}Active Tasks:${NC}"
        for task_file in "$TASKS_DIR"/*.task; do
            if [ -f "$task_file" ]; then
                task_id=$(basename "$task_file" .task)
                task_name=$(grep "^TASK_NAME=" "$task_file" | cut -d'=' -f2)
                started_at=$(grep "^STARTED_AT=" "$task_file" | cut -d'=' -f2)
                echo -e "  ${YELLOW}$task_id${NC} - $task_name (Started: $started_at)"
            fi
        done
        echo
    fi
}

# Create a new task for an agent
create_task() {
    echo -e "${BLUE}Creating new task for GitHub Copilot agent...${NC}"
    
    # Get task details from user
    read -p "Enter task name: " task_name
    read -p "Enter task description: " task_description
    read -p "Enter programming language (optional): " language
    read -p "Enter repository path (optional): " repo_path
    read -p "Enter priority (low/medium/high) [medium]: " priority
    
    # Set defaults
    priority=${priority:-medium}
    task_id=$(date +%s)_$(echo "$task_name" | tr ' ' '_' | tr '[:upper:]' '[:lower:]')
    
    # Create task file
    task_file="$TASKS_DIR/${task_id}.task"
    cat > "$task_file" << EOF
TASK_ID=$task_id
TASK_NAME=$task_name
TASK_DESCRIPTION=$task_description
LANGUAGE=$language
REPO_PATH=$repo_path
PRIORITY=$priority
STATUS=pending
CREATED_AT=$(date '+%Y-%m-%d %H:%M:%S')
STARTED_AT=
COMPLETED_AT=
AGENT_ID=
EOF
    
    echo -e "${GREEN}Task created successfully!${NC}"
    echo -e "Task ID: ${YELLOW}$task_id${NC}"
    echo -e "Task File: $task_file"
    
    # Ask if user wants to start the task immediately
    read -p "Start task immediately? (y/n): " start_now
    if [[ "$start_now" == "y" || "$start_now" == "Y" ]]; then
        start_task "$task_id"
    fi
}

# Start a task
start_task() {
    local task_id="$1"
    local task_file="$TASKS_DIR/${task_id}.task"
    
    if [ ! -f "$task_file" ]; then
        echo -e "${RED}Task not found: $task_id${NC}"
        return 1
    fi
    
    # Check if task is already running
    if grep -q "STATUS=running" "$task_file"; then
        echo -e "${YELLOW}Task is already running: $task_id${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Starting task: $task_id${NC}"
    
    # Update task status
    sed -i "s/STATUS=pending/STATUS=running/" "$task_file"
    sed -i "s/STARTED_AT=/STARTED_AT=$(date '+%Y-%m-%d %H:%M:%S')/" "$task_file"
    
    # Generate a mock agent ID
    agent_id="copilot_agent_$(date +%s)"
    sed -i "s/AGENT_ID=/AGENT_ID=$agent_id/" "$task_file"
    
    # Start the agent process in background
    start_agent_process "$task_id" &
    
    echo -e "${GREEN}Task started successfully!${NC}"
    echo -e "Agent ID: ${YELLOW}$agent_id${NC}"
}

# Simulate agent process (in a real implementation, this would interface with GitHub Copilot)
start_agent_process() {
    local task_id="$1"
    local task_file="$TASKS_DIR/${task_id}.task"
    local log_file="$LOGS_DIR/${task_id}.log"
    
    # Create log file
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting agent process for task: $task_id" > "$log_file"
    
    # Get task details
    local task_name=$(grep "^TASK_NAME=" "$task_file" | cut -d'=' -f2)
    local task_description=$(grep "^TASK_DESCRIPTION=" "$task_file" | cut -d'=' -f2)
    local language=$(grep "^LANGUAGE=" "$task_file" | cut -d'=' -f2)
    
    # Simulate agent work (in reality, this would make API calls to GitHub Copilot)
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Agent analyzing task: $task_name" >> "$log_file"
    sleep 5
    
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Agent generating code for: $task_description" >> "$log_file"
    sleep 10
    
    if [ -n "$language" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Agent optimizing for language: $language" >> "$log_file"
        sleep 5
    fi
    
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Agent finalizing solution" >> "$log_file"
    sleep 5
    
    # Simulate random success/failure (80% success rate)
    if [ $((RANDOM % 10)) -lt 8 ]; then
        # Success
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Agent completed task successfully" >> "$log_file"
        mv "$task_file" "$TASKS_DIR/${task_id}.completed"
        sed -i "s/STATUS=running/STATUS=completed/" "$TASKS_DIR/${task_id}.completed"
        sed -i "s/COMPLETED_AT=/COMPLETED_AT=$(date '+%Y-%m-%d %H:%M:%S')/" "$TASKS_DIR/${task_id}.completed"
        
        # Create mock result file
        cat > "$TASKS_DIR/${task_id}.result" << EOF
# Task Result: $task_name

## Description
$task_description

## Generated Solution
\`\`\`${language:-bash}
# This is a mock solution generated by the GitHub Copilot agent
# In a real implementation, this would contain the actual code generated by Copilot

echo "Hello from GitHub Copilot Agent!"
echo "Task: $task_name"
echo "Description: $task_description"
EOF
        
        if [ -n "$language" ]; then
            echo "echo \"Language: $language\"" >> "$TASKS_DIR/${task_id}.result"
        fi
        
        echo '```' >> "$TASKS_DIR/${task_id}.result"
        echo "" >> "$TASKS_DIR/${task_id}.result"
        echo "## Agent Notes" >> "$TASKS_DIR/${task_id}.result"
        echo "- Task completed successfully" >> "$TASKS_DIR/${task_id}.result"
        echo "- Solution generated based on requirements" >> "$TASKS_DIR/${task_id}.result"
        echo "- Ready for review and integration" >> "$TASKS_DIR/${task_id}.result"
        
    else
        # Failure
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Agent failed to complete task" >> "$log_file"
        mv "$task_file" "$TASKS_DIR/${task_id}.failed"
        sed -i "s/STATUS=running/STATUS=failed/" "$TASKS_DIR/${task_id}.failed"
        sed -i "s/COMPLETED_AT=/COMPLETED_AT=$(date '+%Y-%m-%d %H:%M:%S')/" "$TASKS_DIR/${task_id}.failed"
        
        # Create error report
        cat > "$TASKS_DIR/${task_id}.error" << EOF
# Task Error Report: $task_name

## Error Details
- Task failed to complete
- Reason: Insufficient context or complexity beyond agent capabilities
- Recommendations: 
  - Provide more detailed requirements
  - Break down into smaller subtasks
  - Review task complexity

## Task Information
- Description: $task_description
- Language: ${language:-Not specified}
- Failed at: $(date '+%Y-%m-%d %H:%M:%S')
EOF
    fi
}

# Monitor task progress
monitor_task() {
    local task_id="$1"
    
    if [ -z "$task_id" ]; then
        echo -e "${RED}Please provide a task ID${NC}"
        return 1
    fi
    
    local task_file
    local log_file="$LOGS_DIR/${task_id}.log"
    
    # Find task file (could be .task, .completed, or .failed)
    if [ -f "$TASKS_DIR/${task_id}.task" ]; then
        task_file="$TASKS_DIR/${task_id}.task"
    elif [ -f "$TASKS_DIR/${task_id}.completed" ]; then
        task_file="$TASKS_DIR/${task_id}.completed"
    elif [ -f "$TASKS_DIR/${task_id}.failed" ]; then
        task_file="$TASKS_DIR/${task_id}.failed"
    else
        echo -e "${RED}Task not found: $task_id${NC}"
        return 1
    fi
    
    # Display task information
    echo -e "${BLUE}=== Task Monitor: $task_id ===${NC}"
    echo
    
    local task_name=$(grep "^TASK_NAME=" "$task_file" | cut -d'=' -f2)
    local status=$(grep "^STATUS=" "$task_file" | cut -d'=' -f2)
    local created_at=$(grep "^CREATED_AT=" "$task_file" | cut -d'=' -f2)
    local started_at=$(grep "^STARTED_AT=" "$task_file" | cut -d'=' -f2)
    local completed_at=$(grep "^COMPLETED_AT=" "$task_file" | cut -d'=' -f2)
    local agent_id=$(grep "^AGENT_ID=" "$task_file" | cut -d'=' -f2)
    
    echo -e "Task Name: ${YELLOW}$task_name${NC}"
    echo -e "Status: ${GREEN}$status${NC}"
    echo -e "Created: $created_at"
    [ -n "$started_at" ] && echo -e "Started: $started_at"
    [ -n "$completed_at" ] && echo -e "Completed: $completed_at"
    [ -n "$agent_id" ] && echo -e "Agent ID: $agent_id"
    echo
    
    # Show recent log entries
    if [ -f "$log_file" ]; then
        echo -e "${BLUE}Recent Log Entries:${NC}"
        tail -10 "$log_file"
        echo
    fi
    
    # Show result if completed
    if [ "$status" = "completed" ] && [ -f "$TASKS_DIR/${task_id}.result" ]; then
        echo -e "${GREEN}Task completed! Result available at: $TASKS_DIR/${task_id}.result${NC}"
        read -p "View result? (y/n): " view_result
        if [[ "$view_result" == "y" || "$view_result" == "Y" ]]; then
            cat "$TASKS_DIR/${task_id}.result"
        fi
    fi
    
    # Show error if failed
    if [ "$status" = "failed" ] && [ -f "$TASKS_DIR/${task_id}.error" ]; then
        echo -e "${RED}Task failed! Error report available at: $TASKS_DIR/${task_id}.error${NC}"
        read -p "View error report? (y/n): " view_error
        if [[ "$view_error" == "y" || "$view_error" == "Y" ]]; then
            cat "$TASKS_DIR/${task_id}.error"
        fi
    fi
}

# List all tasks
list_tasks() {
    echo -e "${BLUE}=== All Tasks ===${NC}"
    echo
    
    local task_files=(
        "$TASKS_DIR"/*.task
        "$TASKS_DIR"/*.completed
        "$TASKS_DIR"/*.failed
    )
    
    if [ ${#task_files[@]} -eq 0 ]; then
        echo -e "${YELLOW}No tasks found${NC}"
        return
    fi
    
    printf "%-20s %-30s %-12s %-19s\n" "Task ID" "Task Name" "Status" "Created"
    printf "%-20s %-30s %-12s %-19s\n" "--------" "---------" "------" "-------"
    
    for task_file in "${task_files[@]}"; do
        if [ -f "$task_file" ]; then
            local task_id=$(basename "$task_file" | sed 's/\.\(task\|completed\|failed\)$//')
            local task_name=$(grep "^TASK_NAME=" "$task_file" | cut -d'=' -f2)
            local status=$(grep "^STATUS=" "$task_file" | cut -d'=' -f2)
            local created_at=$(grep "^CREATED_AT=" "$task_file" | cut -d'=' -f2)
            
            # Truncate long task names
            if [ ${#task_name} -gt 28 ]; then
                task_name="${task_name:0:25}..."
            fi
            
            printf "%-20s %-30s %-12s %-19s\n" "$task_id" "$task_name" "$status" "$created_at"
        fi
    done
    echo
}

# Delete a task
delete_task() {
    local task_id="$1"
    
    if [ -z "$task_id" ]; then
        echo -e "${RED}Please provide a task ID${NC}"
        return 1
    fi
    
    # Find and delete all related files
    local files_deleted=0
    for ext in task completed failed result error; do
        if [ -f "$TASKS_DIR/${task_id}.${ext}" ]; then
            rm "$TASKS_DIR/${task_id}.${ext}"
            ((files_deleted++))
        fi
    done
    
    # Delete log file
    if [ -f "$LOGS_DIR/${task_id}.log" ]; then
        rm "$LOGS_DIR/${task_id}.log"
        ((files_deleted++))
    fi
    
    if [ $files_deleted -gt 0 ]; then
        echo -e "${GREEN}Task deleted successfully: $task_id${NC}"
        echo -e "${YELLOW}$files_deleted files removed${NC}"
    else
        echo -e "${RED}Task not found: $task_id${NC}"
    fi
}

# Display help
show_help() {
    echo -e "${BLUE}GitHub Copilot Agent Manager - Help${NC}"
    echo
    echo "This tool allows you to delegate tasks to GitHub Copilot coding agents"
    echo "and monitor their progress in the background."
    echo
    echo "Available commands:"
    echo "  1. Initialize System    - Set up the agent system"
    echo "  2. Show Status         - Display current agent status"
    echo "  3. Create Task         - Create a new task for an agent"
    echo "  4. Start Task          - Start a specific task"
    echo "  5. Monitor Task        - Monitor progress of a specific task"
    echo "  6. List Tasks          - List all tasks"
    echo "  7. Delete Task         - Delete a specific task"
    echo "  8. Help               - Show this help message"
    echo "  9. Exit               - Exit the program"
    echo
    echo -e "${YELLOW}Configuration:${NC}"
    echo "  Config file: $CONFIG_FILE"
    echo "  Tasks directory: $TASKS_DIR"
    echo "  Logs directory: $LOGS_DIR"
    echo
    echo -e "${YELLOW}Note:${NC} This is a demonstration tool. In a production environment,"
    echo "it would integrate with the actual GitHub Copilot API."
}

# Main menu
main_menu() {
    while true; do
        echo -e "${BLUE}=== GitHub Copilot Agent Manager ===${NC}"
        echo
        echo "1. Initialize System"
        echo "2. Show Status"
        echo "3. Create Task"
        echo "4. Start Task"
        echo "5. Monitor Task"
        echo "6. List Tasks"
        echo "7. Delete Task"
        echo "8. Help"
        echo "9. Exit"
        echo
        read -p "Enter your choice: " choice
        echo
        
        case $choice in
            1)
                init_agent_system
                ;;
            2)
                show_agent_status
                ;;
            3)
                create_task
                ;;
            4)
                read -p "Enter task ID to start: " task_id
                start_task "$task_id"
                ;;
            5)
                read -p "Enter task ID to monitor: " task_id
                monitor_task "$task_id"
                ;;
            6)
                list_tasks
                ;;
            7)
                read -p "Enter task ID to delete: " task_id
                delete_task "$task_id"
                ;;
            8)
                show_help
                ;;
            9)
                echo -e "${GREEN}Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice. Please try again.${NC}"
                ;;
        esac
        
        echo
        read -p "Press Enter to continue..."
        clear
    done
}

# Check if running with command line arguments
if [ $# -gt 0 ]; then
    case $1 in
        init)
            init_agent_system
            ;;
        status)
            show_agent_status
            ;;
        create)
            create_task
            ;;
        start)
            start_task "$2"
            ;;
        monitor)
            monitor_task "$2"
            ;;
        list)
            list_tasks
            ;;
        delete)
            delete_task "$2"
            ;;
        help)
            show_help
            ;;
        *)
            echo -e "${RED}Unknown command: $1${NC}"
            echo "Use 'help' to see available commands"
            ;;
    esac
else
    clear
    main_menu
fi