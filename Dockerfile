FROM scratch

ENV BOOST_LIB_SUFFIX=-mt

ADD ubuntu-9.04-root.tar.xz /

RUN cat <<EOF > /etc/apt/sources.list
deb http://old-releases.ubuntu.com/ubuntu jaunty main multiverse restricted universe
deb http://old-releases.ubuntu.com/ubuntu jaunty-backports main multiverse restricted universe
deb http://old-releases.ubuntu.com/ubuntu jaunty-proposed main multiverse restricted universe
deb http://old-releases.ubuntu.com/ubuntu jaunty-security main multiverse restricted universe
deb http://old-releases.ubuntu.com/ubuntu jaunty-updates main multiverse restricted universe
EOF

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y libssl-dev gcc g++ libboost1.37-dev

WORKDIR /tmp

COPY ./db-4.8.30.NC.tar.gz /tmp/
RUN tar xf db-4.8.30.NC.tar.gz
COPY ./miniupnpc-1.6.tar.gz /tmp/
RUN tar xf miniupnpc-1.6.tar.gz

# Install Berkeley DB
RUN cd /tmp/ \
  && cd db-4.8.30.NC \
  && mkdir -p build \
  && sed -i 's/__atomic_compare_exchange/__atomic_compare_exchange_db/g' dbinc/atomic.h \
  && cd build_unix \
  && ../dist/configure --disable-shared --enable-cxx --with-pic --prefix=/usr/local/ \
  && make install

# Install miniupnpc
RUN cd /tmp/ \
  && tar xf miniupnpc-1.6.tar.gz \
  && cd miniupnpc-1.6 \
  && make -j$(nproc) \
  && make install

