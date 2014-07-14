#!/bin/bash
# Search between tags down a directory tree
 
# CPR : Jd Daniel :: Ehime-ken
# MOD : 2014-07-14 @ 12:25:19

# INP : $ ./ScripSearch.sh noscript "/path/to/dir"

EXTS="${1}"
DIRS="${2}"

## ARGV+2 as array
TYPE=( $(echo "${*:3}") )

function run() 
{
    ## Prevent collision via extension(s)
    TRAIL="$HOME/Documents/ScriptSearch-${EXTS}.txt"

    ## Filetypes down the tree
    ## find . -type f -name '*.*' |sed 's|.*\.||' |sort -u
    [ -z "$TYPE" ] && TYPE=('html?' 'jsp' 'php') #defaults
        TYPE=$(printf "|%s" "${TYPE[@]}") #escalated types


    [ -d "${DIRS}" ] && {

        echo "Found: ${DIRS}" 
        cd   "${DIRS}"

            [ -f "${TRAIL}" ] && {
                echo '' > $TRAIL #re-prime if exists
            }


        #while file matches in joined types do, 
        #path match spaces http://goo.gl/1mMYSL
        find -E * -type f -iregex ".*(${TYPE:1})" |\
        while IFS= read -r file; do

            echo "Trying: $file"

            contents='' #flush/reset for empty
            contents=$(python -c "if True:
                import sys, BeautifulSoup
                html = BeautifulSoup.BeautifulSoup(open(sys.argv[1]).read())
                for script in html.findAll(\"$EXTS\"):
                    print u''.join(unicode(item) for item in script)
            " "$(pwd)/$file" )

            #if not empty DOMWalk do
            [ ! -z "${contents}" ] && {
                echo -e "\n\tHIT: ${file}\n"

                    #pad file name length
                    filepath="== $(pwd)/$file =="
                    padding=$(python -c "if True:
                        import sys
                        print '=' * ${#filepath}
                    " )

                #pump file with match contents
                echo -e "$padding\n$filepath\n$padding" >> $TRAIL
                echo -e "${contents}"                   >> $TRAIL
                echo -e "\n\n\n"                        >> $TRAIL
            }  

        done
    }
}

run 