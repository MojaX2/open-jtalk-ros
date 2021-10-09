FROM osrf/ros:melodic-desktop-full
MAINTAINER MojaX2 <zawa0319@gmail.com>

ENV ROS_DISTRO melodic

RUN apt-get update && \
    apt-get install -y \
    wget git build-essential unzip \
    mplayer alsa-base alsa-utils pulseaudio \
    open-jtalk-mecab-naist-jdic hts-voice-nitech-jp-atr503-m001 open-jtalk \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


RUN wget https://sourceforge.net/projects/mmdagent/files/MMDAgent_Example/MMDAgent_Example-1.8/MMDAgent_Example-1.8.zip
RUN unzip MMDAgent_Example-1.8.zip
RUN cp -r MMDAgent_Example-1.8/Voice/mei/ /usr/share/hts-voice/

# RUN ln /usr/bin/python3 /usr/bin/python

# passwordなしでsudoできるユーザの作成
ARG USER_ID=1000
ARG GROUP_ID=1000
ENV USER_NAME=developer
RUN groupadd -g ${GROUP_ID} ${USER_NAME} && \
    useradd -d /home/${USER_NAME} -m -s /bin/bash -u ${USER_ID} -g ${GROUP_ID} ${USER_NAME} && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y sudo && \
    echo 'Defaults visiblepw'             >> /etc/sudoers && \
    echo "${USER_NAME} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
WORKDIR /home/${USER_NAME}

# root以外のユーザになって作業を行う
USER ${USER_NAME}

# rosのパス設定
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc
RUN echo "source /home/developer/catkin_ws/devel/setup.bash" >> ~/.bashrc

# wrokspaceの作成
RUN mkdir -p /home/${USER_NAME}/catkin_ws/src
RUN cd /home/${USER_NAME}/catkin_ws/src && \
git clone https://github.com/MojaX2/open-jtalk-ros && \
mv open-jtalk-ros/jtalk .

RUN /bin/bash -c 'source /opt/ros/${ROS_DISTRO}/setup.bash; catkin_init_workspace /home/${USER_NAME}/catkin_ws/src'
RUN /bin/bash -c 'source /opt/ros/${ROS_DISTRO}/setup.bash; cd /home/${USER_NAME}/catkin_ws; catkin_make'

CMD bash