########################################################################
# Dockerfile for Oracle JDK 8 on Ubuntu 14.04
# contains following R versions:
#   - 3.4.1
#   - 3.3.3
#   - 3.2.5
#   - 3.1.3
#   - 3.0.3
#   - installed R versions can be overriden by setting the R_VERSIONS build arg
########################################################################

# pull base image
FROM ubuntu:16.04

# maintainer details
MAINTAINER h2oai "h2o.ai"

ARG R_VERSIONS='3.4.1,3.3.3,3.2.5,3.1.3,3.0.3'
ARG H2O_USER_UID=1000

# Initialize apt sources
RUN \
  echo 'DPkg::Post-Invoke {"/bin/rm -f /var/cache/apt/archives/*.deb || true";};' | tee /etc/apt/apt.conf.d/no-cache && \
  echo "deb http://ap-northeast-1.ec2.archive.ubuntu.com/ubuntu xenial main universe" >> /etc/apt/sources.list && \
  echo "deb http://cran.mtu.edu/bin/linux/ubuntu xenial/" >> /etc/apt/sources.list.d/cran.list && \
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 51716619E084DAB9 && \
  apt-get update -q -y && \
  apt-get dist-upgrade -y && \
  apt-get clean && \
  rm -rf /var/cache/apt/*

# Install packages
RUN \
  DEBIAN_FRONTEND=noninteractive apt-get install -y wget curl s3cmd libffi-dev libxml2-dev libssl-dev libcurl4-openssl-dev libfreetype6 libfreetype6-dev libfontconfig1 libfontconfig1-dev build-essential chrpath libssl-dev libxft-dev git unzip python-pip python-dev python-virtualenv libmysqlclient-dev texlive texlive-fonts-extra texlive-htmlxml python3 python3-dev python3-pip python3-virtualenv software-properties-common python-software-properties texinfo texlive-bibtex-extra texlive-formats-extra texlive-generic-extra

# Install Java
RUN \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update -q -y && \
  echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y oracle-java8-installer

# Install nodeJS
RUN \
  curl -sL https://deb.nodesource.com/setup_7.x | bash - && \
  apt-get update -q -y && \
  apt-get install -y nodejs

# Install R build dependencies
RUN \
  apt-get -y build-dep r-base

# Install from source dependencies
RUN \
  wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 && \
  tar xvjf phantomjs-2.1.1-linux-x86_64.tar.bz2 -C /usr/local/share/ && \
  rm phantomjs-2.1.1-linux-x86_64.tar.bz2 && \
  ln -sf /usr/local/share/phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin && \
  apt-get clean

RUN \
  virtualenv -p python2 /envs/h2o_env_python2.7 && \
  chmod a+w /envs/h2o_env_python2.7 && \
  virtualenv -p python3 /envs/h2o_env_python3.5 && \
  chmod a+w /envs/h2o_env_python3.5

# Install python dependencies for all virtualenvs
RUN \
  wget https://raw.githubusercontent.com/h2oai/h2o-3/master/h2o-py/requirements.txt && \
  . /envs/h2o_env_python2.7 && \
  pip install --upgrade pip && \
  pip install -r requirements.txt && \
  . /envs/h2o_env_python3.5 && \
  pip install --upgrade pip && \
  pip install -r requirements.txt && \
  rm requirements.txt

# Copy R installation script and install R with different versions
COPY scripts/install_R_version scripts/install_R_versions /usr/sbin/
RUN chmod 700 /usr/sbin/install_R_version && \
  chmod 700 /usr/sbin/install_R_versions && \
  sync && \
  install_R_versions
ENV PATH ${PATH}:/usr/local/R/current/bin/

# Expose ports for services
EXPOSE 54321
EXPOSE 8080

CMD \
  ["/bin/bash"]
