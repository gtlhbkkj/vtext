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

echo ${json_data} | jq 2>/dev/null 1>&2
if [ $? -ne 0 ]; then
    error_content=$(echo "Invalid JSON/bad parameters." | base64 -w 0)
    return_json_content "${output_content}" "${error_content}"
    exit 1
fi

p01=$(echo ${json_data} | jq -r '.p01')
p02=$(echo ${json_data} | jq -r '.p02')
p03=$(echo ${json_data} | jq -r '.p03')
p04=$(echo ${json_data} | jq -r '.p04')
p05=$(echo ${json_data} | jq -r '.p05')
p06=$(echo ${json_data} | jq -r '.p06')
p07=$(echo ${json_data} | jq -r '.p07')
p08=$(echo ${json_data} | jq -r '.p08')
p09=$(echo ${json_data} | jq -r '.p09')
p10=$(echo ${json_data} | jq -r '.p10')
p06material=$(echo ${json_data} | jq -r '.p06material')
p06feinheit=$(echo ${json_data} | jq -r '.p06feinheit')
r01=$(echo ${json_data} | jq -r '.r01')
r02=$(echo ${json_data} | jq -r '.r02')
r03=$(echo ${json_data} | jq -r '.r03')
r04=$(echo ${json_data} | jq -r '.r04')
r05=$(echo ${json_data} | jq -r '.r05')

rm -f ${RESULT_TXT}
rm -f ${MYERRLOG_TXT}
rm -f ${ERRLOG_TXT}
rm -f ${MYERRLOG_TXT}
rm -f ${FIN_TXT}

TMP_DIR="/tmp"
FIN_TXT=${TMP_DIR}"/"${UUID}".fin.txt"
awkdir=${SCRIPT_DIR}"/AKO/DE/AWK/"
txtdir=${SCRIPT_DIR}"/AKO/DE/TXT/"
result_txt=${TMP_DIR}"/"${UUID}".result_ako.txt"

output=$(gawk -v txtdir=${txtdir} -v p01=${p01} -v p02=${p02} -v p03=${p03} -v p04=${p04} -v p05=${p05} -v p06=${p06} -v p07=${p07} -v p08=${p08} -v p06material=${p06material} -v p06feinheit=${p06feinheit} -v r01=${r01} -v r04=${r04} -v r05=${r05} -v result_txt=${result_txt} -f ${awkdir}"print_vtext_ako.awk" ${txtdir}"data_01.txt" ${txtdir}"data_02.txt" > /tmp/awk.err.txt)

output_content=$(cat ${result_txt} | base64 -w 0)

return_json_content "${output_content}" "${error_content}"

exit 0
