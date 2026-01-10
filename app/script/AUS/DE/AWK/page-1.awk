BEGIN {
  print "<pre>" >> errlog_txt
  print "-----------------------------------------------------------------------------" >> errlog_txt
  print "ERROR LOG FILTER AUSLEGUNG : "                                                 >> errlog_txt
  print "-----------------------------------------------------------------------------" >> errlog_txt
  print "</pre>" >> errlog_txt

  RS = "\n"
  FS = "_!_"

str_medium = ""

# DROPDOWNS
# str_input_label_2 = "MEDIUM;ANTRIEB;MATERIAL;MATERIALEL"
str_input_label_2 = "MEDIUM"
split(str_input_label_2, arr_input_label_2, ";")
for (i=1; i<=length(arr_input_label_2); i++) {
  arr_input_values_2[i] = ""
}

} # END OF BEGIN



# ТЕЛО
{

  # DROPDOWNS
  for (i=1; i<=length(arr_input_label_2); i++) {
    field1 = arr_input_label_2[i]                  # field1 = "MEDIUM"
    if ($1 == field1) {
        if (arr_input_values_2[i] == "")
           arr_input_values_2[i] = $2              # $2 = "medium"
        else
           arr_input_values_2[i] = arr_input_values_2[i] "!!" $2 "::" $3 # "medium!!01::01. Kühlschmierstoff (KSS)"
    }
  }


}


END {

# MEDIUM


print_bootstrap_head("Auslegung Seite 1")

print "<h4>Betriebsdaten:</h4>" >> result_txt

print_dropdown(k=1) # 1 = MEDIUM

print "</ul><button type = \"Submit\" class=\"btn btn-primary btn-lg\"> SEND </button>"  >> result_txt
print "</form> "                                 >> result_txt
print "</div>" >> result_txt
print "</div></body></html>" >> result_txt

}


function print_dropdown(k) {
  my_str = arr_input_values_2[k]
  split(my_str, arr_my_str, "!!")
  mylabel = arr_my_str[1]              # "medium"
  split(arr_my_str[2], arr_tmp, "::")
  myheader = arr_tmp[1]                # "Das zu filtrierende Medium angeben:"

  print "<div class=\"row mb-3\">"  >> result_txt
  print "  <label for=\"" mylabel "\" class=\"col-sm-3 col-form-label\">" myheader "</label>"   >> result_txt
  print "  <div class=\"col-sm-4\">"  >> result_txt
  print "    <select class=\"form-select\" id=\"" mylabel "\" name=\"" mylabel "\">"  >> result_txt

  j = 1  # selected
  for (i=3; i<=length(arr_my_str); i++) {
    split(arr_my_str[i],arr_tmp,"::")

     myvalue =  arr_tmp[1]    # "01"
     myoption = arr_tmp[2]    # "01. Kühlschmierstoff (KSS)"

#     option_value = "selected"
#     if (j != 1)
#        option_value = "value"
#     j = 2  # "value"

#     print "<option" option_value "=\"" myvalue "\"   >" myoption "</option>" >> result_txt
     print "<option value=\"" myvalue "\">" myoption "</option>" >> result_txt
  }
  print "</select>" >> result_txt
  print "</div></div>"    >> result_txt  # Bootstrap
}

function print_bootstrap_head(head_of_page) {
# print "<!DOCTYPE html><html><head><meta charset=\"utf-8\">"  >> result_txt
# print "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"  >> result_txt
# print "<title>Filter Auslegung</title>" >> result_txt
# print "<link href=\"https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css\" rel=\"stylesheet\" integrity=\"sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM\" crossorigin=\"anonymous\">" >> result_txt
# print "</head><body>" >> result_txt
print "<div class=\"container content\">"  >> result_txt
print "<div class=\"p-3 mb-2 bg-primary text-white\">"  >> result_txt
print head_of_page "</div>"  >> result_txt
print "<form action=\"/auslegung-1\" method=\"post\">"  >> result_txt
print "<ul class=\"list-group list-striped mb-3\">"  >> result_txt
return
}
