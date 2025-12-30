# "AF173_G3,AF173/G3,3,13,2,1,5,0,2,0,0,3001,4406,AK,A13,KII,AF6016-010"
# 
# KATEGORIE TEXT
# ::
# _""_ OHNE KAT
# Filterbehälter ausgelegt für ungefährliche Flüssigkeiten (Gruppe 2) 
# im Sinne der Druckgeräterichtlinie DGRL 2014/68/EU

BEGIN {
  RS = "\n::"
  FS = "\n"

  found = 0
  n = split(my_string, arr1, ",")

  filter_series_search = arr1[1]
  kat                  = "_" arr1[16] "_"
  ke300x               = arr1[12]

  if (ke300x ~ /^[3][0][0]/)     # Kompletteinsat 300x
   found = 1
}


# начинается проход по файлу данных
{
  if (found == 0 && $2 ~ kat) {
    found = 1
    print "\n"  mt                                                 >> "result.txt"
    for (i=3; i<=NF; i++)
       print mt $i                                                  >> "result.txt"
   }
}

END {
  if (found == 0)
    print mt "\n" mt "Err.code 0707 - CHECK KATEGORIE CODE "              >> "errlog.txt"
  RS = "\n"
  FS = "[[:space:]]+"
}
