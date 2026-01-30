BEGIN {
  RS = "\n"
  FS = "_!_"

# заходит эта строка
# mystring = "MAT::1_!_E256!!AF112_G2!!80;;E256!!AF172_G2!!80;;E257!!AF132_..."

print "<p class=\"fw-bold\">------------  page-32.awk  ---------</p><b> mystring [from page-31.awk]: </b>"mystring  >> result_txt

split(mystring, arr_mystring, "_!_")
split(arr_mystring[1], arr_mat, "::")
material = arr_mat[2]
split(arr_mystring[2], arr_ftype_el_ff, ";;")


# counter для нового массива с элементами // arr_elements[] = "E255;AF120174;783;10,20,30,40,60"
# $1=el.code $2=el.bez. $3=price $4=fineness
counter_arr_elements = 1

# counter для нового массива с базовой конф
# arr_base_conf[] = "AF122_G1;1;AF12243-2121-00000/G1;AF120174;E255;2085"
# $1=f.short $2=material $3=base.conf $4=El.bez $5=El.code $6=price
# позже в конец дописать опции по каждой позиции ";" $7=pos.1 (3,7), usw
counter_arr_base_conf = 1


print "<b><span class=\"text-danger\">arr_ftype_el_ff[]</span> - Suitable filter series for processing - (came from previous script, converted from STR to ARR):</b>" >> result_txt

for (i=1; i<=length(arr_ftype_el_ff); i++)
   print "["i"]: " arr_ftype_el_ff[i] " µm // material code - " material "<BR>" >> result_txt

# INITIALIZATION
arr_elements[1] = ""
arr_base_conf[1] = ""

counter_forms_headers = 1
arr_forms_headers[1] = ""

str_pos1_variants = ""
#arr_pos1_variants[1] = arr_pos2_variants[1] = arr_pos3_variants[1] = arr_pos4_variants[1] = ""
#arr_pos5_variants[1] = arr_pos6_variants[1] = arr_pos7_variants[1] = arr_pos8_variants[1] = ""

   print "<BR> ----------------------- заходим в тело ----------------" >> result_txt


} # END OF BEGIN



# ТЕЛО

