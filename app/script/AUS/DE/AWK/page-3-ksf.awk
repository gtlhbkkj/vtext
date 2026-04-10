# page-3-ksf.awk
# page-1.txt
# flowrate.txt
# fe-code.txt
# fe-pos.txt

BEGIN {
  RS = "\n"
  FS = "_!_"


print_bootstrap_head("Filter Auslegung KSF // Seite 3")

# для аппроксимации расхода от вязкости
# procent_viscosity = smoothing_factor * (viscosity - viscosity1) / (viscosity2 - viscosity1)  # 0.8
smoothing_factor = 0.8
# если он равен нулю то зависимость прямая линия
# если он равен 1 то зависимость возможно сильно крутое скругление
# при необходимости вывести его в текстовый файл для кажд анвендунга

# заходит эта строка
# mystring="${medium};${mdd1};${mdd2};${mdd3};${mdd4};${durchsatz};${wpressure};${wtemperature};
# ${dpressure};${dtemperature};${dpipeline};${fineness};${antrieb};${material};${materialel};${comments};${ksf}"

# поступает в виде переменной
# json_data: label1:111,medium:02,comments:ON,durchsatz:100,wpressure:3,dpressure:3,fineness:80,material:1,materialel:1,ksf:ON 
gsub(/[^a-zA-Z0-9:,]/, "", json_data)

delete arr_main; delete arr_tmp1; delete arr_tmp2;
split(json_data, arr_tmp1, ",")

for (i=1; i<=length(arr_tmp1); i++) {
   split(arr_tmp1[i],arr_tmp2,":")
   arr_main[arr_tmp2[1]] = arr_tmp2[2]
}


# порядок вывода на печать
str_no_of_elements = "1,2,3,6,9,12,18,24,36,48"  # для всех одинаково
#str_no_of_elements = "1:400,2:800,3:1000,6:2400,9:2400,12:2400,18:3600,24:3800,36:3800,48:3800"  # для всех одинаково

str_to_print = "medium,mdd1,mdd2,mdd3,mdd4,viscosity,durchsatz,durchsatz_c,fineness,wpressure,dpressure,wtemperature,"
str_to_print = str_to_print "dtemperature,antrieb,material,materialel,elements,atex,kategorie"

medium = arr_main["medium"]
mdd1 = arr_main["label1"]
mdd2 = arr_main["label2"]
mdd3 = arr_main["label3"]
mdd4 = arr_main["label4"]
durchsatz = arr_main["durchsatz"]
wpressure = arr_main["wpressure"]
wtemperature = arr_main["wtemperature"]
dpressure = arr_main["dpressure"]
dtemperature = arr_main["dtemperature"]
dpipeline = arr_main["dpipeline"]
fineness = arr_main["fineness"]
viscosity = arr_main["viscosity"]
antrieb = arr_main["antrieb"]
material = arr_main["material"]
materialel = arr_main["materialel"]
comments = arr_main["comments"]
ksf = arr_main["ksf"]
atex = arr_main["atex"]


str_medium = str_ivalues = str_pvalues = str_s01 = str_s02 = ""
ffstr_ivalues = ffstr_pvalues = 0           # для поиска в теле. Если нашли то больше не ищем
# формируем поисковую строку для вывода доп опций по среде
field_medium_label_options = "M_" medium
#fstr_ivalues = "MIV_" medium # MV = Medium Input Values
#fstr_pvalues = "MPV_" medium # MPV = Medium Partikeln Values

#counter_mwp = 0              # max. working pressure
#counter_get_str_ftype = 0     # забор str_ftype ="2,3,4,5"

# факторы расхода по дефолту находятся в <page-1.txt> в конце опций по анвендунгу mdd1 ... mdd4
fk1 = fk2 = fk3 = fk4 = 1.0
# прочие вакторы, если они будут

# counters
c_medium = c_antrieb = c_material = c_materialel = c_arr_flowrate = c_el_used_in_flowrate = 0
delete arr_flowrate

str_elements = str_elements_tmp = "" # строка для подходящих фильтроэлементов
str_flowrate = "" # для сохранения расходов из <flowrate.txt>
toleranz_viscosity = 1.0 # default value
toleranz_fineness = 1.0 # default value
#my_regexp = "^[E][1][1-2][4][5-6].[2].[0]"
delete arr_all_elements;

} # END OF BEGIN



