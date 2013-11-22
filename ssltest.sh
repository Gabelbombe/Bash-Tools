#!/bin/bash
# test a site accepts and connects on SSL/443
 
# CPR : Jd Daniel :: Ehime-ken
# MOD : 2013-11-21 @ 15:36:04

# old buggy way for reference =/
# [ '' != "$(echo $(echo ^D | telnet ${address} https 2> /dev/null) | awk '{print $3}')" ] \
#     && protocol="https://${address}" \
#     || protocol="http://${address}"

clear ; declare -r port='443'
while IFS=$'\n' read -r address || [[ -n "$address" ]]; do

    resp=$(echo ^D | openssl s_client -tls1 -connect  ${address}:${port} 2>&1 >/dev/null | grep ':error:' | awk -F':' '{print $6}')
    [ '' == "${resp}" ] && { protocol="https://${address}" ; resp='Connected...' ; } \
                        || { protocol="http://${address}"  ; resp="err: ${resp}"  ; }

    echo -e "Attempt:  ${address}"
    echo -e "Connects: ${protocol}"
    echo -e "Response: ${resp}"
    echo -e "\n"

done <<< $'www.kmsfinancial.com\nwww.erado.com\nwww.emeraldig.com\nwww.financialtelesisinc.com\nwww.carsonwealth.com\nwww.eresponse.com'
