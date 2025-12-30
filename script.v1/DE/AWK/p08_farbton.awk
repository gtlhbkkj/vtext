# "AF173_G3,AF173/G3,3,13,2,1,5,0,2,0,0,3001,4406,AK,A13,KII,AF6016-010"
# A:_!_7037_!_Staubgrau
# B:_!_5010_!_Enzianblau
# C:_!_6011_!_Resedagrün

BEGIN {
  RS = "\n"
  FS = "_!_"
  found = 0
  n = split(my_string, arr1, ",")

  filter_series_search = arr1[1]
  ft                   = arr1[14]
  material             = arr1[6]
  ke300x               = arr1[12]

  farbton     = "6018 Gelbgrün"
  ke300x_text = ""

  if (ke300x ~ /^[3][0][0]/)
    ke300x_text = " Deckel"

  if (ft == "")
     found = 1
}


# начинается проход по файлу данных
{
if (ft != "" && found == 0) 
  if ($1 == (ft ":")) {
     found = 1
     farbton = $2 " " $3
  }
}

END {
  if (found == 0) {  
     print mt >> "result.txt"
     print mt "#### Außenanstrich: Rostschutzfarbe WITH CODE [" ft "] NOT FOUND IN DB"  >> "result.txt"
     print mt "Err.code 0706 - Außenanstrich: Rostschutzfarbe WITH CODE [" ft "] NOT FOUND IN DB" >> "errlog.txt"
  }

  if (ft != "" || (ft == "" && material != 2)) {
     print "\n" mt                                                     >> "result.txt"
     print mt "Außenanstrich" ke300x_text ": Rostschutzfarbe RAL " farbton  >> "result.txt"
  }

  RS = "\n"
  FS = "[[:space:]]+"
}