# ТЕЛО
# в теле cобираем массив arr_to_p[] для красивого вывода на печать
# и недостающие переменные типа viscosity, kategorie, atex, antrieb, elements, faktor1, usw.
{
  # scan <page-1.txt>
  if ($1 == "TOLERANZ_VISCOSITY")
     toleranz_viscosity = $2

  if ($1 == "TOLERANZ_FINENESS")
     toleranz_fineness = $2

  if ($1 == "MEDIUM" && $2 != "medium" && c_medium == 0) {
    arr_to_p["medium"] = $2
    c_medium = 1
  }

  if ($1 == "MEDIUM" && $2 == medium) {
    arr_to_p["medium"] = arr_to_p["medium"] ";" substr($3,4)
    str_other_parameters = $4

    delete arr_tmp; delete arr_tmp1; delete arr_tmp2;
    split(str_other_parameters, arr_tmp1, ";")

    for (i=1; i<=length(arr_tmp1); i++) {
      split(arr_tmp1[i],arr_tmp2,":")
      if (arr_tmp2[1] == "antrieb")
         antrieb = arr_tmp2[2]
      if (arr_tmp2[1] == "viscosity")
         viscosity = arr_tmp2[2]
      if (arr_tmp2[1] == "elements") {
         elements = my_regexp = arr_tmp2[2]
         sub("MATERIAL", materialel, my_regexp) # заменияет "MATERIAL" на "1" или "2"
      }
      # dkb_offl:ON /// Durchsatz Kalkulation - Offene Filter Betrachten : 
      # ON = YES, OFF = общая площадь поверхности играет роль
      if (arr_tmp2[1] == "dkb_offl")
         dkb_offl = arr_tmp2[2]
      if (arr_tmp2[1] == "dpm_g1")
         dpm_g1 = arr_tmp2[2]
    }
  }

  if ($1 == "ANTRIEB" && $2 != "antrieb" && c_antrieb == 0 && antrieb != "") {
    arr_to_p["antrieb"] = $2
    c_antrieb = 1
  }
  if ($1 == "ANTRIEB" && $2 == antrieb) {
    arr_to_p["antrieb"] = arr_to_p["antrieb"] ";" substr($3,4)
  }

  if ($1 == "MATERIAL" && $2 != "material" && c_material == 0 && material != "") {
    arr_to_p["material"] = $2
    c_material = 1
  }
  if ($1 == "MATERIAL" && $2 == material) {
    arr_to_p["material"] = arr_to_p["material"] ";" substr($3,4)
  }

  if ($1 == "MATERIALEL" && $2 != "materialel" && c_materialel == 0 && materialel != "") {
    arr_to_p["materialel"] = $2
    c_materialel = 1
  }
  if ($1 == "MATERIALEL" && $2 == materialel) {
    arr_to_p["materialel"] = arr_to_p["materialel"] ";" substr($3,4)
  }


  # для вывода текста + фактор расхода
  if (mdd1 != "" && $1 == field_medium_label_options) {  # M_02_!_Miscella
     if ($2 == "LABEL" && $3 == substr(mdd1,1,1)) {
        arr_to_p["mdd1"] = $4
     }
     if ($2 == "OPTION" && $3 == substr(mdd1,2,2)) {
        arr_to_p["mdd1"] = arr_to_p["mdd1"] ";" substr($4,4) ";" $5
#        arr_to_p["mdd1"] = arr_to_p["mdd1"] ";" substr($4,4) ";F.Durchsatz = " $5
#        fk1 = $5
        fk_tmp = find_faktor_durchsatz_from_option($5)  # fdurchsatz:1.0
        if (fk_tmp)
           fk1 = fk_tmp
        if (viscosity == "") {
           visc_tmp = find_viscosity_from_option($5)    # viscosity:12000;
           if (visc_tmp)
              arr_main["viscosity"] = viscosity = visc_tmp
        }
     }
  }


  if (mdd2 != "" && $1 == field_medium_label_options) {  # M_02_!_Miscella
     if ($2 == "LABEL" && $3 == substr(mdd2,1,1)) {
        arr_to_p["mdd2"] = $4
     }
     if ($2 == "OPTION" && $3 == substr(mdd2,2,2)) {
        arr_to_p["mdd2"] = arr_to_p["mdd2"] ";" substr($4,4) ";F.Durchsatz = " $5
#        fk2 = $5
        fk_tmp = find_faktor_durchsatz_from_option($5)  # fdurchsatz:1.0
        if (fk_tmp)
           fk2 = fk_tmp
        if (viscosity == "") {
           visc_tmp = find_viscosity_from_option($5)    # viscosity:12000;
           if (visc_tmp)
              arr_main["viscosity"] = viscosity = visc_tmp
        }
     }
  }

  if (mdd3 != "" && $1 == field_medium_label_options) {  # M_02_!_Miscella
     if ($2 == "LABEL" && $3 == substr(mdd3,1,1)) {
        arr_to_p["mdd3"] = $4
     }
     if ($2 == "OPTION" && $3 == substr(mdd3,2,2)) {
        arr_to_p["mdd3"] = arr_to_p["mdd3"] ";" substr($4,4) ";F.Durchsatz = " $5
#        fk3 = $5
        fk_tmp = find_faktor_durchsatz_from_option($5)  # fdurchsatz:1.0
        if (fk_tmp)
           fk3 = fk_tmp
        if (viscosity == "") {
           visc_tmp = find_viscosity_from_option($5)    # viscosity:12000;
           if (visc_tmp)
              arr_main["viscosity"] = viscosity = visc_tmp
        }
     }
  }

  if (mdd4 != "" && $1 == field_medium_label_options) {  # M_02_!_Miscella
     if ($2 == "LABEL" && $3 == substr(mdd4,1,1)) {
        arr_to_p["mdd4"] = $4
     }
     if ($2 == "OPTION" && $3 == substr(mdd4,2,2)) {
        arr_to_p["mdd4"] = arr_to_p["mdd4"] ";" substr($4,4) ";F.Durchsatz = " $5
#        fk4 = $5
        fk_tmp = find_faktor_durchsatz_from_option($5)  # fdurchsatz:1.0
        if (fk_tmp)
           fk4 = fk_tmp
        if (viscosity == "") {
           visc_tmp = find_viscosity_from_option($5)    # viscosity:12000;
           if (visc_tmp)
              arr_main["viscosity"] = viscosity = visc_tmp
        }
     }
  }



  if (durchsatz != "" && $1 == "I_DATA_S" && $2 == "durchsatz")
     arr_to_p["durchsatz"] = $4 ";" durchsatz

  if (viscosity != "" && $1 == "I_DATA_S" && $2 == "viscosity")
     arr_to_p["viscosity"] = $4 ";" viscosity

  if (wpressure != "" && $1 == "I_DATA_S" && $2 == "wpressure")
     arr_to_p["wpressure"] = $4 ";" wpressure

  if (wpressure != "" && $1 == "I_DATA_S" && $2 == "dpressure")
     arr_to_p["dpressure"] = $4 ";" dpressure

  if (wtemperature != "" && $1 == "I_DATA_S" && $2 == "wtemperature")
     arr_to_p["wtemperature"] = $4 ";" wtemperature

  if (dtemperature != "" && $1 == "I_DATA_S" && $2 == "dtemperature")
     arr_to_p["dtemperature"] = $4 ";" dtemperature

  if (fineness != "" && $1 == "I_DATA_S" && $2 == "fineness")
     arr_to_p["fineness"] = $4 ";" fineness

  # scanning <fe-code.txt>
  # EBCPF_!_AF6016_!_E114521102_!_737_!_30,40,50,60,80,100,130,160,200,250,360,500
  # EBCPF_!_AF6036_!_E114552102_!_2156_!_30,40,50,80,100,130,200,250,360,500
  # EBCPF_!_AF6066_!_E124612403_!_903_!_500,800,1000,1500,2000,3000,4000,5000
  # EBCPF_!_AF6076_!_E124612303_!_903_!_100,130,160,200,250,300,360
  if ($1 == "EBCPF" && $3 ~ my_regexp) {  # ^[E][1][1-2][4][5-6].[MATERIAL].[0]
     if (str_elements == "")
        str_elements = $2 "-" $3 "-" $4 "-" $5
     else
        str_elements = str_elements "_!_" $2 "-" $3 "-" $4 "-" $5
  }

  # на всякий случай сохраняем весь файл в памяти. только скребковые элементы
  if ($1 == "EBCPF" && $3 ~ "^[E][1]") {  # ^[E][1][1-2][4][5-6].[MATERIAL].[0]
    arr_all_elements[length(arr_all_elements)+1] = $2 ";" $3 ";" $4 ";" $5
  }


  # scanning <flowrate.txt> вытаскиваем массив строк на расход для данного анвендунга
  # забираем все что есть по нашему MEDIUM в массив
  if ($1 ~ "DSZM_" && $1 ~ medium ) {
    split($4, arr_field4, "__")
    arr_flowrate[length(arr_flowrate)+1] = $2 ":" $3 ":" arr_field4[2] ":" $5
  }

#  if ($1 == "DSZM_" medium ) {
#    c_arr_flowrate++
#    split($4, arr_field4, "__")
#    arr_flowrate[c_arr_flowrate] = $2 ":" $3 ":" arr_field4[2] ":" $5
#  }

    # внутри файла <fe-code.txt> в arr_flowrate[] заменяем "E123" на "E12345678"
    for (i=1; i<=length(arr_flowrate); i++) {
       split(arr_flowrate[i], arr_fr_tmp1, ":")
       el_fr_bez = arr_fr_tmp1[3]               # AF6016

       if ($1 == "EBCPF" && $2 == el_fr_bez)
          arr_flowrate[i] = arr_fr_tmp1[1] ":" $3 ":" arr_fr_tmp1[3] ":" arr_fr_tmp1[4]  # $3 = E12345678
    }

  # scanning <fe-pos.txt>
  # берем оттуда все что есть по поз 4 - площадь поверхности и поз 7 - Drahtbreite
   if ($1 == "POS_4" && FILENAME == txtdir "fe-pos.txt")
     arr_pos_4[$2] = $3

   if ($1 == "POS_7" && FILENAME == txtdir "fe-pos.txt")
     arr_pos_7[$2] = $3

} ################# END OF BODY ###################


