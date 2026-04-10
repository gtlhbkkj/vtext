# f-housing.txt, "fe-pos.txt", "fe-code.txt", "page-2.txt"

BEGIN {
  RS = "\n"
  FS = "_!_"

# заходит эта строка
#mystring = medium:02,comments:ON,dpressure:1,antrieb:4,material:1,materialel:2,ksf:ON_!_str_myarr:9;AF6036-020;E114552102;2156;4:9;AF6066-050;E124612403;903;4:9;AF6076-016;E124612303;903;4 


   delete arr_main; delete arr_tmp1; delete arr_tmp2; delete arr_tmp3; delete arr_tmp4; delete arr_suitable_elements;
   delete arr_main_elements;
   split(mystring, arr_tmp1, "_!_")    # medium:02,comments:ON,dpressure:1,antrieb:4,material:1,materialel:2,ksf:ON,kategorie:ON
                                    # str_myarr:9;AF6036-010;E114552102;2156;4:6;AF6066-050;E124612403;903;4:9;AF6076-010;E124612303;903;4:9;AF6086-010;E124612203;903;4

   split(arr_tmp1[1], arr_tmp2, ",")   # "medium:02" "comments:ON" "dpressure:1" usw
   split(arr_tmp1[2], arr_tmp4, ":")

   for (i=1; i<=length(arr_tmp2); i++) {
      split(arr_tmp2[i],arr_tmp3,":")
      arr_main[arr_tmp3[1]] = arr_tmp3[2]
   }

   dpm_g1 = arr_main["dpm_g1"]
   fineness = arr_main["fineness"]
   viscosity = arr_main["viscosity"]
   medium = arr_main["medium"]
   comments = arr_main["comments"]
   dpressure = arr_main["dpressure"]
   antrieb = arr_main["antrieb"]
   material = arr_main["material"]
   materialel = arr_main["materialel"]
   ksf = arr_main["ksf"]
   atex = arr_main["atex"]
   kategorie = arr_main["kategorie"]

   for (i=2; i<=length(arr_tmp4); i++)
      arr_suitable_elements[i-1] = arr_tmp4[i]

   delete arr_main; delete arr_tmp1; delete arr_tmp2; delete arr_tmp3; delete arr_tmp4;

   if (comments == "ON") {
      print "<b> -------- Begin page-31-ksf.awk --------- </b><BR>[mystring]: "mystring >> result_txt

      # GET SERVER RESPONSE 200 or 404
      #curl -o /dev/null -s -w "%{http_code}" https://shopindustrial.filtrationgroup.com/de/77734700.html
#      mymaterial_nr = "77734700"
#      myvar = "https://shopindustrial.filtrationgroup.com/de/" mymaterial_nr ".html"
#      mycmd = "curl -o /dev/null -s -w \"%{http_code}\" " myvar
#      mycmd | getline result
#      close(mycmd)
#      print "<p></p>Ответ сервера: " result >> result_txt


      print "<BR>medium: " medium " /// comments: " comments " /// dpressure: " dpressure " /// antrieb: " antrieb " /// material: " material " /// materialel: " materialel " /// ksf: " ksf " /// kategorie: " kategorie " /// atex: " atex " /// viscosity: " viscosity >> result_txt

      print "<BR>arr_suitable_elements[i]: "  >> result_txt
      for (i=1; i<=length(arr_suitable_elements); i++)
         print "<BR>["i"]: " arr_suitable_elements[i] >> result_txt

      print "<BR>-------- Enter BODY --------- </i>" >> result_txt
   }

   delete arr_base_conf; delete arr_forms_headers; delete arr_zuordnung
   delete arr_tmp_elements; delete arr_main_elements; delete arr_elements_full;
   counter_forms_headers = 1
   str_passende_filter_series = ""
   counter_arr_zuordnung = 0

}
# END OF BEGIN BLOCK

