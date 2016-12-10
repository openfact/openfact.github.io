#https://github.com/openfact/openfact.github.io/blob/pages/docker/Dockerfile

FROM fedora/apache
MAINTAINER Carlos Feria <carlosthe19916@sistcoop.com>

WORKDIR /tmp

RUN yum --quiet -y install git && rm -rf /var/cache/yum \
   && git clone --quiet --depth=1 -b master https://github.com/openfact/openfact.github.io \
   && yum --quiet -y remove git && rm -rf /var/cache/yum \
   && mv openfact.github.io/* /var/www/html/

EXPOSE 80
ENTRYPOINT ["/run-apache.sh"]
