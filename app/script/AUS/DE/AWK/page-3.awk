BEGIN {
  RS = "\n"
  FS = "_!_"

# это константная строка - те типы RSF фильтров которые вообще существуют
# фильтруем их в хвосте по параметрам EIGNUNG из dropdown для передачи в следующий скрипт

# заходит эта строка
#mystring="${medium};${mdd1};${mdd2};${mdd3};${mdd4};${durchsatz};${wpressure};${wtemperature};${dpressure};${dtemperature};${dpipeline};${fineness};${antrieb};${material};${materialel}"
split(mystring,arr_tmp,";")
medium = arr_tmp[1]
mdd1 = arr_tmp[2]
mdd2 = arr_tmp[3]
mdd3 = arr_tmp[4]
mdd4 = arr_tmp[5]
durchsatz = arr_tmp[6]
wpressure = arr_tmp[7]
wtemperature = arr_tmp[8]
dpressure = arr_tmp[9]
dtemperature = arr_tmp[10]
dpipeline = arr_tmp[11]
fineness = arr_tmp[12]
antrieb = arr_tmp[13]
material = arr_tmp[14]
materialel = arr_tmp[15]

faktor_fineness = 1  # default

str_medium = str_ivalues = str_pvalues = str_s01 = str_s02 = ""
ffstr_ivalues = ffstr_pvalues = 0           # для поиска в теле. Если нашли то больше не ищем
# формируем поисковую строку для вывода доп опций по среде
fstr_medium = "M_" medium
fstr_ivalues = "MIV_" medium # MV = Medium Input Values
fstr_pvalues = "MPV_" medium # MPV = Medium Partikeln Values

counter_mwp = 0              # max. working pressure
counter_get_str_ftype = 0     # забор str_ftype ="2,3,4,5"

str_material_dichtungen = "Material Dichtungen: FPM und Lager: PTFE"
arr_fmaterial[1] = "Gehäuse und Deckel GGG, Innenteile C-Stahl"
arr_fmaterial[2] = "Gehäuse und Deckel 1.4581, Innenteile 1.4571"
arr_fmaterial[3] = "Gehäuse und Deckel Stahl GG oder GGG, Innenteile Edelstahl 1.4301/1.4571"


} # END OF BEGIN



# ТЕЛО
{

  # min_working_pressure в <page-1.txt> находится выше чем str_ftype
  if (counter_mwp == 0 && $1 == "MIN_WP_FOR_EIGENDRUCK") {
     counter_mwp = 1
     min_working_pressure = $2
  }

  if (counter_get_str_ftype == 0 && $1 == "LIST_OF_RSF_FILTERS") {
     counter_get_str_ftype = 1
     str_ftype = $2
     if (wpressure < min_working_pressure)
        str_ftype = $3
  }


  #  MEDIUM
  if ($1 == "MEDIUM" && $2 == medium) {
     medium_txt = $3
     medium_el = $4
  }

  if ($1 == "M_01" && $2 == "OPTION" && $3 == substr(mdd1,2,2)) {
     label1_txt = $4
     eignung1 = $5
     faktor1 = $6
  }
  if ($1 == "M_01" && $2 == "OPTION" && $3 == substr(mdd2,2,2)) {
     label2_txt = $4
     eignung2 = $5
     faktor2 = $6
     viscosity = $7
  }

  if ($1 == "M_01" && $2 == "OPTION" && $3 == substr(mdd3,2,2)) {
     label3_txt = $4
     eignung3 = $5
     faktor3 = $6
  }
  if ($1 == "M_01" && $2 == "OPTION" && $3 == substr(mdd4,2,2)) {
     label4_txt = $4
     eignung4 = $5
     faktor4 = $6
  }

  if ($1 == "RSF_FAKTOR_FINENESS") {
    if (fineness <= $2)
      faktor_fineness = $3
  }


}


END {

# расчет минимального фактора и расчетного расхода
# расчетный расход равен или минимальному фактору (если он меньше 
min_faktor = calculate_min_faktor(faktor1, faktor2, faktor3, faktor4, faktor_fineness)
durchsatz_calc = int(durchsatz / (faktor1 * faktor2 * faktor3 * faktor4 * faktor_fineness))
if (faktor1* faktor2* faktor3* faktor4* faktor_fineness < 0.5)
   durchsatz_calc = int(durchsatz / min_faktor)

print_bootstrap_head("Filter Auslegung // Seite 3")
print_input_data()

# это константная строка - те типы RSF фильтров которые вообще существуют
# фильтруем их по параметрам EIGNUNG из dropdown для передачи в следующий скрипт
# str_ftype ="2,3,4,5"
split(str_ftype,arr_tmp,",")
for (i=1; i<=length(arr_tmp); i++) {
   if (eignung1 ~ arr_tmp[i] && eignung2 ~ arr_tmp[i] && eignung3 ~ arr_tmp[i] && eignung4 ~ arr_tmp[i]) {
      if (str_ftype_new == "")
         str_ftype_new = arr_tmp[i]
      else
         str_ftype_new = str_ftype_new "," arr_tmp[i]
   }
}
##############################
string_return = "FTYPE::" str_ftype_new "_!_DSZ::" durchsatz_calc "_!_FS::" fineness "_!_VS::" viscosity "_!_MAT::" material "_!_DSZO::" durchsatz
print string_return
}