# ТЕЛО
{

   # проверить размер элементов в arr_suitable_elements[i]: и возможно полностью переписать этот массив
   # т.е. пройтись по <fe-code.txt>
   # pos.6 = "1" Alu Elemente, "*" остальное или звездочка или всё кроме "1"
   # использовать шаблон ^[E][1][1-2][$5 - последний член в строке]..[MATERIAL].[0]

   # если нет подходящих фильтров
     if (mystring == "") {
        print "<BR>No suitabe filters found. Exit" >> result_txt
        exit  # выход из тела
     }

   #  заполнение массива заголовков для вывода финальных форм
   if ($1 == "PHEADER") {
      arr_form_headers[counter_forms_headers] = $2 ";" $3
      counter_forms_headers++
   }

   # <fe-code.txt>
   # какие модели применяются для нашего анвендунга "02" - Мисцелла <fe-code.txt>
   # KSFNA = KSF nach Anwendungen / MEDIUM - geeignete KSF TYPEN für die Anwendung
   # $2 = MEDIUM
   # $3 = geeignete Filtertypen
   # KSFNA_!_02_!_AF736_G3,AF736_S1,AF737_S1,AF738_S1,AF747_S1,AF748_S1,AF749_S1,AF757_S1,AF758_S1,AF759_S1
   if ($1 == "KSFNA" && $2 ~ medium) {
      str_passende_filter_series = $3
#      print "<BR>str_passende_filter_series: " str_passende_filter_series >> result_txt
   }


  # <fe-pos.txt>
  # Создаем новый массив accoциативный arr_zuordnung[$1] = $4
  # POS_3 /// FILTER SERIES (ELEMENT ZUORDNUNG NACH FILTER GRÖSSE)
  # POS_3_!_0_!_n/A
  # POS_3_!_1_!_E111,E121_!_AF711_G1_!_# AF7011,AF7031,AF7071,AF7081
  # POS_3_!_2_!_E112,E122,E142_!_AF713_H2,AF713_G1,AF713_GX1,AF713_GX2,AF713_S1,AF713_SH1_!_# AF7013,AF7033,AF7073,AF7083,AF50133
  if ($1 == "POS_3" && $2 >= 1 && $2 <=4 && str_passende_filter_series != "") {
      arr_zuordnung[$2] = $4
#      print "<BR>arr_zuordnung["$2"]: " arr_zuordnung[$2] >> result_txt
  }


  # проходим по accoциативному arr_zuordnung[$1] = $4 в цикле и сравниваем со строкой str_passende_filter_series
  # то, что осталось записываем в arr1[$1] = «» или arr1[$1] = «AF713_GX1» или несколько
  if (length(arr_zuordnung) == 4 && counter_arr_zuordnung == 0) {
     for (k=1; k<=length(arr_zuordnung); k++) {
       new_string = ""
       split(arr_zuordnung[k], arr1_zuordnung, ",")

       for (m=1; m<=length(arr1_zuordnung); m++) {
         if (str_passende_filter_series ~ arr1_zuordnung[m])
            if (new_string == "" )
               new_string = arr1_zuordnung[m]
            else
               new_string = new_string "," arr1_zuordnung[m]
       }
       arr_zuordnung[k] = new_string
     }
     counter_arr_zuordnung = 1   # чтобы условный оператор больше не выполнялся
  }

  # создаем новый финальный массив arr_main_elements
  if (counter_arr_zuordnung == 1) {
    for (k=1; k<=length(arr_suitable_elements); k++) {
       split(arr_suitable_elements[k], arr1, ";")       # 6;AF6036-020;E114552102;2156;4
       no_of_el = arr1[1]
       el_bez   = arr1[2]
       el_code  = arr1[3]
#       el_code_template = "^[E]["substr(el_code,2,1)"]["substr(el_code,3,1)"]["substr(el_code,4,1)"]..["substr(el_code,7,1)"]["substr(el_code,8,1)"].."
       el_code_template = "^[E]["substr(el_code,2,1)"]["substr(el_code,3,1)"]["substr(el_code,4,1)"]..["substr(el_code,7,1)"]["substr(el_code,8,1)"]["substr(el_code,9,1)"]["substr(el_code,10,1)"]"
       filter_size_new = arr1[5]                        # "4" = "4" /// E11[4]552102

#       arr_main_elements[length(arr_main_elements)+1] = no_of_el ";" el_bez ";" el_code_template ";" arr_zuordnung[substr(el_code,4,1)]
       arr_tmp_elements[length(arr_tmp_elements)+1] = no_of_el ";" el_bez ";" el_code_template ";" arr_zuordnung[substr(el_code,4,1)]

       if (filter_size_new != substr(el_code,4,1) && arr_zuordnung[filter_size_new] != "" && no_of_el == 1) {
       #         print "<BR>----arr_suitable_elements[k]: " arr_suitable_elements[k] >> result_txt
          split(el_bez, arr1, "-")  # AF6036-020
          el_code_template = "^[E]["substr(el_code,2,1)"]["substr(el_code,3,1)"]["filter_size_new"]..["substr(el_code,7,1)"]["substr(el_code,8,1)"]["substr(el_code,9,1)"]["substr(el_code,10,1)"]"
#          arr_main_elements[length(arr_main_elements)+1] = no_of_el ";" "REPLACEME-" arr1[2] ";" el_code_template ";" arr_zuordnung[filter_size_new]
          arr_tmp_elements[length(arr_tmp_elements)+1] = no_of_el ";" "REPLACEME-" arr1[2] ";" el_code_template ";" arr_zuordnung[filter_size_new]
       }
    }
    counter_arr_zuordnung = 2

  }

  # <fe-code.txt>
  # считываем все элементы (обозначение - цена) в ассоциативный массив
  if ($1 == "EBCPF") {
     arr_elements_full[$2] = $4
  }


#   x1 = 0
#   if (x1 == 0) {
#     print "<p></p>arr_tmp_elements[]: "  >> result_txt
#     for (k1=1; k1<=length(arr_tmp_elements); k1++) {
#        print "<BR>["k1"]:" arr_tmp_elements[k1] >> result_txt
#     }
#     x1 = 1
#   }



  # <fe-code.txt>
  # дополняем Final array arr_main_elements[]: только те записи в которых нет обозначения элемента
  # [1]:1;AF6036-013;^[E][1][1][4]..[2][1][0][2];AF736_G3,AF736_S1,AF737_S1,AF738_S1,AF747_S1,AF748_S1,AF749_S1
  # [2]:1;REPLACEME-013;^[E][1][1][3]..[2][1][0][2];AF724_G4
  for (m=1; m<=length(arr_tmp_elements); m++) {
     split(arr_tmp_elements[m], arr1, ";")
     no_of_el = arr1[1]
     el_bez = arr1[2]                # AF6036-020
     split(el_bez, arr_el_bez, "-")
     el_fineness = arr_el_bez[2]
  #   print "<BR>---el_fineness" el_fineness >> result_txt
     my_regex  = arr1[3]             # ^[E][1][1][3]..[2]…
     suitable_housings = arr1[4]

     if ($1 == "EBCPF" && $3 ~ my_regex) {
#     if ($3 ~ my_regex) {
        # EBCPF_!_AF6036_!_E114552102_!_2156_!_30,40,50,80,100,130,200,250,360,500
        if (el_bez ~ "REPLACEME")
           arr_main_elements[length(arr_main_elements)+1] = no_of_el ";" $2 "-" el_fineness ";" $3 ";" $4
        else
           arr_main_elements[length(arr_main_elements)+1] = no_of_el ";" el_bez ";" $3 ";" $4        # $4 = list price

#       myprint()

     }

  }


#}

   # <page-2.txt>
   # добавить if (atex == "ON") то $1 == "BASECONF_EX"
   #
   # BASECONF_EX_!_02_!_9_!_AF748_S1_!_1_!_AF7484-521-00000/S1_!_AF6016_!_E114_!_18000
   if ($1 == "BASECONF" && $2 ~ medium && $5 == material && str_passende_filter_series ~ $4) {
#   if ($1 == "BASECONF_EX" && $2 ~ medium && $5 == material && str_passende_filter_series ~ $4) {
#      print "<br>$0: " $0 >> result_txt

      # arr_main_elements[]:
      # [1]:1;AF6036-013;E114;2156
      # [2]:1;AF6034-013;E113;1978
      for (k=1; k<=length(arr_main_elements); k++) {
#         print "<br>arr_main_elements[k]: " arr_main_elements[k] >> result_txt
         split(arr_main_elements[k], arr1, ";")
         no_of_elements = arr1[1]
#         el_bez = arr1[2]
         el_code = arr1[3]

#         # наполняем новый массив
         if ($3 == no_of_elements && substr($8,4,1) == substr(el_code,4,1)) {
            arr_base_conf[length(arr_base_conf)+1] =  $3 ";" $4 ";" $5 ";" $6 ";" $7 ";" $8 ";" $9 "_!_" arr_main_elements[k]
         }

      }

   }

}
# END OF BODY

