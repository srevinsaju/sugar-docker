FROM ubuntu:latest
LABEL maintainer="srevinsaju@sugarlabs.org"
LABEL version="0.1"
LABEL description="A docker image with prebuilt Sugar Desktop"
ARG DEBIAN_FRONTEND=noninteractive

# create a user
RUN useradd -ms /bin/bash sugar && usermod -a -G sudo sugar

WORKDIR /usr/src/app

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
WORKDIR /home/sugar

CMD ["/usr/bin/sugar"]
