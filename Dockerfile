FROM ubuntu:16.04

MAINTAINER Unoparty Developers <dev@unobtanium.uno>

# PyEnv
ENV PYENV_ROOT /root/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
# Configure Python not to try to write .pyc files on the import of source modules
ENV PYTHONDONTWRITEBYTECODE true
ENV PYTHON_VERSION 3.6.2

RUN apt-get update -q \
            && apt-get install -y --no-install-recommends \
            apt-utils \
            ca-certificates \
            wget \
            build-essential \
            ca-certificates \
            curl \
            unzip \
            vim \
            git \
            mercurial \
            software-properties-common \
            gettext-base \
            libbz2-dev \
            net-tools \
            iputils-ping \
            telnet \
            lynx \
            locales \
            libreadline-dev \
            libsqlite3-dev \
            libssl-dev \
            zlib1g-dev

# Install pyenv and default python version
RUN git clone https://github.com/pyenv/pyenv.git /root/.pyenv \
            && cd /root/.pyenv \
            && git checkout `git describe --abbrev=0 --tags` \
            && echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.bashrc \
            && echo 'eval "$(pyenv init -)"'               >> ~/.bashrc

RUN pyenv install $PYTHON_VERSION && pyenv global $PYTHON_VERSION

# Set locale
RUN dpkg-reconfigure -f noninteractive locales && \
            locale-gen en_US.UTF-8 && \
            /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Set home dir env variable
ENV HOME /root

# Install extra unoblock deps
RUN apt-get update -q \
            && apt-get -y upgrade \
            && apt-get install -y --no-install-recommends \
            libjpeg8-dev \
            libgmp-dev \
            libzmq3-dev \
            libxml2-dev \
            libxslt-dev \
            zlib1g-dev \
            libimage-exiftool-perl \
            libevent-dev \
            cython

# Install
COPY requirements.txt /unoblock/
COPY setup.py /unoblock/
COPY ./unoblock/lib/config.py /unoblock/unoblock/lib/
WORKDIR /unoblock
RUN pip3 install --upgrade pip
RUN pip3 install --upgrade -vv setuptools
RUN pip3 install -r requirements.txt
COPY . /unoblock
RUN python3 setup.py develop

COPY docker/server.conf /root/.config/unoblock/server.conf
COPY docker/modules.conf /root/.config/unoblock/modules.conf
COPY docker/modules.conf /root/.config/unoblock/modules.testnet.conf
COPY docker/modules.conf /root/.config/unoblock/modules.regtest.conf
COPY docker/unowallet.conf /root/.config/unoblock/unowallet.conf
COPY docker/start.sh /usr/local/bin/start.sh
RUN chmod a+x /usr/local/bin/start.sh

EXPOSE 4420 4421 4422 14420 14421 14422

ENTRYPOINT ["start.sh"]
