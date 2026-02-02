#!/bin/bash


function return_json_content() {
    echo '{'
    echo '    "output_content": '
    echo '"'${1}'"'
    echo ','

    echo '    "form_content": '
    echo '"'${2}'"'
    echo ','

    echo '    "error_content": '
    echo '"'${3}'"'
    echo '}'
}


UUID=$(uuid)

IFS=

TMP_DIR="/tmp"
RESULT_TXT=${TMP_DIR}"/"${UUID}".result.txt"
MYERRLOG_TXT=${TMP_DIR}"/"${UUID}".myerrlog.txt"
ERRLOG_TXT=${TMP_DIR}"/"${UUID}".errlog.txt"
FIN_TXT=${TMP_DIR}"/"${UUID}".fin.txt"


myfiltername=$1
# удаление пробелов в начале строки
myfiltername=$(echo "$myfiltername" | sed 's/^[[:space:]]*//')
myfiltername=$(echo $myfiltername | tr '[:lower:]' '[:upper:]')

form_content=$(echo "" | base64 -w 0)
output_content==$(echo "" | base64 -w 0)
error_content=$(echo "" | base64 -w 0)


# все RSF продукты
if [[ "${myfiltername}" =~ ^([F][R][BRNZ]) ]]; then
    form_content=$(${SCRIPT_DIR}/vtextako.sh "${myfiltername}" | base64 -w 0)
    return_json_content ${output_content} ${form_content} ${error_content}
    exit
fi

# если строка пустая или длина строки меньше 15
if [[ ( "${myfiltername}" =~ ^([A][F]) ) &&  ("${#myfiltername}" -lt 25) ]]; then
   error_content=$(echo "The filter name for an AF product is too short: Length ==[ ${#myfiltername} chars ]==[$myfiltername]== Please enter a full AF name" | base64 -w 0)
   return_json_content ${output_content} ${form_content} ${error_content}
   exit
fi

mylang="DE"
#if [[ "$2" == "" ]]; then
#   mylang="DE"
#elif [[ "$2" == "DE" ]]; then
#   mylang="DE"
#else
#   error_content=$(echo "UNKNOWN LANGUAGE ==[ $2 ]== FOR V-TEXT, SORRY" | base64 -w 0)
#   return_json_content ${output_content} ${form_content} ${error_content}
#   exit
#fi

awkdir=${SCRIPT_DIR}"/"$mylang"/AWK/"
txtdir=${SCRIPT_DIR}"/"$mylang"/TXT/"

mytstamp=$(date '+%Y-%m-%d %H:%M:%S :: ')
myt=$(date '+%Y-%m-%d_%H:%M:%S__')
errlog_txt0="${TMP_DIR}/${UUID}.errlog.txt"

# echo "1. Start check input info <check_input.awk>"
output=$(gawk -v filter_name="$myfiltername" -v mt="$mytstamp" -v errlog_txt=${errlog_txt0}  -f $awkdir"check_input.awk")

#output=$(gawk -v filter_name="$myfiltername" -v mt="$mytstamp" -v UUID=${UUID} -v TMP_DIR=${TMP_DIR} -f $awkdir"check_input.awk")
read -r err_code <<< "$output"

if [ $err_code -eq "1" ]; then
   cat /dev/null > ${MYERRLOG_TXT}
   output=$(gawk -v mt="$mytstamp" -v UUID=${UUID} -v TMP_DIR=${TMP_DIR} -f $awkdir"print_errlog.awk" ${ERRLOG_TXT})
   error_content=$(cat ${MYERRLOG_TXT} | base64 -w 0)
   cat /dev/null > ${RESULT_TXT}
   cat /dev/null > ${MYERRLOG_TXT}
   cat /dev/null > ${ERRLOG_TXT}
   return_json_content ${output_content} ${form_content} ${error_content}
   exit
fi

# echo "2. Start converting input into string <start_processing.awk>"
my_str=$(gawk -v filter_name="$myfiltername" -v mt="$mytstamp" -v UUID=${UUID} -v TMP_DIR=${TMP_DIR} -f $awkdir"start_processing.awk")

# echo "3. Print Filter Series <p01_fs.awk>"
$(gawk -v my_string=$my_str -v mt="$mytstamp" -v UUID=${UUID} -v TMP_DIR=${TMP_DIR} -f $awkdir"p01_fs.awk" $txtdir"p01_fs.txt")

# echo "4. Print 1x run filter element <p02_element.awk>"
$(gawk -v my_string=$my_str -v callnumber=1 -v mt="$mytstamp" -v UUID=${UUID} -v TMP_DIR=${TMP_DIR} -f $awkdir"p02_element.awk" $txtdir"p02_element.txt")

