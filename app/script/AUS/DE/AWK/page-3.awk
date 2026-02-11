BEGIN {
  RS = "\n"
  FS = "_!_"

print_bootstrap_head("Filter Auslegung // Seite 3")


# заходит эта строка
# mystring="${medium};${mdd1};${mdd2};${mdd3};${mdd4};${durchsatz};${wpressure};${wtemperature};
# ${dpressure};${dtemperature};${dpipeline};${fineness};${antrieb};${material};${materialel};${comments};${ksf}"

#print "<BR>mystring: " mystring >> result_txt

##################### УНИВЕРСАЛЬНЫЙ ВАРИАНТ
arr_tmp[1] = ""
split(mystring,arr_tmp1,";")

for (i=1; i<=length(arr_tmp1); i++) {
   split(arr_tmp1[i],arr_tmp2,":")
   arr_tmp[arr_tmp2[1]] = arr_tmp2[2]
}


medium = arr_tmp["medium"]
mdd1 = arr_tmp["mdd1"]
mdd2 = arr_tmp["mdd2"]
mdd3 = arr_tmp["mdd3"]
mdd4 = arr_tmp["mdd4"]
durchsatz = arr_tmp["durchsatz"]
wpressure = arr_tmp["wpressure"]
wtemperature = arr_tmp["wtemperature"]
dpressure = arr_tmp["dpressure"]
dtemperature = arr_tmp["dtemperature"]
dpipeline = arr_tmp["dpipeline"]
fineness = arr_tmp["fineness"]
antrieb = arr_tmp["antrieb"]
material = arr_tmp["material"]
materialel = arr_tmp["materialel"]
comments = arr_tmp["comments"]
ksf = arr_tmp["ksf"]


#################### БОЛЕЕ ДУБОВЫЙ ВАРИАНТ

#split(mystring,arr_tmp,";")
#medium = arr_tmp[1]
#mdd1 = arr_tmp[2]
#mdd2 = arr_tmp[3]
#mdd3 = arr_tmp[4]
#mdd4 = arr_tmp[5]
#durchsatz = arr_tmp[6]
#wpressure = arr_tmp[7]
#wtemperature = arr_tmp[8]
#dpressure = arr_tmp[9]
#dtemperature = arr_tmp[10]
#dpipeline = arr_tmp[11]
#fineness = arr_tmp[12]
#antrieb = arr_tmp[13]
#material = arr_tmp[14]
#materialel = arr_tmp[15]
#comments = arr_tmp[16]
#ksf = arr_tmp[17]

#######################   END ##################



faktor_fineness = 1
# default - после считывания из <page-1.txt> может измениться
# if (fineness <= 20 µm)  faktor_fineness = 0.8
# RSF_FAKTOR_FINENESS_!_20_!_0.8
# передать его в строке дальше в page-31.awk !!!!!!!!!!!!!!!!!!!!!!!!!!!!!

str_medium = str_ivalues = str_pvalues = str_s01 = str_s02 = ""
ffstr_ivalues = ffstr_pvalues = 0           # для поиска в теле. Если нашли то больше не ищем
# формируем поисковую строку для вывода доп опций по среде
fstr_medium = "M_" medium
fstr_ivalues = "MIV_" medium # MV = Medium Input Values
fstr_pvalues = "MPV_" medium # MPV = Medium Partikeln Values

counter_mwp = 0              # max. working pressure
counter_get_str_ftype = 0     # забор str_ftype ="2,3,4,5"

} # END OF BEGIN



