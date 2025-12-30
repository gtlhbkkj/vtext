# Part 2 - Filterelement
#
# mit <Kantenspaltspule> - замена из тхт файла
# Type: AF 6016 - 010  <Spaltweite:> <100 µm>- замена из тхт файла
#
# mit <Segmentfilterelement> - замена из тхт файла
# Type: AF 100176-004 <Filterfeinheit:> <40 µm, nominelle Abscheiderate ca. 25 µm> - замена из тхт файла
#
# "AF173_G3,AF173/G3,3,13,2,1,5,0,2,0,0,3001,4406,AK,A13,KII,AF6016-010"

# AF6006_!_Lochblechelement
# Feinheit
# Filterelementart: Lochblechelement
# Differenzdruckstabil: bis 10 bar
# Gesamtfläche: 836 [cm2]
# Werkstoffe / Abmessungen: Tragkörper Edelstahl, Filtermedium Edelstahl/ ø110x265 mm
# Feinheit: _XXX_

BEGIN {
  RS = "\n::"
  FS = "\n"

  found = 0
  n = split(my_string, arr1, ",")

  filter_series_search = arr1[1]           # AF173_G3
  filter_element       = arr1[17]          # AF6016-010
  split(filter_element,arr1,"-")
  find_filter_element  = arr1[1]           # AF6016
  str_element =  find_felement(filter_series_search, filter_element, callnumber)
  textsp = ""
  if (arr1[2] ~ "SP") {
     textsp = " [verstärkte Ausführung mit Spirale]"
     find_filter_element = find_filter_element "SP"
     }
}

{
if (found == 0 && $2 ~ find_filter_element) {
    found = 1
    split($2,arr2,"_!_")

    # первый вызов для шапочки
    if (callnumber==1) {
      print mt "mit  " arr2[2]                                >> TMP_DIR "/" UUID ".result.txt"
      print mt "Typ: " filter_element "; " arr2[3] " " str_element >> TMP_DIR "/" UUID ".result.txt"
    }

    # второй вызов для серединки более полный текст
    if (callnumber==2) { 
       print mt "\n" mt "Filterelement:"       >> TMP_DIR "/" UUID ".result.txt" 
       print mt "Typ: " filter_element      >> TMP_DIR "/" UUID ".result.txt" 
       print mt arr2[3] ": " str_element textsp >> TMP_DIR "/" UUID ".result.txt" 
       for (i=3; i<=NF; i++)
         print mt $i                             >> TMP_DIR "/" UUID ".result.txt" 
       print_no_elements(filter_series_search) # Распечатка колва этажей
    }
  }
}

END {
  if (found == 0) {  # В конце, если found все еще 0
    err_msg = "NO DESCRIPTION FOUND FOR : [" filter_element "] IN <p02_element.txt>"
    print mt                                                        >> TMP_DIR "/" UUID ".result.txt"
    print mt "####################################################" >> TMP_DIR "/" UUID ".result.txt"
    print mt "## " err_msg                                          >> TMP_DIR "/" UUID ".result.txt"
    print mt "####################################################" >> TMP_DIR "/" UUID ".result.txt"
    print mt "Err.code 0201 - " err_msg                             >> TMP_DIR "/" UUID ".errlog.txt"
  }

  RS = "\n"
  FS = "[[:space:]]+"
}

# обработка фильтроэлемента
func find_felement(filter_series_search, filter_element, callnumber) {
  split(filter_element, arr_tmp1, "-")
  filter_element_part1 = arr_tmp1[1]
  filter_element_part2 = substr(arr_tmp1[2],1,3) # убираем SP
  fineness = filter_element_part2 * 10
  str_fineness = fineness " µm"

  if ("AF112_G2, AF132_G2, AF113_G3, AF122_G1, AF133_G3, AF172_G2, AF173_G3" ~ filter_series_search) {

    arr2[200] = 125
    arr2[160] = 100
    arr2[130] = 75
    arr2[100] = 60
    arr2[80] = 45
    arr2[60] = 35
    arr2[40] = 25
    arr2[30] = 18
    arr2[20] = 12
    arr2[10] = 7

    if (fineness in arr2) 
      str_fineness = fineness " µm, nominelle Abscheiderate ca. " arr2[fineness] " µm"
    else {
      str_fineness = fineness " µm - WRONG FINENESS SPECIFICATION"
      if (callnumber == 1)
        print mt "Err.code 0202 - " fineness " µm - WRONG FINENESS SPECIFICATION" >> TMP_DIR "/" UUID ".errlog.txt"
    }
  }

return str_fineness
}

func print_no_elements(filter_series_search) {
  arr1[1]= "AF737_!_2,1,2"
  arr1[2]= "AF738_!_3,1,3"
  arr1[3]= "AF746_!_3,1,3"
  arr1[4]= "AF747_!_3,2,6"
  arr1[5]= "AF748_!_3,3,9"
  arr1[6]= "AF749_!_3,4,12"
  for (i=1; i<=6; i++) {
    if (arr1[i] ~ substr(filter_series_search,1,5)) {
     split(arr1[i],arr2,"_!_")
     split(arr2[2],arr3,",")
     print mt "Anzahl der Etagen  : " arr3[1] >> TMP_DIR "/" UUID ".result.txt"
     print mt "Elemente pro Etage : " arr3[2] >> TMP_DIR "/" UUID ".result.txt"
     print mt "Gesamtelementenzahl: " arr3[3] >> TMP_DIR "/" UUID ".result.txt"
    }
  }
}
