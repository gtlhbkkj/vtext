# "AF173_G3,AF173/G3,3,13,2,1,5,0,2,0,0,3001,4406,AK,A13,KII,AF6016-010"
# ::
# P2 –Regeldrossel für AF 11 Fremddruck-Ventil für AF 13,15 u.17 /// P3 –Regeldrossel für AF 11 u. 17
#--------- -.1.../-----------
#::
#AF122_G1_!_1_
#P2-Regeldrossel


BEGIN {
  RS = "\n::"
  FS = "\n"
  found = 0
  n = split(my_string, arr1, ",")

  filter_series_search = arr1[1]
  nr7                  = arr1[8]
#  if (nr7 != 0)
#    print "\n" mt "mit: " >> "result.txt"
}


# начинается проход по файлу данных
{
if (found == 0 && nr7 != 0) {
  if ($2 ~ filter_series_search) {
     split($2, arr_f, "_!_")
     if (arr_f[2] ~ nr7) {
        found = 1
        print mt "\n" mt "mit:" $3 >> "result.txt"
     }
  }
} 
}

END {
  if (nr7 != 0 && found == 0) {  # В конце, если found все еще 0
    err_msg = "NO DATA FOUND IN <p07_lastgr_2.txt> FOR : [" arr1[2] "], [-." nr7 "...-]"
    print_values(arr1[2],nr7)
  }
  RS = "\n"
  FS = "[[:space:]]+"
}


func print_values(fsr,nr7) {
  print mt                                                 >> "result.txt"
  print mt "#############################################" >> "result.txt"
  print mt "### " err_msg                                  >> "result.txt"
  print mt "### filter_series : [" fsr "]"                 >> "result.txt"
  print mt "### third group   : [-." nr7 "...-]""]"        >> "result.txt"
  print mt "#############################################" >> "result.txt"

  print mt "Err.code 0702 - " err_msg                      >> "errlog.txt"
}

