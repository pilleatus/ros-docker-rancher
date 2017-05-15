FROM ros:indigo-robot
ENV ROS_DISTRO indigo
ENV DEBIAN_FRONTEND noninteractive

#default behaviour to avoid roscore-race-conditions when using ROS launch files
ENV WAIT_FOR_ROSCORE 1

# With the following flag it is possible to wait for a ROS parameter from DB,
# therefor the ROS-Node 'config-manager' (https://github.com/strands-project/mongodb_store)
# must be running. The evaluation of this parameter is done in ros_entrypoint.sh
ENV WAIT_FOR_CONFIG_MANAGER 0

#use bash shell
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# get rid of error message:
# libdc1394 error: Failed to initialize libdc1394
# http://stackoverflow.com/questions/12689304/ctypes-error-libdc1394-error-failed-to-initialize-libdc1394
RUN sudo ln /dev/null /dev/raw1394

RUN apt-get update && apt-get -y install wget && \
    sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' && \
    wget https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -O - | sudo apt-key add -

#install system stuff
RUN apt-get clean && \
    apt-get update && apt-get -y install \
    htop \
    mongodb \
    python-pip \
    python-pymongo \
    ssh \
    terminator \
    usbutils \
    vim \
    pulseaudio \
    python-twisted \
    wget

#install some ROS Packages
RUN apt-get update && apt-get -y install \
    ros-$ROS_DISTRO-rviz \
    ros-$ROS_DISTRO-mongodb-store \
    ros-$ROS_DISTRO-openni2-launch

#maybe useful to copy specific ssh keys, for example to have access to private repositories
#COPY .ssh /root/.ssh
#RUN chmod 600 /root/.ssh/id_rsa

# create catkin_ws
RUN source /opt/ros/$ROS_DISTRO/setup.bash && \
    mkdir -p /root/catkin_ws/src && \
    cd /root/catkin_ws/src && \
    catkin_init_workspace && \
    cd /root/catkin_ws && \
    catkin_make && \
    echo "source /root/catkin_ws/devel/setup.bash" >> /root/.bashrc && \

#clone repos
    cd /root/catkin_ws/src && \
    source ../devel/setup.bash && \
    #git clone something...

#build all the stuff
    cd /root/catkin_ws && \
    source devel/setup.bash && \
    #catkin_make -j1 -l1 && \
    catkin_make && \

# https://wiki.ubuntuusers.de/Bash/Prompt/
    echo "PS1='[\[\033[1;31m\]\u\[\033[0m\]@\h \W]\$ '" >> /root/.bashrc

# clean up
RUN sudo rm -rf /var/lib/apt/lists/*

# setup entrypoint (adjusted script for starting ROS container)
COPY ./ros_entrypoint.sh /
ENTRYPOINT ["/ros_entrypoint.sh"]

# default process for a container
CMD roscore
