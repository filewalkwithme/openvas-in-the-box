FROM debian:stretch

RUN apt-get update

RUN apt-get install git vim -y

############################################
# GVM-LIBS v11.0.0 #########################
############################################

# Dependencies for gvm-libs v11.0.0
RUN apt-get install \
    cmake \
    libglib2.0-dev \
    libgnutls28-dev \
    libgpgme11-dev \
    libhiredis-dev \
    libldap2-dev \
    libssh-gcrypt-dev \
    pkg-config \
    uuid-dev \
    -y

RUN git clone https://github.com/greenbone/gvm-libs.git /gvm-libs

# Build gvm-libs v11.0.0 from sources
WORKDIR /gvm-libs
RUN git checkout v11.0.0
RUN mkdir build
WORKDIR /gvm-libs/build
RUN cmake ..
RUN make
RUN make install
RUN make rebuild_cache

############################################
# OPENVAS v7.0.0 ###########################
############################################

# Dependencies for openvas v7.0.0
RUN apt-get install \
    bison \
    gcc \ 
    libgcrypt20-dev \
    libglib2.0-dev \
    libgnutls28-dev \
    libgpgme-dev \
    libksba-dev \
    libpcap-dev \
    libsnmp-dev \
    libssh-gcrypt-dev \
    pkg-config \
    -y

RUN git clone https://github.com/greenbone/openvas.git /openvas

# Build openvas v7.0.0 from sources
WORKDIR /openvas
RUN git checkout v7.0.0
RUN mkdir build
WORKDIR /openvas/build
RUN cmake ..
RUN make
RUN make install
RUN make rebuild_cache


############################################
# OSPD v2.0.0 ##############################
############################################

# Dependencies for ospd v2.0.0
RUN apt-get install \
    python3-defusedxml \
    python3-lxml \
    python3-paramiko \ 
    python3-pip \
    python3-setuptools \
     -y

RUN git clone https://github.com/greenbone/ospd.git /ospd

# Build ospd v2.0.0 from source
WORKDIR /ospd
RUN git checkout v2.0.0
RUN python3 setup.py install


############################################
# OSPD-OPENVAS v1.0.0 ######################
############################################

# Dependencies for ospd-openvas v1.0.0
RUN apt-get install \
    psutils \
    redis-server \
    -y

RUN git clone https://github.com/greenbone/ospd-openvas.git /ospd-openvas

# Build ospd-openvas v1.0.0 from sources
WORKDIR /ospd-openvas
RUN git checkout v1.0.0
RUN python3 setup.py install


############################################
# GVMD v9.0.0 ##############################
############################################

# Dependencies for gvmd v9.0.0
RUN apt-get install \
    cmake \
    gnutls-bin \
    libical-dev \
    libpq-dev \
    postgresql \
    postgresql-contrib \
    postgresql-server-dev-all \
    -y

RUN git clone https://github.com/greenbone/gvmd.git /gvmd

# Build gvmd v9.0.0 from sources
WORKDIR /gvmd
RUN git checkout v9.0.0
RUN mkdir build
WORKDIR /gvmd/build
RUN cmake ..
RUN make
RUN make install
RUN make rebuild_cache


############################################
# GVMD-TOOLS v2.0.0 ########################
############################################

RUN git clone https://github.com/greenbone/gvm-tools /gvm-tools

# Build gvm-tools v2.0.0 from sources
WORKDIR /gvm-tools
RUN git checkout v2.0.0
RUN pip3 install -e .


############################################
# GSA v9.0.0 ###############################
############################################

# Dependencies for gsa v9.0.0
RUN apt-get install \
    libmicrohttpd-dev \
    pkg-config \
    gnutls-bin \
    libgcrypt20-dev \
    libglib2.0-dev \
    libxml2-dev \
    #clang-format \
    curl \ 
    apt-transport-https \
    -y

RUN git clone https://github.com/greenbone/gsa.git /gsa

RUN curl --silent --show-error https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && curl --silent --show-error https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - \
    && echo "deb https://deb.nodesource.com/node_8.x stretch main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install nodejs yarn -y

# Build gsa v9.0.0 from sources
WORKDIR /gsa
RUN git checkout v9.0.0
RUN mkdir build
WORKDIR /gsa/build
RUN cmake ..
RUN make
RUN make install
RUN make rebuild_cache


############################################
# CONFIGURE REDIS ##########################
############################################

WORKDIR /

# Configure Redis for Openvas
ADD redis-openvas.conf /etc/redis/redis.conf
RUN echo "db_address = /var/run/redis/redis.sock" > /usr/local/etc/openvas/openvas.conf


################################################
# CONFIGURE USER AND PERMISSIONS FOR NVT-SYNC ##
################################################

# Set permissions for NVT sync
RUN useradd -m openvas
RUN chown openvas:openvas /usr/local/var/lib/openvas/plugins


############################################
# CONFIGURE POSTGRES #######################
############################################

# # Setting up the PostgreSQL database
ADD setup_postgres.sh setup_postgres.sh
RUN ./setup_postgres.sh

# Make Postgres aware of the gvm libraries
ADD ld.so.conf.d/gvm.conf /etc/ld.so.conf.d/gvm.conf
RUN ldconfig


############################################
# CREATE CERTIFICATES ######################
############################################

# Create certificates
RUN gvm-manage-certs -a


############################################
# SETUP OPENVAS ############################
############################################

RUN apt-get install \
    nmap \
    -y

ADD setup_openvas.sh setup_openvas.sh
RUN ./setup_openvas.sh


############################################
# INSTALL BOOT SCRIPT ######################
############################################

ADD boot.sh /boot.sh
CMD /boot.sh
