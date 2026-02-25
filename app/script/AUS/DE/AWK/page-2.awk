BEGIN {
  RS = "\n"
  FS = "_!_"

# заходят
# medium = "01"
# comments = "ON"

print_bootstrap_head("Filter Auslegung // Seite 2")

if (comments == "ON") {
   print "<BR><i>Input Information from previous page:" >> result_txt
   print "<BR>Medium: \"" medium  "\" /// Comments: \"" comments "\"</i>." >> result_txt
}


str_medium = str_ivalues = str_pvalues = str_s01 = str_s02 = ""
ffstr_ivalues = ffstr_pvalues = 0           # для поиска в теле. Если нашли то больше не ищем
# формируем поисковую строку для вывода доп опций по среде
fstr_medium = "M_" medium
fstr_ivalues = "MIV_" medium # MV = Medium Input Values
fstr_pvalues = "MPV_" medium # MPV = Medium Partikeln Values

# набираем массив для вывода на вебсайте строк ввода параметров давление, тонкость, etc
counter_arr_for_str_input = 1
arr_for_str_input[1] = ""
delete arr_for_str_input

# на базе массива arr_input_label_2 формируем подходящие дропдауны 
counter_aad = 0 # чтобы эту строку ALL_AVAILABLE_DROPDOWNS в <page-1.txt> искать только 1 раз
delete arr_input_label_2
delete arr_dropdowns

} # END OF BEGIN



# ТЕЛО
{
  # эта строка в самом начале файла <page-1.txt>
  if (counter_aad == 0 && $1 == "ALL_AVAILABLE_DROPDOWNS") {
     str_input_label_2 = $2
#     split(str_input_label_2, arr_input_label_2, ";")
     split(str_input_label_2, arr_dropdowns, ";")
     counter_aad = 1 # чтобы эту строку ALL_AVAILABLE_DROPDOWNS в <page-1.txt> искать только 1 раз
  }


  # формируем массив arr_for_str_input[] строк ввода данных из блока # I_DATA_S
  # I_DATA_S_!_wpressure_!_WP_!_Betriebsdruck [bar]:_!_*
  # I_DATA_S_!_wtemperature_!_WT_!_Betriebstemperatur [Grad C]:_!_02-99
  if ($1 == "I_DATA_S" && check_medium_in_ids(medium, $5)) {
     arr_for_str_input[counter_arr_for_str_input] = $2 ";" $3 ";" $4
     counter_arr_for_str_input++
  }


  # LABEL / OPTION для MEDIUM
  # M_01_!_Kühlschmierstoff (KSS)
  # M_01_!_LABEL_!_1_!_Angabe der vorhandenen/aktuellen Vorabscheidung:
  # M_01_!_OPTION_!_11_!_01. Zentrale Filteranlage oder anderer Filter (&lt; 120 µm)_!_12345_!_1.3;
  # M_01_!_OPTION_!_12_!_02. Feinspäneförderer oder Schlitzhülse oder Magnetabscheider (&lt; 2 mm)_!_1345_!_1.0
  if ($1 == fstr_medium) {  # fstr_medium = "M_01"
     if (str_medium == "")
        str_medium = $2
     else
        str_medium = str_medium "!!" $2 "::" $3 "::" $4
  }

  # нужно просто считать эту строку единственный раз
  # MIV = Medium Input Values
  # MIV_01_!_DSZ:1,2000,1;VSC:1,20,1;WP:1,10,0.1;WT:0,80,1;DP:1,16,1;DT:0,100,1;DPLINE:25,150,1;FS:10,100,5
  if (ffstr_ivalues == 0 && $1 == fstr_ivalues) {  # fstr_ivalues = "MIV_01"
    str_ivalues = $2
    ffstr_ivalues = 1
  }

  # формирование массива для дропдаунов типа
  # "materialel!!Gewünschtes Material Filterelement:!!1. Aluminium + Edelstahl!!2. Edelstahl "
  for (i=1; i<=length(arr_dropdowns); i++) {
    field1 = arr_dropdowns[i]
    if ($1 == field1) {
        if (arr_input_values_2[i] == "")
           arr_input_values_2[i] = $2 ";;" $3 ";;" $4
        else
           arr_input_values_2[i] = arr_input_values_2[i] "!!" $2 ";;" $3 ";;" $4
    }
  }

}


