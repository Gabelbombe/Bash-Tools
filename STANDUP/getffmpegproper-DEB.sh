#!/bin/bash
# CPR : Jd Daniel :: Gabelbombe# 
# getffmpegproper
# this sctipt downloads, install and update ffmpeg and x264 from SVN and git for the initial install

#VARIABLES
# edit the below if you wish
#location of installed files
INSTALL="/usr/local/src"
# location of log file
LOG="/var/log/ffmpegupdate.log"
# location of the script's lock file
LOCK="/var/run/ffmpegupdate.pid"
#update the script automatically?, change to NO if you don't want the scrip to update itself automatically
SCRIPTUPDATE="YES"
#FFmpeg additional configure options - think about the dependency issues here
FFMPEGCONFIGURE=
#x264 addiitonal configure options - think about the dependency issues here
X264CONFIGURE=

#####################################
#DONT EDIT ANYTHING BEYOND THIS POINT
SCRIPT="ffmpegupdate.sh"
CONF="/etc/ffmpegupdate.conf"
VERSION=9

saucy_dep ()
{
	apt-get remove -y ffmpeg
	apt-get purge -y libav-tools
	add-apt-repository ppa:jon-severinsson/ffmpeg
	apt-get update
	apt-get -y dist-upgrade
	apt-get install -y ffmpeg frei0r-plugins
	apt-get --purge autoremove
}

#ONEIRIC SPECIFIC
#oneiric install
oneiric_dep ()
{
apt-get -y remove ffmpeg x264 libx264-dev 2>> $LOG >> $LOG
apt-get -y update 2>> $LOG >> $LOG
apt-get -y install build-essential checkinstall git libfaac-dev libjack-jackd2-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libsdl1.2-dev libtheora-dev libva-dev libvdpau-dev libvorbis-dev libx11-dev libxfixes-dev texi2html yasm zlib1g-dev 2>> $LOG >> $LOG
}

oneiric_x264 ()
{
cd $INSTALL 2>> $LOG >> $LOG
git clone git://git.videolan.org/x264 2>> $LOG >> $LOG
cd x264 2>> $LOG >> $LOG
./configure --enable-static $X264CONFIGURE 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --pkgname=x264 --pkgversion=""3:$(./version.sh | awk -F'[" ]' '/POINT/{print $4"+git"$5}')"" --backup=no --deldoc=yes --fstrans=no --default 2>> $LOG >> $LOG
}

oneiric_ffmpeg ()
{
cd $INSTALL 2>> $LOG >> $LOG
git clone --depth 1 git://source.ffmpeg.org/ffmpeg 2>> $LOG >> $LOG
cd ffmpeg 2>> $LOG >> $LOG
./configure --enable-gpl --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libvorbis --enable-libx264 --enable-nonfree --enable-version3 --enable-x11grab $FFMPEGCONFIGURE 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --pkgname=ffmpeg --pkgversion="5:$(date +%Y%m%d%H%M)-git" --backup=no --deldoc=yes --fstrans=no --default 2>> $LOG >> $LOG
hash x264 ffmpeg ffplay ffprobe 2>> $LOG >> $LOG
}

#oneiric update
oneiric_x264depup ()
{
apt-get -y remove x264 libx264-dev 2>> $LOG >> $LOG
apt-get -y update 2>> $LOG >> $LOG
apt-get -y install build-essential checkinstall git libfaac-dev libjack-jackd2-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libsdl1.2-dev libtheora-dev libva-dev libvdpau-dev libvorbis-dev libx11-dev libxfixes-dev libxvidcore-dev texi2html yasm zlib1g-dev 2>> $LOG >> $LOG

}

oneiric_ffmpegdepup ()
{
apt-get -y remove ffmpeg 2>> $LOG >> $LOG
apt-get -y update 2>> $LOG >> $LOG
apt-get -y install build-essential checkinstall git libfaac-dev libjack-jackd2-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libsdl1.2-dev libtheora-dev libva-dev libvdpau-dev libvorbis-dev libx11-dev libxfixes-dev libxvidcore-dev texi2html yasm zlib1g-dev 2>> $LOG >> $LOG

}