# echo "5. Print Antrieb 1x run <p03_antrieb_01.awk>"
output=$(gawk -v my_string=$my_str -v mt="$mytstamp" -v UUID=${UUID} -v TMP_DIR=${TMP_DIR} -f $awkdir"p03_antrieb_01.awk" $txtdir"p03_antrieb_01.txt")
read -r motor_number <<< "$output"

# echo "6. Print Antrieb 2x run <p03_antrieb_02.awk>"
output1=$(gawk -v my_string=$my_str -v motor_nr=$output -v mt="$mytstamp" -v UUID=${UUID} -v TMP_DIR=${TMP_DIR} -f $awkdir"p03_antrieb_02.awk" $txtdir"p03_antrieb_02.txt")

# echo "7. Print Filter Ports <p04_filter_ports.txt>"
output1=$(gawk -v my_string=$my_str -v mt="$mytstamp" -v UUID=${UUID} -v TMP_DIR=${TMP_DIR} -f $awkdir"p04_filter_ports.awk" $txtdir"p04_filter_ports.txt")

# echo "8. Print Filter material <p05_material.txt>"
output1=$(gawk -v my_string=$my_str -v mt="$mytstamp" -v UUID=${UUID} -v TMP_DIR=${TMP_DIR} -f $awkdir"p05_material.awk" $txtdir"p05_material.txt")

# callnumber = 2 /// второй проход
# echo "9. Print 2x run filter element <p02_element.awk>"
$(gawk -v my_string=$my_str -v callnumber=2 -v mt="$mytstamp" -v UUID=${UUID} -v TMP_DIR=${TMP_DIR} -f $awkdir"p02_element.awk" $txtdir"p02_element.txt")

# echo "10. Print dP Manometer <p07_lastgr_1.awk>"
output1=$(gawk -v my_string=$my_str -v mt="$mytstamp" -v UUID=${UUID} -v TMP_DIR=${TMP_DIR} -f $awkdir"p07_lastgr_1.awk" $txtdir"p07_lastgr_1.txt")

# echo "11. Print 2 number in the last group <p07_lastgr_2.awk>"
output1=$(gawk -v my_string=$my_str -v mt="$mytstamp" -v UUID=${UUID} -v TMP_DIR=${TMP_DIR} -f $awkdir"p07_lastgr_2.awk" $txtdir"p07_lastgr_2.txt")

# echo "12. Print drain valve <p07_lastgr_3.awk>"
output1=$(gawk -v my_string=$my_str -v mt="$mytstamp" -v UUID=${UUID} -v TMP_DIR=${TMP_DIR} -f $awkdir"p07_lastgr_3.awk" $txtdir"p07_lastgr_34.txt")

# echo "13. Print RS-Ventil <p07_lastgr_4.awk>"
output1=$(gawk -v my_string=$my_str -v mt="$mytstamp" -v UUID=${UUID} -v TMP_DIR=${TMP_DIR} -f $awkdir"p07_lastgr_4.awk" $txtdir"p07_lastgr_34.txt")

# echo "14. Print Bypass <p07_lastgr_5.awk>"
output1=$(gawk -v my_string=$my_str -v mt="$mytstamp" -v UUID=${UUID} -v TMP_DIR=${TMP_DIR} -f $awkdir"p07_lastgr_5.awk")

# echo "15. Print Farbton <p08_farbton.awk>"
output1=$(gawk -v my_string=$my_str -v mt="$mytstamp" -v UUID=${UUID} -v TMP_DIR=${TMP_DIR} -f $awkdir"p08_farbton.awk" $txtdir"p08_farbton.txt")

# echo "16. Print KAT Text <p09_kategorie.awk>"
output1=$(gawk -v my_string=$my_str -v mt="$mytstamp" -v UUID=${UUID} -v TMP_DIR=${TMP_DIR} -f $awkdir"p09_kategorie.awk" $txtdir"p09_kategorie.txt")

# echo "17. Print Endnummer <p10_endnr.awk>"
output1=$(gawk -v my_string=$my_str -v mt="$mytstamp" -v UUID=${UUID} -v TMP_DIR=${TMP_DIR} -f $awkdir"p10_endnr.awk" $txtdir"p10_endnr.txt")

output=$(gawk -v filter_name="$myfiltername" -v mt="$mytstamp" -v UUID=${UUID} -v TMP_DIR=${TMP_DIR} -f $awkdir"print_vtext.awk" ${RESULT_TXT})
output=$(gawk -v mt="$mytstamp" -v UUID=${UUID} -v TMP_DIR=${TMP_DIR} -f $awkdir"print_errfin.awk" ${ERRLOG_TXT})

output_content=$(cat ${FIN_TXT} | base64 -w 0)

rm -f ${RESULT_TXT}
rm -f ${MYERRLOG_TXT}
rm -f ${ERRLOG_TXT}
rm -f ${MYERRLOG_TXT}
rm -f ${FIN_TXT}

return_json_content ${output_content} ${form_content} ${error_content}