# ТЕЛО
{

  # берем строку описания материала фильтра и внутренностей - только для вывода текста
  if ($1 == "MATERIAL" && $2 == material)
     fmaterial = substr($3,4)

  # берем строку описания материала прокладок и втулок - только для вывода текста
  if ($1 == "MATERIAL_DICHTUNGEN")
     str_material_dichtungen = $2

  # min_working_pressure в <page-1.txt> находится выше чем str_ftype
  if (counter_mwp == 0 && $1 == "MIN_WP_FOR_EIGENDRUCK") {
     counter_mwp = 1
     min_working_pressure = $2
  }


  # отбираем подходящие RSF исходя из рабочего давления
  # LIST OF RSF FILTERS
  # $2 – FULL LIST /// $3 – working pressure < MIN_WP_FOR_EIGENDRUCK
  # LIST_OF_RSF_FILTERS_!_2,3,4,5_!_4,5
  if (counter_get_str_ftype == 0 && $1 == "LIST_OF_RSF_FILTERS") {
     counter_get_str_ftype = 1
     str_ftype = $2
     if (wpressure < min_working_pressure)
        str_ftype = $3
  }

  #  MEDIUM  - только для вывода текста
  if ($1 == "MEDIUM" && $2 == medium) {
     medium_txt = $3
     medium_el = $4
  }

  # для вывода текста + фактор
  if ($1 == "M_01" && $2 == "OPTION" && $3 == substr(mdd1,2,2)) {
     label1_txt = $4
     eignung1 = $5
     faktor1 = $6
  }

  # для вывода текста + фактор
  if ($1 == "M_01" && $2 == "OPTION" && $3 == substr(mdd2,2,2)) {
     label2_txt = $4
     eignung2 = $5
     faktor2 = $6
     viscosity = $7
  }

  # для вывода текста + фактор
  if ($1 == "M_01" && $2 == "OPTION" && $3 == substr(mdd3,2,2)) {
     label3_txt = $4
     eignung3 = $5
     faktor3 = $6
  }

  # для вывода текста + фактор
  if ($1 == "M_01" && $2 == "OPTION" && $3 == substr(mdd4,2,2)) {
     label4_txt = $4
     eignung4 = $5
     faktor4 = $6
  }

  # получаем фактор тонкости фильтрации
  if ($1 == "RSF_FAKTOR_FINENESS") {
    rsf_fk_fineness = $2 ":" $3
    if (fineness <= $2)
      faktor_fineness = $3
  }

}


END {

if (fmaterial == "")
  print "<BR><b>Error. Description for filter material " material " NOT FOUND in page-1.txt" >> result_txt


# расчет минимального фактора и расчетного расхода
# расчетный расход равен или минимальному фактору (если он меньше 
min_faktor = calculate_min_faktor(faktor1, faktor2, faktor3, faktor4, faktor_fineness)
durchsatz_calc = durchsatz / (faktor1 * faktor2 * faktor3 * faktor4 * faktor_fineness)
durchsatz_calc = int(durchsatz_calc*10+0.5)/10
if (faktor1* faktor2* faktor3* faktor4* faktor_fineness < 0.5)
   durchsatz_calc = int(durchsatz / min_faktor)

print_input_data()

# это константная строка - те типы RSF фильтров которые вообще существуют
# фильтруем их по параметрам EIGNUNG из dropdown для передачи в следующий скрипт
# str_ftype ="2,3,4,5"
delete arr_tmp
split(str_ftype,arr_tmp,",")
for (i=1; i<=length(arr_tmp); i++) {
#   print "<BR>arr_tmp[i]:" arr_tmp[i] "/// eignung1:" eignung1 "/// eignung2:" eignung2 "/// eignung3:"eignung3 " /// eignung4:" eignung4 >> result_txt
   if (eignung1 ~ arr_tmp[i] && eignung2 ~ arr_tmp[i] && eignung3 ~ arr_tmp[i] && eignung4 ~ arr_tmp[i]) {
      if (str_ftype_new == "")
         str_ftype_new = arr_tmp[i]
      else
         str_ftype_new = str_ftype_new "," arr_tmp[i]
   }
}

#print "<BR>str_ftype: " str_ftype >> result_txt
#print "<BR>eignung1:" eignung1 "/// eignung2:" eignung2 "/// eignung3:"eignung3 " /// eignung4:" eignung4 >> result_txt
#print "str_ftype_new:" str_ftype_new >> result_txt


s_ret = "FTYPE::" str_ftype_new "_!_DSZ::" durchsatz_calc "_!_FS::" fineness "_!_VS::" viscosity
s_ret = s_ret "_!_MAT::" material "_!_DSZO::" durchsatz "_!_COMM::" comments "_!_KSF::" ksf
string_return = s_ret "_!_MED::" medium "_!_FKF::" rsf_fk_fineness

if (comments == "ON") {
  print "<BR><i>INPUT DATA from WEB page (mystring): "  mystring >> result_txt
  print "<BR>mystring=${medium};${mdd1};${mdd2};${mdd3};${mdd4};${durchsatz};${wpressure};${wtemperature};${dpressure};${dtemperature};${dpipeline};${fineness};${antrieb};${material};${materialel};${comments};${ksf}"  >> result_txt
  print "<BR>parameters for page-31.awk (string_return): "  string_return >> result_txt
  print "<BR><b>--------- End of page-3.awk ----------------</b></i><BR>"  >> result_txt
}

print string_return
}



function print_bootstrap_head(page_header) {
print "<div class=\"container content\">"  >> result_txt
print "<div class=\"p-2 mb-2 bg-primary text-white\">"  >> result_txt
print page_header "</div>"  >> result_txt
#print "<ul class=\"list-group list-striped mb-3\">"  >> result_txt
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
print "<td>"fmaterial"</td><td>" str_material_dichtungen "</td></tr>" >> result_txt



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
