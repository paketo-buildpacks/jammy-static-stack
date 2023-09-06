FROM ubuntu:jammy

ARG sources
ARG packages
ARG package_args='--no-install-recommends'

RUN echo "$sources" > /etc/apt/sources.list && \
  echo "debconf debconf/frontend select noninteractive" | debconf-set-selections && \
  export DEBIAN_FRONTEND=noninteractive && \
  apt-get -y $package_args update && \
  apt-get -y $package_args upgrade && \
  apt-get -y $package_args install locales && \
  locale-gen en_US.UTF-8 && \
  update-locale LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8 && \
  apt-get -y $package_args install $packages && \
  rm -rf /var/lib/apt/lists/* /tmp/* && \
  for path in /workspace /workspace/source-ws /workspace/source; do git config --system --add safe.directory "${path}"; done
