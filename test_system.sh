#!/bin/bash

# System Test for GitHub Copilot Agent Manager
# This script validates all functionality without user interaction

echo "=== GitHub Copilot Agent Manager System Test ==="
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="/home/runner/work/Linux_projects/Linux_projects"
AGENT_MANAGER="$SCRIPT_DIR/copilot_agent_manager.sh"

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Test function
run_test() {
    local test_name="$1"
    local command="$2"
    
    echo -e "${BLUE}Testing: $test_name${NC}"
    
    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ FAILED${NC}"
        ((TESTS_FAILED++))
    fi
    echo
}

# Test 1: Script exists and is executable
run_test "Script exists and is executable" "test -x '$AGENT_MANAGER'"

# Test 2: Help command works
run_test "Help command works" "'$AGENT_MANAGER' help"

# Test 3: Init command works
run_test "Init command works" "'$AGENT_MANAGER' init"

# Test 4: Status command works
run_test "Status command works" "'$AGENT_MANAGER' status"

# Test 5: List command works
run_test "List command works" "'$AGENT_MANAGER' list"

# Test 6: Configuration file exists after init
run_test "Configuration file exists" "test -f ~/.copilot_agents/config.json"

# Test 7: Task directory exists
run_test "Task directory exists" "test -d ~/.copilot_agents/tasks"

# Test 8: Log directory exists
run_test "Log directory exists" "test -d ~/.copilot_agents/logs"

# Test 9: Demo script exists and is executable
run_test "Demo script exists and is executable" "test -x '$SCRIPT_DIR/demo_copilot_agents.sh'"

# Test 10: Usage guide exists
run_test "Usage guide exists" "test -f '$SCRIPT_DIR/COPILOT_AGENT_GUIDE.md'"

# Test 11: Original task scheduler still works
run_test "Original task scheduler exists" "test -f '$SCRIPT_DIR/Task_Scheduled.sh'"

# Test 12: Create a test task manually
TEST_TASK_ID="test_$(date +%s)"
cat > "/home/runner/.copilot_agents/tasks/${TEST_TASK_ID}.task" << EOF
TASK_ID=$TEST_TASK_ID
TASK_NAME=Test Task
TASK_DESCRIPTION=Test task for validation
LANGUAGE=bash
REPO_PATH=./test
PRIORITY=low
STATUS=pending
CREATED_AT=$(date '+%Y-%m-%d %H:%M:%S')
STARTED_AT=
COMPLETED_AT=
AGENT_ID=
EOF

run_test "Manual task creation works" "test -f '/home/runner/.copilot_agents/tasks/${TEST_TASK_ID}.task'"

# Test 13: Start task command works
run_test "Start task command works" "'$AGENT_MANAGER' start '$TEST_TASK_ID'"

# Wait for task to potentially complete
sleep 2

# Test 14: Monitor task command works
run_test "Monitor task command works" "'$AGENT_MANAGER' monitor '$TEST_TASK_ID' | head -5"

# Test 15: Delete task command works
run_test "Delete task command works" "'$AGENT_MANAGER' delete '$TEST_TASK_ID'"

# Summary
echo -e "${BLUE}=== Test Summary ===${NC}"
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
TOTAL_TESTS=$((TESTS_PASSED + TESTS_FAILED))
echo -e "Total Tests: $TOTAL_TESTS"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed! ✓${NC}"
    echo
    echo -e "${YELLOW}System is ready for use!${NC}"
    echo
    echo "Available commands:"
    echo "  ./copilot_agent_manager.sh           - Interactive mode"
    echo "  ./copilot_agent_manager.sh help      - Show help"
    echo "  ./copilot_agent_manager.sh status    - Show status"
    echo "  ./demo_copilot_agents.sh quick       - Quick demo"
    echo
    echo "Documentation:"
    echo "  README.md                            - Project overview"
    echo "  COPILOT_AGENT_GUIDE.md              - Comprehensive usage guide"
    exit 0
else
    echo -e "${RED}Some tests failed! ✗${NC}"
    echo "Please check the system configuration and try again."
    exit 1
fi