END {

# заменяем оригинальную строку на дополненную в конце "-" surface_area "-" draht_breite
#str_elements = str_elements_tmp

# дополняем основной ассоциативный массив и все параметры
# str_other_parameters = "viscosity:1;atex:ON;antrieb:4;kategorie:ON;elements:1,12,4,56,*,*,*,*,*"
delete arr_tmp; delete arr_tmp1; delete arr_tmp2;
split(str_other_parameters, arr_tmp1, ";")
for (i=1; i<=length(arr_tmp1); i++) {
   split(arr_tmp1[i],arr_tmp2,":")
   arr_tmp[arr_tmp2[1]] = arr_tmp2[2]
#   print "<BR>arr_tmp["arr_tmp2[1]"]: " arr_tmp[arr_tmp2[1]] >> result_txt
}

# если в строке "str_other_parameters" содержатся дополнительные параметры то
# дополняем ассоциативный массив arr_main[]



if (arr_tmp["viscosity"] != "") {
   viscosity = arr_main["viscosity"] = arr_tmp["viscosity"]
}

if (arr_tmp["atex"] != "") {
   atex = arr_main["atex"] = arr_tmp["atex"]
   atex_txt = "keine ATEX Zone"
   if (atex == "ON")
      atex_txt = "ATEX Zone 1"
   arr_to_p["atex"] = "ATEX berücksichtigen:;" atex_txt
}

if (arr_main["antrieb"] == "" && antrieb != "")
   arr_main["antrieb"] = antrieb

#print "<BR>Kategorie: " kategorie >> result_txt
#print "<BR>arr_main[\"kategorie\"]: " arr_main["kategorie"] >> result_txt
#print "<BR>arr_tmp[\"kategorie\"]: " arr_tmp["kategorie"] >> result_txt

if (arr_tmp["kategorie"] != "") {
   kategorie = arr_main["kategorie"] = arr_tmp["kategorie"]
   arr_to_p["kategorie"] = "Zertifizierung nach DGRL berücksichtigen:;Ja"
}

if (arr_tmp["elements"] != "") {
   elements = arr_main["elements"] = arr_tmp["elements"]
   split(str_elements,arr_elements,"_!_")
   for (i=1; i<=length(arr_elements);i++) {
     split(arr_elements[i],arr_e,"-")
     if (col_elements == "")
        col_elements = arr_e[1]
     else
        col_elements = col_elements ", " arr_e[1]
   }
   arr_to_p["elements"] = "Elemente:;" col_elements
}

#print "<p></p><i>xxxxxxxxxxxxxxxx: " durchsatz, fk1, fk2, fk3, fk4 >> result_txt

durchsatz_c = durchsatz / (fk1 * fk2 * fk3 * fk4)

arr_main["durchsatz_c"] = arr_to_p["durchsatz_c"] = "Durchsatz umgerechnet [Liter/Min]:;" durchsatz_c

# update arr_flowrate[i] with ":" surface, cm2 ":" Drahtbreite, mm
for (i=1; i<= length(arr_flowrate); i++) {
  split(arr_flowrate[i], arr1, ":")
  arr_flowrate[i] = arr_flowrate[i] ":" arr_pos_4[substr(arr1[2],5,1)] ":" arr_pos_7[substr(arr1[2],8,1)]
}

# update str_elements with ":" surface, cm2 ":" Drahtbreite, mm
str_elements_tmp = ""
split(str_elements, arr_str_elements, "_!_") 
for (i=1; i<=length(arr_str_elements[i]); i++) {
  split(arr_str_elements[i], arr1, "-")
  if (str_elements_tmp == "")
     str_elements_tmp = arr_str_elements[i] "-" arr_pos_4[substr(arr1[2],5,1)] "-" arr_pos_7[substr(arr1[2],8,1)]
  else
     str_elements_tmp = str_elements_tmp "_!_" arr_str_elements[i] "-" arr_pos_4[substr(arr1[2],5,1)] "-" arr_pos_7[substr(arr1[2],8,1)]
}
str_elements = str_elements_tmp



if (comments == "ON") {
  print "<p></p><i>INPUT DATA from previous WEB page: " >> result_txt
  print "<BR>json_data: " json_data  >> result_txt
  print "<BR>arr_main[] - contains real parameters for the next page"  >> result_txt
  print "<BR>arr_tp_p[] - text data for displaying INPUT DATA table"  >> result_txt

  delete arr_tmp; delete arr_tmp1; delete arr_tmp2;
  split(str_to_print, arr_tmp1, ",")
  for (i=1; i<=length(arr_tmp1); i++) {
     print "<p></p>arr_to_p[\""arr_tmp1[i]"\"]: " arr_to_p[arr_tmp1[i]]  >> result_txt
     print "<BR>arr_main[\""arr_tmp1[i]"\"]: " arr_main[arr_tmp1[i]]  >> result_txt
  }

  print "<p></p>str_other_parameters : " str_other_parameters >> result_txt
  delete arr_ttmp; delete arr_ttmp1; delete arr_ttmp2;
  split(str_other_parameters, arr_ttmp1, ";")
  for (i=1; i<=length(arr_ttmp1); i++) {
     split(arr_ttmp1[i],arr_ttmp2,":")
     arr_ttmp[arr_ttmp2[1]] = arr_ttmp2[2]
     print "<BR>arr_tmp["arr_ttmp2[1]"]: " arr_ttmp[arr_ttmp2[1]] >> result_txt
  }
  print "<BR>str_elements : " str_elements " - suitable elements selected from template: arr_tmp[elements] = " arr_ttmp["elements"] >> result_txt
  delete arr_ttmp; delete arr_ttmp1; delete arr_ttmp2;

  print "<p></p>Flow rates (read from =flowrate.txt=) $1 = viscosity, etc. $5 = serface, cm2, $6 = Drahtbreite, mm"  >> result_txt
  for (i=1; i<=length(arr_flowrate); i++)
     print "<BR>arr_flowrate["i"]: " arr_flowrate[i] >> result_txt

  print "<p></p>viscosity: " viscosity  >> result_txt
  print "</i>" >> result_txt

}


print_input_data()

# расчет количества элементов необходимых для данного расхода
# мы их после расчета добавим в str_elements в конце

# str_elements : AF6036-E114552102-2156-30,40,50,80,100,130,200,250,360,500-836-0.5_!_
#                AF6086-E124612203-903-50,60,80,100-836-0.75_!_
#                AF6076-E124612303-903-100,130,160,200,250,300,360-836-1.0_!_
#                AF6066-E124612403-903-500,800,1000,1500,2000,3000,4000,5000-836-1.8

# arr_flowrate[1]: 1:E114521102:AF6016:80-138;100-167;200-278:862:0.5



############## START CALCULATION ################

# 1. собираем подходящие 1-2 записи по вязкости в arr_visc_flowrate[]
arr_visc_flowrate[1] = ""
create_arr_visc_flowrate(viscosity, toleranz_viscosity) # проверить как работает функция на неск записях с разн вязкостями

if (arr_visc_flowrate[1] == "") {  # массив arr_visc_flowrate[1] вернулся пустой
   print "<p></p><i><b>Table Viscosity / Fineness / Flowrate is empty. EXIT:</b>" >> result_txt
   exit
}

viscosity_upd = viscosity

if (length(arr_visc_flowrate) != 1) {
#    print "<p></p><b>2 or more records under development : </b>" >> result_txt

    # у нас гарантированно две записи /// преобразовываем их в ОДНУ 
    # аппроксимацией для указанной вязкости
    # arr_visc_flowrate[1]:1:E114521102:AF6016:30-100;50-140;80-220;100-250;130-270;160-300;200-400:862:0.5
    #  arr_visc_flowrate[2]:1000:E114521102:AF6016:30-50;50-70;80-110;100-125;130-134;160-150;200-200:862:0.5 
#    approximate_arr_visc_flowrate_from_2_to_1_records()


    print_arr_visc_flowrate_as_table_1()
#    print_arr_visc_flowrate_as_table()

}
   split(arr_visc_flowrate[1], arr1, ":")
   viscosity_upd = arr1[1]
#   delete arr1;

#print "<p></p>arr_visc_flowrate[1]: " arr_visc_flowrate[1]   >> result_txt

# 2. определяем границы тонкости ф. в нашей таблице 
# arr_flowrate[1]: 1:E114521102:AF6016:80-138;100-167;200-278:862:0.5
k_max = split(arr1[4], arr2, ";")  #  80-138;100-167;200-278
#print "<br>k_max: " k_max   >> result_txt

split(arr2[1], arr3, "-")          #  80-138
fineness_table_min = arr3[1]
#print "<br>arr2[1]: " arr2[1], fineness_table_min   >> result_txt

split(arr2[k_max], arr3, "-")      #  200-178
fineness_table_max = arr3[1]
#print "<br>arr2[1]: " arr2[k_max], fineness_table_max   >> result_txt

fineness_upd = fineness
if (fineness <= fineness_table_min)
   fineness_upd = fineness_table_min

#print "<br>fineness_upd: " fineness_upd   >> result_txt


# 3. исключаем неподходящие элементы и формируем новый массив arr_suitable_elements[]
#    из str_elements : AF6036-E114552102-2156-30,40,50,80,100,130,200,250,360,500-836-0.5_!_
delete arr_suitable_elements
fineness_tmp = fineness_upd

k_max = split(str_elements, arr_str_elements, "_!_")
#print "<br>str_elements: " str_elements   >> result_txt


for (k=1; k<=k_max; k++) {
   split(arr_str_elements[k], arr1, "-")
   k1_max = split(arr1[4], arr2, ",")                              # 30,40,50,80,100,130,200,250,360,500
   if (arr2[k1_max] > fineness_upd / toleranz_fineness)  {         # 500 > 130/1.05
      for (k1=1; k1<=k1_max; k1++) {
          if (arr2[k1] >= fineness_upd / toleranz_fineness)
             break
      }
      arr_suitable_elements[length(arr_suitable_elements)+1] = arr1[1] "-" arr1[2] "-" arr1[3] "-" arr2[k1] "-" arr1[5] "-" arr1[6]
   }
}


if (length(arr_suitable_elements) == 0) {
   print "<BR><b>No suitable elements found in str_elements</b>" >> result_txt
   exit
}

if (comments == "ON") {
   print "<p></p><i><b>START CALCULATIONS:</b>" >> result_txt
   print "<br>Toleranz Viscosity: " toleranz_viscosity " /// Toleranz Fineness: " toleranz_fineness >> result_txt

   print "<br>Viscosities [cSt]: Input [viscosity]: " viscosity " // Updated [viscosity_upd]: " viscosity_upd  >> result_txt
   for (k=1; k<= length(arr_visc_flowrate); k++)
      print "<BR>arr_visc_flowrate["k"]:" arr_visc_flowrate[k] >> result_txt
   print "<BR>Fineness range in our data table: fineness_table_min = " fineness_table_min "µm to fineness_table_max = " fineness_table_max "µm" >> result_txt
   print "<BR>First fineness check: Input fineness: " fineness "µm /// updated fineness = " fineness_upd "µm" >> result_txt

   dkb_offl_txt = ""
   if (dkb_offl != "ON")
      dkb_offl_txt = "DO NOT"
   print "<BR>Parameter \"dkb_offl\" = ON: " dkb_offl_txt " take open filtration surface as base for flow rate calculations " >> result_txt

   dpm_g1_txt = " All dP-Switches and Manometers may be used"
   if (dpm_g1 == "ON")
      dpm_g1_txt = " Only PIS 3175 and PIS 3180 may be used. Avoid using G1/8 Manometer ports"
   print "<BR>Parameter \"dpm_g1\" = ON: " dpm_g1_txt  >> result_txt

}


# добавляем в ARR arr_suitable_elements открытую площадь поверхности
# чтобы каждый раз потом не пересчитывать и по ней отсортировать
add_open_filter_surface_to_arr_suitable_elements()

# добавляем интервал в который попадает наша тонкость фильтрации
# и если сразу виден макс расход то его также
add_fineness_flowrate_range_and_max_flowrate_to_arr_suitable_elements()

# проверяем возможно можно перейти на более мелкие элементы если расход маленький
# эта функция перепишет в случае необходимости arr_suitable_elements[]
find_smaller_elements_and_rewrite_arr_suitable_elements()

print_arr_suitable_elements_as_table()


#mystr = "medium:02,comments:ON,dpressure:1,antrieb:4,material:1,materialel:2,ksf:ON,kategorie_!_str_myarr"
mystr = "medium:"medium",comments:"comments",dpressure:"dpressure",antrieb:"antrieb ",atex:"atex
mystr = mystr ",viscosity:"viscosity ",dpm_g1:"dpm_g1 ",fineness:"fineness
mystr = mystr ",material:"material",materialel:"materialel",ksf:"ksf",kategorie:"kategorie"_!_str_myarr"

#str_no_of_elements = "1,2,3,6,9,12,18,24,36,48"
string_return = prepare_mystr_for_next_script(mystr, str_no_of_elements)


if (comments == "ON") {
   print "<p></p><BR># arr_suitable_elements[]: <BR># after find_smaller_elements_and_rewrite_arr_suitable_elements()" >> result_txt
   for (k=1; k<=length(arr_suitable_elements); k++)
      print "<BR>["k"]: " arr_suitable_elements[k] >> result_txt

  print "<p></p><i>parameters for page-31-ksf.awk (string_return): "  string_return >> result_txt
  print "<BR>mystr: $1=number of elements; $4=LP; $5=3-rd digit from left in the code = filter size: 2- AF713, 3-AF724, 4- AF73" >> result_txt
  print "<BR>[1;AF6036-020;E114552102;2156] - this is the base for calculations // E11[4] - filter size" >> result_txt
  print "<BR>[;3] - eg. according to calculations, filter size [3]=AF724_G4 is suitable as well" >> result_txt
  print "<BR><b>--------- End of page-3-ksf.awk ----------------</b></i><BR>"  >> result_txt
}

#print "</div>" >> result_txt
print string_return
}



