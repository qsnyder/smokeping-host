FROM phusion/baseimage:0.9.18
MAINTAINER qms (github.com/qsnyder)

# Borrowed heavily from safelink-internet's smokeping Docker container
# Modified as required due to lack of email, etc requirements

# Maintained as part of the deployment automation practice
# to be used for testing and validation of reachability and latency during network changeover

# Set the apache2 environment
ENV DEBIAN_FRONTEND="noninteractive" HOME="/root" TERM="xterm" APACHE_LOG_DIR="/var/log/apache2" APACHE_LOCK_DIR="/var/lock/apache2" APACHE_PID_FILE="/var/run/apache2.pid"

# Set up the smokeping environment

RUN apt-get update && \
apt-get install -y smokeping && \
ln -s /etc/smokeping/apache2.conf /etc/apache2/conf-available/apache2.conf && \
a2enconf apache2 && \
a2enmod cgid && \
apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Run a few things to ensure smokeping starts
ADD init/ /etc/my_init.d/
ADD services/ /etc/service/
RUN chmod -v +x /etc/service/*/run
RUN chmod -v +x /etc/my_init.d/*.sh
RUN mkdir /var/run/smokeping

# Use baseimage-docker's init system (much better than stock ubuntu)
CMD ["/sbin/my_init"]

# expose volumes and ports for inter-container communication
EXPOSE 80