FROM php:5.6-apache
COPY public/ /var/www/html/
RUN \
  curl -L your_url | tar -C /tmp -zx && \
    NR_INSTALL_USE_CP_NOT_LN=1 NR_INSTALL_SILENT=1 /tmp/newrelic-php5-*/newrelic-install install && \
      rm -rf /tmp/newrelic-php5-* /tmp/nrinstall* && \
        sed -i -e 's/"REPLACE_WITH_REAL_KEY"/"Your License Key"/' \
     -e 's/newrelic.appname = "PHP Application"/newrelic.appname = "Your Application Name"/' \
         /usr/local/etc/php/conf.d/newrelic.ini