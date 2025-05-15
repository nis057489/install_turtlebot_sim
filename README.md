# install_turtlebot_sim
Script to install TurtleBot3 Simulation on ROS2 Humble

Create a file in `~/.bashrc.d/ros2.sh` with the following contents. (You may need to create the ~/.bashrc.d directory: `mkdir ~/.bashrc.d/ros2.sh`

## Set up the ROS/Turtlebot sourcing script
```bash
# This will only run if you opened your shell in a container.
# It will run in any container, but I usually use one of the official OSRF ROS containers.
# If ROS is not installed this script doesn't really affect anything.
if [[ -n "$CONTAINER_ID" ]]; then
    # ROS2 setup
    source /opt/ros/$ROS_DISTRO/setup.bash

    #Turtlebot3 simulation setup
    source ~/turtlebot3_ws/install/setup.bash
    # Needed to run Gazebo
    source /usr/share/gazebo/setup.sh
    # Tell your shell where to find all the Gazebo models, including the ones in the turtlebot3_gazebo package
    export GAZEBO_MODEL_PATH=~/.gazebo/models:$GAZEBO_MODEL_PATH
    export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:~/turtlebot3_ws/install/turtlebot3_gazebo/share/turtlebot3_gazebo/models
    export TURTLEBOT3_MODEL=waffle_pi

fi
```

## Create a Container for your TurtleBot simulator
Create a Turtlebot3 container. We'll use ROS2 Humble, but if you're viewing this later consider using one of the official ROS images found here: https://hub.docker.com/r/osrf/ros/tags

```bash
distrobox create my_humble_turtlebot_container -i osrf/ros:humble-desktop-full
```

### About Distrobox
If the amazing `distrobox` is not installed, just install it with your package manager, e.g. `sudo apt install -y distrobox`. [Distrobox](https://github.com/89luca89/distrobox) is a script that highly integrates containers (backed by Docker or Podman runtimes) so that you get all the benefits of walling off volatile parts of your system while maintaining the interactivity of a natively installed app. It's super useful! The `-i` flag lets you use any container image, but there are default ones available too, check the docs!

## Enter Turtlebot Container
```bash
distrobox enter my_humble_turtlebot_container
```

## Download an Run the Installation Script
```bash
curl -O https://raw.githubusercontent.com/nis057489/install_turtlebot_sim/refs/heads/main/setup_turtlebot3_humble.sh && chmod +x ./setup_turtlebot3_humble.sh && ./setup_turtlebot3_humble.sh
```

## Exit and Re-enter the Distrobox
Assuming you have set up the sourcing script the easiest way to start using the turtlebot simulator is to exit and re-enter the container, which will re-source the sourcing scripts.
```bash
exit
distrobox enter my_humble_turtlebot_container
```

## Run as usual
 then all the ROS and Turtlebot components should be ready to go and you can just run:

```bash
ros2 launch turtlebot3_gazebo turtlebot3_world.launch.py
```
