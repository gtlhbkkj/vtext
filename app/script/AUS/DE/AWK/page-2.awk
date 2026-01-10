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


str_medium = ""
# формируем поисковую строку для вывода доп опций по среде
fstr_medium = "M_" medium

# min="5.0" max="40.0" step="1" id="durchsatz" value="6" required>

str_input_label_1 = "DURCHSATZ:1,2000,0,100;VISCOSITY:1,50000,0,20;WPRESSURE:1,400,0,16;WTEMPERATURE:0,200,0,100;DPRESSURE:1,400,0,16;DTEMPERATURE:0,200,0,100;DPIPELINE:25,150,0,50;FINENESS:10,3000,0,50;UTEMPERATURMIN:0,50,0,25;UTEMPERATURMAX:0,60,0,25"
#str_input_label_1 = "DURCHSATZ;VISCOSITY;WPRESSURE;WTEMPERATURE;DPRESSURE;DTEMPERATURE;DPIPELINE;FINENESS;UTEMPERATURMIN;UTEMPERATURMAX"
split(str_input_label_1, arr_input_label_1, ";")
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


  if ($1 == "GENERAL_LIMITS")
     gen_limits_hidden = $2


  for (i=1; i<=length(arr_input_label_1); i++) {
    split(arr_input_label_1[i], arr_tmp, ":")
    field1 = arr_tmp[1]

#    field1 = arr_input_label_1[i]
    if ($1 == field1) {
        if (arr_input_values_1[i] == "")
           arr_input_values_1[i] = $2
        else
           arr_input_values_1[i] = arr_input_values_1[i] "!!" $2
    }
  }

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


print_bootstrap_head("Filter Auslegung // Seite 2")

print "\n\n\n\n\n" medium "\n\n\n\n\n" >> result_txt
print "\n\n\n\n\n" str_medium "\n\n\n\n\n" >> result_txt
#print_medium_options(medium,str_medium)

print "<input type=\"hidden\" name=\"medium\" value=\"" medium "\">\n"  >> result_txt
print_hidden_input(1, 10)

print "<h4>Betriebsdaten:</h4>"  >> result_txt

#print_dropdown(k=1) # 1 = MEDIUM
print_input(mystart=1, myend=4) # durchsaty, viscositz, wpressure, working temperature

print "<h4>Anforderungen zum Filter:</h4>" >> result_txt
print_input(mystart=5, myend=8) # dpressure, dtemperature, dpipeline, fineness


print_dropdown(k=1) # 2 = ANTRIEB
print_input(mystart=9, myend=10) # utempmin, utempmax

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
  print "  <div class=\"col-sm-4\">"  >> result_txt
  print "    <select class=\"form-select\" id=\"" mylabel "\">"  >> result_txt


# жто было без бутстрапа
#  print "<label for=\"" mylabel "\">" myheader "</label>"           >> result_txt
#  print "<select id=\"" mylabel "\" name=\"" mylabel "\">"          >> result_txt
# ----------------------

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
  for (i=mystart; i<=myend; i++) {
     split(arr_input_values_1[i], arr_myhtml, "!!")
     mylabel  = arr_myhtml[1]
     myheader = arr_myhtml[2]

     split(arr_input_label_1[i], arr_tmp, ":")
     split(arr_tmp[2], arr_tmp1, ",")
     min_value = arr_tmp1[1]
     max_value = arr_tmp1[2]
     step_value = arr_tmp1[3]
     default_value = arr_tmp1[4]


    print "<div class=\"row mb-3\">" >> result_txt
    print "<label for=\"" mylabel "\" class=\"col-sm-3 col-form-label\">" myheader "</label>" >> result_txt
    print "<div class=\"col-sm-2\">" >> result_txt
#    print "<input type=\"number\" class=\"form-control\" id=\"" mylabel "\" value=\"0\" required>" >> result_txt
    print "<input type=\"number\" class=\"form-control\" min=\"" min_value "\" max=\"" max_value "\" step=\"" step_value "\" id=\"" mylabel "\" value=\"" default_value "\" required>" >> result_txt

    print "</div></div>" >> result_txt

#             <input type="number" class="form-control" min="5.0" max="40.0" step="1" id="durchsatz" value="6" required>


#     print "<BR><label for=\"" mylabel "\">" myheader "</label>"  >> result_txt
#     print "<input type=\"number\" id=\""mylabel "\" name=\"" mylabel "\" placeholder=\"0\">\n"  >> result_txt
  }
}

function print_hidden_input(mystart, myend) {
  for (i=mystart; i<=myend; i++) {
     split(arr_input_values_1[i], arr_myhtml, "!!")
     mylabel  = arr_myhtml[1]
     myheader = arr_myhtml[2]
     printf "<input type=\"hidden\" name=\"" mylabel "_t" "\" value=\"" myheader "\">\n"  >> result_txt
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
split(str_medium, arr_str_medium, "!!")
medium_selected = arr_str_medium[1]
print "<h4>Medium: " medium_selected  "<h4>"   >> result_txt

#  for (i=2; length(arr_str_medium); i++) {
#      split(arr_str_medium, arr_option, "::")
#      str_label = arr_option[1]
#      print str_label  "<BR>"   >> result_txt

#      for (i=2; length(arr_option); i++) {
#         print  arr_option[i] "<BR>"  >> result_txt
#
#      }
#  }

}
