FROM ubuntu:14.04
MAINTAINER jeffrey.clement@gmail.com
EXPOSE 80 22

# install necessary packages
RUN apt-get update
RUN apt-get install -y make nodejs nodejs-legacy nginx git-core ruby rake imagemagick python ruby-dev supervisor openssh-server
RUN gem install jekyll execjs inflection kramdown mini_magick pygments.rb redcarpet titleize 

# setup supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# setup SSH
COPY authorized_keys /root/.ssh/authorized_keys
RUN mkdir -p /var/run/sshd

# copy nginx configuration file (port 8080)
COPY nginx.default /etc/nginx/sites-enabled/default
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# pull latest website source to /src owned by site-owenr
RUN mkdir -p /src
RUN useradd -ms /bin/hash site-owner
RUN chown site-owner.site-owner /src
USER site-owner
RUN cd /src && git clone https://github.com/jclement/jclement_ca.git 
RUN cd /src/jclement_ca && make
USER root

# start nginx to serve content
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