function print_bootstrap_head(page_header) {
print "<div class=\"container content\">"  >> result_txt
print "<div class=\"p-2 mb-2 bg-primary text-white\">"  >> result_txt
print "     " page_header   >> result_txt
print "</div>"  >> result_txt
#print "<ul class=\"list-group list-striped mb-3\">"  >> result_txt
return
}

# печать всех введенных данных
function print_input_data() {
print "<table class=\"table table-striped\">" >> result_txt
print "<thead><tr><th scope=\"col\">Parameter</th>"  >> result_txt
print "<th scope=\"col\">Value</th>" >> result_txt
print "<th scope=\"col\">Addit.values</th></tr></thead>"  >> result_txt
print "<tbody>" >> result_txt


delete arr_tmp; delete arr_tmp1; delete arr_tmp2;
split(str_to_print, arr_tmp1, ",")

for (i=1; i<=length(arr_tmp1); i++) {
#    print "<BR>arr_tmp1["i"]: " arr_tmp1[i] >> result_txt
    if (arr_to_p[arr_tmp1[i]] != "") {
       split(arr_to_p[arr_tmp1[i]], arr_tmp2, ";")
       col3 = "-"
       if (arr_tmp2[3] != "")
          col3 = arr_tmp2[3]

       print "<tr><td>"arr_tmp2[1]"</td>" >> result_txt
       print "<td>"arr_tmp2[2]"</td>" >> result_txt
       print "<td>"col3"</td></tr>" >> result_txt
    }
}


if (dpm_g1 == "ON") {
    print "<tr><td>DP Messung:</td>" >> result_txt
    print "<td>nur über G1 Anschlüss</td>" >> result_txt
    print "<td>dpm_g1:ON</td></tr>" >> result_txt
}

    print "<tr><td>Offene Filter Fläche berücksichtigen:</td>" >> result_txt
    txt_option = "Nein"
    if (dkb_offl == "ON")
       txt_option = "Ja"
    print "<td>"txt_option"</td>" >> result_txt
    print "<td>dkb_offl: "dkb_offl"</td></tr>" >> result_txt





print "</tbody></table>" >> result_txt

}



########## FUNCTIONS FOR CALCULATION ####################

# добавляем в ARR arr_suitable_elements открытую площадь поверхности
# чтобы каждый раз потом не пересчитывать и по ней отсортировать
function add_open_filter_surface_to_arr_suitable_elements() {
  if (comments == "ON") {
     print "<p></p><i># arr_suitable_elements[]" >> result_txt
     print "<br># $3=price, $4=fineness, $5=total surface, $6=Drahtbreite" >> result_txt
     for (k=1; k<=length(arr_suitable_elements); k++)
        print "<BR>["k"]: " arr_suitable_elements[k] >> result_txt
     print "</i>" >> result_txt
  }

  for (k=1; k<=length(arr_suitable_elements); k++) {
     split(arr_suitable_elements[k], arr1, "-")
     total_square = arr1[5]
     fineness_tmp = arr1[4]
     drahtbreite = arr1[6]
     open_filter_surface = (1000*total_square / (fineness_tmp + 1000*drahtbreite)) * fineness_tmp/1000
     arr_suitable_elements[k] = arr_suitable_elements[k] "-" int(10 * open_filter_surface)/10
  }

  if (comments == "ON") {
     print "<p></p><i># arr_suitable_elements[]" >> result_txt
     print "<br># after function add_open_filter_surface_to_arr_suitable_elements()" >> result_txt
     print "<br># $7=open filter surface" >> result_txt
     for (k=1; k<=length(arr_suitable_elements); k++)
        print "<BR>["k"]: " arr_suitable_elements[k] >> result_txt
     print "</i>" >> result_txt
  }
}

