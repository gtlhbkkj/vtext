BEGIN {

#отделяем цену чтобы не нарушать остальную логику
split(filter_name, arr_tmp, "PRICE:")
filter_name = arr_tmp[1]
filter_list_price = arr_tmp[2]


# FILTER SERIES
split(filter_name,parts,"/")
p1 = substr(parts[1],1,5)
split(parts[2],arr_end," ")
filter_series_search = p1 "_" arr_end[1]
filter_series_report = p1 "/" arr_end[1]
#print "Filter ser :" filter_series_search >> TMP_DIR "/" UUID ".result.txt"
#print "Filter rep :" filter_series_report >> TMP_DIR "/" UUID ".result.txt"

# фильтроэлемент
split(filter_name,parts," ")
filter_element = parts[length(parts)]
temp_element = filter_element
gsub(/[a-zA-Z]/,"",temp_element)
split(temp_element,parts,"-")
filter_element_fineness = parts[2]*10
#print "ELement    :" filter_element >> TMP_DIR "/" UUID ".result.txt"
#print "Filter ser :" filter_element_fineness >> TMP_DIR "/" UUID ".result.txt"

#print "\nпоиск мотора"
split(filter_name,arr_fn_minus,"-")
split(arr_fn_minus[1], arr1, "")            # разделяем на символы в массив
filter_drive =  arr1[length(arr1)]
#print "Motor      :" filter_drive  >> TMP_DIR "/" UUID ".result.txt"

#============= вторая группа =============
#print "\nпоиск размеров портов"
filter_ports =  substr(arr_fn_minus[2], 1, length(arr_fn_minus[2])-2)
#print "Port size n:" filter_ports  >> TMP_DIR "/" UUID ".result.txt"

# Pressure stage"
filter_pn = substr(arr_fn_minus[2], length(arr_fn_minus[2])-1, 1)
#print "Filter PN  :" filter_pn  >> TMP_DIR "/" UUID ".result.txt"

#материала фильтра"
filter_material = substr(arr_fn_minus[2], length(arr_fn_minus[2]), 1)
#print "material   :" filter_material

#============= третья группа =============
#dP Manometer"
group3_1 = substr(arr_fn_minus[3], 1, 1)
#print "Filter dP measurement : " group3_1

#2 цифры в 3 группе"
group3_2 = substr(arr_fn_minus[3], 2, 1)
#print "2 цифра в 3 группе : " group3_2

#3 цифры в 3 группе - DRAIN VALVE"
group3_3 = substr(arr_fn_minus[3], 3, 1)
#print "3 цифра в 3 группе : " group3_3

#RS Valve"
group3_4 = substr(arr_fn_minus[3], 4, 1)
#print "4 цифра в 3 группе : " group3_4

#Bypass"
group3_5 = substr(arr_fn_minus[3], 5, 1)
#print "5 цифра в 3 группе : " group3_5

# Einsatz, Endnummer, Farbton
split(filter_name, arr_fn_slash, "/")

string_tmp = find_eef(arr_fn_slash) 
split(string_tmp, arr_tmp1, ",")
einsatz   = arr_tmp1[1]
endnummer = arr_tmp1[2]
paint     = arr_tmp1[3]


string_tmp = find_ak(arr_fn_slash) 
split(string_tmp, arr_tmp1, ",")
atex   = arr_tmp1[1]
kat    = arr_tmp1[2]

string = filter_series_search ","  \
   filter_series_report "," \
   filter_drive "," \
   filter_ports "," \
   filter_pn "," \
   filter_material "," \
   group3_1 "," \
   group3_2 "," \
   group3_3 "," \
   group3_4 "," \
   group3_5 "," \
   einsatz  "," \
   endnummer  "," \
   paint  "," \
   atex  "," \
   kat  "," \
   filter_element

# добавляем листовую цену
string = string "," filter_list_price

#print "from strart_processing : " string > "/home/vtext/app/script/DE/AWK/111.txt"



print string
# AF736_G3,AF73/G3,3,13,2,1,5,0,2,0,0,3002,4406,AK,A13,KIII,AF6016-010

}



###### FUNCTIONS #########

# EInsatz + Endnummer + Farbton
func find_eef(fn_slash) {
  no_of_groups = split(fn_slash[1], arr_tmp1, "-")

  einsatz   = arr_tmp1[4]
  paint     = substr(arr_tmp1[3],6,2) arr_tmp1[4] arr_tmp1[5]
  endnummer = arr_tmp1[5]

  gsub(/[a-zA-Z]/, "", einsatz)
  gsub(/[a-zA-Z]/, "", endnummer)
  gsub(/[0-9]/, "", paint)

  if (einsatz != "3001" && einsatz != "3002") {
    endnummer = einsatz
    einsatz = ""
  }
  return string = einsatz "," endnummer "," paint
}

# всё что после слеша A13 KII
func find_ak(fn_slash) {
  no_of_groups = split(fn_slash[2], arr_tmp1, " ")
  atex = ""
  kat  = ""

  if (no_of_groups == 3) {
    kat = arr_tmp1[2]
    if (arr_tmp1[2] ~ /^[A]/) {
        atex = arr_tmp1[2]
        kat = ""
    }
  }

  if (no_of_groups == 4) {
    atex = arr_tmp1[2]
    kat = arr_tmp1[3]
    if (arr_tmp1[3] ~ /^[A]/) {
      atex = arr_tmp1[3]
      kat = arr_tmp1[2]
    }
  }

  return string = atex "," kat
}