function print_bootstrap_head(page_header) {
# print "<!DOCTYPE html><html><head><meta charset=\"utf-8\">"  >> result_txt
# print "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"  >> result_txt
# print "<title>Filter Auslegung</title>" >> result_txt
# print "<link href=\"https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css\" rel=\"stylesheet\" integrity=\"sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM\" crossorigin=\"anonymous\">" >> result_txt
# print "</head><body>" >> result_txt
print "<div class=\"container content\">"  >> result_txt
print "<div class=\"p-2 mb-2 bg-primary text-white\">"  >> result_txt
#print "<p class=\"h4\">"page_header"</p></div>" >> result_txt
print page_header "</div>"  >> result_txt
#print "<form action=\"/auslegung-2\" method=\"post\">"  >> result_txt
print "<ul class=\"list-group list-striped mb-3\">"  >> result_txt
return
}

# печать всех введенных данных
function print_input_data() {
#print "medium = " arr_tmp[1] "<BR>"  >> result_txt
#print "mdd1 = "arr_tmp[2] "<BR>" >> result_txt
#print "mdd2 = "arr_tmp[3] "<BR>" >> result_txt
#print "mdd3 = "arr_tmp[4] "<BR>" >> result_txt
#print "mdd4 = "arr_tmp[5] "<BR>">> result_txt
#print "durchsatz = " arr_tmp[6] "<BR>" >> result_txt
#print "wpressure = "arr_tmp[7] "<BR>" >> result_txt
#print "wtemperature = "arr_tmp[8] "<BR>" >> result_txt
#print "dpressure = "arr_tmp[9] "<BR>">> result_txt
#print "dtemperature = "arr_tmp[10] "<BR>" >> result_txt
#print "dpipeline = "arr_tmp[11] "<BR>">> result_txt
#print "fineness = "arr_tmp[12] "<BR>" >> result_txt
#print "antrieb = "arr_tmp[13] "<BR>" >> result_txt
#print "material = "arr_tmp[14] "<BR>">> result_txt
#print "materialel = "arr_tmp[15] "<BR>" >> result_txt


print "<table class=\"table table-striped\">" >> result_txt
print "<thead><tr><th scope=\"col\">Parameter</th>"  >> result_txt
print "<th scope=\"col\">Value</th>" >> result_txt
print "<th scope=\"col\">Addit.values</th></tr></thead>"  >> result_txt
print "<tbody>" >> result_txt

print "<tr><td>Medium:</td>" >> result_txt
print "<td>"medium_txt"</td>" >> result_txt
print "<td>("medium_el")</td></tr>" >> result_txt

print "<tr><td>Vorabscheidung:</td>" >> result_txt
print "<td>" label1_txt "</td>" >> result_txt
print "<td>(Eignung:"eignung1"//F2:"faktor1")</td></tr>" >> result_txt

print "<tr><td>Kühlmittelmedium:</td>" >> result_txt
print "<td>" label2_txt "</td>" >> result_txt
print "<td>(Eignung:"eignung2"//F2:"faktor2"//V:"viscosity"[cSt])</td></tr>" >> result_txt

print "<tr><td>Art der Metallbearbeitung:</td>" >> result_txt
print "<td>" label3_txt "</td>" >> result_txt
print "<td>(Eignung:"eignung3"//F2:"faktor3")</td></tr>" >> result_txt

print "<tr><td>Art des zubearbeitendes Metalls:</td>" >> result_txt
print "<td>" label4_txt "</td>" >> result_txt
print "<td>(Eignung:"eignung4"//F2:"faktor4")</td></tr>" >> result_txt

print "<tr><td>Gewünschte Feinheit:</td>" >> result_txt
print "<td>" fineness " [µm]</td><td>FF:"faktor_fineness" (Faktor Feinheit)</td></tr>" >> result_txt

print "<tr><td>Durchsatz (input):</td>" >> result_txt
print "<td>" durchsatz " [LPM] / input data</td><td>" durchsatz_calc" [LPM] / calculated</td></tr>" >> result_txt

print "<tr><td>Betriebsdruck:</td>" >> result_txt
print "<td>" wpressure " [bar]</td><td>" min_working_pressure" [bar] / Min. für Eigendruck </td></tr>" >> result_txt

print "<tr><td>Filter Material:</td>" >> result_txt
print "<td>"arr_fmaterial[material]"</td><td>" str_material_dichtungen "</td></tr>" >> result_txt



print "</tbody></table>" >> result_txt

}

function calculate_min_faktor(faktor1, faktor2, faktor3, faktor4, faktor_fineness) {
  arr_faktor[1] = faktor1
  arr_faktor[2] = faktor2
  arr_faktor[3] = faktor3
  arr_faktor[4] = faktor4
  arr_faktor[5] = faktor_fineness

  min_faktor = arr_faktor[1] # Инициализируем минимумом первый элемент
    for (i = 2; i <= length(arr_faktor); i++) { # Проходим с второго элемента
      if (arr_faktor[i] < min_faktor) {
        min_faktor = arr_faktor[i]
      }
    }
  return min_faktor
}