# BEGIN END BLOCK
END {
#
# добавляем в arr_base_conf[k] цену базового элемента из ассоциативного массива
for (k=1; k<=length(arr_base_conf); k++) {
  split(arr_base_conf[k], arr1, ";")
  el_bez = arr1[5]
  el_price = arr_elements_full[el_bez]
  arr_base_conf[k] = arr_base_conf[k] "_!_" el_price
}


# ищем одинаковые базовые корпуса в arr_base_conf[k] и упрощаем его, сокращаем кол записей
# [1]: 1;AF736_G3;1;AF7364-1321-00000/G3;AF6016;E114;4935_!_1;AF6036-010;E114552102;2156_!_737
for (k=1; k<=length(arr_base_conf); k++) {
  split(arr_base_conf[k], arr_tmp, "_!_")
  split(arr_tmp[1], arr_tmp1, ";")               # 1;AF736_G3;1;AF7364-1321-00000/G3;AF6016;E114;4935
  split(arr_tmp[2], arr_tmp2, ";")               # 1;AF6036-010;E114552102;2156
  price_el = arr_tmp[3]                          # 737

  # обработка 1 части arr_tmp1: 1;AF736_G3;1;AF7364-1321-00000/G3;AF6016;E114;4935
  no_of_el      = arr_tmp1[1]   # 1
  filter_series = arr_tmp1[2]   # AF736_G3
  material      = arr_tmp1[3]   # 1
  filter_bez    = arr_tmp1[4]   # AF7364-1321-00000/G3
  el_bez        = arr_tmp1[5]   # AF6016
  base_price    = arr_tmp1[7]   # 4935

  if (arr_base_conf_new[filter_series] == "")  # arr_base_conf_new["AF736_G3"]
     arr_base_conf_new[filter_series] = no_of_el ";" el_bez ";" price_el ";" material ";" filter_bez ";" base_price
}

# дополняем ассоциативный массив arr_base_conf_new[] подходящими элементами из arr_base_conf[]
for (key in arr_base_conf_new) {
   split(arr_base_conf_new[key], arr_tmp, ";")      # [AF736_S1]: 1;AF6016;737;1;AF7364-321-00000/S1;9745
   found = 0
   for (k=1; k<=length(arr_base_conf); k++) {
      split(arr_base_conf[k], arr_tmp, "_!_")        # 1;AF736_G3;1;AF7364-1321-00000/G3;AF6016;E114;4935_!_1;AF6036-010;E114552102;2156_!_737
      split(arr_tmp[1], arr_tmp1, ";")               # 1;AF736_G3;1;AF7364-1321-00000/G3;AF6016;E114;4935
      filter_series = arr_tmp1[2]                    # AF736_G3

      if (key == filter_series) {
         split(arr_tmp[2], arr_tmp2, ";")            # 1;AF6036-010;E114552102;2156
         add_element = arr_tmp2[2]
         add_el_price = arr_tmp2[4]

         if (found == 0)
            arr_base_conf_new[key] = arr_base_conf_new[key] "_!_" add_element ";" add_el_price
         else
            arr_base_conf_new[key] = arr_base_conf_new[key] "=" add_element ";" add_el_price

         found = 1
      }
   }

}



# распечатать
if (comments == "ON") {
   print "<p></p><i> str_passende_filter_series: "  str_passende_filter_series >> result_txt

   print "<p></p>arr_zuordnung (updated): length: " length(arr_zuordnung)  >> result_txt
   for (key in arr_zuordnung) {
      print "<BR>["key"]: " arr_zuordnung[key] >> result_txt
   }

   print "<p></p>Final array - arr_main_elements[]: "  >> result_txt
   for (k=1; k<=length(arr_main_elements); k++) {
      print "<BR>["k"]:" arr_main_elements[k] >> result_txt
   }

   print "<p></p>arr_base_conf[], length: " length(arr_base_conf) " /// $1=no of el $3=material" >> result_txt
   for (i=1; i<=length(arr_base_conf); i++)
      print "<br>["i"]: " arr_base_conf[i] >> result_txt

   print "<p></p>Simplified arr_base_conf_new[]: " >> result_txt
   for (key in arr_base_conf_new) {
      print "<BR>["key"]: " arr_base_conf_new[key] >> result_txt
   }

   print "<BR><b>-------- End of &lt page-31-ksf.awk &gt --------- </b>: " >> result_txt

   print "</i>" >> result_txt

}

print "</div>" >> result_txt

# подготавливаем строку для передачи в следующий скрипт
split(mystring, arr_tmp1, "_!_")    # arr_tmp1[1] = medium:02,comments:ON,dpressure:1,antrieb:4,material:1,materialel:2,ksf:ON,kategorie:ON
mystring = arr_tmp1[1]

mystring = arr_tmp1[1]
for (key in arr_base_conf_new) {
   mystring = mystring "_::_" key "_!!_" arr_base_conf_new[key]
}

print  mystring


}
# END OF END BLOCK




#function myprint() {
#   print "<p></p>Final array - arr_main_elements[]: "  >> result_txt
#   for (k1=1; k1<=length(arr_main_elements); k1++) {
#      print "<BR>["k1"]:" arr_main_elements[k1] >> result_txt
#   }
#}
