FROM jclement/baseimage
MAINTAINER jeffrey.clement@gmail.com
EXPOSE 80 22

ENV HOME /root

# install necessary packages
RUN apt-get update
RUN apt-get install -y make nodejs nodejs-legacy nginx git-core ruby rake imagemagick python ruby-dev
RUN gem install jekyll execjs inflection kramdown mini_magick pygments.rb redcarpet titleize 

# setup SSH
COPY authorized_keys /root/.ssh/authorized_keys

# copy nginx configuration file (port 80)
COPY nginx.default /etc/nginx/sites-enabled/default
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# enable nginx service
RUN mkdir -p /etc/service/nginx
RUN echo "#!/bin/sh\nexec /usr/sbin/nginx" > /etc/service/nginx/run
RUN chmod a+x /etc/service/nginx/run

# pull latest website source to /src owned by site-owner
RUN mkdir -p /src
RUN useradd -ms /bin/bash site-owner
RUN chown site-owner.site-owner /src
USER site-owner
RUN cd /src && git clone https://github.com/jclement/jclement_ca.git 
RUN cd /src/jclement_ca && /usr/local/bin/jekyll build
USER root

# setup website refresh crontab 
RUN echo "*/20 * * * * cd /src/jclement_ca && git pull && /usr/local/bin/jekyll build" > /tmp/crontab
RUN crontab -u site-owner /tmp/crontab
RUN rm /tmp/crontab

CMD ["/sbin/my_init"]
