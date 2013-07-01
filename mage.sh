#!/bin/bash

# CPR : Jd Daniel :: Ehime-ken
# MOD : 2013-25-06 @ 10:45:38

clear

stty erase '^?'

DBNAME=''
DBUSER=''
DBPASS=''
ADMIN_PASS=''
INSTALLDIR=''
URL='http://localhost/magento/'

cd $INSTALLDIR

echo "Now installing Magento 1.7.0.2..."

echo
echo "Downloading packages..."
echo

wget http://www.magentocommerce.com/downloads/assets/1.7.0.2/magento-1.7.0.2.tar.gz

echo
echo "Extracting data..."
echo

tar xf magento-1.7.0.2.tar.gz

echo
echo "Moving files..."
echo

mv magento/* magento/.htaccess .

echo
echo "Setting permissions..."
echo

chmod 550 mage; chmod -R o+w media var; chmod o+w var var/.htaccess app/etc

echo
echo "Initializing PEAR registry..."
echo

./mage mage-setup .
./mage config-set preferred_state stable

echo
echo "Installing core extensions..."
echo

./mage install http://connect20.magentocommerce.com/community Mage_All_Latest --force

echo
echo "Refreshing indexes..."
echo

#    php -f shell/indexer.php reindexall

echo
echo "Cleaning up files..."
echo

rm -rf magento/ magento-1.7.0.2.tar.gz *.sample *.txt

echo
echo "Installing Magento..."
echo

RESP=`php -f install.php -- \
    --license_agreement_accepted "yes" \
    --locale "en_US" \
    --timezone "America/Los_Angeles" \
    --default_currency "USD" \
    --db_host "localhost" \
    --db_name "$DBNAME" \
    --db_user "$DBUSER" \
    --db_pass "$DBPASS" \
    --url "$URL" \
    --use_rewrites "yes" \
    --use_secure "no" \
    --secure_base_url "" \
    --use_secure_admin "no" \
    --admin_firstname "Store" \
    --admin_lastname "Owner" \
    --admin_email "jdaniel@erado.com" \
    --admin_username "admin" \
    --admin_password "$ADMIN_PASS"`

echo
echo $RESP
echo

if [ "echo $RESP |awk '{ print $1 }'" != 'SUCCESS' ] ; then
    exit
fi

echo
echo "Resetting permissions..."
echo

# make sure perms to do this are working!
find . -type d -print0 | xargs -0 sudo chmod 0755 
find . -type f -print0 | xargs -0 sudo chmod 0644 

echo
echo "Finished installing the latest stable version of Magento"
echo

echo "+=================================================+"
echo "| MAGENTO LINKS"
echo "+=================================================+"
echo "|"
echo "| Store: $URL"
echo "| Admin: ${URL}admin/"
echo "|"
echo "+=================================================+"
echo "| ADMIN ACCOUNT"
echo "+=================================================+"
echo "|"
echo "| Username: admin"
echo "| Password: $ADMIN_PASS"
echo "|"
echo "+=================================================+"
echo "| DATABASE INFO"
echo "+=================================================+"
echo "|"
echo "| Database: $DBNAME"
echo "| Username: $DBUSER"
echo "| Password: $DBPASS"
echo "|"
echo "+=================================================+"