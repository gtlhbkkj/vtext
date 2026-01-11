BEGIN {
  print "<pre>" >> errlog_txt
  print "-----------------------------------------------------------------------------" >> errlog_txt
  print mt "ERROR LOG FOR FILTER : " filter_name                                        >> errlog_txt
  print "-----------------------------------------------------------------------------" >> errlog_txt
  print "</pre>" >> errlog_txt

  RS = "\n"
  FS = "_!_"

# заходят
# medium


str_medium = str_ivalues = str_pvalues = ""
ffstr_ivalues = ffstr_pvalues = 0           # для поиска в теле. Если нашли то больше не ищем
# формируем поисковую строку для вывода доп опций по среде
fstr_medium = "M_" medium
fstr_ivalues = "MIV_" medium # MV = Medium Input Values
fstr_pvalues = "MPV_" medium # MPV = Medium Partikeln Values

# min="5.0" max="40.0" step="1" id="durchsatz" value="6" required>
str_bparam = "durchsatz:DSZ;viscosity:VSC;wpressure:WP;wtemperature:WT;dpressure:DP;dtemperature:DT;dpipeline:DPLINE;fineness:FS"
split(str_bparam, arr_input_label_1, ";")
for (i=1; i<=length(arr_input_label_1); i++) {
  arr_input_values_1[i] = ""
}

str_input_label_2 = "ANTRIEB;MATERIAL;MATERIALEL"
split(str_input_label_2, arr_input_label_2, ";")
for (i=1; i<=length(arr_input_label_2); i++) {
  arr_input_values_1[i] = ""
}

} # END OF BEGIN



# ТЕЛО
{
  # LABEL / OPTION для MEDIUM
  if ($1 == fstr_medium) {
     if (str_medium == "")
        str_medium = $2
     else
        str_medium = str_medium "!!" $2 "::" $3 "::" $4
  }

  if (ffstr_ivalues == 0 && $1 == fstr_ivalues) {
    str_ivalues = $2
    ffstr_ivalues = 1
  }

  if (ffstr_pvalues == 0 && $1 == fstr_pvalues) {
    str_pvalues = $2
    ffstr_pvalues = 1
  }

  # формирование массива типа "dpressure!!Auslegungsdruck [bar]:"
  for (i=1; i<=length(arr_input_label_1); i++) {
    split(arr_input_label_1[i], arr_tmp, ":")
    field1 = toupper(arr_tmp[1])

#    field1 = arr_input_label_1[i]
    if ($1 == field1) {
        if (arr_input_values_1[i] == "")
           arr_input_values_1[i] = $2
        else
           arr_input_values_1[i] = arr_input_values_1[i] "!!" $2
    }
  }

  # формирование массива для дропдаунов типа 
  # "materialel!!Gewünschtes Material Filterelement:!!1. Aluminium + Edelstahl!!2. Edelstahl "
  for (i=1; i<=length(arr_input_label_2); i++) {
    field1 = arr_input_label_2[i]
    if ($1 == field1) {
        if (arr_input_values_2[i] == "")
           arr_input_values_2[i] = $2
        else
           arr_input_values_2[i] = arr_input_values_2[i] "!!" $2
    }
  }


}


END {

#str_ivalues = MIV_01_!_DSZ:1,2000;VSC:1,20;WP:1,10;WT:0,80;DP:1,16;DT:0,100;DPLINE:25,150;FS:10,100
#str_pvalues = MPV_01_!_06,07_!_01_!_HIDDEN:HIDDEN
#str_bparam = "DURCHSATZ:DSZ;VISCOSITY:VSC;WPRESSURE:WP;WTEMPERATURE:WT;DPRESSURE:DP;DTEMPERATURE:DT;DPIPELINE:DPLINE;FINENESS:FS"
str_bparam = update_bparam(str_bparam, str_ivalues)

print_bootstrap_head("Filter Auslegung // Seite 2")
#print "\n\n\n\n\n" medium "\n\n\n\n\n" >> result_txt
#print "\n\n\n\n\n" str_bparam "\n\n\n\n\n" >> result_txt


print_medium_options(medium,str_medium)
print "<input type=\"hidden\" name=\"medium\" value=\"" medium "\">\n"  >> result_txt
#print_hidden_input(1, 10)

print "<h5>Betriebsdaten:</h5>"  >> result_txt

#print_dropdown(k=1) # 1 = MEDIUM
print_input(mystart=1, myend=4) # durchsaty, viscositz, wpressure, working temperature

print "<h5>Anforderungen zum Filter:</h5>" >> result_txt
print_input(mystart=5, myend=8) # dpressure, dtemperature, dpipeline, fineness


print_dropdown(k=1) # 2 = ANTRIEB

print_dropdown(k=2) # 3 = Filtermaterial
print_dropdown(k=3) # 4 = MAterial Element



print "</ul><button type = \"Submit\" class=\"btn btn-primary btn-lg\"> SEND </button>"  >> result_txt
print "</form> "                                 >> result_txt
print "</div>" >> result_txt
# print "</div></body></html>" >> result_txt

}