# добавляем интервал в который попадает наша тонкость фильтрации
# и если сразу виден макс расход то его также
function add_fineness_flowrate_range_and_max_flowrate_to_arr_suitable_elements() {
#print "<BR>arr_visc_flowrate[1]: " arr_visc_flowrate[1] >> result_txt

split(arr_visc_flowrate[1], arr_total_range, ":")  #  arr_total_range[4] = "80-138;100-167;200-278"
split(arr_total_range[4], arr_single_range, ";")   #  arr_single_range[1] = "80-138" "100-167" "200-278"
drahtbreite_table = arr_total_range[6]
total_surface_table = arr_total_range[5]

for (k=1; k<=length(arr_suitable_elements); k++) {

#   print "<BR>arr_suitable_elements[k]: " arr_suitable_elements[k] >> result_txt

   split(arr_suitable_elements[k], arr1, "-")
   fineness_our = arr1[4]                          #  130 µm
   open_surface_our = arr1[7]                      #  177.8 cm2

   for (m=1; m<length(arr_single_range); m++) {    #  arr_single_range[1] = "80-138" "100-167" "200-278"

      split(arr_single_range[m], arr2, "-")        #  arr2[m] = "80-138"
      table_fineness_min = arr2[1]                 #  arr2[1] = 80 µm
      table_flowrate_min = arr2[2]                 #  arr2[2] = 138 LPM

      split(arr_single_range[m+1], arr3, "-")      #  arr3[m+1] = "100-167"
      table_fineness_max = arr3[1]                 #  arr3[1] = 100 µm
      table_flowrate_max = arr3[2]                 #  arr3[2] = 167 LPM


#   print "<BR>: " table_fineness_min "-" table_flowrate_min ";" table_fineness_max "-" table_flowrate_max>> result_txt


      # absolut max / последнее значение максимальное
      split(arr_single_range[length(arr_single_range)], arr4, "-")      #  "200-278"
      table_fineness_abs_max = arr4[1]                 #  arr4[1] = 200 µm
      table_flowrate_abs_max = arr4[2]                 #  arr4[2] = 278 LPM

#      print "<BR>our: " fineness_our " table_fineness_min: " table_fineness_min " // table_fineness_max: " table_fineness_max >> result_txt

      if (fineness_our == table_fineness_min) {
         if (dkb_offl != "ON")
            arr_suitable_elements[k] = arr_suitable_elements[k] "_!_" arr_single_range[m] "=" table_flowrate_min "_!_" int(100*durchsatz_c/table_flowrate_min)/100
         else {
            open_surface_table =  (1000*total_surface_table / (table_fineness_min + 1000*drahtbreite_table)) * table_fineness_min/1000
            flowrate_our = int(100*table_flowrate_min * open_surface_our / open_surface_table) / 100
            arr_suitable_elements[k] = arr_suitable_elements[k] "_!_" arr_single_range[m] "=" flowrate_our "_!_" int(100*durchsatz_c/flowrate_our)/100
#            print "<BR>--: " arr_suitable_elements[k] "--FR min:" table_flowrate_min "--FR our" flowrate_our >> result_txt

         }
         break
      }

      # если наша тонк ф больше самого большого табличного
      if (fineness_our >= table_fineness_abs_max) {
         if (dkb_offl != "ON")
             arr_suitable_elements[k] = arr_suitable_elements[k] "_!_" arr_single_range[length(arr_single_range)] "=" table_flowrate_abs_max  "_!_" int(100*durchsatz_c/table_flowrate_abs_max)/100
         else {
            open_surface_table =  (1000 * total_surface_table / (table_fineness_abs_max + 1000*drahtbreite_table)) * table_fineness_abs_max/1000
            flowrate_our = int(100 * table_flowrate_abs_max * open_surface_our / open_surface_table)/100
            arr_suitable_elements[k] = arr_suitable_elements[k] "_!_" arr_single_range[length(arr_single_range)] "=" flowrate_our "_!_" int(100*durchsatz_c/flowrate_our)/100
#            print "<BR>open surface table: " open_surface_table " /// open surface our: " open_surface_our >> result_txt
#            print "<BR>--: " arr_suitable_elements[k] "--FR max:" table_flowrate_abs_max "--FR our:" flowrate_our >> result_txt
         }
         break
      }


      if (fineness_our > table_fineness_min && fineness_our < table_fineness_max) {
         approximated_flowrate = approximate_flowrate_1_record(arr_visc_flowrate[1], arr_single_range[m], arr_single_range[m+1], fineness_our, open_surface_our)
         arr_suitable_elements[k] = arr_suitable_elements[k] "_!_" arr_single_range[m] ";" arr_single_range[m+1] "=" approximated_flowrate "_!_" int(100*durchsatz_c/approximated_flowrate)/100
         break
      }



   }

}
  if (comments == "ON") {
     print "<p></p><i># arr_suitable_elements[] " >> result_txt
     print "<br># after function add_fineness_flowrate_range_and_max_flowrate_to_arr_suitable_elements()" >> result_txt
     print "<br># $8=table range, $9=max flow rate " >> result_txt
     for (k=1; k<=length(arr_suitable_elements); k++) 
        print "<BR>["k"]: " arr_suitable_elements[k] >> result_txt
     print "</i><p></p>" >> result_txt
  }

}

# аппроксимация расхода находящегося в интервале тонкостей фильтрации для 1 строки
# function approximate_flowrate_1_record(arr_visc_flowrate[1], arr_single_range[m], arr_single_range[m+1])
# str_table = arr_visc_flowrate[1]:1:E114521102:AF6016:80-138;100-167;200-278:862:0.5
# 100-167;200-278
# fineness_our = 130 µm
# open_surface_our = AF6076-E124612303-903-130-836-1.0-96.1 /// последнее значение
function approximate_flowrate_1_record(str_table, range1, range2, fineness_our, open_surface_our) {

  split(str_table, arr_str_table, ":")
  total_surface_table = arr_str_table[5]  # 862
  drahtbreite_table = arr_str_table[6]    # 0.5

  split(range1, arr_range1, "-")
  fineness1 = arr_range1[1]               # 100 µm
  flowrate1 = arr_range1[2]               # 167 LPM
  open_surface1 = (1000*total_surface_table / (fineness1 + 1000*drahtbreite_table)) * fineness1/1000

  split(range2, arr_range2, "-")
  fineness2 = arr_range2[1]               # 200 µm
  flowrate2 = arr_range2[2]               # 278 LPM
  open_surface2 = (1000*total_surface_table / (fineness2 + 1000*drahtbreite_table)) * fineness2/1000

  # x = open_surface; y = flowrate - из графика уравнения прямой линии y = kx + b
  # k = (y2 - y1) / (x2 - x1)
  # b = y1 - kx1
  k_straight_line = (flowrate2 - flowrate1) / (open_surface2 - open_surface1)
  b_straight_line = flowrate1 - k_straight_line * open_surface1

  open_surface_table = (1000*total_surface_table / (fineness_our + 1000*drahtbreite_table)) * fineness_our/1000  # для 130 µm
  flowrate_table = k_straight_line * open_surface_table + b_straight_line  # для 130 µm по табличному элементу AF6016-

  if (dkb_offl == "ON") {
    specific_flowrate_table = flowrate_table / open_surface_table
    flowrate_our = specific_flowrate_table * open_surface_our
    return flowrate_our
  }


return flowrate_table
}



