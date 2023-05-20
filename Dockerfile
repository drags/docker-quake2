FROM ubuntu:22.04 as builder
RUN apt-get update
RUN apt-get install -y meson gcc libc6-dev libsdl2-dev libopenal-dev \
                libpng-dev libjpeg-dev zlib1g-dev mesa-common-dev \
                libcurl4-gnutls-dev libx11-dev libxi-dev \
                libwayland-dev wayland-protocols libdecor-0-dev \
                libogg-dev libvorbis-dev wget
RUN mkdir /opt/q2pro-src
RUN wget https://skuller.net/q2pro/nightly/q2pro-source.tar.gz -O- | tar zxvf - -C /opt/q2pro-src --strip-components=1
WORKDIR /opt/q2pro-src
RUN meson setup builddir
RUN meson configure -Dprefix=/opt/q2pro builddir
RUN meson compile -C builddir
RUN ninja -C builddir install


FROM ubuntu:22.04 as q2pro
RUN useradd -m -s /bin/bash quake2
COPY --from=builder /opt/q2pro/ /opt/q2pro/
ADD baseq2/ /opt/q2pro/share/q2pro/baseq2/
RUN chown -R quake2:quake2 /opt/q2pro
EXPOSE 27910
WORKDIR /opt/q2pro/
USER quake2
#RUN /bin/bash
CMD bin/q2proded +exec server.cfg +set dedicated 1 +set deathmatch 1
