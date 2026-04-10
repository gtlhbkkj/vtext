BEGIN {
  RS = "\n"
  FS = "_!_"

# заходит эта строка
#mystring = medium:02,comments:ON,dpressure:1,antrieb:4,material:1,materialel:2,ksf:ON_!_str_myarr:9;AF6036-020;E114552102;2156;4:9;AF6066-050;E124612403;903;4:9;AF6076-016;E124612303;903;4 

   print "<div class=\"container content\">" >> result_txt

   delete arr_main; delete arr_tmp1; delete arr_tmp2; delete arr_tmp3; delete arr_tmp4; delete arr_suitable_elements;
   delete arr_main_elements; delete arr_form_headers; delete arr_single_prices
   split(mystring, arr_tmp1, "_::_")    # medium:02,comments:ON,dpressure:1,antrieb:4,material:1,materialel:2,ksf:ON,kategorie:ON
                                    # str_myarr:9;AF6036-010;E114552102;2156;4:6;AF6066-050;E124612403;903;4:9;AF6076-010;E124612303;903;4:9;AF6086-010;E124612203;903;4

   split(arr_tmp1[1], arr_tmp2, ",")   # "medium:02" "comments:ON" "dpressure:1" usw

   for (i=1; i<=length(arr_tmp2); i++) {
      split(arr_tmp2[i],arr_tmp3,":")
      arr_main[arr_tmp3[1]] = arr_tmp3[2]
   }

   medium = arr_main["medium"]
   comments = arr_main["comments"]
   dpressure = arr_main["dpressure"]
   antrieb = arr_main["antrieb"]
   material = arr_main["material"]
   materialel = arr_main["materialel"]
   ksf = arr_main["ksf"]
   atex = arr_main["atex"]
   kategorie = arr_main["kategorie"]

   delete arr_main; delete arr_tmp2; delete arr_tmp3; 

   # собираем arr_main
   # собираем arr_main
   for (i=2; i<=length(arr_tmp1); i++) {

      split(arr_tmp1[i], arr_tmp2, "_!!_")
      # arr_tmp2[2] = 1;AF6016;737;1;AF7364-321-00000/S1;9745_!_AF6036-010;2156=AF6066-050;903=AF6076-010;
      #               903=AF6086-010;903_!_2,3;3,4,5;1,2,3,4;1,2,3;0,9;0;0,1,2;0;0

      split(arr_tmp2[2], arr_3parts, "_!_")
      part_of_arr_main = arr_3parts[1]       # 1;AF6016;737;1;AF7364-321-00000/S1;9745
      part_of_arr_elem = arr_3parts[2]       # AF6036-010;2156=AF6066-050;903=AF6076-010;903=AF6086-010;903
      part_of_arr_poss_conf = arr_3parts[3]  # 2,3;3,4,5;1,2,3,4;1,2,3;0,9;0;0,1,2;0;0

      arr_main[arr_tmp2[1]] = part_of_arr_main
      arr_elem[arr_tmp2[1]] = part_of_arr_elem
      arr_poss_conf[arr_tmp2[1]] = part_of_arr_poss_conf
   }


   if (comments == "ON") {
      print "<i><b> -------- Begin &lt page-33-ksf.awk &gt --------- </b><BR>[mystring]: "mystring >> result_txt
      print "<BR>medium: " medium " /// comments: " comments " /// dpressure: " dpressure " /// antrieb: " antrieb " /// material: " material " /// materialel: " materialel " /// ksf: " ksf " /// kategorie: " kategorie " /// atex: " atex >> result_txt

      for (key in arr_main) {
         print "<p></p>arrays["key"]: " >> result_txt
         print "<BR>arr_main["key"]: " arr_main[key] >> result_txt
         print "<BR>arr_elem["key"]: " arr_elem[key] >> result_txt
         print "<BR>arr_poss_conf["key"]: " arr_poss_conf[key] >> result_txt
      }

      print "<BR>-------- Enter BODY --------- </i>" >> result_txt
   }

   delete arr_pos1_variants;
    field1_pos1 = "CPOS_1"  # ANTRIEB
    field1_pos4 = "CPOS_4"  # ANZEIGE
    field1_pos6 = "CPOS_6"  # ABLASS
    if (atex == "ON") {
        field1_pos1 = "CPOS_1_EX"
        field1_pos4 = "CPOS_4_EX"
        field1_pos6 = "CPOS_6_EX"
    }

}
# END OF BEGIN BLOCK