oneiric_x264update ()
{
cd $INSTALL/x264 2>> $LOG >> $LOG
make distclean 2>> $LOG >> $LOG
git pull 2>> $LOG >> $LOG
./configure --enable-static $X264CONFIGURE 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --pkgname=x264 --pkgversion=""3:$(./version.sh | awk -F'[" ]' '/POINT/{print $4"+git"$5}')"" --backup=no --deldoc=yes --fstrans=no --default2>> $LOG >> $LOG
}

oneiric_ffmpegupdate ()
{
cd $INSTALL/ffmpeg 2>> $LOG >> $LOG
make distclean 2>> $LOG >> $LOG
git pull 2>> $LOG >> $LOG
./configure --enable-gpl --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libvorbis --enable-libx264 --enable-nonfree --enable-version3 --enable-x11grab $FFMPEGCONFIGURE 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --pkgname=ffmpeg --pkgversion="5:$(date +%Y%m%d%H%M)-git" --backup=no --deldoc=yes --fstrans=no --default 2>> $LOG >> $LOG
hash x264 ffmpeg ffplay ffprobe 2>> $LOG >> $LOG
}

#NATTY SPECIFIC
#natty install
natty_dep ()
{
apt-get -y remove ffmpeg x264 libx264-dev 2>> $LOG >> $LOG
apt-get -y update 2>> $LOG >> $LOG
apt-get -y install build-essential checkinstall git libfaac-dev libjack-jackd2-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libsdl1.2-dev libtheora-dev libva-dev libvdpau-dev libvorbis-dev libx11-dev libxfixes-dev texi2html yasm zlib1g-dev 2>> $LOG >> $LOG
}

natty_x264 ()
{
cd $INSTALL 2>> $LOG >> $LOG
git clone git://git.videolan.org/x264 2>> $LOG >> $LOG
cd x264 2>> $LOG >> $LOG
./configure --enable-static $X264CONFIGURE 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --pkgname=x264 --pkgversion=""3:$(./version.sh | awk -F'[" ]' '/POINT/{print $4"+git"$5}')"" --backup=no --deldoc=yes --fstrans=no --default 2>> $LOG >> $LOG
}

natty_ffmpeg ()
{
cd $INSTALL 2>> $LOG >> $LOG
git clone --depth 1 git://source.ffmpeg.org/ffmpeg 2>> $LOG >> $LOG
cd ffmpeg 2>> $LOG >> $LOG
./configure --enable-gpl --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libvorbis --enable-libx264 --enable-nonfree --enable-version3 --enable-x11grab $FFMPEGCONFIGURE 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --pkgname=ffmpeg --pkgversion="5:$(date +%Y%m%d%H%M)-git" --backup=no --deldoc=yes --fstrans=no --default 2>> $LOG >> $LOG
hash x264 ffmpeg ffplay ffprobe 2>> $LOG >> $LOG
}

#natty update
natty_x264depup ()
{
apt-get -y remove x264 libx264-dev 2>> $LOG >> $LOG
apt-get -y update 2>> $LOG >> $LOG
apt-get -y install build-essential checkinstall git libfaac-dev libjack-jackd2-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libsdl1.2-dev libtheora-dev libva-dev libvdpau-dev libvorbis-dev libx11-dev libxfixes-dev libxvidcore-dev texi2html yasm zlib1g-dev 2>> $LOG >> $LOG

}

natty_ffmpegdepup ()
{
apt-get -y remove ffmpeg 2>> $LOG >> $LOG
apt-get -y update 2>> $LOG >> $LOG
apt-get -y install build-essential checkinstall git libfaac-dev libjack-jackd2-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libsdl1.2-dev libtheora-dev libva-dev libvdpau-dev libvorbis-dev libx11-dev libxfixes-dev libxvidcore-dev texi2html yasm zlib1g-dev 2>> $LOG >> $LOG

}