# подготовить строку для следущего скрипта
function prepare_mystr_for_next_script(mystr, str_no_of_elements) {
#str_no_of_elements = "1:400,2:800,3:1000,6:2400,9:2400,12:2400,18:3600,24:3800,36:3800,48:3800"  # для всех одинаково
#print "<BRrd>mystr: "mystr " /// str_no_of_elements: " str_no_of_elements >> result_txt

split(str_no_of_elements, arr_no_of_elements, ",")

for (k=1; k<=length(arr_suitable_elements); k++) {
   split(arr_suitable_elements[k], arr1, "_!_")
   split(arr1[1], arr2, "-")
   el_bez   = arr2[1]
   el_code  = arr2[2]
   el_price = arr2[3]
   el_fineness = arr2[4]
   no_of_el = arr1[3]
   number_of_elements = 0

   for (m=1; m<=length(arr_no_of_elements); m++) {
      split(arr_no_of_elements[m], arr1, ":")
#      min = arr1[1]   # number of elemeents
#      max_flowrate = arr1[2]

      min = arr_no_of_elements[m]


      el_size = 4 # POS_3 ELements code AF73

      if (m==1 && no_of_el <= 1.1 * min/4) {
         number_of_elements = 1
         el_size = 2 # POS_3 ELements code AF713
         break
      }

      if (m==1 && no_of_el <= 1.15 * min/2) {
         number_of_elements = 1
         el_size = 3 # POS_3 ELements code AF724
         break
      }

#      if (min <= 3 && no_of_el <= 1.2 * min && durchsatz <= max_flowrate) {
      if (min <= 3 && no_of_el <= 1.2 * min) {
         number_of_elements = min
         break
      }

      if (min > 3 && no_of_el <= 1.3 * min) {
         number_of_elements = min
         break
      }

   }

   if (number_of_elements == 0) {
      print "<p></p><b>ERROR! Wrong number of filter elements (0 pcs).</b>" >> result_txt
      exit
   }

   ef = "0" el_fineness/10
   if (el_fineness < 100)
      ef = "00" el_fineness/10


   full_el_bez = el_bez "-" ef
#   mystr = mystr ":" number_of_elements ";" full_el_bez ";" el_code ";" el_price
   mystr = mystr ":" number_of_elements ";" full_el_bez ";" el_code ";" el_price ";" el_size
}


return mystr
}






# собираем подходящие записи по вязкости  в arr_visc_flowrate[]
function create_arr_visc_flowrate(viscosity, tv) {
# dano
# arr_flowrate[1]: 1:E114521102:AF6016:80-138;100-167;200-278:862:0.5 /// одна или много записей
# выбираем из него 1 или 2 записи с подходящей вязкостью в arr_visc_flowrate[] или его строку str_arr_visc_flowrate
#
# mystring1 = ""
# delete arr_visc_flowrate

# проверяем границы таблицы TOP / BOTTOM
top_record = arr_flowrate[1]                     # top table record
bot_record = arr_flowrate[length(arr_flowrate)]  # bottom table record
split(top_record, arr_top, ":")
split(bot_record, arr_bot, ":")
min_table_viscosity = arr_top[1]
max_table_viscosity = arr_bot[1]
delete arr_top; delete arr_bot;

# если top значение вязкости в пределах толеранц или введенная вязкость существенно ниже
# в новой таблице будет всего одна пограничная строка
if (min_table_viscosity >= viscosity / tv) {
    arr_visc_flowrate[1] = arr_flowrate[1]
#    print "<BR>EXIT 1: " arr_visc_flowrate[1]  >> result_txt
    return
}

# если bottom значение вязкости в пределах толеранц или введенная вязкость cущественно выше
# в новой таблице будет всего одна пограничная строка
if (max_table_viscosity <= viscosity * tv) {
    arr_visc_flowrate[1] = arr_flowrate[length(arr_flowrate)]
#    print "<BR>EXIT 2: "  >> result_txt
    return
}

# если до сих пор не вышли, значит вязкость гарантированно в интервале
for (k=1; k<length(arr_flowrate); k++) {

   split(arr_flowrate[k],   arr1, ":")  # 1:E114521102:AF6016:80-138;100-167;200-278:862:0.5
   split(arr_flowrate[k+1], arr2, ":")  # 1000:E114521102:AF6016:80-138;100-167;200-278:862:0.5
   viscosity_min = arr1[1]
   viscosity_max = arr2[1]

#    print "<BR>--viscosity: " viscosity, viscosity_min, viscosity_max >> result_txt


   if (viscosity_min == viscosity) {
       arr_visc_flowrate[1] = arr_flowrate[k]
#       print "<BR>break 1 " >> result_txt
       break
   }

   if (viscosity_max == viscosity) {
       arr_visc_flowrate[1] = arr_flowrate[k+1]
#       print "<BR>break 2 " >> result_txt
       break
   }


   if (viscosity_min < viscosity && viscosity_max > viscosity) {
       arr_visc_flowrate[1] = arr_flowrate[k]
       arr_visc_flowrate[2] = arr_flowrate[k+1]

       # приводим наши две записи к идентичным интервалам тонкости фильтрации
       split(arr_visc_flowrate[1], arr1, ":")
       split(arr_visc_flowrate[2], arr2, ":")
       range1 = arr1[4]  #       50-55;80-138;100-167;200-278
       range2 = arr2[4]  #             80-138;100-167;200-278
       newrange2 = ""

       split(range1, arr_range1, ";")
       split(range2, arr_range2, ";")
       for (n=1; n<=length(arr_range2); n++) {
          split(arr_range2[n], arr_pair2, "-")     # 50-35
          for (m=1; m<=length(arr_range1); m++) {
             split(arr_range1[m], arr_pair1, "-")  # 30-50

             if (arr_pair1[1] == arr_pair2[1]) {
                if (newrange2 == "")
                   newrange2 = arr_range1[m]
                else
                   newrange2 = newrange2 ";" arr_range1[m]
             }
          }
       }

       arr_visc_flowrate[1] = arr1[1] ":" arr1[2] ":" arr1[3] ":" newrange2 ":" arr1[5] ":" arr1[6]

       delete arr1; delete arr2;
       return
   }

    delete arr1; delete arr2;
}


} # END of Function


# create one array line (approximated) from two border members
function approximate_arr_visc_flowrate_from_2_to_1_records() {
   delete arr_tmp1; delete arr_tmp2; delete arr_fl_fine_tmp1; delete arr_fl_fine_tmp2
   # arr_visc_flowrate[1]:1:E114521102:AF6016:30-100;50-140;80-220;100-250;130-270;160-300;200-400:862:0.5
   # arr_visc_flowrate[2]:1000:E114521102:AF6016:30-50;50-70;80-110;100-125;130-134;160-150;200-200:862:0.5 
   # у них одинаковые интервалы, общая площ поверхности и drahtbreite

   split(arr_visc_flowrate[1], arr_tmp1, ":")
   split(arr_visc_flowrate[2], arr_tmp2, ":")
   viscosity1 = arr_tmp1[1]                    # 1
   viscosity2 = arr_tmp2[1]                    # 1000
   str_flowrate_fineness1 = arr_tmp1[4]        # 30-100;50-140;80-220;100-250;130-270;160-300;200-400
   str_flowrate_fineness2 = arr_tmp2[4]        # 30-50;50-70;80-110;100-125;130-134;160-150;200-200
   total_f_surface = arr_tmp1[5]  # 862 cm2
   drahtbreite = arr_tmp1[6]                   # 0.5 mm
   el_code = arr_tmp1[2]                       # E114521102
   el_bez  = arr_tmp1[3]                       # AF6016

   split(str_flowrate_fineness1, arr_flowrate_fineness1, ";")
   split(str_flowrate_fineness2, arr_flowrate_fineness2, ";")

   # build new string for ARR with specified fineness (approximated values in string)
   my_new_str = viscosity ":" el_code ":" el_bez
   counterx = 1

   for (k=1; k<=length(arr_flowrate_fineness1); k++) {
      split(arr_flowrate_fineness1[k], arr_fl_fine_tmp1, "-")
      split(arr_flowrate_fineness2[k], arr_fl_fine_tmp2, "-")
      fineness_tmp = arr_fl_fine_tmp1[1]
      flowrate1    = arr_fl_fine_tmp1[2]
      flowrate2    = arr_fl_fine_tmp2[2]

      koef = (flowrate2-flowrate1) / (viscosity2-viscosity1)
      b =  koef * viscosity1 - flowrate1

      # по уравнению прямой линии было бы isf_our = koef * viscosity + b
       flowrate_our = koef * viscosity - b
       dviscosity = (viscosity2 - viscosity1)/10          # шаг 1/10 от разницы вязкостей
       procent_viscosity = smoothing_factor * (viscosity - viscosity1) / (viscosity2 - viscosity1)  # 0.8
       flowrate_our = flowrate_our - (flowrate_our - flowrate2) * procent_viscosity

      # данных для новой единственной строки массива достаточно
      # arr_visc_flowrate[1]:1:E114521102:AF6016:30-100;50-140;80-220;100-250;130-270;160-300;200-400:862:0.5

      if (counterx == 1) {
          my_new_str = my_new_str ":" fineness_tmp "-" int(10 * flowrate_our)/10
          counterx++
      } else {
          my_new_str = my_new_str ";" fineness_tmp "-" int(10 * flowrate_our)/10
      }

   }

   my_new_str = my_new_str ":" total_f_surface ":" drahtbreite
   delete arr_visc_flowrate;
   arr_visc_flowrate[1] = my_new_str
}


