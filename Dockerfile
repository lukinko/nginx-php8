FROM ubuntu:resolute
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
echo "INSTALLING NGINX..........................:"; \
curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null && \
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/mainline/ubuntu/ $(lsb_release -sc) nginx" tee /etc/apt/sources.list.d/nginx.list && \
echo "deb-src [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/mainline/ubuntu/ $(lsb_release -sc) nginx" tee -a /etc/apt/sources.list.d/nginx.list && \
apt-get update; apt-get install -y nginx; \
echo "INSTALLING wkhtmltopdf..........................:"; \
curl -L -o wkhtmltox.deb https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.jammy_amd64.deb && \
apt install --fix-broken -y ./wkhtmltox.deb && \
rm wkhtmltox.deb; \
echo "INSTALING ghostscript..........................:"; \
apt install -y ghostscript; \
echo "INSTALING PHP..........................:"; \
apt -y install php8.5-fpm php8.5-http php8.5-raphf php8.5-gd php8.5-mbstring php8.5-xml php8.5-curl php8.5-intl php8.5-zip php8.5-soap php8.5-bcmath php8.5-calendar php8.5-exif php8.5-gettext php8.5-mysqli php8.5-pgsql php8.5-mysql php8.5-pgsql php8.5-mongodb && \
mkdir /run/php; ln -s /usr/bin/php /usr/local/bin/php; \
sed -i -e"s/listen = \/run\/php\/php8.5-fpm.sock/listen = 9000/" /etc/php/8.5/fpm/pool.d/www.conf; \
echo "INSTALING php-fpm-healthcheck.............:"; \
wget -O /usr/local/bin/php-fpm-healthcheck https://raw.githubusercontent.com/renatomefi/php-fpm-healthcheck/master/php-fpm-healthcheck && chmod +x /usr/local/bin/php-fpm-healthcheck; \
apt-get -y install fcgiwrap; \
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
echo "INSTALLING NPM..........................:"; \
  apt-get -y install npm && \
echo "CLEARING INSTALLATION..........................:"; \
  composer clear-cache; \
apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD start.sh /
ADD supervisord.conf /etc/
ADD openssl.cnf /etc/ssl/

EXPOSE 80
CMD ["/bin/bash", "/start.sh"]
WORKDIR /app

