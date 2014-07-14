#!/bin/bash
# Development server setup
 
# CPR : Jd Daniel :: Ehime-ken
# MOD : 2014-07-14 @ 11:01:30

# INP : $ ./setup.sh

declare web_server=''
declare dev_server='devart' # can be $1 for servers on the fly


# ROOT check
if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as su" 1>&2 ; exit 1
fi


# system running apache2 or httpd? .... or neither.... ;)
if hash httpd 2>/dev/null; then
    web_server='httpd'
elif hash apache2 2>/dev/null; then
    web_server='apache2'
else
	echo "Script requires a web server for installation" 1>&2 ; exit 1
fi


# locate apache2/httpd web directory
case "$web_server" in

	httpd)
		# not gonna worry about RHEL systems, you guys get the drift I'm sure ;)
	;;
 
	apache2)

		cd /etc/apache2/sites-available

		echo -e "<VirtualHost *:80>\n\n\tServerName ${dev_server}.dev\n\tServerAlias *.${dev_server}.dev\n\n\tDocumentRoot /var/www/${dev_server}.dev/public\n\tDirectoryIndex index.php index.html\n\n\tSetEnv APPLICATION_ENV development\n\n\t<Directory /var/www/${dev_server}.dev/public/>\n\t\tRequire all granted\n\t\tOrder allow,deny\n\t\tAllowOverride All\n\t\tAllow from All\n\t</Directory>\n\n</VirtualHost>" \
		> "${dev_server}.conf" # create conf

			sed -i '1s/^/127.0.0.1       '$dev_server'.dev\n/' /etc/hosts # patch hosts

		mkdir -p "/var/www/${dev_server}.dev"

			a2ensite $dev_server
			service apache2 reload

		cd "/var/www/${dev_server}.dev"

		wget http://st.deviantart.net/dt/exercise/exercise.zip
		unzip exercise.zip 

			rm -rf {__MACOSX,*.zip} # don't want
			mv exercise/* . && rm -rf exercise

		# let me get that for you ;)
		if hash firefox 2>/dev/null; then
		    firefox "${dev_server}.dev" 		# open in FF
		elif hash google-chrome 2>/dev/null; then
		    google-chrome "${dev_server}.dev" 	# open in chrome
	    else
			echo "Done, please browse to http://$dev_server.dev should now be available"
	    fi
	;;

esac
