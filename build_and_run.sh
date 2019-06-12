#!/bin/bash
set -e
set -x
IMAGE_NAME="moja2/open-jtalk-ros"

docker build -t ${IMAGE_NAME}:latest .

# set pulseaudio for using sound device
rm -rf /tmp/pulseaudio.*
pactl load-module module-native-protocol-unix socket=/tmp/pulseaudio.socket
cp pulseaudio.client.conf /tmp/pulseaudio.client.conf

docker run --rm -it \
    --name open-jtalk-ros \
    --net host \
    --env PULSE_SERVER=unix:/tmp/pulseaudio.socket \
    --env PULSE_COOKIE=/tmp/pulseaudio.cookie \
    --volume /tmp/pulseaudio.socket:/tmp/pulseaudio.socket \
    --volume /tmp/pulseaudio.client.conf:/etc/pulse/client.conf \
    -v /etc/localtime:/etc/localtime:ro \
    ${IMAGE_NAME}:latest bash -c "source /home/developer/catkin_ws/devel/setup.bash && roslaunch jtalk jtalk.launch"