# ТЕЛО
{

   # если нет подходящих фильтров
     if (mystring == "") {
        print "<BR>No suitabe filters found. Exit" >> result_txt
        exit  # выход из тела
     }


   #  заполнение массива заголовков для вывода финальных форм
   if ($1 == "PHEADER")
      arr_form_headers[length(arr_form_headers)+1] = $2 ";" $3


   for (key in arr_poss_conf) {      # arr_poss_conf[AF748_S1]: 2,4;3,4,5,6,7,8;1,2,3,4;1,2,3;0,9;0;0,1,2;0;0
      f_code = key
      split(arr_poss_conf[key], arr_pos, ";")   # 2,4;  3,4,5,6,7,8;  1,2,3,4;  usw

      # POS_1_EX field1_pos1 = "CPOS_1_EX" или field1_pos1 = "CPOS_1"
      split(arr_pos[1], arr_pos1, ",")          # 2  4
      for (k=1; k<=length(arr_pos1); k++) {
         pos_value = arr_pos1[k]
         # заполнение массивов позиций (мотор индикатор и проч)
         if ($1 == field1_pos1 && ($2 == "*" || $2 ~ f_code) && $3 == pos_value && ($4 == "*" || $4 ~ material)) {
            if (arr_pos1_variants[key] == "")
                arr_pos1_variants[key] =  $3 ";" $5 ";" $6
            else
                arr_pos1_variants[key] = arr_pos1_variants[key] "!!" $3 ";" $5 ";" $6
         }
      }


      # POS_2 /// Port SISE
      split(arr_pos[2], arr_pos2, ",")          # 3,4,5,6,7,8;
      for (k=1; k<=length(arr_pos2); k++) {
         pos_value = arr_pos2[k]

         # заполнение массивов позиций (мотор индикатор и проч)
         if ($1 == "CPOS_2" && ($2 == "*" || $2 ~ f_code) && $3 == pos_value && ($4 == "*" || $4 ~ material)) {
            if (arr_pos2_variants[key] == "")
                arr_pos2_variants[key] =  $3 ";" $5 ";" $6
            else
                arr_pos2_variants[key] = arr_pos2_variants[key] "!!" $3 ";" $5 ";" $6
         }
      }


      # POS_3 /// PN Druck Stufe
      split(arr_pos[3], arr_pos3, ",")          # 1,2,3
      for (k=1; k<=length(arr_pos3); k++) {
         pos_value = arr_pos3[k]

         # заполнение массивов позиций (мотор индикатор и проч)
         if ($1 == "CPOS_3" && ($2 == "*" || $2 ~ f_code) && $3 == pos_value && ($4 == "*" || $4 ~ material)) {
            if (arr_pos3_variants[key] == "")
                arr_pos3_variants[key] =  $3 ";" $5 ";" $6
            else
                arr_pos3_variants[key] = arr_pos3_variants[key] "!!" $3 ";" $5 ";" $6
         }
      }

      # POS_4 /// ANZEIGE /// arr_pos[4] - материал фильтра пропускаем
      split(arr_pos[5], arr_pos4, ",")          # 0,2,3
      for (k=1; k<=length(arr_pos4); k++) {
         pos_value = arr_pos4[k]

         # заполнение массивов позиций (мотор индикатор и проч)
         if ($1 == field1_pos4 && ($2 == "*" || $2 ~ f_code) && $3 == pos_value && ($4 == "*" || $4 ~ material)) {
            if (arr_pos4_variants[key] == "")
                arr_pos4_variants[key] =  $3 ";" $5 ";" $6
            else
                arr_pos4_variants[key] = arr_pos4_variants[key] "!!" $3 ";" $5 ";" $6
         }
      }

      # POS_5 /// следующий после манометра
      split(arr_pos[6], arr_pos5, ",")          # 0,2,3
      for (k=1; k<=length(arr_pos5); k++) {
         pos_value = arr_pos5[k]

         # заполнение массивов позиций (мотор индикатор и проч)
         if ($1 == "CPOS_5" && ($2 == "*" || $2 ~ f_code) && $3 == pos_value && ($4 == "*" || $4 ~ material)) {
            if (arr_pos5_variants[key] == "")
                arr_pos5_variants[key] =  $3 ";" $5 ";" $6
            else
                arr_pos5_variants[key] = arr_pos5_variants[key] "!!" $3 ";" $5 ";" $6
         }
      }

      # POS_6 /// ABLASS
      split(arr_pos[7], arr_pos6, ",")          # 0,2,3
      for (k=1; k<=length(arr_pos6); k++) {
         pos_value = arr_pos6[k]

         # заполнение массивов позиций (мотор индикатор и проч)
         if ($1 == field1_pos6 && ($2 == "*" || $2 ~ f_code) && $3 == pos_value && ($4 == "*" || $4 ~ material)) {
            if (arr_pos6_variants[key] == "")
                arr_pos6_variants[key] =  $3 ";" $5 ";" $6
            else
                arr_pos6_variants[key] = arr_pos6_variants[key] "!!" $3 ";" $5 ";" $6
         }
      }



   }

   # считываем все без исключения 8-значные строки
   # ^.{8}$ - проверка кол-ва знаков в строке = 8 знаков
   if ($1 ~ /^[D][U][M][M][0-9]{4}|^[0-9]{8}/ && $1 ~ /^.{8}$/) {
     arr_single_prices[$1] = $3
   }


   # KATEGORIE FILE
   if (kategorie == "ON" && $1 == "KAT")
      arr_kat_inhalt[$2] = $3 "_!_" $4

   if (kategorie == "ON" && $1 == "KAT_PREIS")
      arr_kat_price[$2] = $3 "_!_" $4

}
# END OF BODY