natty_x264update ()
{
cd $INSTALL/x264 2>> $LOG >> $LOG
make distclean 2>> $LOG >> $LOG
git pull 2>> $LOG >> $LOG
./configure --enable-static $X264CONFIGURE 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --pkgname=x264 --pkgversion=""3:$(./version.sh | awk -F'[" ]' '/POINT/{print $4"+git"$5}')"" --backup=no --deldoc=yes --fstrans=no --default2>> $LOG >> $LOG
}

natty_ffmpegupdate ()
{
cd $INSTALL/ffmpeg 2>> $LOG >> $LOG
make distclean 2>> $LOG >> $LOG
git pull 2>> $LOG >> $LOG
./configure --enable-gpl --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libvorbis --enable-libx264 --enable-nonfree --enable-version3 --enable-x11grab $FFMPEGCONFIGURE 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --pkgname=ffmpeg --pkgversion="5:$(date +%Y%m%d%H%M)-git" --backup=no --deldoc=yes --fstrans=no --default 2>> $LOG >> $LOG
hash x264 ffmpeg ffplay ffprobe 2>> $LOG >> $LOG
}



#MAVERICK SPECIFIC
#maverick install
maverick_dep ()
{
apt-get -y remove ffmpeg x264 libx264-dev 2>> $LOG >> $LOG
apt-get -y update 2>> $LOG >> $LOG
apt-get -y install build-essential checkinstall git libfaac-dev libjack-jackd2-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libsdl1.2-dev libtheora-dev libva-dev libvdpau-dev libvorbis-dev libx11-dev libxfixes-dev texi2html yasm zlib1g-dev 2>> $LOG >> $LOG
}

maverick_x264 ()
{
cd $INSTALL 2>> $LOG >> $LOG
git clone git://git.videolan.org/x264 2>> $LOG >> $LOG
cd x264 2>> $LOG >> $LOG
./configure --enable-static $X264CONFIGURE 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --pkgname=x264 --pkgversion=""3:$(./version.sh | awk -F'[" ]' '/POINT/{print $4"+git"$5}')"" --backup=no --deldoc=yes --fstrans=no --default 2>> $LOG >> $LOG
}

maverick_ffmpeg ()
{
cd $INSTALL 2>> $LOG >> $LOG
git clone --depth 1 git://source.ffmpeg.org/ffmpeg 2>> $LOG >> $LOG
cd ffmpeg 2>> $LOG >> $LOG
./configure --enable-gpl --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libvorbis --enable-libx264 --enable-nonfree --enable-version3 --enable-x11grab $FFMPEGCONFIGURE 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --pkgname=ffmpeg --pkgversion="5:$(date +%Y%m%d%H%M)-git" --backup=no --deldoc=yes --fstrans=no --default 2>> $LOG >> $LOG
hash x264 ffmpeg ffplay ffprobe 2>> $LOG >> $LOG
}

#maverick update
maverick_x264depup ()
{
apt-get -y remove x264 libx264-dev 2>> $LOG >> $LOG
apt-get -y update 2>> $LOG >> $LOG
apt-get -y install build-essential checkinstall git libfaac-dev libjack-jackd2-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libsdl1.2-dev libtheora-dev libva-dev libvdpau-dev libvorbis-dev libx11-dev libxfixes-dev libxvidcore-dev texi2html yasm zlib1g-dev 2>> $LOG >> $LOG

}

maverick_ffmpegdepup ()
{
apt-get -y remove ffmpeg 2>> $LOG >> $LOG
apt-get -y update 2>> $LOG >> $LOG
apt-get -y install build-essential checkinstall git libfaac-dev libjack-jackd2-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libsdl1.2-dev libtheora-dev libva-dev libvdpau-dev libvorbis-dev libx11-dev libxfixes-dev libxvidcore-dev texi2html yasm zlib1g-dev 2>> $LOG >> $LOG

}

