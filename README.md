# Linux Projects

This repository contains a collection of my Linux-based projects and scripts, aimed at simplifying and automating common administrative tasks. Each project includes instructions for setup and usage, making it easy to integrate into various Linux environments.

## Contents:

### 1. Task Scheduler Script (`Task_Scheduled.sh`)
A simple Bash script to manage scheduled tasks using cron jobs. Features include:
- List current scheduled tasks
- Add new tasks with hourly, daily, or weekly schedules
- Remove existing tasks
- Interactive menu-driven interface

### 2. GitHub Copilot Agent Manager (`copilot_agent_manager.sh`)
A comprehensive tool for delegating tasks to GitHub Copilot coding agents and monitoring their progress in the background. This tool provides:

**Key Features:**
- **Agent Delegation**: Create and assign coding tasks to GitHub Copilot agents
- **Progress Monitoring**: Track agent progress in real-time with detailed logging
- **Task Management**: Create, start, monitor, and delete tasks
- **Background Processing**: Agents work in the background while you continue other tasks
- **Result Tracking**: View completed solutions and error reports
- **Configuration Management**: Customizable settings for agent behavior

**Usage:**
```bash
# Interactive mode
./copilot_agent_manager.sh

# Command line mode
./copilot_agent_manager.sh init          # Initialize the system
./copilot_agent_manager.sh status        # Show agent status
./copilot_agent_manager.sh create        # Create new task
./copilot_agent_manager.sh start <id>    # Start specific task
./copilot_agent_manager.sh monitor <id>  # Monitor task progress
./copilot_agent_manager.sh list          # List all tasks
./copilot_agent_manager.sh delete <id>   # Delete task
```

**What are Agents?**
GitHub Copilot agents are AI-powered coding assistants that can be delegated specific programming tasks to work on in the background. This tool allows you to:
- Delegate complex coding tasks to multiple agents simultaneously
- Monitor their progress without blocking your workflow
- Review and integrate their solutions when ready
- Manage multiple concurrent coding projects efficiently

## Purpose:
The goal of this repository is to create and share tools for Linux administrators and enthusiasts, ranging from automation scripts to system monitoring, performance tuning tools, and AI-assisted development workflows.

## How to Use:

### Getting Started
1. Clone the repository:
   ```bash
   git clone https://github.com/Ankledeath/Linux_projects.git
   cd Linux_projects
   ```

2. Make scripts executable:
   ```bash
   chmod +x *.sh
   ```

3. For GitHub Copilot Agent Manager:
   ```bash
   # Initialize the system
   ./copilot_agent_manager.sh init
   
   # Run interactive mode
   ./copilot_agent_manager.sh
   
   # Or use command line mode
   ./copilot_agent_manager.sh help
   ```

4. For Task Scheduler:
   ```bash
   ./Task_Scheduled.sh
   ```

### Testing
Run the comprehensive system test:
```bash
./test_system.sh
```

### Quick Demo
Experience the GitHub Copilot Agent Manager:
```bash
./demo_copilot_agents.sh quick
```

## Documentation
- `README.md` - This file (project overview)
- `COPILOT_AGENT_GUIDE.md` - Comprehensive usage guide for the agent manager
- `test_system.sh` - System validation tests
- `demo_copilot_agents.sh` - Demonstration script

## Contributions:
Feel free to open issues for bug reports or feature requests, or submit pull requests to add new functionality or improvements.

