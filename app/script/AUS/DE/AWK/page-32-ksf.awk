BEGIN {
  RS = "\n"
  FS = "_!_"

# заходит эта строка
#mystring = medium:02,comments:ON,dpressure:1,antrieb:4,material:1,materialel:2,ksf:ON_!_str_myarr:9;AF6036-020;E114552102;2156;4:9;AF6066-050;E124612403;903;4:9;AF6076-016;E124612303;903;4 

   print "<div class=\"container content\">" >> result_txt

   delete arr_main; delete arr_tmp1; delete arr_tmp2; delete arr_tmp3; delete arr_tmp4; delete arr_suitable_elements;
   delete arr_main_elements; 
   split(mystring, arr_tmp1, "_::_")    # medium:02,comments:ON,dpressure:1,antrieb:4,material:1,materialel:2,ksf:ON,kategorie:ON
                                    # str_myarr:9;AF6036-010;E114552102;2156;4:6;AF6066-050;E124612403;903;4:9;AF6076-010;E124612303;903;4:9;AF6086-010;E124612203;903;4

   split(arr_tmp1[1], arr_tmp2, ",")   # "medium:02" "comments:ON" "dpressure:1" usw
#   split(arr_tmp1[2], arr_tmp4, ":")

   for (i=1; i<=length(arr_tmp2); i++) {
      split(arr_tmp2[i],arr_tmp3,":")
      arr_main[arr_tmp3[1]] = arr_tmp3[2]
   }

   dpm_g1 = arr_main["dpm_g1"]
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

   delete arr_main; delete arr_tmp2; delete arr_tmp3; 

   # собираем arr_main
   for (i=2; i<=length(arr_tmp1); i++) {
      split(arr_tmp1[i], arr_tmp2, "_!!_")
      arr_main[arr_tmp2[1]] = arr_tmp2[2]
   }


   if (comments == "ON") {
      print "<i><b> -------- Begin &lt page-32-ksf.awk &gt --------- </b><BR>[mystring]: "mystring >> result_txt
      print "<BR>medium: " medium " /// comments: " comments " /// dpressure: " dpressure " /// antrieb: " antrieb " /// material: " material " /// materialel: " materialel " /// ksf: " ksf " /// kategorie: " kategorie " /// atex: " atex " /// viscosity: " viscosity " /// dpm_g1:" dpm_g1 >> result_txt

      print "<p></p>arr_main[]: " >> result_txt
      for (key in arr_main)
         print "<BR>["key"]: " arr_main[key] >> result_txt

      print "<BR>-------- Enter BODY --------- </i>" >> result_txt
   }

    field1_possconf = "POSSCONF"  # configuration possible
    if (atex == "ON") {
        field1_possconf = "POSSCONF_EX"
    }
    viscosity_limit = 0


}
# END OF BEGIN BLOCK

# ТЕЛО
{
   if (atex != "ON" && $1 == "VISCOSITY_LIMIT") {
      viscosity_limit = $2
      if (viscosity >= viscosity_limit || dpm_g1 == "")
         field1_possconf = "POSSCONF_HV"  # configuration for hochviscosity without DPM G1/8"
   }


   # если нет подходящих фильтров
     if (mystring == "") {
        print "<BR>No suitabe filters found. Exit" >> result_txt
        exit  # выход из тела
     }

   # добавляем POSSIBLE CONFIGURATIONS в конец
   for (key in arr_main) {
      if ($1 == field1_possconf && $2 ~ key && $6 ~ material) {

#   print "<BR>field1_possconf: " $0 >> result_txt


         str_pos = $3 ";" $4 ";" $5 ";" $6 ";" $7 ";" $8 ";" $9 ";" $10 ";" $11
         arr_main[key] = arr_main[key] "_!_" str_pos
      }
   }


}
# END OF BODY

# BEGIN END BLOCK
END {
#


# распечатать
if (comments == "ON") {
   print "<p></p><i>arr_main[]: /// size: " length(arr_main) >> result_txt
   for (key in arr_main)
      print "<BR>["key"]: " arr_main[key] >> result_txt
   print "<BR><b>-------- End of &lt page-32-ksf.awk &gt --------- </b>: " >> result_txt
   print "</i>" >> result_txt
}

print "</div>" >> result_txt

# подготавливаем строку для передачи в следующий скрипт
split(mystring, arr_tmp1, "_!_")    # arr_tmp1[1] = medium:02,comments:ON,dpressure:1,antrieb:4,material:1,materialel:2,ksf:ON,kategorie:ON
mystring = arr_tmp1[1]
for (key in arr_main) {
   mystring = mystring "_::_" key "_!!_" arr_main[key]
}
print  mystring


}
# END OF END BLOCK


