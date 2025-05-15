#!/bin/bash
# filepath: untitled:Untitled-1

set -e          # Exit on error
set -o pipefail # Exit if any command in a pipeline fails

# Print section headers for better readability
print_section() {
    echo -e "\n\033[1;34m==== $1 ====\033[0m"
}

# Error handler
error_handler() {
    echo -e "\033[1;31mError occurred at line $1. Exiting.\033[0m"
    exit 1
}

trap 'error_handler $LINENO' ERR

# Install dependencies
print_section "Installing dependencies"
sudo apt update
sudo apt install -y ros-humble-gazebo-* \
    ros-humble-cartographer \
    ros-humble-cartographer-ros \
    ros-humble-navigation2 \
    ros-humble-nav2-bringup \
    git \
    python3-colcon-common-extensions

# Source ROS 2 environment
print_section "Sourcing ROS 2 environment"
source /opt/ros/humble/setup.bash

# Create and prepare workspace
print_section "Creating TurtleBot3 workspace"
WORKSPACE_DIR=~/turtlebot3_ws
mkdir -p ${WORKSPACE_DIR}/src
cd ${WORKSPACE_DIR}/src

# Clone repositories
print_section "Cloning TurtleBot3 repositories"
repositories=(
    "https://github.com/ROBOTIS-GIT/DynamixelSDK.git"
    "https://github.com/ROBOTIS-GIT/turtlebot3_msgs.git"
    "https://github.com/ROBOTIS-GIT/turtlebot3.git"
    "https://github.com/ROBOTIS-GIT/turtlebot3_simulations.git"
)

for repo in "${repositories[@]}"; do
    repo_name=$(basename "${repo}" .git)
    if [ -d "${repo_name}" ]; then
        echo "${repo_name} already exists. Updating..."
        cd ${repo_name}
        git pull
        cd ..
    else
        echo "Cloning ${repo_name}..."
        git clone -b humble ${repo}
    fi
done

# Initialize rosdep if needed
print_section "Initializing rosdep"
if [ ! -f "/etc/ros/rosdep/sources.list.d/20-default.list" ]; then
    sudo rosdep init
fi
rosdep update

# Install dependencies
print_section "Installing TurtleBot3 dependencies"
cd ${WORKSPACE_DIR}
rosdep install -y -r --from-paths src --ignore-src --rosdistro humble

# Build the workspace
print_section "Building TurtleBot3 workspace"
cd ${WORKSPACE_DIR}
colcon build --symlink-install

# Add workspace to bashrc if not already there
print_section "Updating environment"
SETUP_LINE="source ${WORKSPACE_DIR}/install/setup.bash"
if ! grep -q "$SETUP_LINE" ~/.bashrc; then
    echo "$SETUP_LINE" >>~/.bashrc
    echo "Added workspace to ~/.bashrc"
else
    echo "Workspace already in ~/.bashrc"
fi

# Set TurtleBot3 model
if ! grep -q "TURTLEBOT3_MODEL" ~/.bashrc.d/ros2.sh; then
    echo 'export TURTLEBOT3_MODEL=burger' >>~/.bashrc
    echo "Set default TurtleBot3 model to burger"
fi

# Source the workspace
source ${WORKSPACE_DIR}/install/setup.bash

print_section "Installation Complete"
echo -e "\033[1;32mTurtleBot3 has been installed successfully!\033[0m"
echo "To use in new terminal sessions, either:"
echo "  1. Start a new terminal, or"
echo "  2. Run: source ~/.bashrc"
echo ""
echo "You can change the TurtleBot3 model by editing the TURTLEBOT3_MODEL environment variable:"
echo "  export TURTLEBOT3_MODEL=burger|waffle|waffle_pi"
echo ""
echo "To test your installation, run:"
echo "  ros2 launch turtlebot3_gazebo empty_world.launch.py"
