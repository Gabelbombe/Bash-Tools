#!/bin/bash
# Review and Remove Wireless Access Points on DEB based Systems
# Make sure to place script in /usr/local/bin 

# CPR : Jd Daniel :: Ehime-ken
# MOD : 2013-12-09 @ 09:31:00

# INP : $ wireless -{flag} {arg}


##===============================================================##
##===============================================================##

clear

# If the user is not root
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2 ; exit 1
fi


declare -r VERSION='1.1b'
declare -r net_dir='/etc/NetworkManager/system-connections'


function list ()
{
  cd $net_dir

  # simple ls
  export files=$(ls)
  export count=$(ls |wc -l)

  echo -e "\n\tFound ${count} wireless connections"

    for f in $files; do
        echo -e "\t * $f"
    done
}

function drop ()
{
  # make sure that we have a working file and directory...
  cd "${net_dir}" ; [ -f "$OPTARG" ] || { echo -e "\n\tConnection does not exist..." ; exit 1; }

  # confirmation for removal
  printf "\n\tDo you want to delete $OPTARG [y/n] " ; read -r resp

    # strtolower, and rm
    if [ 'y' == "$(echo $resp | awk '{print tolower($0)}')" ]; then
      echo rm -f ${net_dir}/${OPTARG}
    fi
}

function flush ()
{
  # make sure that we have a directory with files...
  cd "${net_dir}" ; list ; [ 0 -ge "${count}" ] && { echo -e "\tExiting, Nothing to flush..." ;  exit 1 ; }

  # confirmation for removing all files
  printf "\n\tAll Wireless Connections will be removed, continue? [y/n] " ; read -r resp

    # strtolower, and rm
    if [ 'y' == "$(echo $resp | awk '{print tolower($0)}')" ]; then
      rm -f ${net_dir}/*
    fi

  exit 0
}

function version ()
{
  echo -e "\n\twireless (GNU wireless network purge) v${VERSION}"
  echo -e "\n\tCopyright (C) 2013 Hydra Code, LLC."
  echo -e "\tLicense GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.\n\tThis is free software: you are free to change and redistribute it.\n\tThere is NO WARRANTY, to the extent permitted by law."
  echo -e "\n\n\tWritten by Jd Daniel (Ehime-ken) http://github.com/ehime"
  exit 0
}

function help ()
{
  echo -e "\n\tUsage: wireless [OPTION]... [FILE]..."
  echo -e "\tList, remove single or flush the contents of your Wireless Network Manager"
  echo -e "\n\tThe options below may be used to perform the above actions, this program will only"
  echo -e "\trun a single flag or parameter at a time. Flag chaining is only available for -d"
  echo -e "\t  -l, --list \t\t List the contents of your 'Network Manager'"
  echo -e "\t  -d, --drop [conn] \t Drop a single (or multiple) wireless connections"
  echo -e "\t  -f, --flush \t\t Flush all wireless connections."
  echo -e "\t      --help \t\t Display this help menu and exit"
  echo -e "\t      --version \t Display version information and exit"
  exit 0
}

##===============================================================##
##===============================================================##

# no long-opts supported except --help
while getopts ':ld:f-:' OPT; do
  case $OPT in

    l) list  ;;
    d) dirList="${dirList} $OPTARG" ; drop  ;;
    f) flush ;;
    -) #long option
       case $OPTARG in

          list)     list    ;;
          drop)     drop    ;;
          flush)    flush   ;;
          help)     help    ;;
          version)  version ;;

       esac
   ;;
    : ) echo -e "\n\tMissing option argument for -$OPTARG" >&2; exit 1;;
    * ) echo -e "\n\tUnknown flag supplied ${OPTARG}\n\tTry wireless --help"; exit 1;;
  esac
done

shift $(($OPTIND - 1))

##===============================================================##
##===============================================================##