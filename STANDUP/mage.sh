#!/bin/bash

# CPR : Jd Daniel :: Ehime-ken
# MOD : 2013-25-06 @ 10:45:38

clear
stty erase '^?'

# Supported Operating Systems:
#   Linux x86, x86-64

# Supported Web Servers:
#   Apache 1.3.x
#   Apache 2.0.x
#   Apache 2.2.x
#   Nginx (starting from Magento 1.7 Community and 1.12 Enterprise versions)

apachever=`httpd -v | grep 'version' |awk '{print $3}'| cut -d "/" -f2-`


# Supported Browsers:
#   Microsoft Internet Explorer 7 and above
#   Mozilla Firefox 3.5 and above
#   Apple Safari 5 and above on Mac only
#   Google Chrome 7 and above
#   Adobe Flash browser plug-in should be installed


# PHP Compatibility:
#   5.2.13 - 5.3.15
#   Required extensions:
#   * PDO_MySQL
#   * SimpleXML
#   * MCRYPT
#   * HASH
#   * GD
#   * DOM (not the same as the xml extension)
#   * iconv
#   * CURL
#   * SOAP (if Webservices API is to be used)
#   Safe_mode off
#   Memory_limit no less than 256Mb (preferably 512)

# PHP dependancy check

    # versioning
    cur=`php -v |grep -Eow '^PHP [^ ]+' |gawk '{ print $2 }'`
    max='5.3.15'
    min='5.2.13'

    if [ ! $(echo -e "$min\n$cur" | sort --version-sort | head -1) != "$cur" ] ; then
        echo "PHP Version $cur > $min"
        exit
    fi

    if [ ! $(echo -e "$cur\n$max" | sort --version-sort | head -1) != "$max" ] ; then
        echo "PHP Version $cur < $max"
        exit
    fi

    echo "PHP Version met..."

    # modules
    modules=(pdo_mysql SimpleXML mcrypt hash gd dom iconv curl soap)
    for i in "${modules[@]}"
    do
        val=`php -m |grep -x $i`

        if [ "$i" != "$val" ] ; then
            echo "Missing dependancy $i"
            exit
        fi
    done

    echo "PHP Dependancies met..."


# MySQL:
#   EE 1.13.0.0 or later: MySQL 5.0.2 or newer
#   EE 1.12.0.2 or earlier: MySQL 4.1.20 or newer
#   CE (all versions): MySQL 4.1.20 or newer

# Redis NoSQL (optional for CE 1.8 and later, EE 1.13 and later)
#   redis-server version 2.6.9 or later
#   phpredis version 2.2.2 or later

# SSL:
#   If HTTPS is used to work in the admin, SSL certificate should be valid. Self-signed SSL certificates are not supported

# Server - hosting - setup:
#   Ability to run scheduled jobs (crontab) with PHP 5
#   Ability to override options in .htaccess files

echo -n "Database Name: "
read DBNAME

echo -n "Database User: "
read DBUSER

echo -n "Database Password: "
read DBPASS

DBEXISTS=`mysqlshow --user=$DBUSER --password=$DBPASS $DBNAME |grep -v Wildcard |grep -o $DBNAME`

if [ "$DBEXISTS" == "$DBNAME" ] ; then

    echo
    echo "Databse exists, checking if empty..."
    echo

    TBLCOUNT=$(mysql --user=$DBUSER --password=$DBPASS $DBNAME -e " SHOW TABLES; SELECT FOUND_ROWS();" |gawk '/./{line=$0} END{print line}')

    if [ "$TBLCOUNT" -ne 0 ] ; then

        TABLES=$(mysql --user=$DBUSER --password=$DBPASS $DBNAME -e 'SHOW TABLES' |gawk '{ print $1}' |grep -v '^Tables' )

        for t in $TABLES
        do
            echo "Deleting $t table from $DBNAME database..."
            mysql --user=$DBUSER --password=$DBPASS $DBNAME -e "DROP TABLE $t"
        done

    fi
fi

echo -n "Admin Password: "
#read ADMIN_PASS
ADMIN_PASS='passowrd'

echo -n "Installation Directory: "
#read INSTALLDIR
INSTALLDIR='/var/www/html'
rm -rf $INSTALLDIR

echo -n "Store URL (with trailing slash): "
#read URL
URL='http://sm-rdc-c-dev.erado.com/'