# проверяем возможно можно перейти на более мелкие элементы если расход маленький
# эта функция перепишет в случае необходимости
# arr_suitable_elements[]
# [1]: AF6036-E114552102-2156-50-862-0.5-78.3_!_50-138.7=138.7_!_0.21
# [2]: AF6066-E124612403-903-500-836-1.8-181.7_!_200-396.3=396.3_!_0.07
# [3]: AF6076-E124612303-903-100-836-1.0-76_!_100-247.7=247.7_!_0.12
# [4]: AF6086-E124612203-903-50-836-0.75-52.2_!_50-138.7=138.7_!_0.21
#arr_all_elements[1]:
# [1]: AF7011;E111121102;181;30,40,50,60,80,100,130,160,200,250,360,500
# [2]: AF7031;E111142102;1475;30,40,50,60,80,100,130,160,200,250,360,500
# [3]: AF7013;E112221102;213;30,40,50,60,80,100,130,160,200,250,360,500
function find_smaller_elements_and_rewrite_arr_suitable_elements() {
#   for (k=1; k<=length(arr_all_elements); k++)
#      print "<BR>arr_all_elements["k"]: " arr_all_elements[k] >> result_txt

# we take fineness of the first element in array
   first_pass = 1

   for (k=1; k<=length(arr_suitable_elements); k++) {
      split(arr_suitable_elements[k], arr1, "_!_")
      no_of_el = arr1[length(arr1)]                   # 0.21
      split(arr1[1], arr2, "-")                       # AF6036-E114552102-2156-50-862-0.5-78.3
      split(arr1[2], arr2_tmp, "=")                   # 100-247.7=247.7
      max_flowrate_tmp = arr2_tmp[2]

      old_code = arr2[2]                              # E114552102

      if (first_pass == 1) {                           # fineness take only ONE time
        old_fineness = arr2[4]                         # 50
        first_pass = 0
      }

#      print "<BR>--<BR>arr_suitable_elements["k"]: " arr_suitable_elements[k] >> result_txt
#      print "<BR>max_flowrate_tmp: " max_flowrate_tmp >> result_txt
#      print "<BR>old_code: " old_code " /// old_fineness: " old_fineness >> result_txt

      my_regexp1 = "^E1" substr(old_code,3,1)         # ^E11
      my_regexp2 = ".*" substr(old_code,7,4) "$"      # .*2102$

      # заменяем на AF713 если подходит
      if (no_of_el <= 0.3) {             # compare last item 0.22
         my_regexp = my_regexp1 "2" my_regexp2        # ELemente AF713
         for (m=1; m<=length(arr_all_elements); m++) {
#            print "<BR>arr_all_elements["m"]: " arr_all_elements[m] >> result_txt

            split(arr_all_elements[m], arr3, ";")
            if (arr3[2] ~ my_regexp) {                # E114552102
#                print "<BR>-- arr_all_elements["m"]: " arr_all_elements[m] >> result_txt

              # [k] порядковый номер arr_suitable_elements

#               print "<BR>1/4 BEFORE: arr_all_elements["m"]: " arr_all_elements[m] >> result_txt
               replace_element_in_arr_suitable_elements(k, arr_all_elements[m], old_fineness, max_flowrate_tmp/4)
#               print "<BR>AFTER: arr_suitable_elements["k"]: " arr_suitable_elements[k] "<BR>--<BR>" >> result_txt
               break
            }
         }
      }

      # заменяем на AF72 если подходит
      if (no_of_el > 0.3 && arr1[length(arr1)] <= 0.55) {             # compare last item 0.22
         my_regexp = my_regexp1 "3" my_regexp2        # ELemente AF713
         for (m=1; m<=length(arr_all_elements); m++) {
            split(arr_all_elements[m], arr3, ";")
            if (arr3[2] ~ my_regexp) {                # E114552102
               # [k] порядковый номер arr_suitable_elements

#               print "<BR>1/2 BEFORE: arr_all_elements["m"]: " arr_all_elements[m] >> result_txt
               replace_element_in_arr_suitable_elements(k, arr_all_elements[m], old_fineness, max_flowrate_tmp/2)
#               print "<BR>AFTER: arr_suitable_elements["k"]: " arr_suitable_elements[k] "<BR>--<BR>" >> result_txt
               break
#               replace_element_in_arr_suitable_elements(k, arr_all_elements[m], old_fineness, max_flowrate_tmp/2)
            }
         }
      }

   }


}


function replace_element_in_arr_suitable_elements(k, element_arr_all_elements, old_fineness, new_flowrate) {
  delete arr5; delete arr6;
  split(element_arr_all_elements, arr5, ";")     # AF7083;E122212203;600;60,80,100,130,160
  pos4_code = substr(arr5[2],5,1)                # code total filter surface
  total_filer_surface_tmp = arr_pos_4[pos4_code]
  pos7_code = substr(arr5[2],8,1)                # drahtbreite
  drahtbreite_tmp = arr_pos_7[pos7_code]

#  print "<BR>INSIDE total filter surface " arr5[1] " // " arr5[2] " : "  pos4_code " // " total_filer_surface_tmp >> result_txt
#  print "<BR>INSIDE drahtbreite " arr5[1] " // " arr5[2] " : "  pos7_code " // " drahtbreite_tmp >> result_txt

  split(arr5[4], arr6, ",")                      # 60,80,100,130,160
  new_fineness = 0
  for (n=1; n<length(arr6); n++) {
     if (old_fineness <= arr6[n]) {
         new_fineness = arr6[n]
#         print "<BR>INSIDE new_fineness EQUAL: " new_fineness >> result_txt
         break
     }
     if (old_fineness > arr6[n] && old_fineness <= arr6[n+1]) {
         new_fineness = arr6[n+1]
#         print "<BR>INSIDE new_fineness BETWEEN: " new_fineness >> result_txt
         break
     }
  }
  if (new_fineness == 0) {
     new_fineness = arr6[length(arr6)]
#     print "<BR>INSIDE new_fineness OVER RANGE: " new_fineness >> result_txt
  }

  open_filter_surface_tmp = int(10 * total_filer_surface_tmp * new_fineness / (new_fineness + 1000*drahtbreite_tmp))/10

  arr_suitable_elements[k] = arr5[1] "-" arr5[2] "-" arr5[3] "-" new_fineness "-" total_filer_surface_tmp "-" drahtbreite_tmp "-" open_filter_surface_tmp "_!_" new_fineness "-" int(10*new_flowrate)/10 "=" int(10*new_flowrate)/10 "_!_1" 
  delete arr5; delete arr6;
}