maverick_x264update ()
{
cd $INSTALL/x264 2>> $LOG >> $LOG
make distclean 2>> $LOG >> $LOG
git pull 2>> $LOG >> $LOG
./configure --enable-static $X264CONFIGURE 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --pkgname=x264 --pkgversion=""3:$(./version.sh | awk -F'[" ]' '/POINT/{print $4"+git"$5}')"" --backup=no --deldoc=yes --fstrans=no --default2>> $LOG >> $LOG
}

maverick_ffmpegupdate ()
{
cd $INSTALL/ffmpeg 2>> $LOG >> $LOG
make distclean 2>> $LOG >> $LOG
git pull 2>> $LOG >> $LOG
./configure --enable-gpl --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libvorbis --enable-libx264 --enable-nonfree --enable-version3 --enable-x11grab $FFMPEGCONFIGURE 2>> $LOG >> $LOG
make -j $NO_OF_CPUCORES 2>> $LOG >> $LOG
checkinstall --pkgname=ffmpeg --pkgversion="5:$(date +%Y%m%d%H%M)-git" --backup=no --deldoc=yes --fstrans=no --default 2>> $LOG >> $LOG
hash x264 ffmpeg ffplay ffprobe 2>> $LOG >> $LOG
}

#exit function
die ()
{
echo $@
killall $SCRIPT
exit 1
}

#exit if first install function
died ()
{
echo $@
rm $CONF
killall $SCRIPT
exit 1
}

#error function
error ()
{
kill "$PID" &>/dev/null 2>> $LOG >> $LOG

echo $1
echo $@
killall $SCRIPT
exit 1
}

#update function
update_check ()
{
echo "Checking for new version"
cd $INSTALL
wget https://github.com/pruperting/x264-ffmpeg-up-to-date/raw/master/ffmpegversion.txt 2>> $LOG >> $LOG
source ffmpegversion.txt 2>> $LOG >> $LOG
if [ "$CURRENT" -gt "$VERSION" ]; then
echo "There is a newer version of the script, updating to version $CURRENT"
touch updateffmpegupdate.sh 2>> $LOG >> $LOG
echo "#!/bin/bash" > updateffmpegupdate.sh
echo "echo "still updating.."" >> updateffmpegupdate.sh
echo "sleep 5" >> updateffmpegupdate.sh
echo "killall ffmpegupdate.sh" >> updateffmpegupdate.sh
echo "cd $INSTALL" >> updateffmpegupdate.sh
echo "rm ffmpegupdate.sh" >> updateffmpegupdate.sh
echo "wget https://github.com/pruperting/x264-ffmpeg-up-to-date/raw/master/ffmpegupdate.sh" >> updateffmpegupdate.sh
echo "chmod a+x ffmpegupdate.sh" >> updateffmpegupdate.sh
echo "echo ""ffmpegupdate.sh updated""" >> updateffmpegupdate.sh
echo "echo "You have been updated to the latest version."" >> updateffmpegupdate.sh
echo "echo "The new script can be found at "$INSTALL/ffmpegupdate.sh""" >> updateffmpegupdate.sh
echo "echo "The Changelog is "" >> updateffmpegupdate.sh
echo "echo "$CHANGELOG"" >> updateffmpegupdate.sh
echo "echo "Update check complete."" >> updateffmpegupdate.sh
echo "echo "Thats it, all done."" >> updateffmpegupdate.sh
echo "echo "Exiting now, bye."" >> updateffmpegupdate.sh
echo "exit" >> updateffmpegupdate.sh
chmod a+x updateffmpegupdate.sh 2>> $LOG >> $LOG
/bin/bash updateffmpegupdate.sh & 2>> $LOG >> $LOG
rm ffmpegversion.txt 2>> $LOG >> $LOG
exit
else
if [ "$CURRENT" -eq "$VERSION" ]; then
rm ffmpegversion.txt 2>> $LOG >> $LOG
echo "You have the latest version."
echo "Update check complete."
echo "That's it, all done."
echo "Exiting now, bye."
exit
else
rm ffmpegversion.txt 2>> $LOG >> $LOG
echo "Sorry, something went wrong with the update check, skipping."
echo "That's it, all done."
echo "Exiting now, bye."
exit
fi
fi
}

