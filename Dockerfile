FROM debian:latest

ENV USE_UPNP=

WORKDIR /tmp

COPY ./db-4.8.30.NC.tar.gz /tmp/
RUN tar xf db-4.8.30.NC.tar.gz
COPY ./boost_1_37_0.tar.gz /tmp/
RUN tar xf boost_1_37_0.tar.gz
COPY ./miniupnpc-1.6.tar.gz /tmp/
RUN tar xf miniupnpc-1.6.tar.gz
COPY ./openssl-0.9.8g.tar.gz /tmp/
RUN tar xf openssl-0.9.8g.tar.gz
COPY ./libssl-dev_0.9.8k-7ubuntu8.8_amd64.deb /tmp/

# Allow non-validated apt sources
RUN echo 'Acquire::Check-Valid-Until false;' > /etc/apt/apt.conf.d/99no-check-valid-until

RUN apt-get update \
  && apt-get install -y vim wget build-essential

# Clean apt cache
RUN apt-get clean
RUN rm /etc/apt/sources.list.d/debian.sources
RUN cat <<EOF > /etc/apt/sources.list
deb     [trusted=yes] http://snapshot.debian.org/archive/debian/20100101T152753Z/ squeeze main
deb-src [trusted=yes] http://snapshot.debian.org/archive/debian/20100101T152753Z/ squeeze main
deb     [trusted=yes] http://snapshot.debian.org/archive/debian-security/20100101T152753Z/ squeeze/updates main
deb-src [trusted=yes] http://snapshot.debian.org/archive/debian-security/20100101T152753Z/ squeeze/updates main
EOF

RUN apt-get update

# Install Berkeley DB
RUN cd /tmp/ \
  && cd db-4.8.30.NC \
  && mkdir -p build \
  && sed -i 's/__atomic_compare_exchange/__atomic_compare_exchange_db/g' dbinc/atomic.h \
  && cd build_unix \
  && ../dist/configure --disable-shared --enable-cxx --with-pic --prefix=/usr/local/ \
  && make install

RUN apt-get clean

# # Install miniupnpc
# RUN cd /tmp/ \
#   && tar xf miniupnpc-1.6.tar.gz \
#   && cd miniupnpc-1.6 \
#   && make -j$(nproc) \
#   && make install

# Install libssl-dev
RUN cd /tmp/ \
  && dpkg --force-all -i ./libssl-dev_0.9.8k-7ubuntu8.8_amd64.deb

RUN cd /tmp/boost_1_37_0 \
  && ./configure \
  && make -j$(nproc) \
  && make install

# RUN cd /tmp && \
#   apt download libboost-all-dev; dpkg -x libboost-all-dev*.deb

