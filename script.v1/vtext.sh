#!/bin/bash
# comment

cat /dev/null > result.txt
cat /dev/null > myerrlog.txt
cat /dev/null > errlog.txt
cat /dev/null > fin.txt
clear

# "AF173_G3,AF173/G3,3,13,2,1,5,0,2,0,0,3001,4406,AK,A13,KII,AF6016-010"
#myfiltername='AF7133-241-40200-4416AD/GX1 KII AF7073-025'
myfiltername=$1

# если строка пустая или длина строки меньше 15
if [[ -z "$myfiltername" || "${#myfiltername}" -lt 25 ]]; then
  echo "THE FILTER NAME IS TOO SHORT: LENGTH ==[ ${#myfiltername} chars ]==[$myfiltername]=="
  exit
fi


if [[ "$2" == "" ]]; then
  mylang="DE"
elif [[ "$2" == "DE" ]]; then
  mylang="DE"
else
  echo "UNKNOWN LANGUAGE ==[ $2 ]== FOR V-TEXT, SORRY"
  exit
fi

awkdir=$mylang"/AWK/"
txtdir=$mylang"/TXT/"

#read -p "FINISHED <check_input.awk>. Press ENTER to continue"

echo "Create V-TEXT for Filter: ==[ $myfiltername ]== and Language: ==[ $mylang ]=="

################ CHECKING ###################
echo
echo "1. Start check input info <check_input.awk>"
mytstamp=$(date '+%Y-%m-%d %H:%M:%S :: ')
myt=$(date '+%Y-%m-%d_%H:%M:%S__')
#echo $mytstamp $myt
#read -p "Press ENTER to continue"


output=$(gawk -v filter_name="$myfiltername" -v mt="$mytstamp" -f $awkdir"check_input.awk")
read -r err_code <<< "$output"
# echo "err_code: $err_code"
#read -p "FINISHED <check_input.awk>. Press ENTER to continue"

if [ $err_code -eq "1" ]; then
  echo
  echo "----------- cat errlog.txt -------------"
  cat errlog.txt
  cat /dev/null > myerrlog.txt
  output=$(gawk -v mt="$mytstamp" -f $awkdir"print_errlog.awk" errlog.txt)
  echo
  echo "----------- cat myerrlog.txt -------------"
  cat myerrlog.txt
  echo
#  read -p "2. Press ENTER to continue"
  cat /dev/null > result.txt
  cat /dev/null > myerrlog.txt
  cat /dev/null > errlog.txt
#  clear; ls -la; 
  exit
else
  echo "Input correct..."
fi


################ PROCESSING ###################
echo
echo "2. Start converting input into string <start_processing.awk>"
my_str=$(gawk -v filter_name="$myfiltername" -v mt="$mytstamp" -f $awkdir"start_processing.awk")
echo "My String is: " $my_str
echo

echo "3. Print Filter Series <p01_fs.awk>"
$(gawk -v my_string=$my_str -v mt="$mytstamp" -f $awkdir"p01_fs.awk" $txtdir"p01_fs.txt")
echo

# callnumber - ту же самую строку вызывает 1 раз здесь и 1 раз ниже для элемента
#мне из него забирать дальше не нужно
echo "4. Print 1x run filter element <p02_element.awk>"
$(gawk -v my_string=$my_str -v callnumber=1 -v mt="$mytstamp" -f $awkdir"p02_element.awk" $txtdir"p02_element.txt")
echo

## забрать Мат.номер мотора
echo "5. Print Antrieb 1x run <p03_antrieb_01.awk>"
output=$(gawk -v my_string=$my_str -v mt="$mytstamp" -f $awkdir"p03_antrieb_01.awk" $txtdir"p03_antrieb_01.txt")
read -r motor_number <<< "$output"
echo "motor_number : $motor_number"
echo

if [[ "$motor_number" == $"not found" ]]; then
  echo "#### ERROR: MOTOR NOT FOUND, SKIP 2 PART OF MOTOR PROCESSING ####"
  echo
else
  echo "6. Print Antrieb 2x run <p03_antrieb_02.awk>"
  echo 
  output1=$(gawk -v my_string=$my_str -v motor_nr=$output -v mt="$mytstamp" -f $awkdir"p03_antrieb_02.awk" $txtdir"p03_antrieb_02.txt")
fi

echo "7. Print Filter Ports <p04_filter_ports.txt>"
echo
output1=$(gawk -v my_string=$my_str -v mt="$mytstamp" -f $awkdir"p04_filter_ports.awk" $txtdir"p04_filter_ports.txt")

echo "8. Print Filter material <p05_material.txt>"
echo
output1=$(gawk -v my_string=$my_str -v mt="$mytstamp" -f $awkdir"p05_material.awk" $txtdir"p05_material.txt")

# callnumber = 2 /// второй проход
echo "9. Print 2x run filter element <p02_element.awk>"
echo
$(gawk -v my_string=$my_str -v callnumber=2 -v mt="$mytstamp" -f $awkdir"p02_element.awk" $txtdir"p02_element.txt")

echo "10. Print dP Manometer <p07_lastgr_1.awk>"
echo
output1=$(gawk -v my_string=$my_str -v mt="$mytstamp" -f $awkdir"p07_lastgr_1.awk" $txtdir"p07_lastgr_1.txt")

echo "11. Print 2 number in the last group <p07_lastgr_2.awk>"
echo
output1=$(gawk -v my_string=$my_str -v mt="$mytstamp" -f $awkdir"p07_lastgr_2.awk" $txtdir"p07_lastgr_2.txt")

echo "12. Print drain valve <p07_lastgr_3.awk>"
echo
output1=$(gawk -v my_string=$my_str -v mt="$mytstamp" -f $awkdir"p07_lastgr_3.awk" $txtdir"p07_lastgr_34.txt")

echo "13. Print RS-Ventil <p07_lastgr_4.awk>"
echo
output1=$(gawk -v my_string=$my_str -v mt="$mytstamp" -f $awkdir"p07_lastgr_4.awk" $txtdir"p07_lastgr_34.txt")

echo "14. Print Bypass <p07_lastgr_5.awk>"
echo
output1=$(gawk -v my_string=$my_str -v mt="$mytstamp" -f $awkdir"p07_lastgr_5.awk")

echo "15. Print Farbton <p08_farbton.awk>"
echo
output1=$(gawk -v my_string=$my_str -v mt="$mytstamp" -f $awkdir"p08_farbton.awk" $txtdir"p08_farbton.txt")

echo "16. Print KAT Text <p09_kategorie.awk>"
echo
output1=$(gawk -v my_string=$my_str -v mt="$mytstamp" -f $awkdir"p09_kategorie.awk" $txtdir"p09_kategorie.txt")

echo "17. Print Endnummer <p10_endnr.awk>"
echo
output1=$(gawk -v my_string=$my_str -v mt="$mytstamp" -f $awkdir"p10_endnr.awk" $txtdir"p10_endnr.txt")

output=$(gawk -v filter_name="$myfiltername" -v mt="$mytstamp" -f $awkdir"print_vtext.awk" result.txt)
output=$(gawk -v mt="$mytstamp" -f $awkdir"print_errfin.awk" errlog.txt)
cat fin.txt


cat /dev/null > result.txt
cat /dev/null > myerrlog.txt
cat /dev/null > errlog.txt
cat /dev/null > fin.txt
exit
