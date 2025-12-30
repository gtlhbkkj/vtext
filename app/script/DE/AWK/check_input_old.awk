BEGIN {

error_code = 0

################################################
# 1. Убираем двойные пробелы. 
################################################
filter_name = toupper(filter_name)
gsub(/^ +/,"",filter_name)
gsub(/ +$/,"",filter_name)
gsub(/ +/," ",filter_name)

gsub(/ -/,"-",filter_name)
gsub(/- /,"-",filter_name)
gsub("F ","F",filter_name)
gsub("A ","A",filter_name)
gsub(" S","S",filter_name) # for SP elements
gsub(" G","G",filter_name) # for "/ G.." cases

gsub(/ \//,"/",filter_name)
gsub(/\/ /,"/",filter_name)

no_of_parts = split(filter_name,x," ")

print mt "-----------------------------------------------------------------------------" >> TMP_DIR "/" UUID ".errlog.txt"
print mt "ERROR LOG FOR FILTER : " filter_name >> TMP_DIR "/" UUID ".errlog.txt"
print mt "-----------------------------------------------------------------------------" >> TMP_DIR "/" UUID ".errlog.txt"

if (no_of_parts > 4) {
#  print mt "Err. 0011 - TOO MANY BLANK SPACES [ ] IN THE FILTER NAME" >> TMP_DIR "/" UUID ".errlog.txt"
  print mt "Err. 0011 - TOO MANY BLANK SPACES [ ] IN THE FILTER NAME" >> TMP_DIR "/" UUID ".errlog.txt"
  error_code = 1
}

################################################
# 2. check presence / number of  "/"
################################################
#n_of_parts = split(filter_name,x,"/")
#if (n_of_parts != 2) {
if ( !(filter_name ~ /^[^\/]*\/[^\/]*$/)) {    # скопировал из гугла
  gsub(/\//,"[/]",filter_name)
  print mt "Err. 0021 - YOU MUST HAVE 1 SINGLE PRESENCE OF SLASH CHARACTER [/] IN THE FILTER NAME"  >> TMP_DIR "/" UUID ".errlog.txt"
  error_code = 1
}


################################################
# 3. проверка формата ввода через REGEX
################################################
split(filter_name,parts_slash,"/")

# проверка формата для 3, 4, 5 групп до слеша
if (! ((parts_slash[1] ~ /^[A][F][0-9]{4,5}[\-][0-9]{3,4}[\-][0-9]{5}[A-Z]{0,2}$/) || (parts_slash[1] ~ /^[A][F][0-9]{4,5}[\-][0-9]{3,4}[\-][0-9]{5}[\-][0-9]{4}[A-Z]{0,2}$/) || (parts_slash[1] ~ /^[A][F][0-9]{4,5}[\-][0-9]{3,4}[\-][0-9]{5}[\-][0-9]{4}[\-][0-9]{4}[A-Z]{0,2}$/) ))  {
  print mt "Err. 0031 - WRONG INPUT FORMAT FOR FILTER NAME: [" parts_slash[1] "]/" parts_slash[2] >> TMP_DIR "/" UUID ".errlog.txt"
  error_code = 1
}

# проверка формата для ATEX / KAT групп после слеша
agroup = ""
kgroup = ""

no_of_groups = split(parts_slash[2], arr, " ")
if (no_of_groups > 2) {

    for (i=2; i<no_of_groups; i++) {
        if (! ( arr[i] ~ /^[A][1][3-5]$/ || arr[i] == "A23" || arr[i] ~ /^[K][I]{1,3}$/ || arr[i] ~ /^[K][I][V]$/ || arr[i] == "K0")) {
          print mt "Err. 0032 – WRONG INPUT FORMAT IN THE END OF FILTER NAME: [" arr[i] "]" >> TMP_DIR "/" UUID ".errlog.txt"
          error_code = 1
        }
    }

    # определяем кто есть АТЕКС и кто есть КАТ
    for (i=2; i<no_of_groups; i++) {
       if (arr[i] ~ /^[A][1][3-5]$/ || arr[i] == "A23")
           agroup = arr[i]
       if (arr[i] ~ /^[K][I]{1,3}$/  || arr[i] ~ /^[K][I][V]$/  || arr[i] == "K0")
           kgroup = arr[i]
   }

   if (no_of_groups == 4 && arr[2] == arr[3]) {
      print mt "Err. 0033 – AVOID DUPLICATION - TWO IDENTICAL GROUPS IN THE END OF FILTER NAME: [" arr[2] "]" >> TMP_DIR "/" UUID ".errlog.txt"
      error_code = 1
   }
}

# проверка формата фильтроэлемента
# формат элемента – это последняя гр. после пробела. 
# В середине «-«. Перед минусом 6-8 знаков, после минуса 3 зн. И возможно SP.

split(filter_name,parts," ")
#gsub(/[a-zA-Z]/,"",element)
#gsub(/[[:space:]]+/, " ")

element = parts[length(parts)]
if (element !~ /^[A][F][0-9]{4,6}[\-][0-9]{3}$/ && element !~ /^[A][F][0-9]{4}[\-][0-9]{3}[S][P]$/) {
  print mt "Err. 0034 - WRONG INPUT FORMAT OF THE FILTER ELEMENT [" element "]"  >> TMP_DIR "/" UUID ".errlog.txt"
  error_code = 1
}

################################################
# 4. проверка наличия серии фильтра в строке
################################################
p1 = substr(parts_slash[1],1,5)
split(parts_slash[2],arr_end," ")
filter_series = p1 "_" arr_end[1]
filter_series1 = p1 "/" arr_end[1]

x1="AF713_H2,AF711_G1,AF713_G1,AF713_GX1,AF713_GX2,AF724_G4,AF736_G3,AF936_G3,"
x2="AF112_G2,AF113_G3,AF122_G1,AF132_G2,AF133_G3,AF172_G2,AF173_G3,AF424_S1_AF424_SH1,"
x3="AF713_S1,AF724_S1,AF736_S1,AF737_S1,AF738_S1,AF746_S1,AF747_S1,AF748_S1,AF749_S1,"
x4="AF713_SH1,AF724_SH1,AF736_SH1,AF737_SH1,AF738_SH1,AF746_SH1,AF747_SH1,"
x5="AF748_SH1,AF749_SH1,AF736_SG1,AF737_SG1,AF738_SG1"
fg_series = x1 x2 x3 x4 x5

if (fg_series !~ filter_series) {
  print mt "Err. 0041 - FILTER SERIES [" filter_series1 "] IS NOT FOUND in THE DB"  >> TMP_DIR "/" UUID ".errlog.txt"
  error_code = 1
}

################################################
# 5. если RSF то в первой гр. всегда 7 знаков. Иначе 6.
################################################
split(parts_slash[1],arr_groups,"-")

rsf="AF112_G2,AF113_G3,AF122_G1,AF132_G2,AF133_G3,AF172_G2,AF173_G3,"
if ((rsf ~ filter_series) && (length(arr_groups[1]) !=7)) {
  print mt "Err. 0051 - RSF FILTER SERIES CODE [" arr_groups[1] "-] IS WRONG"  >> TMP_DIR "/" UUID ".errlog.txt"
  error_code = 1
}

if ((rsf !~ filter_series) && (length(arr_groups[1]) !=6)) {
  print mt "Err. 0052 - KSP FILTER SERIES [" arr_groups[1] "-] IS WRONG"  >> TMP_DIR "/" UUID ".errlog.txt"
  error_code = 1
}

################################################
# 6. если «300x» то обязательно «-0…» во второй группе
################################################
# проверка формата для Endnummer / Einsatz -300x до слеша

einsatzgroup = ""
endnrgroup = ""
no_of_groups_first = split(parts_slash[1], arr0, "-")

# убираем farbton
gsub(/[a-zA-Z]/,"",arr0[4])  
gsub(/[a-zA-Z]/,"",arr0[5])

if (no_of_groups_first > 3) {
    if (arr0[4] ~ /^[3][0][0]/) {
      einsatzgroup = arr0[4]
      endnrgroup = arr0[5]
    } else {
      endnrgroup = arr0[4]
      einsatzgroup = arr0[5]
    }
}

if (einsatzgroup != "" && endnrgroup != "") {

   if (einsatzgroup !~ /^[3][0][0]/ && endnrgroup !~ /^[3][0][0]/) {
      print mt "Err. 0061 – ONE OF THESE GROUPS MUST BE END NUMBER -300x: [-" einsatzgroup "], [-" endnrgroup "]" >> TMP_DIR "/" UUID ".errlog.txt"
      error_code = 1
   }

   if (einsatzgroup ~ /^[3][0][0]/ && endnrgroup ~ /^[3][0][0]/) {
      print mt "Err. 0062 – BOTH OF THESE GROUPS CAN NOT BE -300x: [-" einsatzgroup "], [-" endnrgroup "]" >> TMP_DIR "/" UUID ".errlog.txt"
      error_code = 1
   }

   if (einsatzgroup == endnrgroup) {
      print mt "Err. 0063 – BOTH OF THESE GROUPS CAN NOT BE SAME: [-" einsatzgroup "], [-" endnrgroup "]" >> TMP_DIR "/" UUID ".errlog.txt"
      error_code = 1
   }

}

if ( einsatzgroup ~ /^[3][0][0][1-2]$/ || endnrgroup ~ /^[3][0][0][1-2]$/) {
   if (substr(arr_groups[2],1,1) != 0) {
     part1_gr2 = substr(arr_groups[2],1,length(arr_groups[2])-2)
     part2_gr2 = substr(arr_groups[2],length(arr_groups[2])-1,2)
     print mt "Err. 0064 - KPL.EINSATZ! PORT SIZE IN THE SECOND GROUP MUST BE -[0]" part2_gr2 "- INSTEAD of -[" part1_gr2 "]" part2_gr2 "- "  >> TMP_DIR "/" UUID ".errlog.txt"
     error_code = 1
  }

  if (arr_groups[3] != "00000") {
    # возможно кроме некоторых RSF фильтров
    print mt "Err. 0065 - KPL.EINSATZ! THIRD GROUP MUST CONTAIN ZERO NUMBERS ONLY -[00000]- INSTEAD OF [-" arr_groups[3] "-]"  >> TMP_DIR "/" UUID ".errlog.txt"
    error_code = 1
  }

}


################################################
# 7 Подходит ли элемент к серии фильтра
################################################
arr[1] = "AF711_G1__AF7011,AF7031,AF7071,AF7081"
arr[2] = "AF713_H2,AF713_G1,AF713_GX1,AF713_GX2,AF713_S1,AF713_SH1__AF7013,AF7033,AF7073,AF7083,AF50133"
arr[3] = "AF724_G4,AF724_S1,AF724_SH1,AF424_S1,AF424_SH1__AF6014,AF6034,AF6064,AF6074,AF6084,AF50134"
arr[4] = "AF736_G3,AF936_G3,AF736_S1,AF736_SH1,AF736_SG1,AF737_S1,AF737_SH1,AF737_SG1,AF738_S1,AF738_SH1,AF738_SG1,AF746_S1,AF746_SH1,AF747_S1,AF747_SH1,AF748_S1,AF748_SH1,AF749_S1,AF749_SH1__AF6016,AF6036,AF6066,AF6076,AF6086,AF6006,AF50136,AF50126"
arr[5] = "AF122_G1__AF120174,AF125214"
arr[6] = "AF112_G2,AF172_G2__AF100174,AF100204"
arr[7] = "AF132_G2__AF170174,AF170204"
arr[8] = "AF113_G3,AF173_G3__AF100176,AF100206,AF100216,AF105176,AF105206,AF105216"
arr[9] = "AF133_G3__AF170176,AF170206,AF170216"

split(element,parts_e,"-")
element_code = parts_e[1]        # AF6016
gsub(/[a-zA-Z]/,"",parts_e[2])   # было например "010SP"
element_end  = parts_e[2]        # стало "010"

found = 0
for (i=1; i<=8; i++) {
  if (arr[i] ~ filter_series && arr[i] ~ element_code){
    found = 1
    i = 20
  }
}

if (found == 0) {
    print mt "Err. 0071 - FILTER ELEMENT SERIES [" element_code "-] DOES NOT FIT FILTER SERIES [" filter_series1 "]"  >> TMP_DIR "/" UUID ".errlog.txt"
    error_code = 1
}

################################################
# 8. проверка тонкости фильтрации
################################################
if (rsf ~ filter_series){
  if ("001,002,003,004,006,008,010,013" !~ element_end){
    print mt "Err. 0081 - CHECK FILTER ELEMENT FINENESS " element_code "-[" element_end "]"  >> TMP_DIR "/" UUID ".errlog.txt"
    error_code = 1
  }
} else {
  if ("003,004,005,006,008,010,013,016,020,025,030,036,050,070,100,200,300,400,500" !~ element_end){
    print mt "Err. 0081 - CHECK FINENESS OF FILTER ELEMENT: " element_code "-[" element_end "]"  >> TMP_DIR "/" UUID ".errlog.txt"
    error_code = 1
  }
}

################################################
# 9. Проверка мотора
################################################
split(filter_name,parts,"-")
split(parts[1],arr1,"")
motor_no = arr1[length(arr1)]

if (motor_no == "0") {
   # no ENDNUMMER
   if (einsatzgroup == "" && endnrgroup == "") {
      print mt "Err. 0091 - IF THE MOTOR = 0, YOU MUST HAVE A GROUP WITH ENDNUMBER " >> TMP_DIR "/" UUID ".errlog.txt"
      error_code = 1
   }

   if (einsatzgroup != "3001" && endnrgroup == "") {
      print mt "Err. 0092 - MOTOR = 0, NOT KOMPLETTEINSATZ -3001, NO ENDNUMBER " >> TMP_DIR "/" UUID ".errlog.txt"
      error_code = 1
   }
} else {

   # MOTOR = 3 // присутствует A13, A14, A23
   if (motor_no == "3" && (agroup ~ /^[A][1][3-5]$/ || arr[i] == "A23"))  {
      print mt "Err. 0093 - MOTOR = [3], BUT ATEX [" agroup "] IN THE END " >> TMP_DIR "/" UUID ".errlog.txt"
      error_code = 1
   }

   if (agroup == "A15" && motor_no != "7") {
      print mt "Err. 0094 - ONLY MOTOR = 7 IS SUITABLE FOR ATEX [" agroup "]" >> TMP_DIR "/" UUID ".errlog.txt"
      error_code = 1
   }

   if (einsatzgroup == "3001" || endnrgroup == "3001") {
      print mt "Err. 0095 - MOTOR != 0, BUT COMPLETE FILTER INSERT -3001 (WITHOUT MOTOR) " >> TMP_DIR "/" UUID ".errlog.txt"
      error_code = 1
   }


}

################################################
# 10. Проверка ATEX манометров 
################################################
split(filter_name,arr_fn_minus,"-")
dp = substr(arr_fn_minus[3], 1, 1) # цифр DP Manometer/Switch

if (dp != 0) {
   if (motor_no == 4 || agroup != "") {
      if ("1,2,3,6,7,8" ~ dp) {
         print mt "Err. 0095 - DP SWITCH [-" dp "....] IS NOT SUITABLE FOR ATEX FILTER" >> TMP_DIR "/" UUID ".errlog.txt"
         error_code = 1
      }
   }
}

print error_code

}

