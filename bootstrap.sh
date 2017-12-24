#!/usr/bin/env bash

Update () {
    echo "-- Update packages --"
    sudo apt-get update -y --force-yes
    sudo apt-get upgrade -y --force-yes
}
Update

echo "-- Prepare configuration for MySQL --"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password root"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password root"

echo "-- Install tools and helpers --"
sudo apt-get install -y --force-yes python-software-properties vim htop curl git npm

echo "-- Install PPA's --"
sudo add-apt-repository ppa:ondrej/php
sudo add-apt-repository ppa:ondrej/apache2
#sudo add-apt-repository ppa:chris-lea/redis-server
Update


echo "-- Install packages --"
#sudo apt-get install -y --force-yes apache2 mysql-server-5.6 git-core
sudo apt-get install -y --force-yes apache2 mariadb-server git-core
Update
#sudo apt-get install -y --force-yes php7.0-common php7.0-dev php7.0-json php7.0-opcache php7.0-cli libapache2-mod-php7.0 php7.0 php7.0-mysql php7.0-fpm php7.0-curl php7.0-gd php7.0-mcrypt php7.0-mbstring php7.0-bcmath php7.0-zip
sudo apt-get install -y --force-yes php7.2-common php7.2-dev php7.2-json php7.2-opcache php7.2-cli libapache2-mod-php7.2 php7.2 php7.2-mysql php7.2-fpm php7.2-curl php7.2-gd php7.2-mbstring php7.2-bcmath php7.2-zip
#sudo apt-get install -y --force-yes php7.2 php7.2-common
Update

echo "-- Configure PHP &Apache --"
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.2/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.2/apache2/php.ini
sudo a2enmod rewrite

#a2enmod proxy_fcgi setenvif
#a2enconf php7.2-fpm

echo "-- Creating virtual hosts --"
sudo ln -fs /vagrant/public/ /var/www/app
cat << EOF | sudo tee -a /etc/apache2/sites-available/default.conf
<Directory "/var/www/">
    AllowOverride All
</Directory>

<VirtualHost *:80>
    DocumentRoot /var/www/app
    ServerName app.dev
</VirtualHost>

<VirtualHost *:80>
    DocumentRoot /var/www/phpmyadmin
    ServerName phpmyadmin.dev
</VirtualHost>
EOF
sudo a2ensite default.conf

echo "-- Restart Apache --"
Update
sudo /etc/init.d/apache2 restart

echo "-- Install Composer --"
curl -s https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer

echo "-- Install phpMyAdmin --"
wget -kq https://files.phpmyadmin.net/phpMyAdmin/4.7.6/phpMyAdmin-4.7.6-all-languages.tar.gz
sudo tar -xzvf phpMyAdmin-4.7.6-all-languages.tar.gz -C /var/www/
sudo rm phpMyAdmin-4.7.6-all-languages.tar.gz
sudo mv /var/www/phpMyAdmin-4.7.6-all-languages/ /var/www/phpmyadmin

echo "-- Setup databases --"
mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION; FLUSH PRIVILEGES;"
mysql -uroot -proot -e "CREATE DATABASE my_database";