END {

#str_ivalues = MIV_02_!_DSZ:1,2000,10;WP:1,10,0.1;DP:1,16,1;FS:80,200,10_!_# остальные данные избыточны

if (comments == "ON") {
   print "<BR>str_input_label_2: "  str_input_label_2  >> result_txt
   print "<BR><i>Aquired data from page-1.txt:" >> result_txt
   for (i=1; i<=length(arr_for_str_input); i++)
      print "<BR>arr_for_str_input["i"]: " arr_for_str_input[i] >> result_txt
   print "<BR>str_ivalues: " str_ivalues  >> result_txt

   print "<p></p>Dropdown Arrays /// arr_input_values_2[i]: "  >> result_txt
   for (i=1; i<=length(arr_input_values_2); i++) {
     print "<BR>["i"]: " arr_input_values_2[i]  >> result_txt
   }

   print "</i><p></p>" >> result_txt
}

# вывод дропдаунов для МЕДИУМ
print_medium_options(medium,str_medium)

print "<input type=\"hidden\" name=\"medium\" value=\"" medium "\">\n"  >> result_txt
print "<input type=\"hidden\" name=\"comments\" value=\"" comments "\">\n"  >> result_txt

print "<p class=\"h4\">Betriebsdaten und Anforderungen:</p>" >> result_txt
# печать строкового ввода отдельных параметров
print_input_strings()

# печать дропдаунов
print_dropdown_newversion() # alle zusammen

# CHECKBOX for KSF in KSS Anwendung
if (medium == "01") { # KSS Anwendung
   print "<div class=\"form-check\">" >> result_txt
   print "  <input class=\"form-check-input border-primary\" type=\"checkbox\" name=\"ksf\" value=\"ON\" id=\"flexCheckDefault\">" >> result_txt
   print "  <label class=\"form-check-label\" for=\"flexCheckDefault\">Kantenspaltfilter berücksichtigen: (Ja / Nein):" >> result_txt
   print "  </label>" >> result_txt
   print "</div>" >> result_txt
} else
   print "<input type=\"hidden\" name=\"ksf\" value=\"ON\">"  >> result_txt

print "\n</ul><button type = \"Submit\" class=\"btn btn-primary btn-lg\"> SEND </button>"  >> result_txt
print "</form> "                                 >> result_txt
print "</div>" >> result_txt

} # END OF END


# печать бутстрап шапки
function print_bootstrap_head(page_header) {
print "<div class=\"container content\">"  >> result_txt
print "<div class=\"p-2 mb-2 bg-primary text-white\">"  >> result_txt
print page_header "</div>"  >> result_txt
print "<form action=\"/auslegung-2\" method=\"post\">"  >> result_txt
print "<ul class=\"list-group list-striped mb-3\">"  >> result_txt
return
}

