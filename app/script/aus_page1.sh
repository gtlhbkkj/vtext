#!/bin/bash


function return_json_content() {
    echo '{'
    echo '    "output_content": '
    echo '"'${1}'"'
    echo ','

    echo '    "error_content": '
    echo '"'${3}'"'
    echo '}'
}


UUID=$(uuid)
TMP_DIR="/tmp"
awkdir=${SCRIPT_DIR}"/AUS/DE/AWK/"
txtdir=${SCRIPT_DIR}"/AUS/DE/TXT/"

errlog_txt="${TMP_DIR}/${UUID}.aus_page1.errlog.txt"
result_txt="${TMP_DIR}/${UUID}.aus_page1.result.txt"

output=$(gawk -v errlog_txt=${errlog_txt} -v result_txt=${result_txt} -f ${awkdir}"page-1.awk" ${txtdir}"page-1.txt")
#output_content=$(cat ${result_txt} ${errlog_txt} | base64 -w 0)
output_content=$(cat ${result_txt} } | base64 -w 0)

rm  ${result_txt} ${errlog_txt}
#error_content=$(cat ${errlog_txt} | base64 -w 0)

return_json_content "${output_content}" "${error_content}"

exit 0
