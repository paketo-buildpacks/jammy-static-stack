FROM ubuntu:jammy AS builder

ARG packages

RUN apt-get update && \
  apt-get install -y xz-utils binutils zstd

ADD install-certs.sh .

ADD files/passwd /static/etc/passwd
ADD files/nsswitch.conf /static/etc/nsswitch.conf
ADD files/group /static/etc/group
ADD files/os-release /static/etc/os-release

RUN mkdir -p /static/tmp /static/var/lib/dpkg/status.d/

# We can't use dpkg -i (even with --instdir=/static) because we don't want to
# install the dependencies, and dpkg-deb has no way to ignore all dependencies;
# each dependency must be explicitly listed
RUN apt download $packages \
    && for pkg in $packages; do \
      dpkg-deb --field $pkg*.deb > /static/var/lib/dpkg/status.d/$pkg \
      && dpkg-deb --extract $pkg*.deb /static; \
    done

RUN ./install-certs.sh

RUN find /static/usr/share/doc/*/* ! -name copyright | xargs rm -rf && \
  rm -rf \
    /static/etc/update-motd.d/* \
    /static/usr/share/man/* \
    /static/usr/share/lintian/*

# Distroless images use /var/lib/dpkg/status.d/<file> instead of /var/lib/dpkg/status
RUN rm -rf /static/var/lib/dpkg/status

FROM scratch
COPY --from=builder /static/ /

