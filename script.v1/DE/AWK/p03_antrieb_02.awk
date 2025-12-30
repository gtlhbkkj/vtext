# Part 2 - ANTRIEB
#
# Filterantrieb:
# "AF173_G3,AF173/G3,3,13,2,1,5,0,2,0,0,3001,4406,AK,A13,KII,AF6016-010"

BEGIN {
  RS = "\n::"
  FS = "\n"

  found = 0
  n = split(my_string, arr1, ",")
  search_filter_series = arr1[1]          # AF173_G3
  motor_code           = arr1[3]
  motor_number         = substr(motor_nr,1,8)
  ke300x               = arr1[12]


  # Kompletteinsatz -3001
  if (ke300x == "3001")
    found = 1

  if (motor_code == 1 || motor_code == 2)
    found = 1
}


{
  if (found == 0 && motor_nr != "not found" && $3 ~ motor_number) {
     found = 1
     for (i = 3; i <= NF; i++)
     print mt $i >> "result.txt"
  }
}

END {
  if (motor_nr != "not found")
    if (found == 0) {
       err_msg = "ANTRIEB CODE: [" motor_number "] NOT FOUND IN <p03_antrieb_02.txt>"
       print mt "####################################################" >> "result.txt"
       print mt "## " err_msg                                          >> "result.txt"
       print mt "####################################################" >> "result.txt"
       print mt "Err.code 0302 - " err_msg                             >> "errlog.txt" 
    }

  RS = "\n"
  FS = "[[:space:]]+"
}