function print_dropdown(k) {
  my_str = arr_input_values_2[k]
  split(my_str, arr_my_str, "!!")
  split(arr_my_str[1],arr_my_str1,"__")
  mylabel = arr_my_str1[1]
  split(arr_my_str[2],arr_my_str1,"__")
  myheader = arr_my_str1[1]

  print "<div class=\"row mb-3\">"  >> result_txt
  print "  <label for=\"" mylabel "\" class=\"col-sm-3 col-form-label\">" myheader "</label>"   >> result_txt
  print "  <div class=\"col-sm-6\">"  >> result_txt
  print "    <select class=\"form-select\" id=\"" mylabel "\">"  >> result_txt

  j = 1  # selected
  for (i=3; i<=length(arr_my_str); i++) {
    split(arr_my_str[i],arr_arr_m,"__")

     myvalue =  arr_my_str[i]
     myoption = arr_arr_m[1]
     if (k != 1)  # MEDIUM
       myoption = substr(arr_arr_m[1],4)

     option_value = "selected"
     if (j != 1)
        option_value = "value"
     j = 2  # "value"

     print "<option " option_value "=\"" myvalue "\"   >" myoption "</option>" >> result_txt
  }
  print "</select>" >> result_txt
  print "</div></div>"    >> result_txt  # Bootstrap
}


function print_input(mystart, myend) {
  step_value = 0
  default_value = 0

  for (i=mystart; i<=myend; i++) {
     split(arr_input_values_1[i], arr_myhtml, "!!")

     mylabel  = arr_myhtml[1]
     myheader = arr_myhtml[2]

     split(str_bparam, arr_tmp, ";")
     for (k=1; k<=length(arr_tmp); k++) {
        split(arr_tmp[k], arr_tmp1, ":")
        split(arr_tmp1[2], arr_tmp2, ",")
        if (arr_tmp1[1] == mylabel) {
          min_value = arr_tmp2[1]
          max_value = arr_tmp2[2]
          default_value = min_value
          break
        }
     }

#     split(arr_input_label_1[i], arr_tmp, ":")
#     split(arr_tmp[2], arr_tmp1, ",")
#     min_value = arr_tmp1[1]
#     max_value = arr_tmp1[2]

    print "<div class=\"row mb-3\">" >> result_txt
    print "<label for=\"" mylabel "\" class=\"col-sm-3 col-form-label\">" myheader " " min_value "-" max_value "</label>" >> result_txt
    print "<div class=\"col-sm-2\">" >> result_txt
#    print "<input type=\"number\" class=\"form-control\" id=\"" mylabel "\" value=\"0\" required>" >> result_txt
    print "<input type=\"number\" class=\"form-control\" min=\"" min_value "\" max=\"" max_value "\" step=\"" step_value "\" id=\"" mylabel "\" value=\"" default_value "\" required>" >> result_txt

    print "</div></div>" >> result_txt

  }
}

function print_bootstrap_head(page_header) {
# print "<!DOCTYPE html><html><head><meta charset=\"utf-8\">"  >> result_txt
# print "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"  >> result_txt
# print "<title>Filter Auslegung</title>" >> result_txt
# print "<link href=\"https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css\" rel=\"stylesheet\" integrity=\"sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM\" crossorigin=\"anonymous\">" >> result_txt
# print "</head><body>" >> result_txt
print "<div class=\"container content\">"  >> result_txt
print "<div class=\"p-3 mb-2 bg-primary text-white\">"  >> result_txt
print page_header "</div>"  >> result_txt
print "<form action=\"/auslegung-1\" method=\"post\">"  >> result_txt
print "<ul class=\"list-group list-striped mb-3\">"  >> result_txt
return
}

function print_medium_options(medium,str_medium) {
kdo = 0  # переменная "в состоянии до"
split(str_medium, arr_str_medium, "!!")
medium_selected = arr_str_medium[1]
print "<h5>Medium: " medium_selected  "</h5>"   >> result_txt
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

#         print "<div class=\"row mb-3 bg-secondary-subtle\">"  >> result_txt
         print "<div class=\"row mb-3\">"  >> result_txt
         print "  <label for=\"" part1 part2 "\" class=\"col-sm-3 col-form-label\">" part3 "</label>"   >> result_txt
         print "  <div class=\"col-sm-6\">"  >> result_txt
         print "    <select class=\"form-select\" id=\"" part1 part2 "\">"  >> result_txt

      } else {
         print "<option value=\"" label_nr part2 "\">" part3 "</option>" >> result_txt
      }
  }

  print "</select>" >> result_txt
  print "</div></div>"    >> result_txt  # Bootstrap
}

function update_bparam(str_bparam, str_ivalues) {
   new_string = ""
#  str_bparam = "DURCHSATZ:DSZ;VISCOSITY:VSC;WPRESSURE:WP;WTEMPERATURE:WT;DPRESSURE:DP;DTEMPERATURE:DT;DPIPELINE:DPLINE;FINENESS:FS"
#  str_ivalues = DSZ:1,2000;VSC:1,20;WP:1,10;WT:0,80;DP:1,16;DT:0,100;DPLINE:25,150;FS:10,100
   split(str_bparam, arr_bparam, ";")
   split(str_ivalues, arr_ivalues, ";")
   for (i=1; i<=length(arr_bparam); i++) {
      split(arr_bparam[i], arr_tmp1, ":")
      param = arr_tmp1[1]
      param_short = arr_tmp1[2]
      for (k=1; k<=length(arr_ivalues); k++) {
         split(arr_ivalues[k], arr_tmp2, ":")
         if (arr_tmp2[1] == param_short) {
            if (new_string == "")
                new_string = param ":" arr_tmp2[2]
            else {
                new_string = new_string ";" param ":" arr_tmp2[2]
                break
            }
         }
      }
   }
  return new_string
}

