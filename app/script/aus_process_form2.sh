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
#mdd1=$(echo ${json_data} | jq -r '.label1')
#mdd2=$(echo ${json_data} | jq -r '.label2')
#mdd3=$(echo ${json_data} | jq -r '.label3')
#mdd4=$(echo ${json_data} | jq -r '.label4')
#durchsatz=$(echo ${json_data} | jq -r '.durchsatz')
#wpressure=$(echo ${json_data} | jq -r '.wpressure')
#wtemperature=$(echo ${json_data} | jq -r '.wtemperature')
#dpressure=$(echo ${json_data} | jq -r '.dpressure')
#dtemperature=$(echo ${json_data} | jq -r '.dtemperature')
#dpipeline=$(echo ${json_data} | jq -r '.dpipeline')
#fineness=$(echo ${json_data} | jq -r '.fineness')
#antrieb=$(echo ${json_data} | jq -r '.antrieb')
#material=$(echo ${json_data} | jq -r '.material')
#materialel=$(echo ${json_data} | jq -r '.materialel')
#comments=$(echo ${json_data} | jq -r '.comments')
#ksf=$(echo ${json_data} | jq -r '.ksf')
#
#
############### УНИВЕРСАЛЬНЫЙ ВАРИАНТ АССОЦИАТИВНЫЙ МАССИВ ############
#### ЕСЛИ НЕ РАБОТАЕТ - ЗАКОММЕНТИРОВАТЬ И ПОМЕНЯТЬ ТО ЖЕ САМОЕ В PAGE-3.awk в начале
#medium=$(echo "medium:${medium}")
#mdd1=$(echo "mdd1:${mdd1}")
#mdd2=$(echo "mdd2:${mdd2}")
#mdd3=$(echo "mdd3:${mdd3}")
#mdd4=$(echo "mdd4:${mdd4}")
#durchsatz=$(echo "durchsatz:${durchsatz}")
#wpressure=$(echo "wpressure:${wpressure}")
#wtemperature=$(echo "wtemperature:${wtemperature}")
#dpressure=$(echo "dpressure:${dpressure}")
#dtemperature=$(echo "dtemperature:${dtemperature}")
#dpipeline=$(echo "dpipeline:${dpipeline}")
#fineness=$(echo "fineness:${fineness}")
#antrieb=$(echo "antrieb:${antrieb}")
#material=$(echo "material:${material}")
#materialel=$(echo "materialel:${materialel}")
#comments=$(echo "comments:${comments}")
#ksf=$(echo "ksf:${ksf}")
############ КОНЕЦ УНИВЕРСАЛЬНОГО ВАРИАНТА


#mys1="${medium};${mdd1};${mdd2};${mdd3};${mdd4};${durchsatz};${wpressure};${wtemperature};"
#mys2="${dpressure};${dtemperature};${dpipeline};${fineness};${antrieb};${material};"
#mys3="${materialel};${comments};${ksf}"
#mystring="$mys1$mys2$mys3"


#echo $mystring > /home/vtext/app/script/111.txt



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

if [[ "${medium}" == "01" ]]; then
  output1=$(gawk -v json_data=${json_data} -v result_txt=${result_txt} -v errlog_txt=${errlog_txt} -f ${awkdir}"page-3.awk" ${txtdir}"page-1.txt")
  #output1=$(gawk  -v mystring=${mystring} -v result_txt=${result_txt} -v errlog_txt=${errlog_txt} -f ${awkdir}"page-3.awk" ${txtdir}"page-1.txt")
  #output2=$(gawk  -v mystring=${output1} -v result_txt=${result_txt} -v errlog_txt=${errlog_txt} -f ${awkdir}"page-31.awk" ${txtdir}"fe-code.txt" )

  output2=$(gawk  -v mystring=${output1} -v result_txt=${result_txt} -v errlog_txt=${errlog_txt} -f ${awkdir}"page-31.awk" ${txtdir}"flowrate.txt" )
  output3=$(gawk  -v mystring=${output2} -v result_txt=${result_txt} -v errlog_txt=${errlog_txt} -f ${awkdir}"page-32.awk" ${txtdir}"fe-pos.txt" ${txtdir}"fe-code.txt" ${txtdir}"page-2.txt")
  #output3=$(gawk  -v mystring=${output2} -v result_txt=${result_txt} -v errlog_txt=${errlog_txt} -f ${awkdir}"page-32.awk" ${txtdir}"page-2.txt")

else
  output1=$(gawk -v json_data=${json_data} -v txtdir=${txtdir} -v result_txt=${result_txt} -f ${awkdir}"page-3-ksf.awk" ${txtdir}"page-1.txt" ${txtdir}"flowrate.txt" ${txtdir}"fe-code.txt" ${txtdir}"fe-pos.txt")
  output2=$(gawk -v mystring=${output1} -v txtdir=${txtdir} -v result_txt=${result_txt} -f ${awkdir}"page-31-ksf.awk" ${txtdir}"fe-code.txt" ${txtdir}"fe-pos.txt" ${txtdir}"page-2.txt")

fi


echo $output > /tmp/xxxx

output_content=$(cat ${result_txt} ${errlog_txt} | base64 -w 0)

#error_content=$(cat ${errlog_txt} | base64 -w 0)

return_json_content "${output_content}" "${error_content}"

exit 0
