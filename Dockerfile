FROM debian:buster

LABEL maintainer="Astrid DELCROS (adelcros@student.42.fr)"

# UPDATE
RUN apt-get update
RUN apt-get upgrade -y

# INSTALL NGINX
RUN apt-get -y install nginx

# INSTALL MYSQL
RUN apt-get -y install mariadb-server

# INSTALL PHP
RUN apt-get -y install php7.3 php-mysql php-fpm php-cli php-mbstring

# INSTALL TOOLS
RUN apt-get -y install wget

# SETUP NGINX
COPY srcs/nginx.conf /etc/nginx/sites-available/localhost
RUN ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/localhost

# SSL
COPY srcs/ssl_cert.key /etc/ssl/private/nginx_cert.key
COPY srcs/ssl_cert.crt /etc/ssl/certs/nginx_cert.crt

# INSTALL PHPMYAMIN
WORKDIR /var/www/html/
RUN wget https://files.phpmyadmin.net/phpMyAdmin/4.9.2/phpMyAdmin-4.9.2-all-languages.tar.gz
RUN tar -xvf phpMyAdmin-4.9.2-all-languages.tar.gz
RUN rm -rf phpMyAdmin-4.9.2-all-languages.tar.gz
RUN mv phpMyAdmin-4.9.2-all-languages phpmyadmin

# INSTALL WORDPRESS
WORKDIR /var/www/html/
RUN wget https://fr.wordpress.org/latest-fr_FR.tar.gz
RUN tar -xvf latest-fr_FR.tar.gz
RUN rm -rf latest-fr_FR.tar.gz
# RUN mv wordpress /var/www/html/

# SETUP WORDPRESS
COPY srcs/wp-config.php /var/www/html/wordpress
# && Link to PHPMYADMIN

COPY srcs/wordpress_db.sql /tmp

# CREATE DATABASE && PASSWORD
RUN service mysql start && \
	mysql -u root -e "CREATE DATABASE wordpress_db" && \
	mysql -u root -e "GRANT ALL ON wordpress_db.* TO 'wordpress_user'@'localhost' IDENTIFIED BY 'password_test' WITH GRANT OPTION" && \
	mysql -u root -e "GRANT ALL ON *.* TO 'bobby'@'localhost' IDENTIFIED BY 'bob'" && \
	mysql wordpress_db < /tmp/wordpress_db.sql

#start server
CMD service nginx start			&& \
	service mysql start			&& \
	service php7.3-fpm start	&& \
	tail -f /dev/null

EXPOSE 80 443