# печать опций на анвендунг
function print_medium_options(medium,str_medium) {
kdo = 0  # переменная "в состоянии до"
split(str_medium, arr_str_medium, "!!")
medium_selected = arr_str_medium[1]
print "<p class=\"h4\">Medium: " medium_selected "</p>" >> result_txt
  for (i=2; i<=length(arr_str_medium); i++) {
      split(arr_str_medium[i], arr_option, "::")
      part1 = arr_option[1] # LABEL
      part2 = arr_option[2] # 1
      part3 = arr_option[3] # Angabe der Vorabscheidung

      if (part1 == "LABEL") {
         label_nr = part2
         if (kdo != 0) {  # до него уже был label, нужно закрыть тэги предыдущего дропдауна
            print "</select>" >> result_txt
            print "</div></div>"    >> result_txt  # Bootstrap
         } else
            kdo = 1

         mylabel = "label" label_nr
#         print "<div class=\"row mb-3 bg-secondary-subtle\">"  >> result_txt
         print "<div class=\"row mb-3\">"  >> result_txt
         print "  <label for=\"" mylabel "\" class=\"col-sm-3 col-form-label\">" part3 "</label>"   >> result_txt
         print "  <div class=\"col-sm-6\">"  >> result_txt
         print "    <select class=\"form-select border-primary\" name=\"" mylabel "\" id=\"" mylabel "\">"  >> result_txt

      } else {
         print "        <option value=\"" label_nr part2 "\">" part3 "</option>" >> result_txt
      }
  }

  print "    </select>" >> result_txt
  print "  </div>"    >> result_txt  # Bootstrap
  print " </div>"    >> result_txt  # Bootstrap
}

#  str_bparam = "DURCHSATZ:DSZ;VISCOSITY:VSC;WPRESSURE:WP;WTEMPERATURE:WT;DPRESSURE:DP;DTEMPERATURE:DT;DPIPELINE:DPLINE;FINENESS:FS"
#  str_ivalues = DSZ:1,2000;VSC:1,20;WP:1,10;WT:0,80;DP:1,16;DT:0,100;DPLINE:25,150;FS:10,100
#function update_bparam(str_bparam, str_ivalues) {
#   new_string = ""
#   split(str_bparam, arr_bparam, ";")
#   split(str_ivalues, arr_ivalues, ";")
#   for (i=1; i<=length(arr_bparam); i++) {
#      split(arr_bparam[i], arr_tmp1, ":")
#      param = arr_tmp1[1]
#      param_short = arr_tmp1[2]
#      for (k=1; k<=length(arr_ivalues); k++) {
#         split(arr_ivalues[k], arr_tmp2, ":")
#         if (arr_tmp2[1] == param_short) {
#            if (new_string == "")
#                new_string = param ":" arr_tmp2[2]
#            else {
#                new_string = new_string ";" param ":" arr_tmp2[2]
#                break
#            }
#         }
#      }
#   }
#  return new_string
#}

# Schmutzart und Schmutzeigenschaften
#function print_schmutzart(str_pvalues, str_s0x, h4_head, position, field_name) {
#  #  print "..........." str_s0x >> result_txt
#  print "<p class=\"h4\">"h4_head"</p>" >> result_txt
#  print "<div class=\"form-check\">" >> result_txt
#
#  split(str_s0x, arr_s01, "!!")
#  split(str_pvalues, arr_tmp1, "!!")
#  split(arr_tmp1[position], arr_tmp2, ",")
#
#  for (i=1; i<=length(arr_tmp2); i++) {
#
#     # значение содержит "МИНУС" от и до
#     if (arr_tmp2[i] ~ /-/) {
#        split(arr_tmp2[i], arr_tmp3, "-")
#        kmin = arr_tmp3[1] * 1
#        kmax = arr_tmp3[2] * 1
#
#        for (k=kmin; k<=kmax; k++) {
#           index_s01 = "0" k
#           if (k>=10)
#             index_s01 = k
#
#           for (j=1; j<=length(arr_s01); j++) {
#              split(arr_s01[j], arr_s01_tmp, "::")
#              if (arr_s01_tmp[1] == index_s01) {
#                 print_checkbox(index_s01,arr_s01_tmp[2],field_name)
#                 break
#              }
#           }
#        }
#     }
#
#     # значение звездочка
#     if (arr_tmp2[i] ~ /\*/) {
#       for (j=1; j<=length(arr_s01); j++) {
#          split(arr_s01[j], arr_s01_tmp, "::")
#          print_checkbox(index_s01,arr_s01_tmp[2],field_name)
#       }
#     }
#
#     # значение не содержит ни "МИНУС" ни ЗВЕЗДОЧКУ. Простое перечисление
#     if (arr_tmp2[i] !~ /\*/ && arr_tmp2[i] !~ /-/)  {
#        index_s01 = arr_tmp2[i]
#
#           for (j=1; j<=length(arr_s01); j++) {
#              split(arr_s01[j], arr_s01_tmp, "::")
#              if (arr_s01_tmp[1] == index_s01) {
#                 print_checkbox(index_s01,arr_s01_tmp[2],field_name)
#                 break
#              }
#           }
#
#     }
#  }
#  print "     </div>" >> result_txt
#}


