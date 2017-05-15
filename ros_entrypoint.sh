#!/bin/bash
set -e
# setup ros environment
source "/root/catkin_ws/devel/setup.bash"

# to ensure that the roscore container will be used for roscore
if [ -z ${WAIT_FOR_ROSCORE+0} ]
then 
  echo "WAIT_FOR_ROSCORE variable not set -> program processing continues";
else
  if [ ${WAIT_FOR_ROSCORE} -eq 1 ]
  then
    echo "WAIT_FOR_ROSCORE == 1 -> waiting for roscore being started.."
    while ! rostopic list > /dev/null; do
	sleep 1
    done
    echo "roscore ready"
  fi
fi

#wait until default parameter are loaded from database
if [ -z ${WAIT_FOR_CONFIG_MANAGER+0} ]
then
  echo "WAIT_FOR_CONFIG_MANAGER variable not set -> program processing continues";
else
  if [ ${WAIT_FOR_CONFIG_MANAGER} == 0 ]
  then
    echo "WAIT_FOR_CONFIG_MANAGER == 0 -> program processing continues";
  else
    echo "WAIT_FOR_CONFIG_MANAGER with variable $WAIT_FOR_CONFIG_MANAGER";
    rosservice call --wait /config_manager/get_param ${WAIT_FOR_CONFIG_MANAGER}
  fi
fi

exec "$@"
