FROM debian:jessie

LABEL Maintainer = JDK <jeand98.jd@gmail.com> \ 
      Description = "This is a VLAMP 7.1 image made with love by IT4"

# MAJ et prerequis
ENV MYSQL_USER=mysql \
    MYSQL_VERSION=5.5 \
    MYSQL_DATA_DIR=/var/lib/mysql \
    MYSQL_RUN_DIR=/run/mysqld \
    MYSQL_LOG_DIR=/var/log/mysql \
    DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get -y install nano \
    && apt-get -y install unzip \ 
    && mkdir /vtiger/

# APACHE 2
RUN apt-get -y install apache2 \
    && a2enmod rewrite
COPY vtiger.conf /etc/apache2/sites-available
RUN a2ensite vtiger.conf \
    && a2dissite 000-default.conf \
    && service apache2 restart

# MYSQL 5.5
RUN apt-get install -y mysql-server

# PHP 7.2
RUN apt-get -y install ca-certificates \
    && apt-get -y install lsb-release \
    && apt-get -y install apt-transport-https     

ADD https://packages.sury.org/php/apt.gpg /etc/apt/trusted.gpg.d/php.gpg
RUN cd /etc/apt/trusted.gpg.d \
    &&  apt-key add php.gpg \
    &&  echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list

RUN apt-get update \
    && apt-get -y install php7.2 \
    &&  apt-get -y install libapache2-mod-php7.2 \
    &&  apt-get -y install php7.2-common \
    &&  apt-get -y install php7.2-mbstring \
    &&  apt-get -y install php7.2-xmlrpc \
    &&  apt-get -y install php7.2-soap \
    &&  apt-get -y install php7.2-gd \
    &&  apt-get -y install php7.2-xml \
    &&  apt-get -y install php7.2-intl \
    &&  apt-get -y install php7.2-mysql \
    &&  apt-get -y install php7.2-cli \
    &&  apt-get -y install php7.2-ldap \
    &&  apt-get -y install php7.2-zip \
    &&  apt-get -y install php7.2-curl

RUN service apache2 restart

# Configuration de php.ini
RUN sed -i 's/display_errors =/display_errors = On/' /etc/php/7.2/apache2/php.ini \
    && sed -i 's/max_execution_time =/max_execution_time = 30/' /etc/php/7.2/apache2/php.ini \
    && sed -i 's/error_reporting =/error_reporting = E_WARNING & ~E_NOTICE & ~E_DEPRECATED & ~E_STRICT/' /etc/php/7.2/apache2/php.ini \
    && sed -i 's/log_errors =/log_errors = Off/' /etc/php/7.2/apache2/php.ini \
    && sed -i 's/short_open_tag =/short_open_tag = Off/' /etc/php/7.2/apache2/php.ini \
    && sed -i 's/upload_max_filesize =/upload_max_filesize = 64M/' /etc/php/7.2/apache2/php.ini \
    && sed -i 's/max_input_vars =/max_input_vars = 1500/' /etc/php/7.2/apache2/php.ini \
    && sed -i 's/memory_limit =/memory_limit = 256M/' /etc/php/7.2/apache2/php.ini \
    && sed -i 's/post_max_size =/post_max_size = 128M/' /etc/php/7.2/apache2/php.ini \
    && sed -i 's/max_input_time =/max_input_time = 120/' /etc/php/7.2/apache2/php.ini \
    && sed -i 's/output_buffering =/output_buffering = On/' /etc/php/7.2/apache2/php.ini \ 
    && sed -i '$ a / upload_max_size = 5M ' /etc/php/7.2/apache2/php.ini \
    && sed -i '$ a / register_globals = Off ' /etc/php/7.2/apache2/php.ini \ 
    && sed -i '$ a / allow_call_time_reference = On ' /etc/php/7.2/apache2/php.ini \
    && sed -i '$ a / safe_mode = Off ' /etc/php/7.2/apache2/php.ini \
    && sed -i '$ a / suhosin.simulation = On ' /etc/php/7.2/apache2/php.ini \
    && sed -i '$ a / file_uploads = On' /etc/php/7.2/apache2/php.ini \
    && service apache2 restart

# VTIGER
COPY vtigercrm7.1.0.tar.gz /vtiger
RUN cd /vtiger \
    && tar xvf vtigercrm7.1.0.tar.gz \
    && mv vtigercrm /var/www/vtigercrm \
    && chmod -R 0775 /var/www/vtigercrm \
    && chown -R www-data:www-data /var/www/vtigercrm
RUN service apache2 restart

WORKDIR /var/www/html

VOLUME /var/www/html
VOLUME /var/lib/mysql

EXPOSE 80/tcp 3306/tcp

CMD service mysql start && service apache2 start 