{

#  заполнение массива заголовков для вывода финальных форм
if ($1 == "PHEADER") {
   arr_form_headers[counter_forms_headers] = $2 ";" $3
   counter_forms_headers++
}


for (i=1; i<= length(arr_ftype_el_ff); i++) { #
   gsub(/!!/, ";", arr_ftype_el_ff[i])
   split(arr_ftype_el_ff[i], arr_main_tmp, ";") # делим эту строку "E256!!AF172_G2!!80" на 3 части
   el_code = arr_main_tmp[1]
   f_code = arr_main_tmp[2]
   fineness = arr_main_tmp[3]

   if ($1 == "EBCPF" && substr($3,1,4) == el_code) {
      # наполняем новый массив элементами
      found1 = 0
      for (k=1; k<=length(arr_elements); k++) {  # E257;AF170174;783;10,20,30,40,60,80,100 
          split(arr_elements[k], arr_k, ";")
          if (arr_k[2] == $2)
             found1 = 1
      }

      if (found1 == 0) {
        arr_elements[counter_arr_elements] = el_code ";" $2 ";" $4 ";" $5
        counter_arr_elements++
      }
   }


   if ($1 == "BASECONF" && $2 == f_code && $3 == material && $6 == el_code) {

      found2 = 0
      for (k=1; k<=length(arr_base_conf); k++) {  # AF132_G2;1;AF13243-221-03000/G2;AF170174;E257;3619
          split(arr_base_conf[k], arr_k, ";")
          if (arr_k[1] == $2 && arr_k[2] == $3 && arr_k[5] == $6)
             found2 = 1
      }

      # наполняем новый массив
      if (found2 == 0) {
         arr_base_conf[counter_arr_base_conf] = f_code ";" $3 ";" $4 ";" $5 ";" $6 ";" $7
         counter_arr_base_conf++
      }
   }

   if ($1 == "POSSCONF" && $2 == f_code) {
      # дополняем существующий массив
      # приведение к однородному виду
      # из E256!!AF172_G2!!10;3;2;2;1;0,1,2,4;3;0,2;0,2
      # в  E256;AF172_G2;10;3;2;2;1;0,1,2,4;3;0,2;0,2
#      gsub(/!!/, ";", arr_ftype_el_ff[i])
      arr_ftype_el_ff[i] = arr_ftype_el_ff[i] ";" $3 ";" $4 ";" $5 ";" $6 ";" $7 ";" $8 ";" $9 ";" $10
   }

   # заполнение массивов позиций (мотор индикатор и проч)
   if ($1 == "CPOS_1" && ($2 == "*" || $2 ~ f_code) && ($4 == "*" || $4 == material)) {
#      print "<BR> f-code Pos 1 (Antrieb): " $0   >> result_txt
      if (str_pos1_variants == "")
         str_pos1_variants = f_code ";" material ";" $3 ";" $5 ";" $6
      str_pos1_variants = str_pos1_variants "!!" f_code ";" material ";" $3 ";" $5 ";" $6
   }

   if ($1 == "CPOS_2" && ($2 == "*" || $2 ~ f_code) && ($4 == "*" || $4 ~ material)) {
#      print "<BR> Pos. 2 (port size): " $0   >> result_txt
#      print "<BR> Pos. 2: " f_code " // " material " // " arr_ftype_el_ff[i]   >> result_txt
      if (str_pos2_variants == "")
         str_pos2_variants = f_code ";" material ";" $3 ";" $5 ";" $6
      str_pos2_variants = str_pos2_variants "!!" f_code ";" material ";" $3 ";" $5 ";" $6
   }

   if ($1 == "CPOS_3" && ($2 == "*" || $2 ~ f_code) && ($4 == "*" || $4 ~ material)) {
      if (str_pos3_variants == "")
         str_pos3_variants = f_code ";" material ";" $3 ";" $5 ";" $6
      str_pos3_variants = str_pos3_variants "!!" f_code ";" material ";" $3 ";" $5 ";" $6
   }

   if ($1 == "CPOS_4" && ($2 == "*" || $2 ~ f_code) && ($4 == "*" || $4 ~ material)) {
      if (str_pos4_variants == "")
         str_pos4_variants = f_code ";" material ";" $3 ";" $5 ";" $6
      str_pos4_variants = str_pos4_variants "!!" f_code ";" material ";" $3 ";" $5 ";" $6
      # в нашей строке $3=value $5=text $6=price / Mat-Nr 
   }

   if ($1 == "CPOS_5" && ($2 == "*" || $2 ~ f_code) && ($4 == "*" || $4 ~ material)) {
      if (str_pos5_variants == "")
         str_pos5_variants = f_code ";" material ";" $3 ";" $5 ";" $6
      str_pos5_variants = str_pos5_variants "!!" f_code ";" material ";" $3 ";" $5 ";" $6
   }

   if ($1 == "CPOS_6" && ($2 == "*" || $2 ~ f_code) && ($4 == "*" || $4 ~ material)) {
      if (str_pos6_variants == "")
         str_pos6_variants = f_code ";" material ";" $3 ";" $5 ";" $6
      str_pos6_variants = str_pos6_variants "!!" f_code ";" material ";" $3 ";" $5 ";" $6
   }


   if ($1 == "CPOS_7" && ($2 == "*" || $2 ~ f_code) && ($4 == "*" || $4 ~ material)) {
      if (str_pos7_variants == "")
         str_pos7_variants = f_code ";" material ";" $3 ";" $5 ";" $6
      str_pos7_variants = str_pos7_variants "!!" f_code ";" material ";" $3 ";" $5 ";" $6
   }

   # ^.{8}$ - проверка кол-ва знаков в строке = 8 знаков
   if ($1 ~ /^[D][U][M][M][0-9]{4}|^[0-9]{8}/ && $1 ~ /^.{8}$/) {
     arr_single_prices[$1] = $3
   }

}


}