#function print_checkbox(myid, mytext, myname) {
#   #  print "  <input class=\"form-check-input\" type=\"checkbox\" data-bs-theme=\"dark\" name=\"" myname "\" value=\"" myid "\" id=\"" myid "\">" >> result_txt
#  print "  <input class=\"form-check-input\" type=\"checkbox\" data-bs-theme=\"dark\" name=\"" myname"_"myid "\" value=\"" myid "\" id=\"flexCheckDefault\">" >> result_txt
#  print "     <label class=\"form-check-label \" for=\"" myid "\">" >> result_txt
#  print "        " mytext  >> result_txt
#  print "      </label><BR>" >> result_txt
#  return
#}


# проверяем, содержится ли medium = "01" в строке str_myrange = "02,04-06,usw."
function check_medium_in_ids(medium, str_myrange) {
   if (str_myrange ~ medium)
     return 1 # TRUE
   if (str_myrange ~ "*")
     return 1 # TRUE

   delete arr_myrange
   delete arr_tmp
   split(str_myrange, arr_myrange, ",")
   for (n=1; n<=length(arr_myrange); n++) {
     if (split(arr_myrange[n], arr_tmp, "-") > 1) {  # т.е. в серединке был минус "04-06"
        m_first = 1 * arr_tmp[1]
        m_last = 1 * arr_tmp[2]
        if (1 * medium < m_first)
            return 0 # FALSE

        for (m=m_first; m<=m_last; m++) {  # проходим по 04-06 т.е. 4, 5, 6
           mystr = m
           if (m<10)
             mystr = "0" m # достраиваем строку до двузначного числа
           if (mystr == medium)
             return 1 # TRUE
        }
     }
   }
   return 0 #  FALSE - не нашли
}

# из этого массива /// arr_for_str_input: durchsatz;DSZ;Durchsatz [Liter/Min]:
# а из этого пограничные величины str_ivalues = "DSZ:1,2000;VSC:1,20;WP:1,10;WT:0,80;DP:1,16;DT:0,100;DPLINE:25,150;FS:10,100"
function print_input_strings() {
  split(str_ivalues, arr_tmp, ";") # поделили на "DSZ:1,2000" "VSC:1,20"
  for (i=1; i<=length(arr_for_str_input); i++) {
     split(arr_for_str_input[i], arr_myhtml, ";")
     mylabel  = arr_myhtml[1]  # durchsatz
     my_code  = arr_myhtml[2]  # DSZ
     myheader = arr_myhtml[3]  # Durchsatz [Liter/Min]:

     for (k=1; k<=length(arr_tmp); k++) {
        split(arr_tmp[k], arr_tmp1, ":")  # "DSZ" "1,2000"

        if (arr_tmp1[1] == my_code) {     # "DSZ" == "DSZ"
          split(arr_tmp1[2], arr_tmp2, ",")
          min_value = arr_tmp2[1]
          max_value = arr_tmp2[2]
          step_value = arr_tmp2[3]

          default_value = min_value
          break
        }
     }

    print "<div class=\"row mb-3\">" >> result_txt
    print "   <label for=\"" mylabel "\" class=\"col-sm-3 col-form-label\">" myheader " " min_value "-" max_value "</label>" >> result_txt
    print "       <div class=\"col-sm-2\">" >> result_txt
    print "          <input type=\"number\" class=\"form-control border-primary\" name=\"" mylabel "\" min=\"" min_value "\" max=\"" max_value "\" step=\"" step_value "\" id=\"" mylabel "\" value=\"" default_value "\" required>" >> result_txt
    print "       </div>" >> result_txt
    print "</div>" >> result_txt

  }

}


