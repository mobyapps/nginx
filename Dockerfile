FROM phusion/baseimage:0.11

LABEL maintainer="charescape@outlook.com"

ENV NGINX_VERSION 1.17.4

COPY ./startserv.sh               /etc/my_init.d/
COPY ./conf/nginx.conf            /usr/local/src/

# see http://www.ruanyifeng.com/blog/2017/11/bash-set.html
RUN set -eux \
&& export DEBIAN_FRONTEND=noninteractive \
&& sed -i 's/http:\/\/archive.ubuntu.com/https:\/\/mirrors.tencent.com/' /etc/apt/sources.list \
&& sed -i 's/http:\/\/security.ubuntu.com/https:\/\/mirrors.tencent.com/' /etc/apt/sources.list \
&& sed -i 's/https:\/\/archive.ubuntu.com/https:\/\/mirrors.tencent.com/' /etc/apt/sources.list \
&& sed -i 's/https:\/\/security.ubuntu.com/https:\/\/mirrors.tencent.com/' /etc/apt/sources.list \
&& apt-get -y update            \
&& apt-get -y upgrade           \
&& apt-get -y install build-essential \
curl                            \
libssl-dev                      \
zlib1g-dev                      \
libpcre3-dev                    \
libgeoip-dev                    \
libevent-dev                    \
socat                           \
\
&& groupadd group7 \
&& useradd -g group7 -M -d /usr/local/nginx user7 -s /sbin/nologin \
\
&& chmod +x /etc/my_init.d/startserv.sh \
\
&& cd /usr/local/src \
\
&& curl -O https://mirrors.sohu.com/nginx/nginx-${NGINX_VERSION}.tar.gz \
&& tar -zxf nginx-${NGINX_VERSION}.tar.gz \
\
&& cd /usr/local/src/nginx-${NGINX_VERSION} \
&& ./configure --prefix=/usr/local/nginx \
--without-select_module \
--with-poll_module \
--with-threads \
--with-file-aio \
--with-http_ssl_module \
--with-http_v2_module \
--with-http_realip_module \
--with-http_addition_module \
--with-http_geoip_module \
--with-http_geoip_module=dynamic \
--with-http_sub_module \
--with-http_gzip_static_module \
--with-http_auth_request_module \
--with-http_random_index_module \
--with-http_secure_link_module \
--with-http_slice_module \
--with-http_stub_status_module \
--without-mail_pop3_module \
--without-mail_imap_module \
--without-mail_smtp_module \
--with-stream \
--with-stream=dynamic \
--with-stream_ssl_module \
--with-stream_realip_module \
--with-stream_geoip_module \
--with-stream_geoip_module=dynamic \
--with-stream_ssl_preread_module \
--with-pcre \
--with-pcre-jit \
\
&& make \
&& make install \
\
&& mkdir /usr/local/nginx/vhosts \
&& mkdir /usr/local/nginx/vconfs \
&& mkdir /usr/local/nginx/vlogs \
&& mkdir /usr/local/nginx/vcerts \
\
&& cd /usr/local/src \
&& yes | cp ./nginx.conf  /usr/local/nginx/conf/nginx.conf \
\
&& chown -R user7:group7 /usr/local/nginx \
&& /usr/local/nginx/sbin/nginx -t \
&& /usr/local/nginx/sbin/nginx \
&& sleep  3s \
&& /usr/local/nginx/sbin/nginx -s stop \
\
&& echo '' >> ~/.bashrc \
&& echo 'export PATH="$PATH:/usr/local/nginx/sbin"' >> ~/.bashrc \
\
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
&& rm -rf /usr/local/src/*

EXPOSE 80 443

CMD ["/sbin/my_init"]

# source ~/.bashrc
# curl  https://get.acme.sh | sh
