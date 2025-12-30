# Part 1 - ANTRIEB
#
# Filterantrieb:
# "AF173_G3,AF173/G3,3,13,2,1,5,0,2,0,0,3001,4406,AK,A13,KII,AF6016-010"
#
# .3._!_Standard Getriebemotor:
#AF711_G1,AF713_G1,AF713_GX1,AF713_GX2,AF42_S1,AF42_SH1_!_79745209:
#AF71_H2,AF72_G4,AF736_G3,AF112_G2,AF122_G1,AF132_G2,AF172_G2_!_79303983:

BEGIN {
  RS = "\n::"
  FS = "\n"

  found = 0
  n = split(my_string, arr1, ",")
  search_filter_series = arr1[1]          # AF173_G3
  motor_code           = ":" arr1[3] ":"            # приводим к виду <3>
  ke300x               = arr1[12]


  # нужно для идентификации пневматического мотора с Атексом и БЕЗ
  atex_code = "no_EX"
  if (arr1[15] != ""){
     atex_code = arr1[15]  }                # A13

  if (arr1[3] == 7)
     motor_code = motor_code atex_code

  # Kompletteinsatz -3001
  if (ke300x == "3001")
    found = 1

  print mt "\n" mt "Filterantrieb:"  >> "result.txt"
}


{
if (found == 0 && $2 ~ motor_code) {
    split($2, arr2, "_!_")
    print mt arr2[2] >> "result.txt"
    for (i = 2; i <= NF; i++) {
      if ($i ~ search_filter_series) {
        found = 1
        split($i, arr2, "_!_")

      }
   }
 }
}

END {
  # Kompletteinsatz -3001
  if (ke300x == "3001")
    print mt "OHNE Antrieb im Lieferumfang" >> "result.txt"

  if (found == 0) {  # В конце, если found все еще 0
    string = "not found"
    err_msg = "ANTRIEB CODE: [" arr1[3] "] FOR [" arr1[2] "] NOT FOUND IN <p03_antrieb_01.txt>"
    print mt "####################################################" >> "result.txt"
    print mt "## " err_msg                                          >> "result.txt"
    print mt "####################################################" >> "result.txt"
    print mt "Err.code 0301 - " err_msg                             >> "errlog.txt"
  } else {
    string =  arr2[2] 
  }
  print string

  RS = "\n"
  FS = "[[:space:]]+"
}