#first run - install instead of update

first_install ()
{
#first, lets warn the user that use of this script requires some common sense and may mess things up
echo "WARNING, if you don't know what this script does"
echo "#-#-#-#-#-#-#-#-#-DO NOT RUN IT-#-#-#-#-#-#-#-#-#"
read -p "Continue (y/n)?"
[ "$REPLY" == y ] || die "exiting (chicken ;) )..."
echo

#next, lets find out what version of Ubuntu we are running and check it
DISTRO=( $(cat /etc/lsb-release | grep CODE | cut -c 18-) )
OKDISTRO="maverick natty oneiric"

if [[ ! $(grep $DISTRO <<< $OKDISTRO) ]]; then
die "Exiting. Your distro is not supported, sorry.";
fi

DISTRIB=( $(cat /etc/lsb-release | grep ID | cut -c 12-) )

read -p "You are running $DISTRIB $DISTRO, is this correct (y/n)?"
[ "$REPLY" == y ] || die "Sorry, I think you are using a different distro, exiting to be safe."
echo
echo "This script uses a configuration file."
echo "If you want to customise the default install and log file locations,"
echo "please edit the variables at the begining of this file accordingly."
echo "If you are happy to leave them as is or you have already edited them, then lets begin."
echo
read -p "Are you happy to continue without any edits (y/n)?"
[ "$REPLY" == y ] || die "Please edit the first part of this scrip, titled #VARIABLES."
echo
# ok, already, last check before proceeding
echo "OK, we are ready to rumble."
read -p "Shall I proceed, remember, this musn't be stopped (y/n)?"
[ "$REPLY" == y ] || died "exiting. Bye, bye."

echo
echo "Lets roll!"
echo "script started" > $LOG
rm -rf "$INSTALL"/ffmpeg
rm -rf "$INSTALL"/x264
echo "installing dependencies"
echo "installing dependencies" 2>> $LOG >> $LOG
"$DISTRO"_dep || error "Sorry something went wrong installing dependencies, please check the $LOG file." &
PID=$!
#this is a simple progress indicator
while ps |grep $PID &>/dev/null; do
echo -n "."
echo -en "\b-"
sleep 1
echo -en "\b\\"
sleep 1
echo -en "\b|"
sleep 1
echo -en "\b/"
sleep 1
done

echo -e "\bDone"
echo
echo "downloading, building and installing x264"
echo "downloading, building and installing x264" 2>> $LOG >> $LOG
"$DISTRO"_x264 || error "Sorry something went wrong installing x264, please check the $LOG file." &
PID=$!
#this is a simple progress indicator
while ps |grep $PID &>/dev/null; do
echo -n "."
echo -en "\b-"
sleep 1
echo -en "\b\\"
sleep 1
echo -en "\b|"
sleep 1
echo -en "\b/"
sleep 1
done

echo -e "\bDone"
echo
echo "downloading, building and installing FFmpeg"
echo "downloading, building and installing FFmpeg" 2>> $LOG >> $LOG
"$DISTRO"_ffmpeg || error "Sorry something went wrong installing FFmpeg, please check the $LOG file." &
PID=$!
#this is a simple progress indicator
while ps |grep $PID &>/dev/null; do
echo -n "."
echo -en "\b-"
sleep 1
echo -en "\b\\"
sleep 1
echo -en "\b|"
sleep 1
echo -en "\b/"
sleep 1
done

echo -e "\bDone"
echo
echo "FFmpeg has now been built from source."
echo "You can now run this script whenever you want to update to the latest version."
echo
echo "Creating configuration file."
touch $CONF
echo "#configuration file for the ffmpegupdate.sh script" > $CONF
echo "#last modified on `date "+%m/%d/%y %l:%M:%S %p"`" >> $CONF
echo "INSTALL=$INSTALL" >> $CONF
echo "LOG=$LOG" >> $CONF
echo "FFMPEGCONFIGURE="$FFMPEGCONFIGURE"" >> $CONF
echo "X264CONFIGURE="$X264CONFIGURE"" >> $CONF
echo "SCRIPTUPDATE=$SCRIPTUPDATE" >> $CONF
echo
echo "Configuration file created."
}

