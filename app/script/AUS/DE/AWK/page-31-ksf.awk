BEGIN {
  RS = "\n"
  FS = "_!_"

# заходит эта строка
#mystring = medium:02,comments:ON,dpressure:1,antrieb:4,material:1,materialel:2,ksf:ON_!_str_myarr:9;AF6036-020;E114552102;2156;4:9;AF6066-050;E124612403;903;4:9;AF6076-016;E124612303;903;4 


   delete arr_main; delete arr_tmp1; delete arr_tmp2; delete arr_tmp3; delete arr_tmp4; delete arr_suitable_elements;
   split(mystring, arr_tmp1, "_!_")    # medium:02,comments:ON,dpressure:1,antrieb:4,material:1,materialel:2,ksf:ON,kategorie:ON
                                    # str_myarr:9;AF6036-010;E114552102;2156;4:6;AF6066-050;E124612403;903;4:9;AF6076-010;E124612303;903;4:9;AF6086-010;E124612203;903;4

   split(arr_tmp1[1], arr_tmp2, ",")   # "medium:02" "comments:ON" "dpressure:1" usw
   split(arr_tmp1[2], arr_tmp4, ":")

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

   for (i=2; i<=length(arr_tmp4); i++)
      arr_suitable_elements[i-1] = arr_tmp4[i]

   delete arr_main; delete arr_tmp1; delete arr_tmp2; delete arr_tmp3; delete arr_tmp4;

   if (comments == "ON") {
      print "<b> -------- Begin page-31-ksf.awk --------- </b><BR>[mystring]: "mystring >> result_txt
      print "<BR>medium: " medium " /// comments: " comments " /// dpressure: " dpressure " /// antrieb: " antrieb " /// material: " material " /// materialel: " materialel " /// ksf: " ksf " /// kategorie: " kategorie " /// atex: " atex >> result_txt

      print "<BR>arr_suitable_elements[i]: "  >> result_txt
      for (i=1; i<=length(arr_suitable_elements); i++)
         print "<BR>["i"]: " arr_suitable_elements[i] >> result_txt
   }

   delete arr_base_conf; delete arr_forms_headers
   counter_forms_headers = 1
   str_passende_filter_series = ""

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

   # какие модели применяются для нашего анвендунга "02" - Мисцелла <fe-code.txt>
   # KSFNA = KSF nach Anwendungen / MEDIUM - geeignete KSF TYPEN für die Anwendung
   # $2 = MEDIUM
   # $3 = geeignete Filtertypen
   # KSFNA_!_02_!_AF736_G3,AF736_S1,AF737_S1,AF738_S1,AF747_S1,AF748_S1,AF749_S1,AF757_S1,AF758_S1,AF759_S1
   if ($1 == "KSFNA" && $2 == medium) {
      str_passende_filter_series = $3
   }

   # добавить if (atex == "ON") то $1 == "BASECONF_EX"
   #
   # BASECONF_EX_!_02_!_9_!_AF748_S1_!_1_!_AF7484-521-00000/S1_!_AF6016_!_E114_!_18000
   if ($1 == "BASECONF_EX" && $2 ~ medium && $5 == material && str_passende_filter_series ~ $4) {
      print "<p></p>$0: " $0 >> result_txt

      # arr_suitable_elements[i]:
      # [1]: 9;AF6036-010;E114552102;2156;4
      for (k=1; k<=length(arr_suitable_elements); k++) {
         print "<br>arr_suitable_elements[k]: " arr_suitable_elements[k] >> result_txt

         split(arr_suitable_elements[k], arr1, ";")
         no_of_elements = arr1[1]
         el_bez = arr1[2]
         el_code = substr(arr1[3],1,4)
         el_price = arr1[4]

#         print "<br>no_of_elements: " no_of_elements " /// el_code: " el_code  >> result_txt

         # наполняем новый массив
         if ($3 == no_of_elements && $8 == el_code) {
            arr_base_conf[length(arr_base_conf)+1] =  $4 ";" $5 ";" $6 ";" $7 ";" $8 ";" $9 "_!_" arr_suitable_elements[k]
         }

      }

   }

}
# END OF BODY

# BEGIN END BLOCK
END {
#
  print "<br>str_passende_filter_series: " str_passende_filter_series >> result_txt
  print "<p></p>arr_base_conf[]:" length(arr_base_conf) >> result_txt
  for (i=1; i<=length(arr_base_conf); i++)
     print "<br>["i"]: " arr_base_conf[i] >> result_txt


print "</div>" >> result_txt

}
# END OF END BLOCK


