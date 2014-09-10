#######################################################################
#                                                                     #
# Creates a base CentOS image with JBoss FSW 6.0.0.GA 								#
#                                                                     #
#######################################################################

# Set the base image to CentOS 6
FROM centos:centos6

MAINTAINER rmarins <rmarins@redhat.com>

# Update the system
RUN yum -y update; yum clean all

####### EPEL REPOSITORY ##########
RUN yum -y install http://dl.fedoraproject.org/pub/epel/6Server/x86_64/epel-release-6-8.noarch.rpm ; yum clean all
# disable mirrorlist - broken metalink for epel
RUN sed -i'' 's/^mirrorlist/#mirrorlist/g' /etc/yum.repos.d/epel.repo && \
    sed -i'' 's/^#baseurl/baseurl/g' /etc/yum.repos.d/epel.repo


####### PACKAGES INSTALL #########
RUN yum -y install supervisor java-1.7.0-openjdk openssh-server sudo openssh-clients postgresql httpd mod_cluster ; yum clean all

# disable the mod_proxy_balancer module, it's incompatible with mod_cluster
RUN sed -i -e 's/LoadModule proxy_balancer_module modules\/mod_proxy_balancer.so/#LoadModule proxy_balancer_module modules\/mod_proxy_balancer.so/g' /etc/httpd/conf/httpd.conf

# place our mod_cluster.conf
RUN mv /etc/httpd/conf.d/mod_cluster.conf /etc/httpd/conf.d/mod_cluster.conf-dist
ADD mod_cluster.conf /etc/httpd/conf.d/mod_cluster.conf
RUN chmod 644 /etc/httpd/conf.d/mod_cluster.conf

####### ADD JBOSS USER ###########

# enabling sudo group for jboss
RUN echo '%jboss ALL=(ALL) ALL' >> /etc/sudoers

# Create jboss user
RUN useradd -m -d /home/jboss -p jboss jboss
RUN mkdir -p /home/jboss/.ssh && chmod 700 /home/jboss/.ssh
RUN echo 'jboss:jboss' | chpasswd

# Set root password
RUN echo 'root:jboss' | chpasswd


##########################################################
# Install Java JDK, SSH and other useful cmdline utilities
##########################################################

ENV JAVA_HOME /usr/lib/jvm/jre


############################################
# Install JBoss Fuse Service Works 6.0.0.GA
############################################
RUN mkdir /home/jboss/fsw && \
   mkdir /home/jboss/fsw/software && \
   mkdir /home/jboss/fsw/support && \
   mkdir /home/jboss/fsw/supervisord

# Binaries
ADD jboss-fsw-installer-6.0.0.GA-redhat-4.jar /home/jboss/fsw/software/jboss-fsw-installer-6.0.0.GA-redhat-4.jar 
ADD postgresql-9.2-1004.jdbc4.jar /home/jboss/fsw/software/postgresql-9.2-1004.jdbc4.jar 

# Install scripts
ADD InstallationScript.xml /home/jboss/fsw/support/InstallationScript.xml
ADD InstallationScript.xml.variables /home/jboss/fsw/support/InstallationScript.xml.variables

# Add supervisor.d initializers
ADD sshd.ini /home/jboss/fsw/supervisord/sshd.ini
ADD httpd.ini /home/jboss/fsw/supervisord/httpd.ini
ADD fsw-node1.ini /home/jboss/fsw/supervisord/fsw-node1.ini
ADD fsw-node2.ini /home/jboss/fsw/supervisord/fsw-node2.ini
ADD inet_http_server.ini /home/jboss/fsw/supervisord/inet_http_server.ini

####### BASE SERVICES ############

RUN cat /home/jboss/fsw/supervisord/inet_http_server.ini >> /etc/supervisord.conf && rm -f /home/jboss/fsw/supervisord/inet_http_server.ini
RUN cat /home/jboss/fsw/supervisord/sshd.ini >> /etc/supervisord.conf && rm -f cat /home/jboss/fsw/supervisord/sshd.ini

# sshd
ADD sshd_keygen_init.sh /home/jboss/fsw/support/sshd_keygen_init.sh
RUN chmod +x /home/jboss/fsw/support/sshd_keygen_init.sh && /home/jboss/fsw/support/sshd_keygen_init.sh
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config

####### INSTALL SCRIPT ###########

ADD install_fsw.sh /home/jboss/fsw/support/install_fsw.sh
RUN chmod +x /home/jboss/fsw/support/install_fsw.sh
RUN /home/jboss/fsw/support/install_fsw.sh

RUN cp -r /home/jboss/fsw/jboss-eap-6.1/standalone /home/jboss/fsw/jboss-eap-6.1/fsw1 && cp -r /home/jboss/fsw/jboss-eap-6.1/standalone /home/jboss/fsw/jboss-eap-6.1/fsw2

# Add docker_init.sh
ADD docker_init.sh /docker_init.sh
RUN chmod +x /docker_init.sh

# Command line shortcuts
RUN echo "export JAVA_HOME=/usr/lib/jvm/jre" >> /home/jboss/.bash_profile
RUN echo "alias ll='ls -l --color=auto'" >> /home/jboss/.bash_profile
RUN echo "alias grep='grep --color=auto'" >> /home/jboss/.bash_profile
RUN echo "alias c='clear'" >> /home/jboss/.bash_profile
RUN echo "alias sfsw1='/home/jboss/fsw/jboss-eap-6.1/bin/standalone.sh -c standalone-ha.xml -b 0.0.0.0 -bmanagement 0.0.0.0 -Djboss.server.base.dir=fsw1 -Djboss.node.name=fsw1'" >> /home/jboss/.bash_profile
RUN echo "alias sfsw2='/home/jboss/fsw/jboss-eap-6.1/bin/standalone.sh -c standalone-ha.xml -b 0.0.0.0 -bmanagement 0.0.0.0 -Djboss.server.base.dir=fsw2 -Djboss.node.name=fsw2 -Djboss.socket.binding.port-offset=1000'" >> /home/jboss/.bash_profile
RUN echo "alias xfsw1='/home/jboss/fsw/jboss-eap-6.1/bin/jboss-cli.sh --controller localhost:9999 --commands=connect,:shutdown'" >> /home/jboss/.bash_profile
RUN echo "alias xfsw2='/home/jboss/fsw/jboss-eap-6.1/bin/jboss-cli.sh --controller localhost:10999 --commands=connect,:shutdown'" >> /home/jboss/.bash_profile

###### THE END ###################

# Clean up
RUN rm -rf /home/jboss/fsw/support && \
    rm -rf /home/jboss/fsw/software && \
    rm -rf /home/jboss/fsw/supervisord

# Reset jboss user permissions
RUN chown -R jboss:jboss /home/jboss


EXPOSE 22 80 8080 9001 9080 9990 10990 9999 10999

CMD ["/docker_init.sh"]

# Finished