# BEGIN END BLOCK
END {
#

# удаляем из  arr_kat_inhalt все лишнее
delete arr_new;
for (key in arr_main) {
   arr_new[key] = arr_kat_inhalt[key]
}
delete arr_kat_inhalt;

for (key in arr_new) {
   arr_kat_inhalt[key] = arr_new[key]
}
delete arr_new;



# распечатать
if (comments == "ON") {
   print "<p></p><i>arr_main[]: /// size: " length(arr_main) >> result_txt
   for (key in arr_main) {
      print "<BR>["key"]: " arr_main[key] >> result_txt
   }

   for (k=1; k<=length(arr_form_headers); k++)
      print "<BR>["k"]: " arr_form_headers[k] >> result_txt

   # AWK как отсортировать ассоциативный массив
#   PROCINFO["sorted_in"] = "@ind_str_asc"
#   for (key in arr_single_prices)
#      print "<BR>["key"]: " arr_single_prices[key] >> result_txt

   print "<p></p>: arr_pos1_variants /// ANTRIEB: "  >> result_txt
   for (key in arr_pos1_variants)
      print "<BR>["key"]: " arr_pos1_variants[key] >> result_txt

   print "<p></p>: arr_pos2_variants /// PORT SIZE: "  >> result_txt
   for (key in arr_pos2_variants)
      print "<BR>["key"]: " arr_pos2_variants[key] >> result_txt

   print "<p></p>: arr_pos3_variants /// DRUCK STUFE: "  >> result_txt
   for (key in arr_pos3_variants)
      print "<BR>["key"]: " arr_pos3_variants[key] >> result_txt

   print "<p></p>: arr_pos4_variants /// ANZEIGE: "  >> result_txt
   for (key in arr_pos4_variants)
      print "<BR>["key"]: " arr_pos4_variants[key] >> result_txt

   print "<p></p>: arr_pos5_variants /// : "  >> result_txt
   for (key in arr_pos5_variants)
      print "<BR>["key"]: " arr_pos5_variants[key] >> result_txt

   print "<p></p>: arr_pos6_variants /// ABLASS : "  >> result_txt
   for (key in arr_pos6_variants)
      print "<BR>["key"]: " arr_pos6_variants[key] >> result_txt


   if (kategorie == "ON") {
     print "<p></p>: Geh.Inhalt für Kategoriebestimmung arr_kat_inhalt[] : "  >> result_txt
     for (key in arr_kat_inhalt)
        print "<BR>["key"]: " arr_kat_inhalt[key] >> result_txt

     print "<p></p>: Kategorie preise arr_kat_price: "  >> result_txt
     for (key in arr_kat_price)
        print "<BR>["key"]: " arr_kat_price[key] >> result_txt
   }

   print "<p></p></i>" >> result_txt


}





print_table_with_prices()




# проходим в цикле по всем отобранным базовым конфигурациям
for (key in arr_main) {       # arr_main[AF747_S1]: 6;AF6016;737;1;AF7472-821-00000/S1;15000
                              # arr_main[AF748_S1]: 9;AF6016;737;1;AF7482-821-00000/S1;18000

   print "<hr class=\"border border-primary border-1 opacity-100\">" >> result_txt

   split(arr_main[key], arr_tmp, ";")
   f_type = key
   no_of_el = arr_tmp[1]
   el_bez_base = arr_tmp[2]
   el_base_price = arr_tmp[3]
   f_base = arr_tmp[5]
   f_price_base = arr_tmp[6]

   f_base_hidden = f_base ";" fe_bez ";" f_feinheit ";" f_price_base

   delete arr_pos_variants;
   arr_pos_variants[1] = arr_pos1_variants[key]  # [1]: 1;Antrieb
   # : arr_pos1_variants /// ANTRIEB:
   # [AF747_S1]: 2;Standard Handratsche;DUMM0000!!4;77768559 *** GETR.MOT.230/400V50HZ 0.25KW II2G T3 20U /// 400,-;77768559
   # [AF748_S1]: 2;Standard Handratsche;DUMM0000!!4;77768559 *** GETR.MOT.230/400V50HZ 0.25KW II2G T3 20U /// 400,-;77768559

   arr_pos_variants[2] = arr_pos2_variants[key]  # [2]: 2;Filter Anschlüsse (Eingang/Ausgang)
   arr_pos_variants[3] = arr_pos3_variants[key]  # [3]: 3;Auslegungsdruck
   arr_pos_variants[4] = arr_pos4_variants[key]  # [4]: 4;DP Messung
   arr_pos_variants[5] = arr_pos5_variants[key]  # [5]: 5;Fremddruckventil 
   arr_pos_variants[6] = arr_pos6_variants[key]  # [6]: 6;Ablassventil
                                                 # [7]: 7;Rückspüllventil

   # это то что было в КСС
   # <input type="hidden" name="f_base" value="AF17363-1321-03000/G3;AF105216;20;6785">
   # это то что получается для всего остального KSF
   # <input type="hidden" name="f_base" value="AF7472-821-00000/S1;15000">

   # <input type="hidden" name="pos1" value="3;0"> /// Antrieb
   # <input type="hidden" name="pos2" value="13;0"> /// Anschl
   # <input type="hidden" name="pos3" value="2;0"> /// PN16


   my_string = key". Base configuration: " f_base " with " el_bez_base " [LP ca. " f_price_base ",- EUR]"

   print "<div class=\"container content\" id=\"change_config" key "\">"  >> result_txt
   print "<h5><b><p class=\"text-primary\">" my_string "</p></b></h5>" >> result_txt
   print "<form action=\"/rsf-auslegung-fin\" method=\"post\">"  >> result_txt

# -----

   for (k=1; k<=length(arr_pos_variants); k++) {
       pos_number = k                                         # для формирования HTML кода чтобы ясно было
       split(arr_form_headers[pos_number], arr_headers, ";")  # [1]: 1;Antrieb /// pos_number = [1]

       split(arr_pos_variants[k], arr_all_pos_var, "!!") # 2;Standard Handratsche;DUMM0000!!4;77768559 *** GETR.MOT.230/400V50HZ 0.25KW II2G T3 20U /// 400,-;77768559

       if (length(arr_all_pos_var) == 1) {              # если у данной позиции одна единственная опция, то дропдаунов не выводим 
           split(arr_all_pos_var[1], arr_option_tmp, ";")
           print "   <input type=\"hidden\" name=\"pos" pos_number "\" value=\"" arr_option_tmp[1] ";0\">" >> result_txt
           continue
       }

       print "   <div class=\"row align-items-center\">" >> result_txt
       print "   <label for=\"pos" pos_number "\" class=\"row mb-2 col-sm-2 col-form-label\">" arr_headers[2] ":</label>" >> result_txt
       print "     <div class=\"col-auto\">"  >> result_txt

       # заголовок опции например "ANTRIEB"
       print "        <select class=\"form-select border-primary\" id=\"pos" pos_number "\" name=\"pos" pos_number "\">" >> result_txt

    # ------
       for (m=1; m<=length(arr_all_pos_var); m++) {     # 2;Standard Handratsche;DUMM0000
                                                        # 4;77768559 *** GETR.MOT.230/400V50HZ 0.25KW II2G T3 20U /// 400,-;77768559

         split(arr_all_pos_var[m], arr_option_tmp, ";")
         pos_option = arr_option_tmp[1]  # 2 für Handratsche
         pos_text   = arr_option_tmp[2]  # "Standard Handratsche"
         pos_mat_nr = arr_option_tmp[3]  # DUMM000 für Handratsche
         option_value = pos_option ";" arr_single_prices[pos_mat_nr]

         txt_option = pos_text
         if (arr_single_prices[pos_mat_nr] == 0)
            txt_option = txt_option " /// Standardausführung ohne Mehrkosten"
         else
            txt_option = txt_option " /// Mehrpreis: " arr_single_prices[pos_mat_nr] ",- EUR"

         print "         <option value=\"" option_value "\">" txt_option "</option>" >> result_txt

         # <select class="form-select border-primary" id="pos4" name="pos4">
         # <option value="0;0">ohne DP Kontrolle /// Standardausführung ohne Mehrkosten</option>
         # <option value="1;251">PIS 3076/1,2 Alu  /// Mehrpreis: 251,- EUR</option>
       }
    # ----

       print "       </select>" >> result_txt
       print "   </div>" >> result_txt
       print "   </div>" >> result_txt
   }

       # входят член асс массива с элементами arr_elem[AF747_S1]: AF6036-020;2156=AF6066-050;903=AF6076-016;903
       # цена базового элемента в базовой конфигурации, количество элементов 
       print_html_code_for_dropdown_element(arr_elem[key], el_base_price, no_of_el)

       if (kategorie == "ON")
          print_html_code_for_dropdown_kategorie(key)



# -----

   print "   <input type=\"hidden\" name=\"f_base\" value=\""f_base_hidden"\">" >> result_txt
   print "<button type = \"Submit\" class=\"btn btn-primary btn-lg\"> SEND </button>"  >> result_txt
   print "</form>" >> result_txt
   print "</div>" >> result_txt
}

print "</div>" >> result_txt


} # END OF END-PART





