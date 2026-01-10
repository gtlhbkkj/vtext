#!/bin/bash

#x="/opt/vtext/app/script/AKO/DE/AWK/check_input_ako.awk"

UUID=$(uuid)
TMP_DIR="/tmp"
awkdir=${SCRIPT_DIR}"/AKO/DE/AWK/"
txtdir=${SCRIPT_DIR}"/AKO/DE/TXT/"

myfiltername=$1

echo
mytstamp=$(date '+%Y-%m-%d %H:%M:%S :: ')
#errlog_txt0="errlog_ako.txt"
#result_txt0="result_ako.txt"

errlog_txt0="${TMP_DIR}/${UUID}.errlog.txt"
result_txt0="${TMP_DIR}/${UUID}.result.txt"
# echo " ${errlog_txt0}" >> /tmp/pedro.txt

output=$(gawk -v filter_name="$myfiltername" -v mt="$mytstamp" -v errlog_txt=${errlog_txt0} -v result_txt=${result_txt0} -f ${awkdir}"check_input_ako.awk" ${txtdir}"data_01.txt")

cat ${result_txt0} ${errlog_txt0}
rm  ${result_txt0} ${errlog_txt0}