END {


print "<BR><b><span class=\"text-danger\">arr_elements[]</span> - Suitable filter elements, general code extended to specific elements:</b>" >> result_txt
for (i=1; i<=length(arr_elements) ; i++)
   print "["i"]: " arr_elements[i] "<BR>" >> result_txt

#print "<BR><b>Filter base/default configuration, read from TXT in arr_base_conf[], $last = List price:</b>" >> result_txt
#for (i=1; i<=length(arr_base_conf) ; i++)
#   print "<BR>["i"]: " arr_base_conf[i] " EUR St/Brt" >> result_txt

########## здесь просто сортировка и добавление тонкости фильтрации ##########
# пузырьковая сортировка arr_base_conf[] по возрастанию цены.
delete arr_tmp
length_arr_base_conf = length(arr_base_conf)
for (i=1; i<=length_arr_base_conf; i++) {
   found = 0
   # Последние i элементов уже отсортированы
   for (j=1; j<=(length_arr_base_conf-i); j++) {
      split(arr_base_conf[j], arr_tmp1, ";")
      split(arr_base_conf[j+1], arr_tmp2, ";")
      # Сравниваем соседние элементы
      if (arr_tmp1[6] > arr_tmp2[6]) {
          tmp = arr_base_conf[j]
          arr_base_conf[j] = arr_base_conf[j+1]
          arr_base_conf[j+1] = tmp
          found = 1
      }
   }
   if (found == 0)
      break
}
delete arr_tmp

# добавляем тонкость фильтрации в массив arr_base_conf[]
delete arr_tmp1; delete arr_tmp2
for (i=1; i<=length(arr_base_conf); i++) {
  split(arr_base_conf[i], arr_tmp1, ";")
  for (j=1; j<=length(arr_ftype_el_ff); j++) {
     split(arr_ftype_el_ff[j], arr_tmp2, ";")
     if (arr_tmp1[1] == arr_tmp2[2] && arr_tmp1[5] == arr_tmp2[1]) {
        arr_base_conf[i] = arr_base_conf[i] ";" arr_tmp2[3]
        break
     }
  }
}
delete arr_tmp1; delete arr_tmp2

print "<b><span class=\"text-danger\">arr_base_conf[]</span> - Filter base conf., read from TXT, SORTED, zus. with fineness:</b>" >> result_txt
for (i=1; i<=length(arr_base_conf); i++)
   print  arr_base_conf[i] "<BR>" >> result_txt

#print "<BR><b>Array with single prices (arr_single_prices): </b>" >> result_txt
#for (key in arr_single_prices) {
#   print "<BR>" key, ": ", arr_single_prices[key] " EUR" >> result_txt
#}

# вывод таблицы с ценами
print_table_with_prices()

########## КОНЕЦ  сортировка и добавление тонкости фильтрации ##########


print "<BR><b><span class=\"text-danger\">arr_ftype_el_ff[]</span> - Feasible Filter Series Configurations:</b> $1 = Antrieb, ... $last = RSVentil" >> result_txt
for (i=1; i<=length(arr_ftype_el_ff) ; i++)
   print "<BR>["i"]: " arr_ftype_el_ff[i] >> result_txt

#print "<BR><b>Position Headers in arr_form_headers[i]:</b>" >> result_txt
#for (i=1; i<=length(arr_form_headers); i++)
#   print "<BR>["i"]: " arr_form_headers[i] >> result_txt


# собираем данные по отдельным позициям для каждой подходящей серии фильтра

# arr_pos1_variants // Antrieb
# AF112_G2;1;3;Standard Getriebemotor 230/400V 50Hz;0
# AF172_G2;1;3;Standard Getriebemotor 230/400V 50Hz;0
# AF132_G2;1;3;Standard Getriebemotor 230/400V 50Hz;0
str_pos1_variants = remove_duplicates_from_str_pos_variants(str_pos1_variants)
#split(str_pos1_variants, arr_pos1_variants, "!!")
#print "<BR><b>arr_pos1_variants // Antrieb</b> " >> result_txt
#for (i=1; i<=length(arr_pos1_variants); i++)
#   print "<BR> " arr_pos1_variants[i] >> result_txt

str_pos2_variants = remove_duplicates_from_str_pos_variants(str_pos2_variants)
str_pos3_variants = remove_duplicates_from_str_pos_variants(str_pos3_variants)
str_pos4_variants = remove_duplicates_from_str_pos_variants(str_pos4_variants)
str_pos5_variants = remove_duplicates_from_str_pos_variants(str_pos5_variants)
str_pos6_variants = remove_duplicates_from_str_pos_variants(str_pos6_variants)

str_pos7_variants = remove_duplicates_from_str_pos_variants(str_pos7_variants)
#split(str_pos7_variants, arr_pos7_variants, "!!")
#print "<BR><b>arr_pos7_variants // RS Ventil</b> " >> result_txt
#for (i=1; i<=length(arr_pos7_variants); i++)
#   print "<BR> " arr_pos7_variants[i] >> result_txt


# объединяем длинные строки полученные выше в массив строк
arr_str_pos_variants[1] = str_pos1_variants
arr_str_pos_variants[2] = str_pos2_variants
arr_str_pos_variants[3] = str_pos3_variants
arr_str_pos_variants[4] = str_pos4_variants
arr_str_pos_variants[5] = str_pos5_variants
arr_str_pos_variants[6] = str_pos6_variants
arr_str_pos_variants[7] = str_pos7_variants
# и так далее по всем 8 позициям


# print final forms
print "<BR><b>print final forms - arr_base_conf[i] ПОВТОР ВЕРХНЕГО</b>" >> result_txt

# проходим в цикле по всем отобранным базовым конфигурациям
for (i=1; i<=length(arr_base_conf); i++) {  # AF132_G2;1;AF13243-221-03000/G2;AF170174;E257;3619 
   print "<hr>" >> result_txt

   print "<BR>["i"]:" arr_base_conf[i] >> result_txt
   split(arr_base_conf[i], arr_base_tmp, ";")
   f_type = arr_base_tmp[1]
   f_matr = arr_base_tmp[2]
   f_base = arr_base_tmp[3]
   fe_bez = arr_base_tmp[4]
   fe_code = arr_base_tmp[5]
   f_price_base = arr_base_tmp[6]
   f_feinheit = arr_base_tmp[7]
   f_base_hidden = f_base ";" fe_bez ";" f_feinheit ";" f_price_base

   # initialization
   counter_arr_ftype_el_ff = 0

   # здесь нужны уже массивы по всем позициям и по всем элементам
   for (k=1; k<=length(arr_ftype_el_ff); k++) {  # E256;AF172_G2;10;3;2;2;1;0,1,2,4;3;0,2;0,2

      # находим номер нашего счетчика / номера нашего члена массива
      # проверяем, равен ли второй член нашему типу фильтра
      # # mystring = "E256;AF172_G2;10;3;2;2;1;0,1,2,4;3;0,2;0,2"
      if (find_mycounter(arr_ftype_el_ff[k],f_type, pos=2)) {
         counter_arr_ftype_el_ff = k
         break
      }
   }

   if (counter_arr_ftype_el_ff == 0) 
      print "<BR>String with feasible positions for " arr_base_conf[i] " N OT FOUND in arr_ftype_el_ff[]" >> result_txt

   dcounter = 3 # это разница между каунтерами pos_headers и arr_tmp[].
   # arr_ftype_el_ff[i] = E255;AF122_G1;30;3,7;21;2;1;0,1,2,4,B;0,1;0,2;0,2
   split(arr_ftype_el_ff[counter_arr_ftype_el_ff], arr_tmp, ";")
   # arr_tmp[4] это строка pos.1 = "3,7"
   # arr_tmp[5] это строка pos.2 = "13,14,15,18"
   # arr_tmp[6] это строка pos.3 = "2" // PN16
   # arr_tmp[7] это строка pos.4 = "1" // Material - ПРОПУСКАЕМ !!!!!
   arr_tmp[7] = arr_tmp[8]
   arr_tmp[8] = arr_tmp[9]
   arr_tmp[9] = arr_tmp[10]
   arr_tmp[10] = arr_tmp[11]

   # arr_tmp[7] это строка pos.5 = "1,2,4" // dP MEssung



#   print "<BR><b>Base configuration: " f_base " with " fe_bez " [LP ca. " f_price_base ",- EUR]</b>" >> result_txt

   print "<BR><b id=\"change_config" i "\">Base configuration: " f_base " with " fe_bez " [LP ca. " f_price_base ",- EUR]</b>" >> result_txt

   print "<form action=\"/rsf-auslegung-fin\" method=\"post\">"  >> result_txt

   # пока делаем для первых 4 позиций, m-3=1 это номер первой позиции, а в строке
   # arr_ftype_el_ff[i] = E255;AF122_G1;30;3,7;21;2;1;0,1,2,4,B;0,1;0,2;0,2  это поз m=4

   for (m=4; m<=10; m++) {

     # arr_form_headers[m-dcounter] = "1;Antrieb" // 1 - номер позиции, затем название позиции
     split(arr_form_headers[m-dcounter], arr_fh_tmp, ";") # разделили на "1" и "Antrieb"

     print "   <div class=\"row align-items-center\">" >> result_txt
     print "   <label for=\"pos" arr_fh_tmp[1] "\" class=\"row mb-2 col-sm-2 col-form-label\">" arr_fh_tmp[2] ":</label>" >> result_txt
     print "     <div class=\"col-auto\">"  >> result_txt

#     print "<BR> diapazon values: " arr_tmp[m] >> result_txt

     split(arr_tmp[m], arr_pos_values, ",")   # поделили мотор например на "3" и "7"
#     print "   <div class=\"row mb-3\">" >> result_txt

     # заголовок опции например "ANTRIEB"
     print "        <select class=\"form-select\" id=\"pos" arr_fh_tmp[1] "\" name=\"pos" arr_fh_tmp[1] "\">" >> result_txt


     ######## это вывод дропдауна только для одной позиции - например мотор ############
     # arr_pos_values - это перечисление вариантов данной позиции, например для мотора "3,7"
     for (j=1; j<=length(arr_pos_values); j++) {

        if (m-dcounter <=7) {  # ANTRIEB / TEST
           # arr_pos1_variants
           # AF113_G3;1;3;Standard Getriebemotor 230/400V 50Hz;0
           # AF173_G3;1;3;Standard Getriebemotor 230/400V 50Hz;0
           # AF122_G1;1;7;Standard pneum. Drehantrieb;0
           # AF112_G2;1;7;Standard pneum. Drehantrieb;0 
#           txt_option = find_txt_option(f_type, arr_str_pos_variants[m-dcounter], material, arr_pos_values[j])

        txt_option_tmp = find_txt_option(f_type, arr_str_pos_variants[m-dcounter], material, arr_pos_values[j])
        split(txt_option_tmp, arr_txt_option_tmp, ";")
        pos_price = arr_txt_option_tmp[2]

        txt_option = arr_txt_option_tmp[1] " /// Standardausführung ohne Mehrkosten"
        if (arr_txt_option_tmp[2] != 0)
           txt_option = arr_txt_option_tmp[1] " /// Mehrkosten: " pos_price ",- EUR"

        } else {
            txt_option = arr_pos_values[j]
        }
        option_value = arr_pos_values[j] ";" pos_price

        print "         <option value=\"" option_value "\">" txt_option "</option>" >> result_txt
     }
     print "       </select>" >> result_txt
     print "   </div>" >> result_txt
print "   </div>" >> result_txt
   }
   ######## конец вывода дропдауна только для одной позиции - например мотор ############



   print "   <input type=\"hidden\" name=\"f_base\" value=\""f_base_hidden"\">" >> result_txt
#   print "<button type=\"button\" class=\"btn btn-primary\">SEND</button>" >> result_txt
print "</ul><button type = \"Submit\" class=\"btn btn-primary btn-lg\"> SEND </button>"  >> result_txt


   print "</form>"                                 >> result_txt
}

} # END OF END-PART