# split(arr_base_conf[i], arr_tmp, ";") = "AF173_G3;1;AF17363-1321-03000/G3;AF105216;E268;6785;20"
function print_table_with_prices() {
  print_bootstrap_head("Auslegungsergebnisse / Filtervorschläge:")
  delete arr_tmp; delete arr_tmp1; delete arr_tmp2;

  for (key in arr_main) {
    split(arr_main[key], arr_main_tmp, ";")
    no_of_el   = arr_main_tmp[1]
    base_el    = arr_main_tmp[2]
    filter_bez = arr_main_tmp[5]   # AF7474-523-00000/S1
    lprice     = arr_main_tmp[6]   # 15000

    split(arr_elem[key], arr_elem_tmp, "=")
    str_elements = ""
    for (k=1; k<=length(arr_elem_tmp); k++) {  # AF6066-050;903=AF6076-010;903 
       split(arr_elem_tmp[k], arr1, ";")       # AF6066-050;903
       if (str_elements == "")
          str_elements = arr1[1]
       else
          str_elements = str_elements " o. " arr1[1]
    }

    # заменяем для линка косую черту на подстроку "%2F"
#    tmp3 = arr_tmp[3]
#    gsub(/\//, "%2F", tmp3)

    # добавляем строку с ценой
#    tmp_price = "PRICE%3A" arr_tmp[6]

    # для красивого вывода
#    filter_type = "  /// RSF: "
#    if (substr(arr_tmp[3],1,3) == "AF7")
#       filter_type = "  /// KSF: "

#    str_fineness = " " arr_tmp[7] " µm"
#    if (substr(arr_tmp[3],1,3) != "AF7" && arr_tmp[7] in arr_nom_feinheit)
#       str_fineness = " abs: " arr_tmp[7] " µm, / nom: ca. " arr_nom_feinheit[arr_tmp[7]] " µm"
#
#    filter_type = filter_type str_fineness
    ########## конец красивого вывода



#    mylink = "https://salestext.ddns.net/?filter_name=" tmp3 "+" el_code tmp_price
#    mystr1 = i ". " arr_tmp[3] " mit " el_code
#    mystr2 = arr_tmp[6] ",-"
#    mystr3 = "[<a href=\""mylink"\">V-Text</a>]"" / [<a href=\"#change_config" i "\">change configuration</a>]"

    mystr3 = "[<a href=\"#change_config" key "\">change configuration</a>]"
    mystr = filter_bez " mit " no_of_el " x " str_elements
    mylprice = "ab ca. " lprice ",- EUR"

    # создаем временный массив для сортировки
    arr_tmp1[length(arr_tmp1)+1] = lprice "_!_" mystr "_!_" mylprice "_!_" mystr3
  }

  # сортируем arr_tmp1 в arr_tmp2 по возрастанию цены
  for (k=1; k<=length(arr_tmp1); k++) {
     split(arr_tmp1[k], arr_tmp1_k, "_!_")
     for (m=k+1; m<=length(arr_tmp1); m++) {
        split(arr_tmp1[m], arr_tmp1_m, "_!_")
        if (arr_tmp1_m[1] < arr_tmp1_k[1]) {
           tmp_elem = arr_tmp1[k]
           arr_tmp1[k] = arr_tmp1[m]
           arr_tmp1[m] = tmp_elem
#           break
        }
     }
  }

  # печать сводной таблицы с ценами
  print "<table class=\"table table-striped\">" >> result_txt
  print "<thead><tr><th scope=\"col\">Base configuration</th>"  >> result_txt
  print "<th scope=\"col\">LP, EUR St/Brt</th>" >> result_txt
  print "<th scope=\"col\">Zuzätzliche Info</th></tr></thead>"  >> result_txt
  print "<tbody>" >> result_txt

  for (k=1; k<=length(arr_tmp1); k++) {
    split(arr_tmp1[k], arr_tmp2, "_!_")
    mystr    = arr_tmp2[2]
    mylprice = arr_tmp2[3]
    mystr3   = arr_tmp2[4]
    print "<tr><td>"mystr"</td>" >> result_txt
    print "<td>" mylprice "</td>" >> result_txt
    print "<td>" mystr3 "</td></tr>" >> result_txt
  }

  print "</tbody></table>" >> result_txt
  delete arr_tmp; delete arr_tmp1; delete arr_tmp2;
}


