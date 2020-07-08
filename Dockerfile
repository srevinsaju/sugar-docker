FROM ubuntu:latest
LABEL maintainer="srevinsaju@sugarlabs.org"
LABEL version="0.1"
LABEL description="A docker image with prebuilt Sugar Desktop"
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update

# clone Sugar and deps

# enable source packages
RUN sed -i '/deb-src/s/^# //' /etc/apt/sources.list
RUN apt update

WORKDIR /usr/src/app

COPY sugar .
COPY sugar-artwork .
COPY sugar-datastore .
COPY sugar-toolkit-gtk3 . 
COPY sugar-toolkit . 

# install build time deps
# RUN apt build-dep sugar-datastore
RUN apt build-dep -y sugar-artwork
# RUN apt build-dep -y sugar-toolkit 
RUN apt build-dep -y sugar-toolkit-gtk3
# RUN apt build-dep -y sugar

RUN apt install -y python-six python3-six python3-empy

ADD sugar /usr/src/app/sugar
ADD sugar-toolkit /usr/src/app/sugar-toolkit
ADD sugar-artwork /usr/src/app/sugar-artwork
ADD sugar-toolkit-gtk3 /usr/src/app/sugar-toolkit-gtk3
ADD sugar-datastore /usr/src/app/sugar-datastore

# make sugar-artwork
WORKDIR /usr/src/app/sugar-artwork
RUN PYTHON=/usr/bin/python3 ./autogen.sh --with-python3 --prefix=/usr
RUN make                                 
RUN make install

# make sugar-toolkit-gtk3
WORKDIR /usr/src/app/sugar-toolkit-gtk3
RUN PYTHON=/usr/bin/python3 ./autogen.sh --with-python3 --prefix=/usr
RUN make                                 
RUN make install

# make sugar-datastore
RUN apt install -y python3-dev
WORKDIR /usr/src/app/sugar-datastore
RUN PYTHON=/usr/bin/python3 ./autogen.sh --with-python3 --prefix=/usr
RUN make                                 
RUN make install
 
# make sugar
WORKDIR /usr/src/app/sugar
RUN PYTHON=/usr/bin/python3 ./autogen.sh --with-python3 --prefix=/usr
RUN make                                 
RUN make install 

RUN apt install -y python3-decorator python3-dbus gir1.2-gstreamer-1.0
RUN apt install -y gir1.2-soup-2.4
RUN apt install -y gir1.2-wnck-3.0 gir1.2-webkit2-4.0 gir1.2-vte-2.91
RUN apt install -y gir1.2-telepathyglib-0.12
RUN apt install -y python3-xapian
RUN apt install -y python3-dateutil
RUN apt install -y gir1.2-gtksource-3.0
RUN apt install -y gir1.2-xkl-1.0

# install gwebsockets
RUN apt install -y python3-pip
RUN python3 -m pip install gwebsockets

# install metacity
RUN apt install -y metacity 

# install cairo
RUN apt install -y python3-gi-cairo
RUN apt install -y telepathy-gabble
# install sudo
RUN apt install -y sudo

# install telepathy mission control
RUN apt install -y telepathy-mission-control-5

# create activities directory
RUN mkdir -p /usr/share/sugar/activities

WORKDIR /usr/share/sugar/activities
ADD Terminal-activity /usr/share/sugar/activities/Terminal.activity
# clean
# RUN rm -rf /var/lib/apt/lists/* && apt clean
RUN rm -rf /usr/src/app/sugar*

# test
RUN mkdir -p /usr/lib/python3.8/dist-packages
RUN mv /usr/lib/python3.8/site-packages/* /usr/lib/python3.8/dist-packages/.

# create a user
RUN useradd -ms /bin/bash sugar
RUN usermod -a -G sudo sugar
USER sugar
WORKDIR /home/sugar

CMD ["/usr/bin/sugar"]