# печатает дропдауны на основании считанной из <page-1.txt> $3="03,05-07"
# ANTRIEB_!_antrieb_!_03,05-07
# ANTRIEB_!_Der gewünschte Antrieb:_!_this is a HEAD for dropdowns
function print_dropdown_newversion() {
  for (i=1; i<=length(arr_input_values_2); i++) {
#    print "<BR>arr_input_values_2["i"] = " arr_input_values_2[i] >> result_txt
    split(arr_input_values_2[i], arr_my_str, "!!")

    # antrieb;;03,05-07  !!
    # Der gewünschte Antrieb:;;this is a HEAD for dropdowns  !!
    # 1;;1. Sterngriff / Handratsche!!7;;7. Pneumatischer Antrieb!!6;;6. Ohne Getriebemotor, jedoch mit Motorbock  !!

    split(arr_my_str[1],arr_my_str1,";;")
    # поделили строку "antrieb;;03,05-07" на "antrieb" и "03,05-07"

    if (check_medium_in_string(arr_my_str1[2]) == 0)  # т.е. в строке "03,05-07" нашего MEDIUM нету
        continue

#    split(arr_my_str[1],arr_my_str1,";;")
    mylabel = arr_my_str1[1]                       # mylabel = "antrieb"
    split(arr_my_str[2],arr_my_str1,";;")
    myheader = arr_my_str1[1]

    print "<div class=\"row mb-3\">"  >> result_txt
    print "  <label for=\"" mylabel "\" class=\"col-sm-3 col-form-label\">" myheader "</label>"   >> result_txt
    print "  <div class=\"col-sm-6\">"  >> result_txt
    print "    <select class=\"form-select border-primary\" name=\"" mylabel "\" id=\"" mylabel "\">"  >> result_txt

    j = 1  # selected
    for (i3=3; i3<=length(arr_my_str); i3++) {
       split(arr_my_str[i3],arr_arr_m,";;")
       myvalue = arr_arr_m[1]
       myoption = arr_arr_m[2]

       if (check_medium_in_string(arr_arr_m[3]) == 0)  # т.е. в строке "03,05-07" нашего MEDIUM нету
          continue

       print "        <option value=\"" myvalue "\" >" myoption "</option>" >> result_txt
    }

    print "      </select>" >> result_txt
    print "   </div>"    >> result_txt  # Bootstrap
    print "</div>"    >> result_txt  # Bootstrap

  }
}


# проверка наличия medium = "01" в строке типа "02-06,07,usw"
function check_medium_in_string(str_tmp) { # зашла строка "02-06,07,usw"
#  print "<BR> str_tmp: " str_tmp >> result_txt

  if (str_tmp ~ medium || str_tmp == "*")
     return "true"

  split(str_tmp, arr_str_tmp, ",")         # поделили нашу строку на "02-06" "07" "usw."
#  print "<BR> number of parts: "  split(str_tmp, arr_str_tmp, ",") >> result_txt

  for (i2=1; i2<=length(arr_str_tmp); i2++) {
     split(arr_str_tmp[i2], arr_func_tmp, "-")
#     print "<BR> arr_str_tmp["i2"] " arr_str_tmp[i2] >> result_txt

     minv = arr_func_tmp[1]
     maxv = arr_func_tmp[2]

#     print "<BR> minv: " minv " /// maxv:" maxv  >> result_txt


     for (i1=minv; i1<=maxv; i1++) {
       compare_value = i1
       if (i1<10)
          compare_value = "0" i1
       if (compare_value == medium) {
#         print "<BR> return TRUE"  >> result_txt
         return "true"
       }

     }
  }

#print "<BR> return FALSE"  >> result_txt
return 0
}
