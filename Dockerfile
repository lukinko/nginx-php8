FROM ubuntu:focal
#https://linuxize.com/post/how-to-install-php-8-on-ubuntu-20-04/

ENV PHP_USER_ID=33 \
    PHP_ENABLE_XDEBUG=0 \
    VERSION_COMPOSER_ASSET_PLUGIN=^1.4.3 \
    VERSION_PRESTISSIMO_PLUGIN=^0.3.0 \
    PATH=/app:/app/vendor/bin:/root/.composer/vendor/bin:$PATH \
    TERM=linux \
    COMPOSER_ALLOW_SUPERUSER=1 \
	  DEBIAN_FRONTEND=noninteractive \
	  LC_ALL=pl_PL.UTF-8

RUN apt-get update && \ 
echo "INSTALLING locales..........................:"; \
apt-get install -y locales && echo "pl_PL.UTF-8 UTF-8" | tee /etc/locale.gen && locale-gen && \
echo "INSTALLING STUFFs..........................:"; \
apt-get -y install software-properties-common lsb-release wget curl supervisor joe xtail git unzip gnupg2 iputils-ping net-tools host && \ 
echo "ADDING ppa ondrej..........................:"; \
add-apt-repository -y ppa:ondrej/php && \
echo "INSTALLING NGINX..........................:"; \
echo "deb http://nginx.org/packages/mainline/ubuntu/ $(lsb_release -sc) nginx" > /etc/apt/sources.list.d/nginx.list && \
echo "deb-src http://nginx.org/packages/mainline/ubuntu/ $(lsb_release -sc) nginx" >> /etc/apt/sources.list.d/nginx.list && \
curl -s https://nginx.org/keys/nginx_signing.key | apt-key add - && \
apt update && \
apt-get -y install nginx; \
echo "INSTALLING wkhtmltopdf..........................:"; \
curl -L -o wkhtmltox.deb https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.$(lsb_release -sc)_amd64.deb && \
apt install -y ./wkhtmltox.deb && \
rm wkhtmltox.deb; \
echo "INSTALING PHP..........................:"; \
apt -y install php8.0-fpm php8.0-gd php8.0-mbstring php8.0-xml php8.0-curl php8.0-intl php8.0-zip php8.0-soap php8.0-bcmath php8.0-calendar php8.0-exif php8.0-gettext php8.0-mysqli php8.0-pgsql php8.0-mysql php8.0-pgsql php8.0-mongodb && \
mkdir /run/php; ln -s /usr/bin/php /usr/local/bin/php; \
sed -i -e"s/listen = \/run\/php\/php8.0-fpm.sock/listen = 9000/" /etc/php/8.0/fpm/pool.d/www.conf; \
echo "INSTALING php-fpm-healthcheck.............:"; \
wget -O /usr/local/bin/php-fpm-healthcheck https://raw.githubusercontent.com/renatomefi/php-fpm-healthcheck/master/php-fpm-healthcheck && chmod +x /usr/local/bin/php-fpm-healthcheck; \
echo "INSTALLING FONTS..........................:"; \
apt-get -y install fonts-liberation; \
echo "INSTALLING COMPOSER..........................:"; \
curl -sS https://getcomposer.org/installer | php -- \
      --filename=composer \
      --install-dir=/usr/local/bin && \
  composer global require --optimize-autoloader \
      "fxp/composer-asset-plugin:${VERSION_COMPOSER_ASSET_PLUGIN}" \
      "hirak/prestissimo:${VERSION_PRESTISSIMO_PLUGIN}" && \
  composer global dumpautoload --optimize && \
echo "INSTALLING SSMTP..........................:"; \
  apt-get -y install ssmtp mailutils && \
	sed -i -e"s/mailhub=mail/mailhub=smtp.i/g" /etc/ssmtp/ssmtp.conf \
echo "CLEARING INSTALLATION..........................:"; \
  composer clear-cache; \
apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD start.sh /
ADD supervisord.conf /etc/

EXPOSE 80
CMD ["/bin/bash", "/start.sh"]
WORKDIR /app