function print_bootstrap_head(page_header) {
#  print "<div class=\"container content\">"  >> result_txt
  print "<div class=\"p-2 mb-2 bg-primary text-white\">"  >> result_txt
  print page_header "</div>"  >> result_txt
#  print "<ul class=\"list-group list-striped mb-3\">"  >> result_txt
  return
}

# входят член асс массива с элементами arr_elem[AF747_S1]: AF6036-020;2156=AF6066-050;903=AF6076-016;903
# цена базового элемента в базовой конфигурации, количество элементов
function  print_html_code_for_dropdown_element(arr_elem_key, el_base_price, no_of_el) {
   # заголовок опции "ELEMENT"
   print "   <div class=\"row align-items-center\">" >> result_txt
   print "   <label for=\"element" "\" class=\"row mb-2 col-sm-2 col-form-label\">Filterelement:</label>" >> result_txt
   print "     <div class=\"col-auto\">"  >> result_txt
   print "        <select class=\"form-select border-primary\" id=\"element" "\" name=\"element"  "\">" >> result_txt

   # arr_elem[AF748_S1]: AF6036-013;2156=AF6076-013;903
   split(arr_elem_key, arr_elem_tmp, "=")
   delete arr_tmp1
   for (n=1; n<=length(arr_elem_tmp); n++) {
      split(arr_elem_tmp[n], arr_tmp1, ";")   # "AF6036-013;2156"

      elem_new_bez = arr_tmp1[1]              # "AF6036-013"
      elem_new_price = arr_tmp1[2]            # "2156"
      price_change = (elem_new_price - el_base_price) * no_of_el
      if (price_change > 0)
         o_txt = " /// Mehrpreis: " price_change ",- EUR"
      if (price_change < 0)
         o_txt = " /// Peisminderung: " price_change ",- EUR"
      if (price_change == 0)
         o_txt = " /// Ohne Mehrkosten: "

      txt_option = "mit " no_of_el "x " elem_new_bez o_txt
      print "         <option value=\"" elem_new_bez";"price_change "\">" txt_option "</option>" >> result_txt
   }

   print "       </select>" >> result_txt
   print "   </div>" >> result_txt
   print "   </div>" >> result_txt

   return
}



