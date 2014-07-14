#!/bin/bash
# Search between tags down a directory tree
 
# CPR : Jd Daniel :: Ehime-ken
# MOD : 2014-07-14 @ 12:25:19

# INP : $ ./ScripSearch.sh noscript "/path/to/dir"

EXTS="${1}"
DIRS="${2}"
TYPE=( $(echo "${*:3}") )

function run() 
{
    ## Prevent collision via extension(s)
    PATH="$HOME/Documents/ScriptSearch-${EXTS}.txt"

    ## Filetypes down the tree
    ## find . -type f -name '*.*' |sed 's|.*\.||' |sort -u

    [ -z "$TYPE" ] && TYPE=('html?' 'jsp' 'php')

        TYPE=$(printf "|%s" "${TYPE[@]}") #escalates types

    [ -d "${DIRS}" ] && {

        echo "Found: ${DIRS}" && cd "${DIRS}"

        [ -f "${PATH}" ] && {
            echo '' > $PATH #clear
        }

        for file in $(/usr/bin/find -E * -type f -iregex ".*(${TYPE:1})"); do 

            echo "Trying: $file"

            contents='' #flush
            contents=$(/usr/local/bin/python -c "if True:
                import sys, BeautifulSoup
                html = BeautifulSoup.BeautifulSoup(open(sys.argv[1]).read())
                for script in html.findAll(\"$EXTS\"):
                    print u''.join(unicode(item) for item in script)
            " "$(pwd)/$file" )

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
            }  

        done
    }
}
run 