#update function
update ()
{
DISTRO=( $(cat /etc/lsb-release | grep CODE | cut -c 18-) )
OKDISTRO="maverick natty oneiric"
if [[ ! $(grep $DISTRO <<< $OKDISTRO) ]]; then
die "Exiting. Your distro is not supported, sorry.";
fi
echo
echo "Checking if an update is needed."
#check if x264 needs updating
echo "Checking x264"
cd $INSTALL/x264
git remote update
X264VERCUR=( $(git status -uno | grep behind | cut -c18-23) )
if [ "$X264VERCUR" = "behind" ]; then
echo "x264 needs updating"
echo "Now running the update."
X264_UPDATE
else
echo "x264 already up-to-date"
fi
#check if FFmpeg needs updating
echo "Checking FFmpeg"
cd $INSTALL/ffmpeg
git remote update
FFMPEGVERCUR=( $(git status -uno | grep behind | cut -c18-23) )
if [ "$FFMPEGVERCUR" = "behind" ]; then
echo "FFmpeg needs updating"
echo "Now running the update."
FFMPEG_UPDATE
else
echo "FFmpeg already up-to-date"
fi
echo
echo "That's it, all done."
echo
}

#generic x264 update
X264_UPDATE ()
{
echo "Now updating x264."
"$DISTRO"_x264depup || error "Sorry something went wrong installing dependencies, please check the $LOG file." &
PID=$!
#this is a simple progress indicator
while ps |grep $PID &>/dev/null; do
echo -n "."
echo -en "\b-"
sleep 1
echo -en "\b\\"
sleep 1
echo -en "\b|"
sleep 1
echo -en "\b/"
sleep 1
done
"$DISTRO"_x264update || error "Sorry, something went wrong, please check the $LOG file." &
PID=$!
#this is a simple progress indicator
while ps |grep $PID &>/dev/null; do
echo -n "."
echo -en "\b-"
sleep 1
echo -en "\b\\"
sleep 1
echo -en "\b|"
sleep 1
echo -en "\b/"
sleep 1
done
echo -e "\bDone"
echo "x264 updated."
echo
}

#generic FFmpeg update
FFMPEG_UPDATE ()
{
echo "Now updating FFmpeg."
"$DISTRO"_ffmpegdepup || error "Sorry something went wrong installing dependencies, please check the $LOG file." &
PID=$!
#this is a simple progress indicator
while ps |grep $PID &>/dev/null; do
echo -n "."
echo -en "\b-"
sleep 1
echo -en "\b\\"
sleep 1
echo -en "\b|"
sleep 1
echo -en "\b/"
sleep 1
done
"$DISTRO"_ffmpegupdate || error "Sorry something went wrong, please check the $LOG file." &
PID=$!
#this is a simple progress indicator
while ps |grep $PID &>/dev/null; do
echo -n "."
echo -en "\b-"
sleep 1
echo -en "\b\\"
sleep 1
echo -en "\b|"
sleep 1
echo -en "\b/"
sleep 1
done
echo -e "\bDone"
echo "FFmpeg updated."
echo
}


###############
# THE MAIN SCRIPT
###############

# speed up build time using multpile processor cores.
NO_OF_CPUCORES=`grep -c ^processor /proc/cpuinfo 2>/dev/null`
if [ ! "$?" = "0" ]; then
NO_OF_CPUCORES=2
fi

#this script must be run as root, so lets check that
if [ "$(id -u)" != "0" ]; then
echo "Fail. This script must be run as root." 1>&2
   exit 1
fi

#check for the conf file and act accordingly
if [ -e $CONF ]; then
source $CONF
update
else
first_install
fi

#run an update check

if [ $SCRIPTUPDATE="YES" ]; then
update_check
fi
#sign off
exit