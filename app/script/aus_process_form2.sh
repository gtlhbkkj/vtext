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


output_content==$(echo "" | base64 -w 0)
error_content=$(echo "" | base64 -w 0)

if [ -z "${1}" ]; then
    error_content=$(echo "ERROR: Empty parameters." | base64 -w 0)
    return_json_content "${output_content}" "${error_content}"
    exit 1;
fi

UUID=$(uuid)

IFS=

json_data=${1}

echo ${json_data} > /tmp/form2.txt

echo ${json_data} | jq 2>/dev/null 1>&2
if [ $? -ne 0 ]; then
    echo $json_data > /tmp/xxxx
    error_content=$(echo "Invalid JSON/bad parameters." | base64 -w 0)
    return_json_content "${output_content}" "${error_content}"
    exit 1
fi

medium=$(echo ${json_data} | jq -r '.medium')
durchsatz=$(echo ${json_data} | jq -r '.durchsatz')
viscosity=$(echo ${json_data} | jq -r '.viscosity')
wpressure=$(echo ${json_data} | jq -r '.wpressure')
wtemperature=$(echo ${json_data} | jq -r '.wtemperature')
dpressure=$(echo ${json_data} | jq -r '.dpressure')
dtemperature=$(echo ${json_data} | jq -r '.dtemperature')
dpipeline=$(echo ${json_data} | jq -r '.dpipeline')
fineness=$(echo ${json_data} | jq -r '.fineness')

#s01=$(echo ${json_data} | jq -r '.S01')

rm -f ${RESULT_TXT}
rm -f ${MYERRLOG_TXT}
rm -f ${ERRLOG_TXT}
rm -f ${MYERRLOG_TXT}
rm -f ${FIN_TXT}



#UUID=$(uuid)
TMP_DIR="/tmp"
awkdir=${SCRIPT_DIR}"/AUS/DE/AWK/"
txtdir=${SCRIPT_DIR}"/AUS/DE/TXT/"

errlog_txt="${TMP_DIR}/${UUID}.aus_page1.errlog.txt"
result_txt="${TMP_DIR}/${UUID}.aus_page1.result.txt"


output=$(gawk -v txtdir=${txtdir} -v medium=${medium} -v result_txt=${result_txt} -v errlog_txt=${errlog_txt} -f ${awkdir}"page-2.awk" ${txtdir}"page-1.txt" > /tmp/awk.err.txt)

echo $output > /tmp/xxxx

output_content=$(cat ${result_txt} ${errlog_txt} | base64 -w 0)

#error_content=$(cat ${errlog_txt} | base64 -w 0)

return_json_content "${output_content}" "${error_content}"

exit 0
