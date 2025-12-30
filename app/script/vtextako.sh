#!/bin/bash

#x="/opt/vtext/app/script/AKO/DE/AWK/check_input_ako.awk"

UUID=$(uuid)
TMP_DIR="/tmp"
awkdir=${SCRIPT_DIR}"/AKO/DE/AWK/"
txtdir=${SCRIPT_DIR}"/AKO/DE/TXT/"

myfiltername=$1
# echo "Create V-TEXT for Filter: ==[ $myfiltername ]== "
# read -p "Нажмите Enter для продолжения..."

################ CHECKING ###################
echo
mytstamp=$(date '+%Y-%m-%d %H:%M:%S :: ')
#errlog_txt0="errlog_ako.txt"
errlog_txt0="${TMP_DIR}/${UUID}.errlog.txt"
result_txt0="${TMP_DIR}/${UUID}.result.txt"

# echo "1. Start check input info <check_input_ako.awk>"
#        $(gawk -v filter_name="$myfiltername" -v mt="$mytstamp" -v errlog_txt=${errlog_txt0} -f ${awkdir}"test.awk"            ${txtdir}"data_01.txt")

output=$(gawk -v filter_name="$myfiltername" -v mt="$mytstamp" -v errlog_txt=${errlog_txt0} -v result_txt=${result_txt0} -f ${awkdir}"check_input_ako.awk" ${txtdir}"data_01.txt")

# echo "2. Finisched check input info <check_input_ako.awk>"
# echo

#read -r err_code <<< "$output"

# echo "=========== ${errlog_txt0} ================"

cat ${result_txt0} ${errlog_txt0}
rm  ${result_txt0} ${errlog_txt0}

# read -p "Нажмите Enter для продолжения..."

#- cat errlog.txt
# read -p "Нажмите Enter для продолжения..."


#if [ $err_code -eq "1" ]; then
  # echo ""
  # clear
  # cat ${errlog_txt0} > mypage.html
  # cat /dev/null > ${errlog_txt0}
  # cat /dev/null > errlog.txt
  # exit
#else
#  echo "Input correct..."
#fi