echo -n "Include Dummy Data? [Y/N] "
#read SAMPLE_DATA
SAMPLE_DATA='y'

if [ ! -d $INSTALLDIR ]; then

    echo
    echo "Creating Installation Directory..."
    echo

    mkdir -p $INSTALLDIR
else

    # clear install directory, or bad things will happen ;)
    [ "$(ls -A $INSTALLDIR)" ] && rm -rf "$INSTALLDIR/*"
fi

cd $INSTALLDIR

if [[ $SAMPLE_DATA == 'y' || $SAMPLE_DATA == 'Y' ]]; then
    echo
    echo "Now installing Magento with Dummy Data..."

    echo
    echo "Downloading packages..."
    echo

    wget http://www.magentocommerce.com/downloads/assets/1.7.0.2/magento-1.7.0.2.tar.gz
    wget http://www.magentocommerce.com/downloads/assets/1.6.1.0/magento-sample-data-1.6.1.0.tar.gz

    echo
    echo "Extracting data..."
    echo

    tar xf magento-1.7.0.2.tar.gz
    tar xf magento-sample-data-1.6.1.0.tar.gz

    echo
    echo "Moving files..."
    echo

    mv magento-sample-data-1.6.1.0/media/* magento/media/
    mv magento-sample-data-1.6.1.0/magento_sample_data_for_1.6.1.0.sql magento/data.sql
    mv magento/* magento/.htaccess .

    echo
    echo "Setting permissions..."
    echo

    chmod 550 mage
    chmod -R o+w media var
    chmod o+w var var/.htaccess app/etc

    echo
    echo "Importing sample products..."
    echo

    mysql -h localhost -u $DBUSER -p$DBPASS $DBNAME < data.sql

    echo
    echo "Initializing PEAR registry..."
    echo

    ./mage mage-setup .
    ./mage config-set preferred_state stable`

    echo
    echo "Installing core extensions..."
    echo

    ./mage install http://connect20.magentocommerce.com/community Mage_All_Latest --force

    echo
    echo "Refreshing indexes..."
    echo

    php -f shell/indexer.php reindexall

    echo
    echo "Cleaning up files..."
    echo

    rm -rf magento/ magento-sample-data-1.6.1.0/
    rm -rf magento-1.7.0.2.tar.gz magento-sample-data-1.6.1.0.tar.gz
    rm -rf *.sample *.txt data.sql

    echo
    echo "Installing Magento..."
    echo

    response=`php -f install.php -- \
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
        --admin_email "dodomeki@gmail.com" \
        --admin_username "admin" \
        --admin_password "$ADMIN_PASS"`

    echo
    echo $response
    echo

    if [ "echo $response |awk '{ print $1 }'" != 'SUCCESS' ] ; then
        exit
    fi

    echo
    echo "Resetting permissions..."
    echo

    find . -type f -exec chmod 644 {} ;
    find . -type d -exec chmod 755 {} ;

    echo
    echo "Finished installing the latest stable version of Magento with Dummy Data"
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

    exit
else
    echo "Now installing Magento without Dummy Data..."

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

    chmod 550 mage
    chmod -R o+w media var
    chmod o+w var var/.htaccess app/etc

    echo
    echo "Initializing PEAR registry..."
    echo

    ./mage mage-setup .
    ./mage config-set preferred_state stable`

    echo
    echo "Installing core extensions..."
    echo

    ./mage install http://connect20.magentocommerce.com/community Mage_All_Latest --force

    echo
    echo "Refreshing indexes..."
    echo

    php -f shell/indexer.php reindexall

    echo
    echo "Cleaning up files..."
    echo

    rm -rf magento/ magento-1.7.0.2.tar.gz
    rm -rf *.sample *.txt

    echo
    echo "Installing Magento..."
    echo

    response=`php -f install.php -- \
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
        --admin_email "dodomeki@gmail.com" \
        --admin_username "admin" \
        --admin_password "$ADMIN_PASS"`

    echo
    echo $response
    echo

    if [ "echo $response |awk '{ print $1 }'" != 'SUCCESS' ] ; then
        exit
    fi

    echo
    echo "Resetting permissions..."
    echo

    find . -type f -exec chmod 644 {} ;
    find . -type d -exec chmod 755 {} ;

    echo
    echo "Finished installing the latest stable version of Magento without Dummy Data"
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

    exit
fi