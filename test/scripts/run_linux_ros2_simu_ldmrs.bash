#!/bin/bash

#
# Set environment
#

function simu_ldmrs_killall()
{
  sleep 1 ; killall -SIGINT rviz2
  sleep 1 ; killall -SIGINT sick_generic_caller
  sleep 1 ; killall -SIGINT test_server
  sleep 1 ; killall -9 rviz2
  sleep 1 ; killall -9 sick_generic_caller
  sleep 1 ; killall -9 test_server 
  sleep 1
}

simu_ldmrs_killall
printf "\033c"
pushd ../../../..
source ./install/setup.bash

#
# Run LDMRS simulation:
# 1. Start LDRMS test server
# 2. Start LDMRS driver
# 3. Run rviz
# 4. Stop simulation after 20 seconds
#

sleep  1 ; ros2 run sick_scan test_server ./src/sick_scan_xd/tools/test_server/config/test_server_ldmrs.launch &
sleep  1 ; ros2 run sick_scan sick_generic_caller ./src/sick_scan_xd/launch/sick_ldmrs.launch hostname:=127.0.0.1 & 
sleep  1 ; ros2 run rviz2 rviz2 -d ./src/sick_scan_xd/launch/rviz/sick_ldmrs.rviz &
sleep 20 ; ros2 topic echo diagnostics > ./log/sick_ldmrs_diagnostics.log &
sleep  1 ; simu_ldmrs_killall
sleep  1 ; tail -n 62 ./log/sick_ldmrs_diagnostics.log
sleep 3

#
# Run Cola based simulation:
# 1. Start Cola test server
# 2. Start TIM/LMS/MRS driver
# 3. Run rviz
# 4. Stop simulation after 10 seconds
#

for launch_file in sick_tim_240.launch sick_tim_5xx.launch sick_mrs_1xxx.launch ; do
  #sleep  1 ; ros2 run sick_scan test_server --ros-args --params-file src/sick_scan_xd/tools/test_server/config/test_server_cola.yaml &
  sleep  1 ; ros2 run sick_scan test_server ./src/sick_scan_xd/tools/test_server/config/test_server_cola.launch &
  sleep  1 ; ros2 run sick_scan sick_generic_caller ./src/sick_scan_xd/launch/$launch_file hostname:=127.0.0.1 port:=2112 frame_id:=cloud sw_pll_only_publish:=False & 
  sleep  1 ; ros2 run rviz2 rviz2 -d ./src/sick_scan_xd/launch/rviz/sick_cola.rviz &
  sleep 10 ; simu_ldmrs_killall
done

simu_ldmrs_killall
popd