# вывод дропдауна для категории
function  print_html_code_for_dropdown_kategorie(key) {
   split(arr_kat_inhalt[key], arr_inhalt1, "_!_") # [AF747_S1]: 75_!_2-2.6;3-13.3;4-25
   split(arr_inhalt1[2], arr_inhalt2, ";")        # 2-2.6;3-13.3;4-25

   # заголовок опции "KATEGORIE"
   print "   <div class=\"row align-items-center\">" >> result_txt
   print "   <label for=\"kategorie" "\" class=\"row mb-2 col-sm-2 col-form-label\">DRGL Zertifizierung ("arr_inhalt1[1]" [L]):</label>" >> result_txt
   print "     <div class=\"col-auto\">"  >> result_txt
   print "        <select class=\"form-select border-primary\" id=\"kategorie" "\" name=\"kategorie"  "\">" >> result_txt

   delete arr_tmp1
   for (n=1; n<=length(arr_inhalt2); n++) {  # 2-2.6  3-13.3   4-25
      split(arr_inhalt2[n], arr_tmp1, "-")   # 2 - 2.6
      kat_nr = arr_tmp1[1]
      split(arr_kat_price[kat_nr], arr_kat_price_tmp, "_!_")  #KII_!_1400
      price_change = arr_kat_price_tmp[2]
      kat_roemisch = arr_kat_price_tmp[1]

      txt_option = "Kategorie " kat_roemisch " bis " arr_tmp1[2] " bar /// Mehrpreis: " price_change ",- EUR"
      print "         <option value=\"" kat_roemisch";"price_change "\">" txt_option "</option>" >> result_txt
   }

   print "       </select>" >> result_txt
   print "   </div>" >> result_txt
   print "   </div>" >> result_txt

   return
}


