BEGIN {
  RS = "\n"
  FS = "_!_"

# заходит эта строка
#string_return = "FTYPE::" str_ftype_new "_!_DSZ::" durchsatz_calc 
# "_!_FS::" fineness "_!_VS::" viscosity "_!_MAT::" material "_!_DSZO::" durchsatz  "_!_COMM::" comments


# коды ошибок - НЕ ЗАБЫТЬ ПРОВЕРКУ И ВЫВЕСТИ ИХ 
str_err[1] = "ERR. 0001 - Filter type string is empty, no suitable RSF found"
str_err[2] = "ERR. 0002 - Durchsatz string is empty"
str_err[3] = "ERR. 0003 - Fineness string is empty"
str_err[4] = "ERR. 0004 - Viscosity string is empty"

# подготовка переменных вязкость расход тонкость тип фильтров
# SUITABLE FILTER TYPES / отфильтрованные - разбиваем вх строку на части
split(mystring,arr_mystring,"_!_")
str_ftype = arr_mystring[1]
split(str_ftype, arr_tmp, "::")
str_part2 = arr_tmp[2]
if (str_part2 == "")
   print str_err[1] >> result_txt
split(str_part2, arr_ftypes, ",")
#print "<BR>TEST geeignete ftypen :" str_part2  >> result_txt

split(arr_mystring[2], arr_tmp, "::")
durchsatz_c = arr_tmp[2]
#print "<BR>TEST calc flow rate :" durchsatz_c  >> result_txt

split(arr_mystring[3], arr_tmp, "::")
fineness_input = arr_tmp[2]
#print "<BR>TEST input finenes :" fineness_input  >> result_txt

split(arr_mystring[4], arr_tmp, "::")
viscosity = arr_tmp[2]
#print "<BR>TEST viscosity :" viscosity  >> result_txt

# в финальной версии можно или из предыдущего скрипта в строке передать или из <page-1.txt>
mat[1] = "1. Gehäuse und Deckel: GGG40 oder C-Stahl / Innenteile C-Stahl"
mat[2] = "2. Gehäuse und Deckel: Edelstahl / Innenteile Edelstahl"
mat[3] = "3. Gehäuse und Deckel: GGG40 oder C-Stahl / Innenteile Edelstahl"

split(arr_mystring[5], arr_tmp, "::")
material = arr_tmp[2]

split(arr_mystring[6], arr_tmp, "::")
durchsatz = arr_tmp[2]

split(arr_mystring[7], arr_tmp, "::")
comments = arr_tmp[2]


dtoleranz = 1.0      # DURCHSATZ_TOLERANZ_!_1.05_!_# 5%
j = 1  # counter for new arr_fbez[] = "AF122_G1", "AF133_G3", etc.
m = 1  # counter for new  arr_elem_durchsatz[m] = "E255!!10-30;20-50;30-80;40-100;60-120;80-140;100-150;200-200", etc.
arr_fbez[1] = ""




} # END OF BEGIN



# ТЕЛО
{
  if ($1 == "DURCHSATZ_TOLERANZ")
     dtoleranz = $2 # на сколько % можем превысить расход в нашей КСС табл


  # наполняем массив обозначений фильтров arr_fbez[] = "AF122_G1", "AF133_G3", etc.
  for (i=1; i<=length(arr_ftypes); i++) {
     if ($1 == "FTYPE" && $2 == arr_ftypes[i]) {
        split($3, arr_field3, ",")
        for (k=1; k<=length(arr_field3); k++) {
            arr_fbez[j] = arr_field3[k]
            j++
        }
     }
  }


  # наполняем массив для передачи в след скрипт "E255;AF122_G1;10-30;20-50;30-80;40-100;60-120;80-140;100-150;200-200"
  if (length(arr_fbez) > 0) {
     for (n=1; n<=length(arr_fbez); n++) {
        if ($1 == "DSZM_01" && $3 ~ arr_fbez[n]) {
           arr_main[m] = $2 "!!" arr_fbez[n] "!!" $4
           m++
        }
     }
  }

}


END {


if (comments == "ON") {
  print "<p class=\"fw-bold\">---------  page-31.awk  ----------</p>mystring [from page-3.awk]: "mystring  >> result_txt
  print "<BR> Filter series to process: "  >> result_txt
  for (i=1; i<=length(arr_fbez); i++)
     print "["arr_fbez[i] "];" >> result_txt
}


  str_to_return = ""
  for (i=1; i<=length(arr_main); i++) {
     if (comments == "ON")
        print "<BR>" i " -- " arr_main[i] >> result_txt
     if (str_to_return == "")
       str_to_return = arr_main[i]
     else 
       str_to_return = str_to_return "_!_" arr_main[i]
  }


# финальная проверка расходов во всех выбранных фильтрах
k = 1 # counter для финального массива arr_final[k] = fe_code "!!" af_bez "!!" fineness_tmp

for (i=1; i<=length(arr_main); i++) {
   max_durchsatz = 0 # это величина подходящего диапазона 

   split(arr_main[i], arr_main_rec, "!!" ) # делим строку "E259!!AF133_G3!!30-200;40-250;60-300;80-350;100-400"
   fe_code = arr_main_rec[1]
   af_bez  = arr_main_rec[2]
   str_durchsatz = arr_main_rec[3]
   split(str_durchsatz, arr_tmpnew, ";")
   split(arr_tmpnew[length(arr_tmpnew)], arr_tmp_end, "-")  # максимальные значения "100-400"
   max_durchsatz_element = arr_tmp_end[2]

   dt = durchsatz_c * dtoleranz
   if (dt > max_durchsatz_element) {      # наш расход за пределами диапазона строки
      print "<BR>Filter series ["af_bez "] with ["fe_code"] is too small for " durchsatz_c "/["durchsatz"] LPM, skip to next one" >> result_txt
      continue
   }

   # проходим по всей строке "30-200;40-250;60-300;80-350;100-400" и ищем куда попадает наш расход
   for (j=1; j<=length(arr_tmpnew); j++) {
      split(arr_tmpnew[j], arr_diapazon, "-")
      if (dt <= arr_diapazon[2]) {   # если наш расчетный расход попадает в мелкий диапазон
        # здесь нужно создать новый массив
        arr_final[k] = fe_code "!!" af_bez "!!" arr_diapazon[1]
        k++
        break
      }
   }
}


if (length(arr_final) == 0) {
   print "<H5>no suitable filters found</H5>" >> result_txt
   exit
   # дописать обработчик выхода
}

if (comments == "ON")
   print "<BR>Filter series, which are suitable in arr_final[]:" >> result_txt

return_string = "MAT::" material "_!_"
for (i=1; i<=length(arr_final); i++) {
   if (comments == "ON")
      print "<BR>["i"]: " arr_final[i] " // " >> result_txt
   return_string =  return_string  arr_final[i] ";;"
}

# каким то образом в начало попал спецсимвол убираем всё кроме букв цифр, "!", ";", ":"
gsub(/[^a-zA-Z0-9!;:_]/, "", return_string)

# убираем ";;" в хвосте
return_string = substr(return_string,1,length(return_string)-2) "CCC-" comments

if (comments == "ON")
  print "Return-string: " return_string >> result_txt

print return_string


}



