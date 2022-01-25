FROM registry.suse.com/suse/sle15:15.3
LABEL maintainer="Michele Bologna <michele.bologna@suse.com>"
LABEL name="SUSE Manager apache build profile"
LABEL version="3.0.1-20220125"

ARG repo
ARG cert

RUN echo "$cert" > /etc/pki/trust/anchors/RHN-ORG-TRUSTED-SSL-CERT.pem
RUN update-ca-certificates
RUN echo "$repo" > /etc/zypp/repos.d/susemanager:dockerbuild.repo

ADD add_packages.sh /root/add_packages.sh
RUN /root/add_packages.sh

ADD pub.conf /etc/apache2/conf.d/pub.conf
RUN mkdir -p /srv/www/htdocs/pub/
ADD index.html /srv/www/htdocs/pub/index.html

CMD /usr/sbin/start_apache2 -DFOREGROUND -k start
