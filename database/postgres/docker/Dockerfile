# Set the base image to CentOS 7
FROM centos:centos7

# File Author / Maintainer
MAINTAINER "Rafael Marins" "rmarins@redhat.com"

# Update the repository sources list
RUN yum update -y; yum clean all

## Install and configure SSH server
#RUN yum -y install openssh-server; yum clean all
#RUN sed -i '/#PermitRootLogin yes/c\PermitRootLogin without-password' /etc/ssh/sshd_config

####### INSTALL PostgreSQL ############
RUN yum -y install postgresql-server postgresql-contrib; yum clean all

####### Configure PostgreSQL ############
USER postgres

RUN /usr/bin/initdb -D /var/lib/pgsql/data

RUN echo "host    all             all             samenet                   trust" >> /var/lib/pgsql/data/pg_hba.conf
RUN echo "host    all             all             172.17.42.1/32            trust" >> /var/lib/pgsql/data/pg_hba.conf

RUN echo "listen_addresses='*'" >> /var/lib/pgsql/data/postgresql.conf

####### OPEN PORTS ###############
EXPOSE 5432

####### START SERVICES ###########
CMD /usr/bin/postgres -D /var/lib/pgsql/data
