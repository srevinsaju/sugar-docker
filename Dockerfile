# (C) MIT License 2020-21
# Some part of this file is copied from https://github.com/gitpod-io/workspace-images/tree/master/full-vnc

FROM ubuntu:latest
LABEL maintainer="srevinsaju@sugarlabs.org"
LABEL version="0.1"
LABEL description="A docker image with prebuilt Sugar Desktop"
ARG DEBIAN_FRONTEND=noninteractive

# create a user
RUN useradd -ms /bin/bash sugar && usermod -a -G sudo sugar

WORKDIR /usr/src/app


# Install Xvfb
RUN apt-get update \
    && apt-get install -yq xvfb x11vnc xterm \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*

# Install novnc
RUN git clone https://github.com/novnc/noVNC.git /opt/novnc \
    && git clone https://github.com/novnc/websockify /opt/novnc/utils/websockify
COPY novnc-index.html /opt/novnc/index.html

# Add VNC startup script
COPY start-vnc-session.sh /usr/bin/
RUN chmod +x /usr/bin/start-vnc-session.sh

RUN \
        # enable deb-src source repositories
        sed -i '/deb-src/s/^# //' /etc/apt/sources.list && \
        # install the runtime dependencies
        apt update && apt install -y git python3-decorator python3-dbus gir1.2-gstreamer-1.0 \
        gir1.2-soup-2.4 gir1.2-wnck-3.0 gir1.2-webkit2-4.0 gir1.2-vte-2.91 \
        gir1.2-telepathyglib-0.12 python3-xapian python3-dateutil gir1.2-gtksource-3.0 \
        gir1.2-xkl-1.0 python3-pip python3-gi-cairo telepathy-gabble sudo \
        metacity telepathy-mission-control-5 \
        python-six python3-six python3-empy python3-pip && \
        python3 -m pip install gwebsockets && \
        # cleanup
        rm -rf /var/lib/apt/lists/* && apt clean && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/sugarlabs/sugar-toolkit-gtk3 --depth=1 && \
    cd sugar-toolkit-gtk3 && \
    # install some build dependencies
    apt update && \
    apt build-dep -y sugar-artwork sugar-toolkit-gtk3 && \
    # install it systemwide
    PYTHON=/usr/bin/python3 ./autogen.sh --with-python3 --prefix=/usr && \
    make && make install && \
    cd .. && \
    rm -rf sugar-toolkit-gtk3 && \
    # cleanup
    rm -rf /var/lib/apt/lists/* && apt clean && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/sugarlabs/sugar --depth=1 && \
    cd sugar && \
    # install it systemwide
    PYTHON=/usr/bin/python3 ./autogen.sh --with-python3 --prefix=/usr && \
    make && make install && \
    cd .. && \
    rm -rf sugar


RUN git clone https://github.com/sugarlabs/sugar-datastore --depth=1 && \
    cd sugar-datastore && \
    # install it systemwide
    PYTHON=/usr/bin/python3 ./autogen.sh --with-python3 --prefix=/usr && \
    make && make install && \
    cd .. && \
    rm -rf sugar-datastore

RUN git clone https://github.com/sugarlabs/sugar-artwork --depth=1 && \
    cd sugar-artwork && \
    # install it systemwide
    PYTHON=/usr/bin/python3 ./autogen.sh --with-python3 --prefix=/usr && \
    make && make install && \
    cd .. && \
    rm -rf sugar-artwork

# create activities directory
RUN mkdir -p /usr/share/sugar/activities && \
        git clone https://github.com/sugarlabs/Terminal-activity /usr/share/sugar/activities/Terminal.activity


# test
RUN mkdir -p /usr/lib/python3.8/dist-packages && mv /usr/lib/python3.8/site-packages/* /usr/lib/python3.8/dist-packages/.

USER sugar


# This is a bit of a hack. At the moment we have no means of starting background
# tasks from a Dockerfile. This workaround checks, on each bashrc eval, if the X
# server is running on screen 0, and if not starts Xvfb, x11vnc and novnc.
RUN echo "[ ! -e /tmp/.X0-lock ] && (/usr/bin/start-vnc-session.sh 0 &> /tmp/display-0.log)" >> ~/.bashrc
RUN echo "export DISPLAY=:0" >> ~/.bashrc



WORKDIR /home/sugar

CMD ["/usr/bin/sugar"]
