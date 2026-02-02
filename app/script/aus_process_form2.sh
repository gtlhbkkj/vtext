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

# mdd = Medium Drop Down
mdd1=$(echo ${json_data} | jq -r '.label1')
mdd2=$(echo ${json_data} | jq -r '.label2')
mdd3=$(echo ${json_data} | jq -r '.label3')
mdd4=$(echo ${json_data} | jq -r '.label4')

durchsatz=$(echo ${json_data} | jq -r '.durchsatz')
wpressure=$(echo ${json_data} | jq -r '.wpressure')
wtemperature=$(echo ${json_data} | jq -r '.wtemperature')
dpressure=$(echo ${json_data} | jq -r '.dpressure')
dtemperature=$(echo ${json_data} | jq -r '.dtemperature')
dpipeline=$(echo ${json_data} | jq -r '.dpipeline')
fineness=$(echo ${json_data} | jq -r '.fineness')
antrieb=$(echo ${json_data} | jq -r '.antrieb')
material=$(echo ${json_data} | jq -r '.material')
materialel=$(echo ${json_data} | jq -r '.materialel')
comments=$(echo ${json_data} | jq -r '.comments')

mystring="${medium};${mdd1};${mdd2};${mdd3};${mdd4};${durchsatz};${wpressure};${wtemperature};${dpressure};${dtemperature};${dpipeline};${fineness};${antrieb};${material};${materialel};${comments}"

# для другой ветки  -  всё кроме КСС
# viscosity=$(echo ${json_data} | jq -r '.viscosity')
# Schmutz S01
s01_01=$(echo ${json_data} | jq -r '.S01_01')
# usw.
# s02_01 usw


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

# это для меня простая проверка того что мы получаем из JSONa
# echo ${json_data} | jq > /home/vtext/app/script/111.txt

#output1=$(gawk -v txtdir=${txtdir} -v mystring=${mystring} -v result_txt=${result_txt} -v errlog_txt=${errlog_txt} -f ${awkdir}"page-3.awk" ${txtdir}"page-1.txt" > /tmp/awk.err.txt)

#output1=$(gawk -v txtdir=${txtdir} -v mystring=${mystring} -v result_txt=${result_txt} -v errlog_txt=${errlog_txt} -f ${awkdir}"page-3.awk" ${txtdir}"page-1.txt")
output1=$(gawk  -v mystring=${mystring} -v result_txt=${result_txt} -v errlog_txt=${errlog_txt} -f ${awkdir}"page-3.awk" ${txtdir}"page-1.txt")
output2=$(gawk  -v mystring=${output1} -v result_txt=${result_txt} -v errlog_txt=${errlog_txt} -f ${awkdir}"page-31.awk" ${txtdir}"fe-code.txt")
output3=$(gawk  -v mystring=${output2} -v result_txt=${result_txt} -v errlog_txt=${errlog_txt} -f ${awkdir}"page-32.awk" ${txtdir}"fe-code.txt" ${txtdir}"page-2.txt")

echo $output > /tmp/xxxx

output_content=$(cat ${result_txt} ${errlog_txt} | base64 -w 0)

#error_content=$(cat ${errlog_txt} | base64 -w 0)

return_json_content "${output_content}" "${error_content}"

exit 0
