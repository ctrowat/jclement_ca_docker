FROM ubuntu:14.04
MAINTAINER jeffrey.clement@gmail.com
EXPOSE 8080
RUN apt-get update
RUN apt-get install -y make nodejs nodejs-legacy nginx git-core ruby rake imagemagick python ruby-dev
RUN gem install jekyll execjs inflection kramdown mini_magick pygments.rb redcarpet titleize

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

CMD /usr/sbin/nginx
