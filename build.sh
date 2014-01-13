#!/bin/bash


# install python-software-properties before trying to add a PPA
sudo apt-get -y update
sudo apt-get install -y python-software-properties

# install apt-fast to speed up later dependency installation
sudo add-apt-repository -y ppa:apt-fast/stable
sudo apt-get -y update
sudo apt-get -y install apt-fast

# install the actual dependencies
sudo apt-fast -y update
sudo apt-fast -y install git-core cmake g++ libboost1.48-dev libmysqlclient-dev \
  libxml2-dev libmcrypt-dev libicu-dev openssl build-essential binutils-dev \
  libcap-dev libgd2-xpm-dev zlib1g-dev libtbb-dev libonig-dev libpcre3-dev \
  autoconf libtool libcurl4-openssl-dev libboost-regex1.48-dev libboost-system1.48-dev \
  libboost-program-options1.48-dev libboost-filesystem1.48-dev libboost-thread1.48-dev \
  wget memcached libreadline-dev libncurses-dev libmemcached-dev libbz2-dev \
  libc-client2007e-dev php5-mcrypt php5-imagick libgoogle-perftools-dev \
  libcloog-ppl0 libelf-dev libdwarf-dev libunwind7-dev subversion

# install gcc 4.7
sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt-get update
sudo apt-get -y install gcc-4.7 g++-4.7
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.7 60 \
                         --slave /usr/bin/g++ g++ /usr/bin/g++-4.7
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.6 40 \
                         --slave /usr/bin/g++ g++ /usr/bin/g++-4.6
sudo update-alternatives --set gcc /usr/bin/gcc-4.7

# Git clone hhvm
git clone https://github.com/facebook/hhvm.git

# init submodules
cd hhvm
git submodule update --init

cd ..
export CMAKE_PREFIX_PATH=`pwd`

# libevent
git clone git://github.com/libevent/libevent.git
cd libevent
git checkout release-1.4.14b-stable
cat ../hphp/third_party/libevent-1.4.14.fb-changes.diff | patch -p1
./autogen.sh
./configure --prefix=$CMAKE_PREFIX_PATH
make
make install
cd ..

# curl
git clone git://github.com/bagder/curl.git
cd curl
./buildconf
./configure --prefix=$CMAKE_PREFIX_PATH
make
make install
cd ..

# glog
svn checkout http://google-glog.googlecode.com/svn/trunk/ google-glog
cd google-glog
./configure --prefix=$CMAKE_PREFIX_PATH
make
make install
cd ..

# jemaloc
wget http://www.canonware.com/download/jemalloc/jemalloc-3.0.0.tar.bz2
tar xjvf jemalloc-3.0.0.tar.bz2
cd jemalloc-3.0.0
./configure --prefix=$CMAKE_PREFIX_PATH
make
make install
cd ..

# cleanup
rm -rf libevent curl google-glog jemalloc-3.0.0.tar.bz2 jemalloc-3.0.0

cd hhvm
export HPHP_HOME=`pwd`
cmake -DENABLE_ZEND_COMPAT=ON .
make
