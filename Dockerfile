FROM centos:7.8.2003

MAINTAINER Joey

# 修改默认时区和字符集
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8
RUN echo "export LANG=en_US.UTF-8" >>  /etc/bashrc  \
    && echo "export LANGUAGE=en_US.UTF-8" >>  /etc/bashrc  \
    && echo "export LC_ALL=en_US.UTF-8" >>  /etc/bashrc  \
    && source /etc/bashrc

# RUN rpm --import /etc/pki/rpm-gpg/RPM*

# 必要工具
RUN yum -y install which wget gcc gcc+ gcc-c++ make autoconf automake libtool ncurses-devel openssl-devel

RUN mkdir /app


####################################################################################################
#
# JDK
#
####################################################################################################
RUN cd /app \
    && wget https://download.java.net/openjdk/jdk12/ri/openjdk-12+32_linux-x64_bin.tar.gz \
    && tar -zxvf openjdk-12+32_linux-x64_bin.tar.gz
ENV JAVA_HOME=/app/jdk-12
ENV PATH=$PATH:$JAVA_HOME/bin
# in case you want to ssh this container 
RUN echo "export JAVA_HOME=$JAVA_HOME" >>  /etc/bashrc  \
    && echo "export PATH=$PATH:$JAVA_HOME/bin" >>  /etc/bashrc \
    && source /etc/bashrc


####################################################################################################
#
# MAVEN
#
####################################################################################################
RUN cd /app \
    && wget --no-check-certificate https://mirrors.bfsu.edu.cn/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz \
    && tar -zxvf apache-maven-3.6.3-bin.tar.gz 
ENV MAVEN_HOME /app/apache-maven-3.6.3
ENV PATH=$PATH:$MAVEN_HOME/bin
# in case you want to ssh this container 
RUN echo "export MAVEN_HOME=$MAVEN_HOME" >>  /etc/bashrc  \
    && echo "export PATH=$PATH:$MAVEN_HOME/bin" >>  /etc/bashrc \
    && source /etc/bashrc

####################################################################################################
#
# CMAKE
#
####################################################################################################
RUN cd /app \
    && wget https://cmake.org/files/v3.17/cmake-3.17.3.tar.gz \
    && tar -zxvf cmake-3.17.3.tar.gz \
    && cd /app/cmake-3.17.3 \
    && ./bootstrap \
    && make \
    && make install \
    && rm -rf /app/cmake-3.17.3


####################################################################################################
#
# PYTHON
#
####################################################################################################
RUN yum install -y zlib zlib-devel libffi-devel \
    && cd /app \
    && wget https://www.python.org/ftp/python/3.8.2/Python-3.8.2.tgz \
    && tar -zxvf Python-3.8.2.tgz \
    && cd /app/Python-3.8.2/ \
    && ./configure \
    && make \
    && make install \
    && python3 -m ensurepip --default-pip 


####################################################################################################
#
# SSH
#
####################################################################################################
#安装openssh-server
RUN yum -y install openssh-server \
    && sed -i 's/#Port 22/Port 22/g' /etc/ssh/sshd_config \
    && sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config \
    && sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config \
    && echo "root:root"|chpasswd
    
####################################################################################################
#
# GCC HIGHER
#
####################################################################################################

RUN yum install -y  centos-release-scl scl-utils scl-utils-build \
    && yum -y install devtoolset-7-gcc devtoolset-7-gcc-c++ devtoolset-7-binutils \
    && yum -y install devtoolset-7-gdb make \
    && yum -y install libatomic
RUN echo "source /opt/rh/devtoolset-7/enable" >> ~/.bashrc


EXPOSE 22

#运行脚本，启动sshd服务
CMD /usr/sbin/sshd -D
