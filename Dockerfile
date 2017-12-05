FROM ruby:2.4-slim

#Install all prerequisites (Install Redis 3.3.x. See https://github.com/rails/rails/issues/30527)
RUN echo "deb http://ftp.uk.debian.org/debian jessie-backports main" >> /etc/apt/sources.list \
    && apt-get -qq update \
    && apt-get install -y -t jessie-backports wget \
                                              zip \
                                              git \
                                              build-essential \
                                              redis-server=3:3.2.8-2~bpo8+1 \
                                              ghostscript \
                                              imagemagick \
                                              libreoffice \
                                              libsqlite3-dev \
                                              nodejs \
                                              openjdk-8-jre-headless \
                                              ca-certificates-java \
                                              openjdk-8-jdk \
                                              tomcat7 \
                                              ffmpeg \
                                              solr-tomcat 

# Install Fedora-commons
RUN export JAVA_OPTS="${JAVA_OPTS} -Dfcrepo.modeshape.configuration=classpath:/config/file-simple/repository.json -Dfcrepo.home=/mnt/fedora-data" \
    && wget --no-check-certificate https://github.com/fcrepo4/fcrepo4/releases/download/fcrepo-4.7.4/fcrepo-webapp-4.7.4.war \
    && mv fcrepo-webapp-4.7.4.war /var/lib/tomcat7/webapps

#Create the startup script
RUN echo '#!/bin/bash \n (solr_wrapper &) && (sleep 2 && fcrepo_wrapper &) && (start-stop-daemon --start --user hyrax --exec /usr/bin/redis-server &) && sleep 5 && rails server ; tail -f /dev/stdout' > /docker-entrypoint.sh \
    && chmod a+x /docker-entrypoint.sh

#Start Redis on container startup
RUN update-rc.d redis-server enable

#Switch to a non-root user or Solr will refuse to start
RUN useradd -ms /bin/bash hyrax
USER hyrax
WORKDIR /home/hyrax

#Install rails
RUN gem install rails -v 5.0.6
#&& gem install sqlite3 -v '1.3.13'

#Install Fits
RUN wget --quiet http://projects.iq.harvard.edu/files/fits/files/fits-1.0.5.zip \
    && unzip fits-1.0.5.zip \
    && mv fits-1.0.5 fits \
    && chmod a+x fits/fits.sh
ENV PATH="${PATH}:/home/hyrax/fits/"

#Enable cache busting to force cloning the Hyrax repository.
ARG TAG=
ARG REV=1
ARG BRANCH=
#Install and build Hyrax
RUN git clone -b ${BRANCH:-master} https://github.com/samvera/hyrax \
    && cd ./hyrax \
    && if [ -n "$TAG" ]; then git checkout tags/${TAG}; fi \ 
    && bundle install \
    && rake engine_cart:generate

WORKDIR /home/hyrax/hyrax/.internal_test_app

#Add a default administrator 
COPY admin_role_map.yml config/role_map.yml

EXPOSE  3000

ENTRYPOINT ["/docker-entrypoint.sh"]
