#! /bin/bash
#

# Check that we are superuser (i.e. $(id -u) is zero)
if (( $(id -u) ))
then
    echo "This script needs to run as root"
    exit 1
fi

username_=wsgi
uid_=240
realname_="WSGI Daemon"

dscl . -create /Groups/_$username_
dscl . -create /Groups/_$username_ PrimaryGroupID $uid_
dscl . -create /Groups/_$username_ RecordName _$username_ $username_
dscl . -create /Groups/_$username_ RealName $realname_
dscl . -create /Groups/_$username_ Password \*

dscl . -create /Users/_$username_
dscl . -create /Users/_$username_ NFSHomeDirectory /xpt/local/apache2/wsgi/api
dscl . -create /Users/_$username_ Password \*
dscl . -create /Users/_$username_ PrimaryGroupID $uid_
dscl . -create /Users/_$username_ RealName $realname_
dscl . -create /Users/_$username_ RecordName _$username_ $username_
dscl . -create /Users/_$username_ UniqueID $uid_
dscl . -create /Users/_$username_ UserShell /usr/bin/false
dscl . -delete /Users/_$username_ PasswordPolicyOptions
dscl . -delete /Users/_$username_ AuthenticationAuthority
