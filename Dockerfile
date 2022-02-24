FROM php:8.1.2-cli-bullseye
COPY public/ /var/www/html/
RUN \
  curl -L https://download.newrelic.com/php_agent/release/newrelic-php5-8.3.0.226-linux.tar.gz | tar -C /tmp -zx && \
    NR_INSTALL_USE_CP_NOT_LN=1 NR_INSTALL_SILENT=1 /tmp/newrelic-php5-*/newrelic-install install && \
      rm -rf /tmp/newrelic-php5-* /tmp/nrinstall* && \
        sed -i -e 's/"REPLACE_WITH_REAL_KEY"/"XXXYYYZZZ"/' \
     -e 's/newrelic.appname = "PHP Application"/newrelic.appname = "hello_world"/' \
         /usr/local/etc/php/conf.d/newrelic.ini
EXPOSE 80