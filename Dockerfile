FROM php:5.6-apache

RUN echo "deb http://ftp.us.debian.org/debian jessie main contrib non-free" > /etc/apt/sources.list && rm -rf /var/lib/apt/lists/* && apt-get -y update && apt-get install -y rsync

RUN a2enmod rewrite

# install the PHP extensions we need
RUN apt-get update && apt-get install -y libpng12-dev && rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-install gd \
	&& apt-get purge --auto-remove -y libpng12-dev
RUN docker-php-ext-install mysqli

VOLUME /var/www/html

ENV WORDPRESS_VERSION 4.0.1
ENV WORDPRESS_UPSTREAM_VERSION 4.0.1
ENV WORDPRESS_SHA1 ef1bd7ca90b67e6d8f46dc2e2a78c0ec4c2afb40

# upstream tarballs include ./wordpress/ so this gives us /usr/src/wordpress
RUN curl -o wordpress.tar.gz -SL https://wordpress.org/wordpress-${WORDPRESS_UPSTREAM_VERSION}.tar.gz \
	&& echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c - \
	&& tar -xzf wordpress.tar.gz -C /usr/src/ \
	&& rm wordpress.tar.gz

COPY docker-entrypoint.sh /entrypoint.sh

# grr, ENTRYPOINT resets CMD now
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2", "-DFOREGROUND"]
