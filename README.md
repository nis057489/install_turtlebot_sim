# TurtleBot3 Simulator in a portable Distrobox
Script to install TurtleBot3 Simulation on ROS2 Humble

## Set up the ROS/Turtlebot sourcing script
Create a file in `~/.bashrc.d/ros2.sh` with the following contents. (we may need to create the ~/.bashrc.d directory: `mkdir ~/.bashrc.d`

```bash
# This will only run if we opened our shell in a container.
# It will run in any container, but I usually use one of the official OSRF ROS containers.
# If ROS is not installed this script doesn't really affect anything.
if [[ -n "$CONTAINER_ID" ]]; then
    # ROS2 setup
    source /opt/ros/$ROS_DISTRO/setup.bash

    #Turtlebot3 simulation setup
    source ~/turtlebot3_ws/install/setup.bash
    # Tell our shell where to find all the Gazebo models, including the ones in the turtlebot3_gazebo package
    export GAZEBO_MODEL_PATH=~/.gazebo/models:$GAZEBO_MODEL_PATH
    export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:~/turtlebot3_ws/install/turtlebot3_gazebo/share/turtlebot3_gazebo/models
    export TURTLEBOT3_MODEL=waffle_pi

    # Gazebo Setup
    source /usr/share/gazebo/setup.sh
fi
```

## Modify our `~/.bashrc`
While there are tons of online articles that assume *their* software is the only one running on our system, and therefore ask us to mangle our `~/.bashrc` files leading to tears of anguish from broken shell environments, actually it's best practice to keep our default `~/.bashrc` file as stock as possible to prevent any issues during sytem upgrades. We'll add all our customisations (like we just made in `ros2.sh`) to a separate directory, and tell our `~/.bashrc` to load our customisations from there.

Some distributions already include this, so check first, and add this to the end of our `~/.bashrc` file if it is not already there. (Just open it in a text editor and paste that in).

```bash
# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc
```

## Create a Container for our TurtleBot simulator
Create a Turtlebot3 container. We'll use ROS2 Humble, but if we're viewing this later consider using one of the official ROS images found here: https://hub.docker.com/r/osrf/ros/tags

```bash
distrobox create my_humble_turtlebot_container -i osrf/ros:humble-desktop-full
```

### About Distrobox
If the amazing `distrobox` is not installed, just install it with our package manager, e.g. `sudo apt install -y distrobox`. [Distrobox](https://github.com/89luca89/distrobox) wraps container runtimes and creation steps to easily and consistently create highly integrates containers (backed by Docker or Podman runtimes) so that we get all the benefits of walling off volatile parts of our system while maintaining the interactivity of a natively installed app. It's super useful! The `-i` flag lets we use any container image, but there are default ones available too, check the docs!

## Enter Turtlebot Container
```bash
distrobox enter my_humble_turtlebot_container
```

## Download an Run the Installation Script
```bash
curl -O https://raw.githubusercontent.com/nis057489/install_turtlebot_sim/refs/heads/main/setup_turtlebot3_humble.sh && chmod +x ./setup_turtlebot3_humble.sh && ./setup_turtlebot3_humble.sh
```

## Exit and Re-enter the Distrobox
Assuming we have set up the sourcing script the easiest way to start using the turtlebot simulator is to exit and re-enter the container, which will re-source the sourcing scripts.
```bash
exit
distrobox enter my_humble_turtlebot_container
```

## Run as usual
Finally, all the ROS and Turtlebot components should be ready to go and we can just run:

```bash
ros2 launch turtlebot3_gazebo turtlebot3_world.launch.py
```
