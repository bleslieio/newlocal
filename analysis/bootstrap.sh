# ANALYSIS BOOTSTRAP

#!/usr/bin/env bash

# This script can be used to perform any sort of command line actions to setup your box. 
# This includes installing software, importing databases, enabling new sites, pulling from 
# remote servers, etc. 

# update
echo "########################"
echo "##### UPDATING APT #####"
echo "########################"
sudo apt-get update

# Install Apache
echo "#############################"
echo "##### INSTALLING APACHE #####"
echo "#############################"
sudo apt-get -y install apache2

# Creating folder
# echo "####################################"
# echo "##### CREATING WEBSITE FOLDER #####"
# echo "####################################"
mkdir /var/www/html
chmod 0777 -R /var/www/html

# enable modrewrite
echo "#######################################"
echo "##### ENABLING APACHE MOD-REWRITE #####"
echo "#######################################"
sudo a2enmod rewrite

# append AllowOverride to Apache Config File
echo "#######################################"
echo "##### CREATING APACHE CONFIG FILE #####"
echo "#######################################"
echo "
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html
		ServerName siteanalysis.dev
		ServerAlias www.siteanalysis.dev
		
		<Directory '/var/www/html'>
			Options Indexes FollowSymLinks MultiViews
			AllowOverride All
			Require all granted
		</Directory>

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
" > /etc/apache2/sites-available/siteanalysis.conf

#echo "ServerName localhost" >> /etc/apache2/apache2.conf 

# Enabling Site
echo "##################################"
echo "##### Enabling Magento2 Site #####"
echo "##################################"
sudo a2ensite siteanalysis.conf

# Install MySQL 5.6
echo "############################"
echo "##### INSTALLING MYSQL #####"
echo "############################"
export DEBIAN_FRONTEND=noninteractive
apt-get -q -y install mysql-server-5.6 mysql-client-5.6
#apt-get --yes install mysql-client
#apt-get --yes install mysql-server
#apt-get --yes install php5-mysql

# Create Database instance
echo "#############################"
echo "##### CREATING DATABASE #####"
echo "#############################"
mysql -u root -e "create database siteanalysis;"

# Import database
#echo "##############################"
#echo "##### IMPORTING DATABASE #####"
#echo "##############################"
#mysql -u root -e "siteanalysis < siteanalysis_20140720.sql;"

# Install PHP 5.5
echo "##########################"
echo "##### INSTALLING PHP #####"
echo "##########################"
apt-get -y install php5

# Install Required PHP extensions
echo "#####################################"
echo "##### INSTALLING PHP EXTENSIONS #####"
echo "#####################################"
apt-get -y install php5 php5-mhash php5-mcrypt php5-curl php5-cli php5-mysql php5-gd php5-intl php5-common php-pear php5-dev
php5enmod mcrypt

# Install MAKE to allow for XDebug install 
echo "#####################################"
echo "##### INSTALLING MAKE FOR XDEBUG ####"
echo "#####################################"
apt-get -y install make

# Install XDebug
echo "#####################################"
echo "###### INSTALLING XDEBUG ############"
echo "#####################################"
sudo pecl install xdebug
echo "zend_extension=/usr/lib/php5/20121212/xdebug.so" >> /etc/php5/apache2/php.ini
echo "xdebug.remote_enable = 1" >> /etc/php5/apache2/php.ini
echo "xdebug.remote_connect_back = 1" >> /etc/php5/apache2/php.ini

# Mcrypt issue
echo "#############################"
echo "##### PHP MYCRYPT PATCH #####"
echo "#############################"
sudo ln -s /etc/php5/mods-available/mcrypt.ini /etc/php5/apache2/conf.d/20-mcrypt.ini
sudo ln -s /etc/php5/mods-available/mcrypt.ini /etc/php5/cli/conf.d/20-mcrypt.ini

echo "Restarting Apache server"
sudo service apache2 restart

# Set PHP Timezone
echo "########################"
echo "##### PHP TIMEZONE #####"
echo "########################"
echo "date.timezone = America/New_York" >> /etc/php5/cli/php.ini

# Install Git
echo "##########################"
echo "##### INSTALLING GIT #####"
echo "##########################"
apt-get -y install git

# Composer Installation
echo "###############################"
echo "##### INSTALLING COMPOSER #####"
echo "###############################"
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# Set Ownership and Permissions
echo "#############################################"
echo "##### SETTING OWNERSHIP AND PERMISSIONS #####"
echo "#############################################"
chown -R www-data /var/www/html/
find /var/www/html/ -type d -exec chmod 777 {} \;
find /var/www/html/ -type f -exec chmod 777 {} \;

# Magerun
wget http://files.magerun.net/n98-magerun-latest.phar -O n98-magerun.phar
chmod +x ./n98-magerun.phar
cp ./n98-magerun.phar /usr/local/bin/magerun

# PHP Mess Detector
wget -c http://static.phpmd.org/php/latest/phpmd.phar
chmod +x ./phpmd.phar
mv ./phpmd.phar /usr/local/bin/phpmd

# PHP Code Sniffer & ECG Standards
pear install PHP_CodeSniffer
git clone https://github.com/magento-ecg/coding-standard.git /home/vagrant/Ecg/

# Restart apache
echo "#############################"
echo "##### RESTARTING APACHE #####"
echo "#############################"
sudo service apache2 restart

# Post Up Message
echo "Vagrant Box ready!"
# echo "Go to http://192.168.33.10/magento2/setup/ to finish installation."
# echo "If you configured your hosts file, go to http://www.magento2.dev/setup/"
