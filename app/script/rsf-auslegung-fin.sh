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
    echo $json_data > /tmp/xxxx
    error_content=$(echo "Invalid JSON/bad parameters." | base64 -w 0)
    return_json_content "${output_content}" "${error_content}"
    exit 1
fi

pos_1=$(echo ${json_data} | jq -r '.pos1')
pos_2=$(echo ${json_data} | jq -r '.pos2')
pos_3=$(echo ${json_data} | jq -r '.pos3')
pos_4=$(echo ${json_data} | jq -r '.pos4')
pos_5=$(echo ${json_data} | jq -r '.pos5')
pos_6=$(echo ${json_data} | jq -r '.pos6')
pos_7=$(echo ${json_data} | jq -r '.pos7')
f_base=$(echo ${json_data} | jq -r '.f_base')

rm -f ${RESULT_TXT}
rm -f ${MYERRLOG_TXT}
rm -f ${ERRLOG_TXT}
rm -f ${MYERRLOG_TXT}
rm -f ${FIN_TXT}

echo ${pos_1} >> /tmp/xxxx
echo ${pos_2} >> /tmp/xxxx
echo ${pos_3} >> /tmp/xxxx
echo ${pos_4} >> /tmp/xxxx
echo ${pos_5} >> /tmp/xxxx
echo ${pos_6} >> /tmp/xxxx
echo ${pos_7} >> /tmp/xxxx
echo ${f_base} >> /tmp/xxxx

#UUID=$(uuid)
TMP_DIR="/tmp"
awkdir=${SCRIPT_DIR}"/AUS/DE/AWK/"
txtdir=${SCRIPT_DIR}"/AUS/DE/TXT/"

errlog_txt="${TMP_DIR}/${UUID}.aus_page1.errlog.txt"
result_txt="${TMP_DIR}/${UUID}.aus_page1.result.txt"

output=$(gawk -v txtdir=${txtdir} \
    -v pos1=${pos_1} \
    -v pos2=${pos_2} \
    -v pos3=${pos_3} \
    -v pos4=${pos_4} \
    -v pos5=${pos_5} \
    -v pos6=${pos_6} \
    -v pos7=${pos_7} \
    -v f_base=${f_base} \
    -v result_txt=${result_txt} -v errlog_txt=${errlog_txt} -f ${awkdir}"page-33.awk" > /tmp/awk.err.txt)

#echo $output > /tmp/xxxx
#echo "11111111111" > /home/vtext/app/script/111.txt


output_content=$(cat ${result_txt} ${errlog_txt} | base64 -w 0)

#error_content=$(cat ${errlog_txt} | base64 -w 0)

return_json_content "${output_content}" "${error_content}"

exit 0
