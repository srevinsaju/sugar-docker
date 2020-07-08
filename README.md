# sugar-docker (beta) :whale:

[![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/srevinsaju/sugar?logo=docker)
![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/srevinsaju/sugar)
![Docker Pulls](https://img.shields.io/docker/pulls/srevinsaju/sugar)
![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/srevinsaju/sugar?sort=date)
![Docker Image Version (latest by date)](https://img.shields.io/docker/v/srevinsaju/sugar)](https://hub.docker.com/r/srevinsaju/sugar)

A docker image for sugar desktop

An attempt to make Sugar possible to be installed as a Docker Container, or as a Desktop App! :smile: :whale:


## Getting Started

* **Install Docker.**
  
  Docker is a tool that is designed to benefit both developers and 
  system administrators, making it a part of many DevOps (developers + operations) 
  toolchains. For developers, it means that they can focus on writing code without 
  worrying about the system that it will ultimately be running on. It also allows 
  them to get a head start by using one of thousands of programs already designed to 
  run in a Docker container as a part of their application. For operations staff, Docker 
  gives flexibility and potentially reduces the number of systems needed because of 
  its small footprint and lower overhead.  ~ _[opensource.com](https://opensource.com/resources/what-docker)_
  
  
* Pull the container
  ```bash
  docker pull srevinsaju/sugar
  ```
  
* Optional. Suggested : Install `x11docker`.
  
  `x11docker` is a tool that enables a user to run a desktop environment within a docker container. 
  ```bash
  curl -fsSL https://raw.githubusercontent.com/mviereck/x11docker/master/x11docker | sudo bash -s -- --update
  ```

* Run the container
  
  ```bash
  x11docker --desktop srevinsaju/sugar
  ```
* To also integrate your the home directory of the container with a folder use the `-m` option
  ```bash
  x11docker --desktop srevinsaju/sugar -m
  ```
  
  This will give read / write access to the home directory of the logged in used of `srevinsaju/sugar`. The integrated directory will be 
  created in `~/.local/share/x11docker/sugar/`
  
  

  
  
  
  