# находим номер нашего счетчика / номера нашего члена массива
# проверяем, равен ли второй член нашему типу фильтра
# # mystring = "E256;AF172_G2;10;3;2;2;1;0,1,2,4;3;0,2;0,2"
function find_mycounter(mystring, f_type, pos_nr) {
  split(mystring, arr_tmp, ";")
  if (f_type == arr_tmp[pos_nr]) {
     return 1
  }
  return 0
}

# вытаскиваем из этой строки текст "AF122_G1;1;3;Standard Getriebemotor 230/400V 50Hz;0 "
# f_type = "AF112_G2"
# str_pos_variants_tmp = "AF112_G2;1;3;Standard Getriebemotor 230/400V 50Hz;0!!AF172_G2;1;3;Standard Getriebem.. usw"
# material = "1"
# pos_single_value = "3" для мотора
#
function find_txt_option(f_type, str_pos_variants_tmp, material, pos_single_value) {
#   print "<BR>values: " f_type "///" str_pos_variants_tmp "///" material "///" pos_single_value >> result_txt

   str_txt = "============= NOT FOUND =============="
   delete arr_func_tmp
   delete arr_func_tmp1
   split(str_pos_variants_tmp, arr_func_tmp, "!!")
   str_price = "Price not found"
   for (fi=1; fi<=length(arr_func_tmp); fi++) {
      split(arr_func_tmp[fi], arr_func_tmp1, ";")
      if (arr_func_tmp1[1] == f_type && arr_func_tmp1[2] == material && arr_func_tmp1[3] == pos_single_value) {
          str_txt = arr_func_tmp1[4]
          material_nr = arr_func_tmp1[5] # это Мат-Нр типа DUMM0005

          if (arr_func_tmp1[5] in arr_single_prices)
             str_price = arr_single_prices[arr_func_tmp1[5]]

#          print "<BR>arr_func_tmp[fi]: " arr_func_tmp[fi] >> result_txt
#          print "<BR>str_txt: " str_txt " /// material_nr: " material_nr " /// Mehrpreis: " str_price >> result_txt
          break

      }
   }
#   print "<BR>ВЫШЛИ ИЗ ЦИКЛА //// str_txt: " str_txt " /// material_nr: " material_nr " /// Mehrpreis: " str_price >> result_txt

   str_txt = str_txt ";" str_price
   return str_txt
}



