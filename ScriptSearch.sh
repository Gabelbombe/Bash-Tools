#!/bin/bash
# Development server setup
 
# CPR : Jd Daniel :: Ehime-ken
# MOD : 2014-07-14 @ 11:01:30

# INP : $ ./ScripSearch.sh "/path/to/dir"

PATH="$HOME/Documents/ScriptSearch.txt"
EXTS="${1}"
DIRS="${2}" ## 

[ -d "${DIRS}" ] && {

    echo "Found: ${DIRS}" && cd "${DIRS}"

    ## F-Types
    #  find . -type f -name '*.*' |sed 's|.*\.||' |sort -u


    [ -f "${PATH}" ] && {
        echo '' > $PATH #clear
    }

    for file in $(/usr/bin/find -E * -type f -iregex ".*(html?|jsp|php)"); do 

        echo "Trying: $file"

        contents='' #flush
        contents=$(/usr/local/bin/python -c 'if True:
            import sys, BeautifulSoup
            html = BeautifulSoup.BeautifulSoup(open(sys.argv[1]).read())
            for script in html.findAll("${EXTS}"):
                print "".join(script.contents)
        ' "$(pwd)/$file" )

        [ ! -z "${contents}" ] && {
            echo -e "\n\tHIT: ${file}\n"

            #pad file name length
            filepath="== $(pwd)/$file =="
            padding=$(/usr/local/bin/python -c "if True:
                import sys
                print '=' * ${#filepath}
            ")

            echo -e "$padding\n$filepath\n$padding" >> $PATH
            echo -e "${contents}"                   >> $PATH
            echo -e "\n\n\n"                        >> $PATH
            contents='' #flush
        }  

    done
}