function find_faktor_durchsatz_from_option(value) { # fdurchsatz:1.0
   fdurchsatz = ""
   split(value, arr_value, ";")
   for (c=1; c<=length(arr_value); c++) {
      split(arr_value[c], arr_tmp1, ":")
      if (arr_tmp1[1] == "fdurchsatz") {
         fdurchsatz = arr_tmp1[2]
         break
      }
   }

   delete arr_value; delete arr_tmp1;
   return fdurchsatz
}

function find_viscosity_from_option(value) {    # viscosity:12000;
   viscosity = ""
   split(value, arr_value, ";")
   for (c=1; c<=length(arr_value); c++) {
      split(arr_value[c], arr_tmp1, ":")
      if (arr_tmp1[1] == "viscosity") {
         viscosity = arr_tmp1[2]
         break
      }
   }

   delete arr_value; delete arr_tmp1;
   return viscosity
}





function print_arr_visc_flowrate_as_table_1() {
# Flow rates (read from =flowrate.txt=) $1 = viscosity, etc. $5 = serface, cm2, $6 = Drahtbreite, mm
# arr_flowrate[1]: 1:E114521102:AF6016:30-100;50-140;80-220;100-250;130-270;160-300;200-400:862:0.5
# arr_flowrate[2]: 1000:E114521102:AF6016:30-50;50-70;80-110;100-125;130-134;160-150;200-200:862:0.5
# arr_flowrate[3]: 10000:E114521102:AF6016:50-35;80-55;100-63;130-70;160-75;200-100:862:0.5
# arr_flowrate[4]: 50000:E114521102:AF6016:80-27;100-33;130-37;160-40;200-50:862:0.5

print "<BR><u>Table. Flowrate (LPM) vs. filter fineness</u>" >> result_txt

split(arr_flowrate[1], arr_tmp1, ":")                      # take 1st the line with most wide range
max_range = arr_tmp1[4]                                    # 30-100;50-140;80-220;100-250;130-270;160-300;200-400
length_of_max_range = split(max_range, arr_max_range, ";") # кол-во столбцов в таблице

print "<table class=\"table table-striped\">" >> result_txt
print "<thead><tr>"  >> result_txt

# print Table header
print "<th scope=\"col\">Viscosity, cSt</th>"  >> result_txt
print "<th scope=\"col\">Element</th>" >> result_txt
for (n=1; n<=length_of_max_range; n++) {
   split(arr_max_range[n], arr_range1_tmp, "-")                           # 30-100
   print "<th scope=\"col\">"arr_range1_tmp[1] "µm</th>"  >> result_txt   # 30
}

print "</th>"          >> result_txt
print "</tr></thead>"  >> result_txt

# конец заголовка начало тела
print "<tbody>" >> result_txt

# вывод таблицы

found = 0
for (k=1; k<=length(arr_flowrate); k++) {
   split(arr_flowrate[k], arr_tmp1, ":")
   viscosity_k = arr_tmp1[1]
   element_k = arr_tmp1[3]
   range_k = arr_tmp1[4]
   length_of_range_k = split(range_k, arr_range_k, ";")

   print "<tr>" >> result_txt
   print "<td>"viscosity_k"</td>" >> result_txt
   print "<td>"element_k"</td>" >> result_txt

   for (n=1; n<=length(arr_max_range); n++) {
      split(arr_max_range[n], arr_max_range_tmp, "-")            # 30-100
      fineness_tmp   = arr_max_range_tmp[1]

      for (m=1; m<=length(arr_range_k); m++) {
         split(arr_range_k[m], arr_range_tmp_k, "-")            # 80-120
         fineness_tmp_k = arr_range_tmp_k[1]

         if (fineness_tmp == fineness_tmp_k) {
             print "<td>"arr_range_tmp_k[2]"</td>"  >> result_txt
             found = 1
             break
         }
      }
      if (found == 0)
         print "<td>--</td>"  >> result_txt

      found = 0
   }

   print "</tr>" >> result_txt
   # конец строки таблицы
}

  approximate_arr_visc_flowrate_from_2_to_1_records()
  # и еще раз повторяем другим цветом

  # last line in RED COLOR
  split(arr_visc_flowrate[1], arr_tmp2, ":")
  viscosity2 = arr_tmp2[1]
  element2 = arr_tmp2[3]
  range_red = arr_tmp2[4]
  split(range_red, arr_range_red, ";")

  print "<tr>" >> result_txt
  print "<td><b><p class=\"text-danger\">"viscosity2"</p></td></b>" >> result_txt
  print "<td><b><p class=\"text-danger\">"element2"</p></td></b>" >> result_txt

  found = 0
   for (n=1; n<=length(arr_max_range); n++) {
      split(arr_max_range[n], arr_max_range_tmp, "-")            # 30-100
      fineness_tmp   = arr_max_range_tmp[1]

      for (m=1; m<=length(arr_range_red); m++) {
         split(arr_range_red[m], arr_range_tmp_red, "-")            # 80-120
         fineness_tmp_red = arr_range_tmp_red[1]

         if (fineness_tmp == fineness_tmp_red) {
             print "<td><b><p class=\"text-danger\">"arr_range_tmp_red[2]"</p></td></b>"  >> result_txt
             found = 1
             break
         }
      }
      if (found == 0)
         print "<td><b><p class=\"text-danger\">--</p></td></b>"  >> result_txt

      found = 0
   }
  print "</tr>" >> result_txt



print "</tbody></table>" >> result_txt

} # END OF FUNC



function  print_arr_suitable_elements_as_table() {
   print "<BR><u>Suitable filter elements</u>" >> result_txt
   print "<table class=\"table table-striped\">" >> result_txt
   print "<thead><tr>"  >> result_txt

   # print Table header
   print "<th scope=\"col\">Element</th>"  >> result_txt
   print "<th scope=\"col\">Feinheit, µm</th>" >> result_txt
   print "<th scope=\"col\">LP, EUR</th>" >> result_txt
   print "<th scope=\"col\">Gesamt Fl., cm2</th>" >> result_txt
   print "<th scope=\"col\">Drahtbreite, mm</th>" >> result_txt
   print "<th scope=\"col\">Offene F.Fläche, cm2</th>" >> result_txt
   print "<th scope=\"col\">Durchsatz/El., LPM</th>" >> result_txt
   print "<th scope=\"col\">Elementzahl</th>" >> result_txt
   print "</tr></thead>"  >> result_txt

   # конец заголовка начало тела
   print "<tbody>" >> result_txt
   for (k=1; k<=length(arr_suitable_elements); k++) {
      print "<tr>"  >> result_txt

      split(arr_suitable_elements[k], arr_k1, "_!_")
      split(arr_k1[1], arr_k2, "-")
      element_k = arr_k2[1]
      fineness_k = arr_k2[4]
      price_k = arr_k2[3]
      total_flaeche_k = arr_k2[5]
      drahtbreite_k = arr_k2[6]
      offene_flaeche_k = arr_k2[7]
      split(arr_k1[2], arr_k3, "=")
      durchsatz_k = arr_k3[2]
      no_of_el_k = arr_k1[3]
      print "<td>"element_k"</td>"  >> result_txt
      print "<td>"fineness_k"</td>"  >> result_txt
      print "<td>"price_k"</td>"  >> result_txt
      print "<td>"total_flaeche_k"</td>"  >> result_txt
      print "<td>"drahtbreite_k"</td>"  >> result_txt
      print "<td>"offene_flaeche_k"</td>"  >> result_txt
      print "<td>"durchsatz_k"</td>"  >> result_txt
      print "<td>"no_of_el_k"</td>"  >> result_txt
      print "<td>""</td>"  >> result_txt

      print "</tr>"  >> result_txt
   }
   print "</tbody></table><p>.</p>" >> result_txt
   delete arr_k1; delete arr_k2; delete arr_k3;
}