# удаляем дубликаты
function remove_duplicates_from_str_pos_variants(mystr) {
  counter_new_arr = 1
  delete arr_tmp
  delete arr_new

  split(mystr, arr_tmp, "!!")

  arr_new[1] = arr_tmp[1]   # инициализируем первый член нового массива
  for (i=1; i<=length(arr_tmp); i++) {
     found = 0
     # проходим по новому массиву и ищем совпадения
     for (k=1; k<= length(arr_new); k++) {
        if (arr_new[k] == arr_tmp[i])
           found = 1
     }
     if (found == 0) {
        counter_new_arr++
        arr_new[counter_new_arr] = arr_tmp[i]
     }
     arr_tmp[i] = ""
  }

  # формируем новую строку
  for (k=1; k<= length(arr_new); k++) {
     if (k == 1)
       newstring = arr_new[k]
     else
       newstring = newstring "!!" arr_new[k]
  }
  return newstring
}



function print_table_with_prices() {
  delete arr_tmp
  print "<table class=\"table table-striped\">" >> result_txt
  print "<thead><tr><th scope=\"col\">Base configuration</th>"  >> result_txt
  print "<th scope=\"col\">LP, EUR St/Brt</th>" >> result_txt
  print "<th scope=\"col\">Zuzätzliche Info</th></tr></thead>"  >> result_txt
  print "<tbody>" >> result_txt

  for (i=1; i<=length(arr_base_conf); i++) {
    split(arr_base_conf[i], arr_tmp, ";")
    el_code = arr_tmp[4]
    if (arr_tmp[7] < 100)
       el_code = el_code "-00" arr_tmp[7]/10
    else
       el_code = el_code "-0" arr_tmp[7]/10
    # заменяем для линка косую черту на подстроку "%2F"
    tmp3 = arr_tmp[3]
    gsub(/\//, "%2F", tmp3)

    mylink = "https://salestext.ddns.net/?filter_name=" tmp3 "+" el_code
    mystr1 = i ". " arr_tmp[3] " mit " el_code
    mystr2 = arr_tmp[6] ",-"
    mystr3 = "[<a href=\""mylink"\">V-Text</a>]"" / [<a href=\"#change_config" i "\">change configuration</a>]"

    print "<tr><td>"mystr1"</td>" >> result_txt
    print "<td>"mystr2"</td>" >> result_txt
    print "<td>"mystr3"</td></tr>" >> result_txt
  }
  print "</tbody></table>" >> result_txt
  delete arr_tmp
}
