#!/bin/bash
set -euo pipefail
dnf update -y
dnf install -y httpd php php-mysqlnd wget tar
systemctl enable --now httpd
cd /tmp
wget -q https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -R wordpress/* /var/www/html/
chown -R apache:apache /var/www/html
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sed -i "s/database_name_here/${db_name}/" /var/www/html/wp-config.php
sed -i "s/username_here/${db_username}/" /var/www/html/wp-config.php
sed -i "s/password_here/${db_password}/" /var/www/html/wp-config.php
sed -i "s/localhost/${db_host}/" /var/www/html/wp-config.php
systemctl restart httpd

